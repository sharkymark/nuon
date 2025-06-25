data "aws_iam_policy_document" "odr" {
  statement {
    effect    = "Allow"
    actions   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "lambda:InvokeFunction",
      "lambda:InvokeAsync",
      "apigateway:GET",
      "apigateway:POST",
      "apigateway:PUT",
      "apigateway:DELETE",
      "apigateway:PATCH"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "odr" {
  name   = "${local.prefix}-odr"
  policy = data.aws_iam_policy_document.odr.json
}

data "aws_iam_policy_document" "odr_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "apigateway.amazonaws.com"
      ]
    }
  }
}

module "odr_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = ">= 5.1.0"

  create_role       = true
  role_requires_mfa = false

  role_name                       = "odr-${local.prefix}"
  role_path = "/nuon/"

  create_custom_role_trust_policy = true
  custom_role_trust_policy        = data.aws_iam_policy_document.odr_trust.json
  custom_role_policy_arns         = [aws_iam_policy.odr.arn]
}
