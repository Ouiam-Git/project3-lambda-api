# Project 3 — Lambda Function + API Gateway

Serverless HTTP API built with AWS Lambda and API Gateway, provisioned via Terraform and deployed automatically through a GitHub Actions CI/CD pipeline.

## Architecture

```
GitHub Push
    │
    ▼
GitHub Actions
    │
    ├── terraform init
    ├── terraform validate
    ├── terraform plan
    └── terraform apply
            │
            ▼
    ┌───────────────────┐
    │   API Gateway     │  GET /hello
    │   (HTTP API)      │◄──── curl / browser
    └────────┬──────────┘
             │
             ▼
    ┌───────────────────┐
    │  Lambda Function  │  Python 3.12
    │  handler.py       │
    └───────────────────┘
             │
             ▼
    CloudWatch Logs (IAM)
```

## Project Structure

```
project3-lambda-api/
├── .github/
│   └── workflows/
│       └── deploy.yml      # CI/CD pipeline
├── lambda/
│   └── handler.py          # Lambda function code
├── main.tf                 # Lambda + API Gateway + IAM
├── variables.tf            # Input variables
├── outputs.tf              # Output values (API URL, ARN...)
├── .gitignore
└── README.md
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.3.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with valid credentials
- AWS IAM user with permissions for: Lambda, API Gateway, IAM

## Usage

### Deploy locally

```bash
terraform init
terraform apply
```

### Call the API

```bash
curl "$(terraform output -raw api_endpoint)"

# With query parameter
curl "$(terraform output -raw api_endpoint)?name=Ouiam"
```

Expected response:
```json
{ "message": "Hello, Ouiam!" }
```

### Destroy infrastructure

```bash
terraform destroy
```

## CI/CD Pipeline

| Event | Action |
|---|---|
| Pull Request → `main` | `terraform plan` + posts result as PR comment |
| Push → `main` | `terraform apply` (auto-deploy) |

### Required GitHub Secrets

Go to **Settings → Secrets and variables → Actions** and add:

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | AWS access key |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |

## Variables

| Name | Default | Description |
|---|---|---|
| `aws_region` | `us-east-1` | AWS region |
| `function_name` | `hello-api` | Lambda function name |
| `environment` | `dev` | Deployment environment |

## Outputs

| Name | Description |
|---|---|
| `api_endpoint` | Live HTTP URL for the API |
| `lambda_function_name` | Deployed Lambda function name |
| `lambda_arn` | ARN of the Lambda function |
