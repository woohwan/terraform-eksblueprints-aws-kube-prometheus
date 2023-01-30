data "aws_iam_policy_document" "thanos_sidecar" {
  statement {
    sid = "thanosSicdecarS3"
    effect = "Allow"
    actions = [
      "s3:ListBuckt",
      "s3:GetObject" ,
      "s3:PutObject",
      "s3:DeleteObject"
      ]
    resources = [
      "${local.s3_bucket_arn}",
      "${local.s3_bucket_arn}/*"
    ]
  }
}
