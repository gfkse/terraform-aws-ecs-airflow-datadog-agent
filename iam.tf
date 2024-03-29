resource "aws_iam_role" "datadog_task_execution_role" {
  name = "${var.resource_prefix}_datadog_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = var.tags
}


resource "aws_iam_role_policy_attachment" "aws_managed_ecs_task_execution_policy_attachment" {
  role       = aws_iam_role.datadog_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "datadog_task_execution_role_policy" {
  count = var.dd_api_encryption_kms_key_id == "" || var.dd_api_encryption_kms_key_id == null ? 1 : 0

  name        = "${var.resource_prefix}_datadog_task_execution_role_policy"
  path        = "/"
  description = "Ensures to have the needed execution permissions for datadog task."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ]
        Resource = [
          local.dd_api_key_param_arn
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "datadog_tasks_execution_role_policy_attachment" {
  count = var.dd_api_encryption_kms_key_id == "" || var.dd_api_encryption_kms_key_id == null ? 1 : 0

  role       = aws_iam_role.datadog_task_execution_role.name
  policy_arn = aws_iam_policy.datadog_task_execution_role_policy[0].arn
}


resource "aws_iam_policy" "datadog_task_execution_role_policy_with_kms_key" {
  count = var.dd_api_encryption_kms_key_id != "" && var.dd_api_encryption_kms_key_id != null ? 1 : 0

  name        = "${var.resource_prefix}_datadog_task_execution_role_policy_with_kms_key"
  path        = "/"
  description = "Ensures to have the needed execution permissions for datadog task."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ]
        Resource = [
          local.dd_api_key_param_arn,
          local.dd_api_enc_kms_key_arn
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "datadog_tasks_execution_role_policy_attachment_with_kms_key" {
  count = var.dd_api_encryption_kms_key_id != "" && var.dd_api_encryption_kms_key_id != null ? 1 : 0

  role       = aws_iam_role.datadog_task_execution_role.name
  policy_arn = aws_iam_policy.datadog_task_execution_role_policy_with_kms_key[0].arn
}