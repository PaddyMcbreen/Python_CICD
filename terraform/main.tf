#============================================================================#
# AWS CodePipeline - CodeStar Connection
#============================================================================#

resource "aws_codestarconnections_connection" "codestar_connection" {
  name          = "GitHub_Connect"
  provider_type = "GitHub"
}

#============================================================================#
# AWS CodePipeline - IaC
#============================================================================#

resource "aws_codepipeline" "codepipeline" {
  name     = "tf-test-pipeline"
}