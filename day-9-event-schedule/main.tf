provider "aws" {
  region = "us-west-2"
}

# 1️⃣ Create the Lambda function
# 1️⃣ Upload the local zip file to your S3 bucket
resource "aws_s3_object" "lambda_code" {
  bucket = "terraform-day-2-88ucket" # Your existing bucket name
  key    = "lambda_function.zip"     # The name it will have in S3
  source = "lambda_function.zip"     # The path to your local zip file

  # This ensures Terraform uploads a new version to S3 if you change your local code
  etag = filemd5("lambda_function.zip")
}

# 2️⃣ Create the Lambda function referencing the S3 object
resource "aws_lambda_function" "example" {
  function_name = "example-scheduled-lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 900
  memory_size   = 128

  # Point to the S3 bucket and key defined in the aws_s3_object above
  s3_bucket = aws_s3_object.lambda_code.bucket
  s3_key    = aws_s3_object.lambda_code.key

  # This forces Lambda to deploy the new code when the S3 object changes
  source_code_hash = filebase64sha256("lambda_function.zip")

  # Ensure the object is uploaded to S3 BEFORE the Lambda function tries to read it
  depends_on = [aws_s3_object.lambda_code]
}
# 2️⃣ IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# 3️⃣ Attach basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda_exec.name
  
  # Standard secure policy allowing Lambda to write logs to CloudWatch
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  
  # (If you absolutely must use admin access for testing, the correct ARN is: "arn:aws:iam::aws:policy/AdministratorAccess")
}





# 4️⃣ Create EventBridge rule (schedule)
resource "aws_cloudwatch_event_rule" "every_five_minutes" {
  name                = "every-five-minutes"
  description         = "Trigger Lambda every 5 minutes"
#   schedule_expression = "rate(5 minutes)"
  schedule_expression = "cron(0/5 * * * ? *)"

}

# 5️⃣ Add the Lambda target for schedule to invoke the Lambda function
resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule      = aws_cloudwatch_event_rule.every_five_minutes.name
  target_id = "lambda"
  arn       = aws_lambda_function.example.arn
}

# 6️⃣ Allow EventBridge to invoke the Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_five_minutes.arn
}