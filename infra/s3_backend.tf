resource "aws_s3_bucket" "tf_state" {
  bucket = "florencio-terraform-state-bucket"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = {
    Name = "Terraform State Bucket"
  }
}
