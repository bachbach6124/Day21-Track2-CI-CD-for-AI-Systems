#!/usr/bin/env bash
set -euo pipefail

: "${BUCKET:?Set BUCKET to your S3 bucket name}"
: "${VM_HOST:?Set VM_HOST to the EC2 public IP}"
: "${VM_USER:?Set VM_USER to the EC2 login user, usually ubuntu}"
REGION="${AWS_REGION:-us-east-1}"

AWS_ACCESS_KEY_ID_VALUE="${AWS_ACCESS_KEY_ID:-$(aws configure get aws_access_key_id)}"
AWS_SECRET_ACCESS_KEY_VALUE="${AWS_SECRET_ACCESS_KEY:-$(aws configure get aws_secret_access_key)}"

if [ -z "$AWS_ACCESS_KEY_ID_VALUE" ] || [ -z "$AWS_SECRET_ACCESS_KEY_VALUE" ]; then
  echo "AWS credentials not found in env or aws config." >&2
  exit 1
fi

if [ ! -f "$HOME/.ssh/mlops_deploy" ]; then
  echo "$HOME/.ssh/mlops_deploy not found. Run scripts/setup_aws_ec2.sh first." >&2
  exit 1
fi

printf "%s" "$AWS_ACCESS_KEY_ID_VALUE" | gh secret set AWS_ACCESS_KEY_ID
printf "%s" "$AWS_SECRET_ACCESS_KEY_VALUE" | gh secret set AWS_SECRET_ACCESS_KEY
printf "%s" "$REGION" | gh secret set AWS_REGION
printf "%s" "$BUCKET" | gh secret set S3_BUCKET
printf "%s" "$VM_HOST" | gh secret set VM_HOST
printf "%s" "$VM_USER" | gh secret set VM_USER
gh secret set VM_SSH_KEY < "$HOME/.ssh/mlops_deploy"

echo "GitHub Actions AWS secrets are set."
