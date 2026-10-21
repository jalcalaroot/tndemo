# Three-Tier VPC with ALB, NGINX and Apache Demo — Terraform

Terraform demo stack in `us-east-1`: a three-tier VPC (public, private with NAT, isolated private), an Application Load Balancer, and two Ubuntu web servers (NGINX and Apache) in a private subnet, managed via SSM Session Manager.

> **Status:** legacy reference (2020), not actively maintained. Review and update before using. Written for **Terraform 0.11** (`"${...}"` interpolation, `tags { }` block syntax, `count.index` without `count`, quoted `depends_on`) and the pre-3.x AWS provider.

## Architecture

- **VPC** `10.0.0.0/16` with DNS support/hostnames.
- **Public subnets** (`10.0.128.0/20`, `10.0.144.0/20`, `10.0.160.0/20` in us-east-1a/b/c) with auto-assign public IP, routed to an Internet Gateway.
- **Private subnets A** (`10.0.0.0/19`, `10.0.32.0/19`, `10.0.64.0/19`) — outbound only, **one NAT Gateway per AZ** (3 EIPs, 3 route tables).
- **Private subnets B** (`10.0.192.0/21`, `10.0.200.0/21`, `10.0.208.0/21`) — no internet route.
- **EC2 SG** — SSH, HTTP, HTTPS from `10.0.0.0/16` only.
- **IAM role** `ec2-role` (trusts EC2 and ECS) with `AmazonSSMFullAccess` and `CloudWatchFullAccess`, plus instance profile.
- **Key pair** `main_public_key` from a hardcoded SSH public key.
- **Server01** (NGINX) and **Server02** (Apache) — hardcoded Ubuntu AMI for us-east-1, `t2.small`, 30 GiB gp2, both in `private-subnet-A1`. User data (`user-data/deploy_nginx.sh`, `user-data/deploy_apache.sh`) upgrades packages, installs the SSM agent (snap) and the web server, and writes a "Server 01 NGINX" / "Server 02 APACHE" page.
- **ALB** in the public subnets, SG allowing 80/443 from `0.0.0.0/0`; HTTP:80 listener → target group (health check `/`) with both servers, so requests alternate between NGINX and Apache.
- **Outputs**: VPC and subnet IDs, `elb_dns_name`, instance IDs.

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `access_key` | AWS access key ID (avoid — see Security notes) | — |
| `secret_key` | AWS secret access key (avoid — see Security notes) | — |

Region (`us-east-1`), AZs, CIDRs, AMI and instance types are hardcoded in `main.tf` / `variables.tf`.

## Usage

```bash
git clone git@github.com:jalcalaroot/tndemo.git && cd tndemo
terraform init
terraform plan  -var access_key=<AWS_ACCESS_KEY_ID> -var secret_key=<AWS_SECRET_ACCESS_KEY>
terraform apply -var access_key=<AWS_ACCESS_KEY_ID> -var secret_key=<AWS_SECRET_ACCESS_KEY>
curl http://$(terraform output elb_dns_name)/
```

The original instructions used `sudo terraform ...`; running Terraform as root is unnecessary. Prefer `AWS_PROFILE` over the credential variables.

## Security notes

- Web servers are private and SSH is VPC-only — a reasonable baseline. Access is via SSM Session Manager.
- The ALB listens on HTTP only (the SG opens 443 but there is no HTTPS listener or certificate).
- `AmazonSSMFullAccess` is broader than needed (`AmazonSSMManagedInstanceCore` suffices); the role also trusts `ecs.amazonaws.com` without need.
- Hardcoded SSH public key; credentials as Terraform variables; local state only; unencrypted root volumes; no IMDSv2 enforcement.
- Cost: three NAT Gateways + ALB run continuously — destroy when done.

## Cleanup

```bash
terraform destroy -var access_key=<AWS_ACCESS_KEY_ID> -var secret_key=<AWS_SECRET_ACCESS_KEY>
```

## License

MIT — see [LICENSE](LICENSE).
