
resource "aws_db_subnet_group" "default" {
  name        = "${var.env_name}-rds-subnet-group"
  description = "My DB subnet group keep only public subnet if you want internet"
  subnet_ids  = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id] #TOBE here you must provide private subnet only
  tags        = local.tags
}
resource "aws_db_instance" "postgres_instance" {
  network_type           = "IPV4"
  identifier             = var.env_name
  engine                 = "postgres"
  engine_version         = "14.9"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  publicly_accessible    = true #TOBE you must set it as false
  multi_az               = false
  availability_zone      = data.aws_availability_zones.available.names[0]
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.sg_rds.id]
  parameter_group_name   = "default.postgres14"
  skip_final_snapshot    = true
  # maintenance_window                  = "Mon:00:00-Mon:03:00"
  # backup_window                       = "03:00-06:00"
  # apply_immediately                   = true
  iam_database_authentication_enabled = false
  username                            = var.DBA_ADMIN_USER
  password                            = var.DBA_ADMIN_PASSWORD
  tags                                = local.tags
}

output "database_host" {
  value = aws_db_instance.postgres_instance.address
}

resource "null_resource" "vcheck_db_creation" {
  depends_on = [aws_db_instance.postgres_instance]

  provisioner "local-exec" {
    environment = {
      "PGPASSWORD"  = var.DBA_ADMIN_PASSWORD,
      "ADMIN_USER"  = var.DBA_ADMIN_USER,
      "DB_NAME"     = var.DB_NAME
      "DB_USER"     = var.DB_USER,
      "DB_PASSWORD" = var.DB_PASSWORD,
      "DB_HOST"     = aws_db_instance.postgres_instance.address
    }

    command = "powershell.exe -File db_creation.ps1"
  }
}

