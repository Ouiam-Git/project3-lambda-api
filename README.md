# Project 3 — Lambda Function + API Gateway

Serverless HTTP API built with AWS Lambda and API Gateway, provisioned via Terraform and deployed automatically through a GitHub Actions CI/CD pipeline.

## What I Built & Why

This project provisions a fully serverless HTTP API on AWS — no servers to manage, no manual clicking in the console. Everything is defined as code and deployed automatically.

### What I did step by step

**1. Wrote the Lambda function (`lambda/handler.py`)**  
A Python function that receives an HTTP request, reads an optional `?name=` query parameter, and returns a JSON response. This is the actual logic that runs in the cloud.

**2. Configured IAM (`main.tf`)**  
Created an IAM role that allows Lambda to run and write logs to CloudWatch. Without this role, AWS won't allow the function to execute. Used the AWS-managed policy `AWSLambdaBasicExecutionRole` to keep permissions minimal.

**3. Packaged and deployed the Lambda (`main.tf`)**  
Terraform automatically zips the `lambda/` folder and uploads it to AWS. It also tracks code changes via a SHA256 hash — so every time the code changes, Terraform knows to redeploy.

**4. Created an API Gateway (`main.tf`)**  
Set up an HTTP API (API Gateway v2) with a single route: `GET /hello`. The route is connected to the Lambda via a proxy integration — meaning API Gateway forwards the full request to Lambda and returns whatever Lambda responds with.

**5. Granted API Gateway permission to invoke Lambda (`main.tf`)**  
Added a `lambda_permission` resource so API Gateway is explicitly allowed to call the function. Without this, the invocation would be blocked even if everything else is correct.

**6. Defined variables and outputs (`variables.tf`, `outputs.tf`)**  
Made the region, function name, and environment configurable via variables. Exposed the live API URL, function name, and ARN as outputs so they're easy to retrieve after deployment.

**7. Automated deployment with GitHub Actions (`.github/workflows/deploy.yml`)**  
Set up a CI/CD pipeline that:
- Runs `terraform plan` on every Pull Request and posts the result as a comment
- Runs `terraform apply` automatically on every push to `main`

This means infrastructure changes are reviewed before they're applied, and deployment is fully hands-off.

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
