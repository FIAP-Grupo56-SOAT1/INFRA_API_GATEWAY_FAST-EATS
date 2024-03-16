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


# Criando um modulo que utiliza os dados do infra para criação do ambiente
module "prod" {
  source                = "../../"
  url_pagamento_service = jsondecode(data.aws_secretsmanager_secret_version.credentials_pedido.secret_string)["url_pagamento_service"]
  url_cozinha_service   = jsondecode(data.aws_secretsmanager_secret_version.credentials_pedido.secret_string)["url_cozinha_service"]
  url_pedido_service    = jsondecode(data.aws_secretsmanager_secret_version.credentials_producao.secret_string)["url_pedido_service"]
  lambda_sts_arn        = jsondecode(data.aws_secretsmanager_secret_version.credentials_sts.secret_string)["lambda_sts_arn"]
  lambda_authorizer_arn = jsondecode(data.aws_secretsmanager_secret_version.credentials_sts.secret_string)["lambda_authorizer_arn"]
}


#obteando dados do secret manager
data "aws_secretsmanager_secret" "secrets_pedido" {
  name = "prod/soat1grupo56/Pedido"
}

data "aws_secretsmanager_secret_version" "credentials_pedido" {
  secret_id = data.aws_secretsmanager_secret.secrets_pedido.id
}

#obteando dados do secret manager
data "aws_secretsmanager_secret" "secrets_pagamento" {
  name = "prod/soat1grupo56/Pagamento"
}

data "aws_secretsmanager_secret_version" "credentials_pagamento" {
  secret_id = data.aws_secretsmanager_secret.secrets_pagamento.id
}

#obteando dados do secret manager
data "aws_secretsmanager_secret" "secrets_producao" {
  name = "prod/soat1grupo56/Producao"
}

data "aws_secretsmanager_secret_version" "credentials_producao" {
  secret_id = data.aws_secretsmanager_secret.secrets_producao.id
}


#obteando dados do secret manager
data "aws_secretsmanager_secret" "secrets_sts" {
  name = "prod/soat1grupo56/Sts"
}

data "aws_secretsmanager_secret_version" "credentials_sts" {
  secret_id = data.aws_secretsmanager_secret.secrets_sts.id
}