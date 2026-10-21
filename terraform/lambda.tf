locals {
  routes = {
    create   = { route = "POST /links", auth = true }
    list     = { route = "GET /links", auth = true }
    delete   = { route = "DELETE /links/{code}", auth = true }
    redirect = { route = "GET /{code}", auth = false }
  }
  all_functions = toset(concat(keys(local.routes), ["migrate"]))
}

#Run scripts/build.sh first: it creates build/package.
data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../build/package"
  output_path = "${path.module}/../build/lambda.zip"
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

#One role per function so each gets only what it needs.
resource "aws_iam_role" "fn" {
  for_each           = local.all_functions
  name               = "${var.project}-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role_policy_attachment" "vpc_logs" {
  for_each   = local.all_functions
  role       = aws_iam_role.fn[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

#Only the API functions may connect to the DB as app_user (not migrate).
resource "aws_iam_role_policy" "db_connect" {
  for_each = toset(keys(local.routes))
  name     = "db-connect"
  role     = aws_iam_role.fn[each.key].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "rds-db:connect"
      Resource = "arn:aws:rds-db:${var.region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.main.resource_id}/${var.db_app_user}"
    }]
  })
}

resource "aws_cloudwatch_log_group" "fn" {
  for_each          = local.all_functions
  name              = "/aws/lambda/${var.project}-${each.key}"
  retention_in_days = 14
}

resource "aws_lambda_function" "fn" {
  for_each         = local.all_functions
  function_name    = "${var.project}-${each.key}"
  role             = aws_iam_role.fn[each.key].arn
  runtime          = "python3.12"
  architectures    = ["arm64"]
  handler          = "${each.key}.handler"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  memory_size      = 256
  timeout          = each.key == "migrate" ? 60 : 10

  environment {
    variables = merge(
      {
        DB_HOST = aws_db_instance.main.address
        DB_NAME = var.db_name
        DB_USER = var.db_app_user
      },
      each.key == "migrate" ? {
        DB_ADMIN_USER     = aws_db_instance.main.username
        DB_ADMIN_PASSWORD = random_password.db_admin.result
        DB_APP_USER       = var.db_app_user
      } : {}
    )
  }

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda.id]
  }

  depends_on = [aws_cloudwatch_log_group.fn, aws_iam_role_policy_attachment.vpc_logs]
}

#Runs the migration on every apply where migrate.py changed.
resource "aws_lambda_invocation" "migrate" {
  function_name = aws_lambda_function.fn["migrate"].function_name
  input         = jsonencode({ version = filesha256("${path.module}/../lambda/migrate.py") })
  depends_on    = [aws_db_instance.main]
}
