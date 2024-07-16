#============================================================================#
# AWS CodePipeline - Variable Values
#============================================================================#

project_name                = "Python_CICD"

codestar_connection_name    = "GitHub_Connection"

full_repo_id                = "PaddyMcbreen/Python_CICD"
branch_name                 = "main"

cluster_name                = "Python_Cluster"
service_name                = "Python_ECS_Service"
file_name                   = "imagedefinitions.json"

compute_type                = "BUILD_GENERAL1_SMALL"
codebuild_image             = "aws/codebuild/amazonlinux2-aarch64-standard:2.0" 
build_type                  = "ARM_CONTAINER" 
image_pull_credentials_type = "CODEBUILD" 
buildspec_loc               = "docker/buildspec"

pipeline_artifact_s3        = "codepipelines-artifacts-store"
pipeline_report_s3          = "codepipelines-test-reports-store"