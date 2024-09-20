# main.tf

terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.0"
    }
  }
}

provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}

resource "mongodbatlas_project" "example" {
  name   = var.project_name
  org_id = var.atlas_org_id
}

resource "mongodbatlas_cluster" "example" {
  project_id                 = mongodbatlas_project.example.id
  name                       = var.cluster_name
  provider_name              = var.provider_name
  provider_region_name       = var.provider_region_name
  provider_instance_size_name = var.provider_instance_size_name
  mongo_db_major_version     = var.mongo_db_major_version

  # Cluster type configuration
  cluster_type = var.cluster_type
  
  # Disk size configuration
  disk_size_gb = var.disk_size_gb

  # Advanced configuration options
  advanced_configuration {
    javascript_enabled                   = true
    minimum_enabled_tls_protocol         = "TLS1_2"
  }
}

resource "mongodbatlas_database_user" "user" {
  username           = var.database_username
  password           = var.database_password
  project_id         = mongodbatlas_project.example.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "mydatabase"
  }
}

resource "mongodbatlas_project_ip_access_list" "ip" {
  project_id = mongodbatlas_project.example.id
  ip_address = var.ip_address
  comment    = "Allowed IP address"
}

data "mongodbatlas_cluster" "example" {
  project_id = mongodbatlas_project.example.id
  name       = mongodbatlas_cluster.example.name
}

output "connection_string" {
  value = nonsensitive("mongodb+srv://${mongodbatlas_database_user.user.username}:${mongodbatlas_database_user.user.password}@${split("mongodb+srv://", data.mongodbatlas_cluster.example.connection_strings[0].standard_srv)[1]}")
  sensitive = false
}