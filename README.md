# 🏗️ QRify Infrastructure

This repository manages the infrastructure for the QRify platform using Terraform and GitHub Actions. It currently provisions foundational cloud resources like:

- Amazon ECR repositories for app container images
- S3 bucket for storing generated QR codes
- IAM roles and policies for secure access

More infrastructure components will be added incrementally as the platform evolves, including Kubernetes (EKS), Argo CD, monitoring, and more.

## 🚀 Tech Stack
- **Terraform**: Infrastructure as Code
- **AWS**: Cloud provider
- **GitHub Actions**: CI/CD automation
