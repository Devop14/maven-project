resource "aws_cloudwatch_log_group" "application" {
  name              = "/applications/${var.name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.name}/cluster"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}
resource "aws_sns_topic" "alerts" {
  name = "${var.name}-alerts"
  tags = var.tags
}
