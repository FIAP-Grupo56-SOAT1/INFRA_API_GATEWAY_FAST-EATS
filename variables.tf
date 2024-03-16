variable "AWS_REGION" {
  default = "us-east-1"
}

variable "url_pagamento_service" {
  type    = string
  default = "http://ecs-fasteats-api-pagamento-399390289.us-west-2.elb.amazonaws.com"
}

variable "url_cozinha_service" {
  type    = string
  default = "http://ecs-fasteats-api-cozinha-399390289.us-west-2.elb.amazonaws.com"
}

variable "url_pedido_service" {
  type    = string
  default = "http://ecs-fasteats-api-pedido-399390289.us-west-2.elb.amazonaws.com"
}

variable "stage_prod" {
  default = "prod"
  type    = string
}

variable "lambda_sts_arn" {
  default = "arn:aws:lambda:us-east-1:730335661438:function:lambda_sts"
  type    = string
}

variable "lambda_authorizer_arn" {
  default = "arn:aws:lambda:us-east-1:730335661438:function:lambda_authorizer"
  type    = string
}


######### OBS: a execution role acima foi trocada por LabRole devido a restricoes de permissao na conta da AWS Academy ########
variable "execution_role_ecs" {
  type    = string
  default = "arn:aws:iam::730335661438:role/LabRole" #aws_iam_role.ecsTaskExecutionRole.arn
}