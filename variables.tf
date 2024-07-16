#============================================================================#
# AWS CodePipeline - Variables
#============================================================================#
variable "project_name" {
  description = "The name of the project"
  type        = string
}

#============================================================================#
# CodeStar - Variables
#============================================================================#
variable "codestar_connection_name" {
    description = "Name of the code star connection"
    type        = string
}

#============================================================================#
# AWS CodePipeline (Source Stage) - Variables
#============================================================================#
variable "full_repo_id" {
  description = "The ID of the GitHub Repo being used for the AWS codepipeline"
  type        = string
}

variable "branch_name" {
  description = "The name of the branch that is being used for the AWS codepipeline"
  type        = string
}

#============================================================================#
# AWS CodePipeline (Deploy Stage) - Variables
#============================================================================#
variable "cluster_name" {
  description = "Name of the ECS cluster that the codepipeline deploys too"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service that the codepipeline deploys too and uses"
  type        = string
}

variable "file_name" {
  description = "Name of the file that the ECS uploads (imagedefinitions file)"
  type        = string
}

#============================================================================#
# CodeBuild Config - Variables
#============================================================================#
variable "compute_type" {
  description = "Compute type used in the codebuild configuration"
  type        = string
}

variable "codebuild_image" {
  description = "The chosen image for the codebuild configuration"
  type        = string
}

variable "build_type" {
  description = "The type of build environment used for codebuild"
  type        = string
}

variable "image_pull_credentials_type" {
  description = "The type of credentials AWS codebuild uses to pull images in your build"
  type        = string
}

variable "buildspec_loc" {
  description = "The location/file path of the buildspec file being used for the code pipeline"
  type        = string
}


#============================================================================#
# Codepipeline S3 - Variables
#============================================================================#

variable "pipeline_artifact_s3" {
  description = "The name of the S3 bucket used in the code pipeline for the artifacts"
  type        = string
}

variable "pipeline_report_s3" {
  description = "The name of the S3 bucket used in the code pipeline for the test reports"
  type        = string
}