#!/usr/bin/env bash
set -euo pipefail

: "${BUCKET:?Set BUCKET to a globally unique S3 bucket name}"
REGION="${AWS_REGION:-us-east-1}"

if ! aws s3api head-bucket --bucket "$BUCKET" >/dev/null 2>&1; then
  if [ "$REGION" = "us-east-1" ]; then
    aws s3api create-bucket --bucket "$BUCKET" --region "$REGION"
  else
    aws s3api create-bucket \
      --bucket "$BUCKET" \
      --region "$REGION" \
      --create-bucket-configuration "LocationConstraint=$REGION"
  fi
fi

aws s3api put-public-access-block \
  --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

.venv/bin/dvc remote modify myremote url "s3://${BUCKET}/dvc"
.venv/bin/dvc push

echo "S3 and DVC are ready: s3://${BUCKET}/dvc"
