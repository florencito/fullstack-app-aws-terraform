# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.project}-vpc"
  }
}

# Subnets
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "${var.project}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "us-east-1b"

  tags = {
    Name = "${var.project}-private-subnet"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "${var.project}-private-subnet-2"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-igw"
  }
}

# Route Table para subnet pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project}-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group para MySQL
resource "aws_security_group" "mysql_sg" {
  name        = "${var.project}-mysql-sg"
  description = "Permite acceso a MySQL solo desde EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-mysql-sg"
  }
}

resource "aws_db_subnet_group" "mysql_subnet_group" {
  name       = "${var.project}-mysql-subnet-group"
  subnet_ids = [aws_subnet.private.id, aws_subnet.private_2.id]

  tags = {
    Name = "${var.project}-mysql-subnet-group"
  }
}


resource "aws_db_instance" "mysql" {
  identifier             = "${var.project}-mysql"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "mydb"
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.mysql_subnet_group.name

  tags = {
    Name = "${var.project}-mysql"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.project}-ec2-sg"
  description = "Permite acceso HTTP y SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-ec2-sg"
  }
}

resource "aws_key_pair" "flask_key" {
  key_name = "flask-key"
  # Terraform no expande la tilde (~), por lo que usamos una variable
  # para especificar la ruta del archivo de clave pública.
  public_key = file(var.public_key_path)
}

resource "aws_instance" "flask_server" {
  ami                    = "ami-0150ccaf51ab55a51" # Amazon Linux 2023 AMI 2023.8.20250707.0 x86_64 HVM kernel-6.1
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  key_name               = aws_key_pair.flask_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
#!/bin/bash
set -e

# Actualizar e instalar Docker, Git y MySQL client
yum update -y
yum install -y docker git mysql

# Iniciar Docker
systemctl start docker
systemctl enable docker

# Agregar ec2-user al grupo docker
usermod -a -G docker ec2-user

# Clonar el repositorio
cd /home/ec2-user
git clone https://github.com/florencito/fullstack-app-aws-terraform.git

# Ir al proyecto
cd fullstack-app-aws-terraform

# Crear archivo .env para la app Flask
cat <<EOT >> app/.env
DB_HOST=${aws_db_instance.mysql.address}
DB_USER=${var.db_username}
DB_PASSWORD=${var.db_password}
DB_NAME=mydb
EOT

# Dar permisos de ejecución al script para cargar datos en RDS
chmod +x db/docker-entrypoint.sh

# Ejecutar el script de inicialización de la base de datos
DB_HOST="${aws_db_instance.mysql.address}" \
DB_USER="${var.db_username}" \
DB_PASSWORD="${var.db_password}" \
./db/docker-entrypoint.sh > /home/ec2-user/sql_output.log 2>&1

# Ir al directorio de la app Flask
cd app

# Construir y correr el contenedor usando el .env
docker build -t flask-app .
docker run -d --env-file .env -p 5000:5000 --name flask-container flask-app
EOF


  tags = {
    Name = "${var.project}-ec2"
  }
}
