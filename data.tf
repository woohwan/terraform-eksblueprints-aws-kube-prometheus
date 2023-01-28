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
      "${aws_s3_bucket.thanos.arn}",
      "${aws_s3_bucket.thanos.arn}/*"
    ]
  }
}
