# Create per-env Postgres databases on the shared private RDS instance.
# Runs in-cluster (only EKS nodes can reach RDS). Idempotent CREATE DATABASE.
resource "kubernetes_job_v1" "rds_create_databases" {
  metadata {
    name      = "rds-create-app-databases"
    namespace = "kube-system"
    labels = {
      app       = "rds-init"
      managedby = "terraform"
    }
  }

  spec {
    ttl_seconds_after_finished = 600
    backoff_limit              = 4

    template {
      metadata {
        labels = {
          app = "rds-init"
        }
      }
      spec {
        restart_policy = "Never"

        container {
          name  = "psql"
          image = "public.ecr.aws/docker/library/postgres:16-alpine"

          command = ["/bin/sh", "-c"]
          args = [
            <<-EOT
            set -eu
            echo "Waiting for Postgres at $PGHOST..."
            until psql -h "$PGHOST" -U "$PGUSER" -d "$PGDATABASE" -c 'SELECT 1' >/dev/null 2>&1; do
              sleep 3
            done
            for db in qrify_dev qrify_prod; do
              exists="$(psql -h "$PGHOST" -U "$PGUSER" -d "$PGDATABASE" -tAc "SELECT 1 FROM pg_database WHERE datname='$${db}'")"
              if [ "$${exists}" = "1" ]; then
                echo "Database $${db} already exists"
              else
                echo "Creating database $${db}"
                psql -h "$PGHOST" -U "$PGUSER" -d "$PGDATABASE" -v ON_ERROR_STOP=1 -c "CREATE DATABASE $${db}"
              fi
            done
            echo "Done"
            EOT
          ]

          env {
            name  = "PGHOST"
            value = module.rds.db_instance_address
          }
          env {
            name  = "PGPORT"
            value = "5432"
          }
          env {
            name  = "PGUSER"
            value = module.rds.master_username
          }
          env {
            name  = "PGPASSWORD"
            value = module.rds.master_password
          }
          env {
            name  = "PGDATABASE"
            value = module.rds.db_name
          }
        }
      }
    }
  }

  wait_for_completion = true

  timeouts {
    create = "10m"
  }

  depends_on = [module.rds, module.eks]
}
