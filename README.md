# AWS Terraform Flask App

This project uses Terraform to provision a basic infrastructure on AWS, including:

- An EC2 instance running a simple Flask API.
- An RDS MySQL database instance.
- Security group rules allowing proper communication between the app and the DB.

## 🧱 Technologies

- **Terraform**
- **AWS (EC2, RDS, VPC, Security Groups)**
- **Flask**
- **Python 3**

## 📦 Project Structure

```
.
├── app/                   # Flask app code
├── infra/                 # Terraform code
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   └── outputs.tf
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

4. Apply the infrastructure (remember to pass the path to your public SSH key):
   ```bash
   terraform apply -var="public_key_path=~/.ssh/flask-key.pub"
   ```

5. Once the infrastructure is deployed, copy the EC2 public IP and open it in your browser:
   ```
   http://<EC2_PUBLIC_IP>:5000
   ```

## 📄 API Endpoints

- `/` → "Hola desde Flask en EC2!"
- `/inventario` → Returns a JSON list of items.

## 🔐 Notes

- The EC2 instance uses `user_data` to automatically install dependencies and launch the Flask app.
- Make sure your `.pem` file (key pair) is secured and added to your SSH agent.
- Provide the path to your public key using the `public_key_path` variable when
  running Terraform.

## 🧹 To Destroy

When you're done, destroy the infrastructure:
```bash
terraform destroy
```