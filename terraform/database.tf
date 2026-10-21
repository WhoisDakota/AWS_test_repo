# The admin password is only used by the migrate Lambda. The app never uses it.
# NOTE: it lives in Terraform state, so protect the state (see README).
resource "random_password" "db_admin" {
  length  = 32
  special = false
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-db"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "main" {
  identifier                          = "${var.project}-db"
  engine                              = "postgres"
  engine_version                      = "16"
  instance_class                      = "db.t4g.micro"
  allocated_storage                   = 20
  storage_type                        = "gp3"
  storage_encrypted                   = true
  db_name                             = var.db_name
  username                            = "dbadmin"
  password                            = random_password.db_admin.result
  iam_database_authentication_enabled = true
  publicly_accessible                 = false
  db_subnet_group_name                = aws_db_subnet_group.main.name
  vpc_security_group_ids              = [aws_security_group.db.id]
  backup_retention_period             = 1
  skip_final_snapshot                 = true # learning project; remove for real data
  apply_immediately                   = true
}
