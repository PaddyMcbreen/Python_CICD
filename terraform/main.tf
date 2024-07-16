#============================================================================#
# AWS CodePipeline - CodeStar Connection
#============================================================================#

resource "aws_codestarconnections_connection" "codestar_connection" {
  name          = "GitHub_Connect"
  provider_type = "GitHub"
}
