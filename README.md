# aws-platform-bootstrap
Bootstrap infrastructure for AWS platform provisioning, including Terraform backend, OIDC authentication, IAM roles, and security foundations.

## Overview

This repository contains the bootstrap infrastructure required to establish the foundational components for a production-grade AWS platform.

The purpose of this repository is to create and manage the resources required before the main Infrastructure as Code (IaC) and CI/CD pipelines can operate. Once the bootstrap resources are provisioned, all subsequent infrastructure deployments are performed through GitHub Actions using OIDC authentication and Terraform.

## Why This Repository Exists

Infrastructure provisioning pipelines require a trusted authentication mechanism and a remote Terraform backend before they can manage AWS resources.

This repository solves the initial bootstrap problem by creating the foundational resources that enable secure and automated infrastructure deployments.

## Components

### Terraform Remote State

* Amazon S3 Bucket for Terraform state storage
* DynamoDB Table for state locking
* Server-side encryption using AWS KMS

### Identity & Access Management

* GitHub OIDC Provider
* IAM Roles for GitHub Actions
* Least-privilege IAM policies

### Security

* AWS KMS Keys
* Encryption configuration
* IAM trust relationships

## Architecture

GitHub Actions → AWS OIDC → IAM Role → Terraform → AWS Resources

## Resources Managed

* AWS KMS Key
* S3 Backend Bucket
* DynamoDB Lock Table
* GitHub OIDC Provider
* GitHub Actions IAM Roles
* IAM Policies and Trust Relationships

## Repository Structure

```text
aws-platform-bootstrap/
├── kms.tf
├── s3.tf
├── dynamodb.tf
├── oidc.tf
├── iam.tf
├── outputs.tf
├── variables.tf
└── README.md
```

## Deployment Strategy

This repository is executed only during the initial platform setup.

After the bootstrap process is complete:

* Terraform state is stored remotely in S3.
* State locking is handled by DynamoDB.
* GitHub Actions authenticates to AWS using OIDC.
* All future infrastructure changes are managed through dedicated platform repositories.

## Design Principles

* Infrastructure as Code (IaC)
* Security First
* Least Privilege Access
* GitOps Friendly
* Production Ready
* Reusable Across AWS Accounts
* Fully Auditable

## Scope

This repository does not provision application or platform resources such as:

* VPC
* EKS
* RDS
* Redis
* EFS
* ArgoCD
* Monitoring Stack

These resources are managed in the platform infrastructure repository after bootstrap completion.

## Future Repositories

* aws-platform-bootstrap
* aws-platform-infra
* aws-platform-gitops
* aws-platform-apps

```
```
