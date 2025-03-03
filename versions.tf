terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.85.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.6.1"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = ">=0.9.6"
    }
  }
}