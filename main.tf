#============================================================================#
# Connect to AWS
#============================================================================#
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#============================================================================#
# AWS CodePipeline
#============================================================================#

// Code Star Connection for CodeBuild -> GitHub
resource "aws_codestarconnections_connection" "CodeStar_Connection" {
  name          = var.codestar_connection_name
  provider_type = "GitHub"
}

// Code Pipeline
resource "aws_codepipeline" "codepipeline" { 
  name     = "${var.project_name}-Codepipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipelines_artifacts_bucket.bucket
    type     = "S3"
  }


  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]


      configuration = {
        ConnectionArn = aws_codestarconnections_connection.CodeStar_Connection.arn

        FullRepositoryId  = var.full_repo_id
        BranchName        = var.branch_name
      }
    }
  }


  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_project.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["BuildArtifact"]
      version         = "1"

      configuration = {
        ClusterName = var.cluster_name
        ServiceName = var.service_name
        FileName    = var.file_name
      }
    }
  }
}

#============================================================================#
# CodeBuild Config - CodePipeline
#============================================================================#

# CodeBuild for docker
resource "aws_codebuild_project" "codebuild_project" {
  name         = "${var.project_name}-Codebuild"
  service_role = aws_iam_role.codebuild_role.arn

  environment {
    compute_type                = var.compute_type
    image                       = var.codebuild_image

    type                        = var.build_type

    privileged_mode             = true
    image_pull_credentials_type = var.image_pull_credentials_type

    environment_variable {
      name  = "DOCKER_USERNAME"
      value = "DOCKER_USERNAME"
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "DOCKER_PASSWORD"
      value = "DOCKER_PASSWORD"
      type  = "PARAMETER_STORE"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_loc
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  artifacts {
    type = "CODEPIPELINE"
  }
}

#============================================================================#
# CodePipeline - S3 Artifact Buckets
#============================================================================#

# S3 Bucket for CodePipeline build artifacts (both pipelines)
resource "aws_s3_bucket" "codepipelines_artifacts_bucket" {
  bucket = var.pipeline_artifact_s3
}

resource "aws_s3_bucket_versioning" "artifact_version_bucket" {
  bucket = aws_s3_bucket.codepipelines_artifacts_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

#============================================================================#
# CodePipeline - S3 Test Reports Bucket
#============================================================================#

# S3 Bucket for CodePipeline test reports
resource "aws_s3_bucket" "codepipeline_test_reports_bucket" {
  bucket = var.pipeline_report_s3
}

#============================================================================#
# CodePipeline IAM Policys and Roles
#============================================================================#

# IAM Role for CodePipeline & Related Policys
resource "aws_iam_role" "codepipeline_role" {
  name = "${var.project_name}-Codepipeline_roles"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_role_policy" "cloudwatch_event_policy" {
  name        = "CloudWatchEventPolicy"
  role   = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = [
          "codepipeline:StartPipelineExecution"
        ],
        Resource  = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy" "amazon_ecs_policy" {
  name   = "AmazonECS"
  role   = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:*"
        ],
        Resource = [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_iam_pass_role_policy" {
  name   = "ECSIAMPassRole"
  role   = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "iam:PassRole"
        ],
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/bridge-production-ecs-execution-role",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/bridge-production-ecs-container-role",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecs_events_role",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsEventsRole"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "CodeBuild"
  role   = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:BatchGetProjects"
        ],
        Resource = "*"           
      }
    ]
  })
}

resource "aws_iam_role_policy" "aws_codestar_connections_policy" {
  name   = "AWSCodeStarconnections"
  role   = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "codestar-connections:CreateConnection",
          "codestar-connections:DeleteConnection",
          "codestar-connections:UseConnection",
          "codestar-connections:GetConnection",
          "codestar-connections:ListConnections",
          "codestar-connections:PassConnection"
        ],
        Resource = [
          "arn:aws:codestar-connections:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:connection/*"
        ]
      }
    ]
  })
}



# IAM Policy for CodePipeline
resource "aws_iam_policy" "codepipeline_policy" {
  name        = "${var.project_name}-Codepipeline_policy"
  path        = "/"
  description = "IAM policy for AWS CodePipeline"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Action" : [
          "iam:PassRole"
        ],
        "Resource" : "*",
        "Effect" : "Allow",
        "Condition" : {
          "StringEqualsIfExists" : {
            "iam:PassedToService" : [
              "ec2.amazonaws.com",
              "ecs-tasks.amazonaws.com"
              
            ]
          }
        }
      },
      {
        "Action" : [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        Action    = [
          "codepipeline:PutJobSuccessResult",
          "codepipeline:PutJobFailureResult"
        ],
        Resource  = "*",
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "codestar-connections:UseConnection"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "ec2:*",
          "s3:*",
          "ecs:*"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuildBatches",
          "codebuild:StartBuildBatch",
          "codebuild:BatchGetProjects"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:DescribeImages",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        "Resource" : "*"
      }
    ]
  })
}


# Attach policy to the role
resource "aws_iam_role_policy_attachment" "codepipeline_policy_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

// IAM Code Build Role & Related Policys
resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_name}-Codepipeline_cb_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_role_policy" "artifact_store_bucket_policy" {
  name   = "ArtifactStoreBucket"
  role   = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion",
          "s3:PutObjectAcl",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:DeleteBucket"
        ],
        Resource = [
          "${aws_s3_bucket.codepipelines_artifacts_bucket.arn}/*",
          "${aws_s3_bucket.codepipeline_test_reports_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecr_authentication_policy" {
  name   = "ECRAuthentication"
  role   = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ],
        Resource = [
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-ecr-repo",
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-test-ecr-backend",
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-test-ecr-backend-cron",
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-test-ecr-backend-worker",
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-test-ecr-nginx",
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecr_pull_policy" {
  name   = "ECRPull"
  role   = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:CompleteLayerUpload"
        ],
        Resource = [
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-ecr-repo",
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-test-ecr-backend",
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-test-ecr-backend-cron",
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-test-ecr-backend-worker",
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-test-ecr-nginx"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecr_push_policy" {
  name   = "ECRPush"
  role   = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:GetAuthorizationToken",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer"
        ],
        Resource = [
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-ecr-repo",
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-test-ecr-backend",
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-test-ecr-backend-cron",
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-test-ecr-backend-worker",
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-test-ecr-nginx"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "ssm_policy" {
  name   = "SMMPolicy"
  role   = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ssm:GetParameters"
        ],
        Resource = [
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-ecr-repo",
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-test-ecr-backend",
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-test-ecr-backend-cron",
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-test-ecr-backend-worker",
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bridge-test-ecr-nginx",
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudwatch_logs_policy" {
  name   = "CloudWatchLogs"
  role   = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "codebuild_logs_s3_policy" {
  name        = "${var.project_name}-Codepipeline_S3_policy"
  path        = "/"
  description = "IAM policy for AWS CodeBuild logs and S3 access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Resource = [
          "*"
        ],
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
      {
        Effect = "Allow",
        Resource = [
          "*"
        ],
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
          "s3:DeleteObject",
          "s3:DeleteBucket"
]
      },
      {
        Effect = "Allow",
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages",
          "codebuild:BatchGetProjects"
        ],
        Resource = [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attach_2" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_logs_s3_policy.arn
}