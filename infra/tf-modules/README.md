# AWS application Terraform modules

These modules implement the architecture documented at:

http://127.0.0.1:8081/architecture/#logical-architecture

The intended flow is CloudFront -> private S3 for the UI and CloudFront -> internet-facing NLB created by the AWS Load Balancer Controller -> EKS Java API pods -> private RDS. The modules are intentionally independent so environments can compose them from their own root module and state.

## Modules

| Module | Creates |
| --- | --- |
| `network` | VPC, public/private/database subnets, NAT gateways, route tables, VPC endpoints, and security groups |
| `eks` | EKS control plane, managed node group, cluster IAM, and node IAM |
| `ecr` | ECR repository with scan-on-push and immutable tags |
| `rds` | Encrypted Multi-AZ RDS instance, subnet group, parameter group, and security group |
| `s3-ui` | Private versioned UI bucket and CloudFront OAC policy |
| `cloudfront` | CloudFront distribution with S3 default behavior and `/api/*` NLB behavior |
| `waf` | CloudFront-scoped WAF with managed rules and rate limiting |
| `iam` | OIDC provider and EKS service-account role for AWS Load Balancer Controller |
| `observability` | CloudWatch log groups, retention, and alarms |

Use an encrypted remote backend per environment. Do not commit `terraform.tfvars`, database passwords, or generated state.

## Environment variables

Environment-specific variable files are available at:

```text
environments/dev/terraform.tfvars
environments/qa/terraform.tfvars
environments/staging/terraform.tfvars
environments/production/terraform.tfvars
```

Run Terraform from this directory with the required environment file:

```bash
terraform plan -var-file=environments/dev/terraform.tfvars
terraform plan -var-file=environments/qa/terraform.tfvars
terraform plan -var-file=environments/staging/terraform.tfvars
terraform plan -var-file=environments/production/terraform.tfvars
```

Use a separate backend configuration and state key for each environment. Keep passwords, certificate ARNs, domain names, and other sensitive or account-specific values in a secret manager or protected CI variables.

## GitHub Actions

The workflow at `.github/workflows/terraform.yml` runs formatting and validation for pull requests and pushes to `main`. Pull requests from the same repository and manual workflow runs initialize the S3 backend, create a plan, and upload the plan as a short-lived GitHub artifact. This CI workflow does not apply infrastructure.

Configure these repository or environment values before running a plan:

- Secrets: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
- Variables: `AWS_REGION` and `TF_STATE_BUCKET`
- Optional variable: `TF_STATE_KEY` when the existing S3 object is not `investment-platform/<environment>/terraform.tfstate`

Create the four GitHub environments named `terraform-dev`, `terraform-qa`, `terraform-staging`, and `terraform-production` if you want environment-specific credentials or approval rules. The selected environment's secrets and variables take precedence over repository-level values.