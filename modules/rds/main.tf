resource "random_password" "master" {
  length  = 32
  special = true
  # Avoid URL/Shell pain in DATABASE_URL
  override_special = "!#$%&*()-_=+[]{}"
}

resource "aws_db_subnet_group" "this" {
  name       = "qrify-rds"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name      = "qrify-rds"
    Project   = "QRify"
    ManagedBy = "Terraform"
  }
}

resource "aws_security_group" "rds" {
  name        = "qrify-rds"
  description = "Postgres only from EKS nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name      = "qrify-rds"
    Project   = "QRify"
    ManagedBy = "Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_eks" {
  security_group_id            = aws_security_group.rds.id
  description                  = "Postgres from EKS cluster/node SG"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = var.eks_node_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "rds_all" {
  security_group_id = aws_security_group.rds.id
  description       = "Allow outbound (RDS needs it for maintenance/monitoring)"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_db_instance" "this" {
  identifier     = "qrify-postgres"
  engine         = "postgres"
  engine_version = "16"

  instance_class        = var.instance_class
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.master.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = 1
  deletion_protection     = false
  skip_final_snapshot     = true
  apply_immediately       = true

  tags = {
    Name      = "qrify-postgres"
    Project   = "QRify"
    ManagedBy = "Terraform"
  }
}

locals {
  # One Postgres *database* per env on the shared instance (isolation without 2x RDS cost).
  # Initial aws_db_instance.db_name ("qrify") is only for admin/bootstrap connections;
  # app DBs qrify_dev / qrify_prod are created by kubernetes_job.rds_create_databases (private VPC).
  app_databases = {
    for env in var.environments : env => "qrify_${env}"
  }

  # urlencode password so special chars are safe in DATABASE_URL
  database_urls = {
    for env, db_name in local.app_databases :
    env => format(
      "postgresql://%s:%s@%s:%d/%s",
      var.db_username,
      urlencode(random_password.master.result),
      aws_db_instance.this.address,
      aws_db_instance.this.port,
      db_name,
    )
  }
}

resource "aws_secretsmanager_secret" "database_url" {
  for_each = toset(var.environments)

  name        = "${var.secret_prefix}/${each.key}/${var.secret_name}"
  description = "QRify ${each.key} API DATABASE_URL (RDS db qrify_${each.key})"

  tags = {
    Project     = "QRify"
    ManagedBy   = "Terraform"
    Environment = each.key
    SecretName  = var.secret_name
  }
}

resource "aws_secretsmanager_secret_version" "database_url" {
  for_each = toset(var.environments)

  secret_id = aws_secretsmanager_secret.database_url[each.key].id
  secret_string = jsonencode({
    DATABASE_URL = local.database_urls[each.key]
  })
}
