variable "AWS_REGION" {
  default = "us-east-1"
}

variable "url_pedido_service" {
  type    = string
  default = "load-balancer-pedido-1114194348.us-east-1.elb.amazonaws.com"
}

variable "stage_prod" {
  default = "prod"
  type    = string
}

######### OBS: a execution role acima foi trocada por LabRole devido a restricoes de permissao na conta da AWS Academy ########
variable "execution_role_ecs" {
  type    = string
  default = "arn:aws:iam::730335661438:role/LabRole" #aws_iam_role.ecsTaskExecutionRole.arn
}