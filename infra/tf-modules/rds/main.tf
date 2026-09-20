resource "aws_db_subnet_group" "this" {
  name       = var.name
  subnet_ids = var.subnet_ids
  tags       = var.tags
}
resource "aws_db_instance" "this" {
  identifier                = var.name
  engine                    = "mysql"
  engine_version            = "8.0"
  instance_class            = var.instance_class
  allocated_storage         = 100
  storage_type              = "gp3"
  storage_encrypted         = true
  multi_az                  = true
  db_name                   = var.database_name
  username                  = "appadmin"
  password                  = var.master_password
  port                      = 3306
  db_subnet_group_name      = aws_db_subnet_group.this.name
  vpc_security_group_ids    = var.security_group_ids
  backup_retention_period   = 7
  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.name}-final"
  tags                      = var.tags
}
