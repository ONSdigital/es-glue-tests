resource "aws_s3_bucket" "glue-bucket" {
    bucket = "results-glue-tests-bucket"

    tags = merge(
        var.common_tags,
        {"ons:name" = "glue-tests-bucket"}
    )
}

resource "aws_s3_bucket_object" "glue-python-deps" {
    bucket = aws_s3_bucket.glue-bucket.id
    source = "pipeline_deps-0.1-py3-none-any.whl"
    key = "pipeline_deps-0.1-py3-none-any.whl"

    etag = filemd5("./pipeline_deps-0.1-py3-none-any.whl")

    tags = merge(
        var.common_tags,
        {}
    )
}

resource "aws_s3_bucket_object" "glue-python-script" {
    bucket = aws_s3_bucket.glue-bucket.id
    source = "./test_step.py"
    key = "test_step.py"

    etag = filemd5("./test_step.py")

    tags = merge(
        var.common_tags,
        {}
    )
}
resource "aws_iam_role" "glue-role" {
    name = "results-glue-test-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "glue-role-policy" {
  name = "results_glue_test_policy"
  role = aws_iam_role.glue-role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "glue:*",
                "s3:GetBucketLocation",
                "s3:ListBucket",
                "s3:ListAllMyBuckets",
                "s3:GetBucketAcl",
                "ec2:DescribeVpcEndpoints",
                "ec2:DescribeRouteTables",
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface",				
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcAttribute",
                "iam:ListRolePolicies",
                "iam:GetRole",
                "iam:GetRolePolicy",
                "cloudwatch:PutMetricData"                
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket"
            ],
            "Resource": [
                "arn:aws:s3:::aws-glue-*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"				
            ],
            "Resource": [
                "arn:aws:s3:::results-glue-tests*/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::crawler-public*",
                "arn:aws:s3:::aws-glue-*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:AssociateKmsKey"                
            ],
            "Resource": [
                "arn:aws:logs:*:*:/aws-glue/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Condition": {
                "ForAllValues:StringEquals": {
                    "aws:TagKeys": [
                        "aws-glue-service-resource"
                    ]
                }
            },
            "Resource": [
                "arn:aws:ec2:*:*:network-interface/*",
                "arn:aws:ec2:*:*:security-group/*",
                "arn:aws:ec2:*:*:instance/*"
            ]
        }
    ]
}
EOF
}

resource "aws_glue_job" "glue-job" {
    name = "results-glue-test"
    role_arn = aws_iam_role.glue-role.arn
    command {
        name="pythonshell"
        script_location = "s3://${aws_s3_bucket.glue-bucket.id}/test_step.py"
        python_version = 3
    }

    default_arguments = {
        "--extra-py-files" = "s3://${aws_s3_bucket.glue-bucket.id}/pipeline_deps-0.1-py3-none-any.whl"
    }
}
