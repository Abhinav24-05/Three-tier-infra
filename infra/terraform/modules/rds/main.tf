resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnet"
  subnet_ids = var.private_subnets
}

resource "aws_db_instance" "this" {
  identifier = "${var.name}-db"
  engine = "postgres"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  username = var.db_username
  password = var.db_password # replace with secrets/SSM in real deployments
  db_subnet_group_name = aws_db_subnet_group.this.name
  skip_final_snapshot = true
}

output "db_endpoint" { value = aws_db_instance.this.address }

output "db_identifier" { value = aws_db_instance.this.id }
