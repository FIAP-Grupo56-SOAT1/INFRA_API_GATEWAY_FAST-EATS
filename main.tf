terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.23.1"
    }
  }

  backend "s3" {
    bucket = "bucket-fiap56-to-remote-state"
    key    = "aws-apigateway-fiap56/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_default_vpc" "default_vpc" {
}


# Provide references to your default subnets
resource "aws_default_subnet" "default_subnet_a" {
  # Use your own region here but reference to subnet 1a
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  # Use your own region here but reference to subnet 1b
  availability_zone = "us-east-1b"
}


resource "aws_api_gateway_rest_api" "apigateway" {
  name        = "fasteats"
  description = "API Gateway para projeto feasteats"
  body        = data.template_file.api_gateway.rendered

  endpoint_configuration {
    types = ["REGIONAL"]
  }

}

data "template_file" "api_gateway" {
  template = file("api-gateway-fasteats.yaml")

  vars = {
    lambda_authorizer_arn = var.lambda_authorizer_arn
    lambda_sts_arn        = var.lambda_sts_arn
    aws_region            = var.AWS_REGION
    nlbpedido             = var.url_pedido_service
  }

}


resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.apigateway.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.apigateway.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.apigateway.id
  depends_on    = [aws_cloudwatch_log_group.log_group]
  stage_name    = var.stage_prod
  #auto_deploy       = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.log_group.arn
    format          = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"

  }
}

resource "aws_lambda_permission" "apigw_sts" {
    statement_id  = "AllowAPIGatewayInvoke"
    action        = "lambda:InvokeFunction"
    function_name = var.lambda_sts_arn
    principal     = "apigateway.amazonaws.com"
    source_arn    = "${replace(aws_api_gateway_deployment.deployment.execution_arn, var.stage_prod, "")}*/*"
}

resource "aws_lambda_permission" "apigw_authorizer" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_authorizer_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${replace(aws_api_gateway_deployment.deployment.execution_arn, var.stage_prod, "")}*/*"
}



#resource "aws_api_gateway_method_settings" "all" {
#  rest_api_id = aws_api_gateway_rest_api.apigateway.id
#  stage_name  = aws_api_gateway_stage.stage.stage_name
#  method_path = "*/*"
##Off
#  settings {
#    logging_level = "OFF"
#  }
#  # Errors and Info Logs
#  #settings {
#  #  logging_level      = "INFO"
#  #  metrics_enabled    = true
#  #  data_trace_enabled = false
#  #}
##Full Request and Response Logs
# # settings {
# #   logging_level      = "INFO"
# #   metrics_enabled    = true
# #   data_trace_enabled = true
# # }
#}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/api-gateway/${aws_api_gateway_rest_api.apigateway.name}/${var.stage_prod}"
  retention_in_days = 1
}

#resource "aws_api_gateway_account" "gateway_account" {
#  cloudwatch_role_arn = var.execution_role_ecs
#}