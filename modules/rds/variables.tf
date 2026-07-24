variable "vpc_id" {
  type        = string
  description = "VPC where RDS and EKS run"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnets for the DB subnet group (no public RDS)"
}

variable "eks_node_security_group_id" {
  type        = string
  description = "EKS cluster/node security group — only source allowed on 5432"
}

variable "db_name" {
  type        = string
  description = "Bootstrap/admin Postgres database on the instance (app DBs are qrify_<env>)"
  default     = "qrify"
}

variable "db_username" {
  type        = string
  description = "Master username"
  default     = "qrify"
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "secret_prefix" {
  type        = string
  description = "Secrets Manager prefix (qrify/<env>/<name>)"
  default     = "qrify"
}

variable "environments" {
  type        = list(string)
  description = "Envs that get their own Postgres database + DATABASE_URL secret"
  default     = ["dev", "prod"]
}

variable "secret_name" {
  type        = string
  description = "K8s / SM secret name (stable for ExternalSecret)"
  default     = "qrify-web-api-db"
}
