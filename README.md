# AWS Terraform Flask App

This project provisions a small AWS environment using Terraform:

- An EC2 instance that runs the Flask API inside a Docker container.
- An RDS MySQL database instance.
- Security groups allowing the instance to reach the database.

## 🧱 Technologies

- **Terraform**
- **AWS (EC2, RDS, VPC, Security Groups)**
- **Flask**
- **Python 3**
- **Docker**
- **GitHub Actions**

## 📦 Project Structure

```
.
├── app/                   # Flask app code
├── db/                    # Database init script and Dockerfile
├── infra/                 # Terraform code
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   └── outputs.tf
└── .github/workflows/     # Terraform CI workflows
```

## 🚀 How to Deploy

1. Clone the repo and navigate to the `infra/` directory:
   ```bash
   git clone https://github.com/your-user/aws-terraform-flask-app.git
   cd aws-terraform-flask-app/infra
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Preview the changes:
   ```bash
   terraform plan
   ```

4. Apply the infrastructure. Provide your SSH **public key** along with the
   database credentials:
   ```bash
   terraform apply \
     -var="public_key=$(cat ~/.ssh/flask-key.pub)" \
     -var="db_username=<user>" \
     -var="db_password=<password>"
   ```

5. Once the infrastructure is deployed, copy the EC2 public IP and open it in your browser:
   ```
   http://<EC2_PUBLIC_IP>:5000
   ```

### Deploy via GitHub Actions

The repository provides workflows under `.github/workflows/` that can apply or
destroy the infrastructure. Configure the following secrets in your repository
before triggering them:

- `ACCESS_KEY_ID` and `SECRET_ACCESS_KEY` – AWS credentials
- `DB_USERNAME` and `DB_PASSWORD` – credentials for the RDS instance
- `PUBLIC_KEY` – contents of the SSH public key for the EC2 instance

## 📄 API Endpoints

- `/` → "Hola desde Flask en EC2!"
- `/inventario` → Returns a JSON list of items.

- The EC2 instance clones this repository, builds the Docker image and runs the
  Flask app automatically.
- The key pair used for SSH access is created from the `PUBLIC_KEY` value, which
  can be stored as a GitHub secret.

## 🧹 To Destroy

When you're done, destroy the infrastructure:
```bash
terraform destroy
```
