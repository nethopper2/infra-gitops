provider "aws" {
  shared_credentials_file = "aws-creds.ini"
  region = "us-east-2"
}

// Modules _must_ use remote state. The provider does not persist state.
terraform {
  backend "kubernetes" {
    secret_suffix     = "providerconfig-default"
    namespace         = "devops-admin-tf"
    in_cluster_config = true
  }
}
resource "aws_vpc" "main" {
 cidr_block = "10.0.0.0/16"
 
 tags = {
   Name = "xplane-tf-demo-vpc"
 }
}