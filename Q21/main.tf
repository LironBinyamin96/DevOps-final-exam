provider "aws" {
  region = "var.region"
}

data "aws_vpc" "existing_vpc" {
  id = "var.my-vpc-id"  
}

data "aws_subnet" "existing_subnet" {
  id = "var.my-subnet-id"
}


data "aws_security_group" "existing_sg" {
  id = "var.my-sg-id"  
}

data "aws_key_pair" "existing_key" {
  key_name = "var.my-key-name" 
}

resource "aws_instance" "example" {
  ami           = "var.ami_id"  
  instance_type = "var.instance_type"    
  subnet_id     = data.aws_subnet.existing_subnet.id
  security_group_ids = [data.aws_security_group.existing_sg.id]
  key_name      = data.aws_key_pair.existing_key.key_name

  tags = {
    Name = "liron-ec2-instance"
  }

  associate_public_ip_address = false 
}

resource "aws_db_instance" "mysql_rds" {
  allocated_storage    = 20
  storage_type         = "gp2"
  db_instance_class    = "db.t3.micro"
  engine               = "mysql"
  engine_version       = "8.0"
  db_name              = "lirondatabase"
  username             = "admin"
  password             = "aA123456"
  db_subnet_group_name = data.aws_subnet.existing_subnet.id
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]

  publicly_accessible = false

  tags = {
    Name = "lironRDSInstance"
  }

}

output "ec2_instance_id" {
  value = aws_instance.example.id
}

output "rds_instance_id" {
  value = aws_db_instance.mysql_rds.id
}
