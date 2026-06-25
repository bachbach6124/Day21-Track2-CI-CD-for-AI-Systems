#!/usr/bin/env bash
set -euo pipefail

: "${BUCKET:?Set BUCKET to your S3 bucket name}"
REGION="${AWS_REGION:-us-east-1}"
INSTANCE_NAME="${INSTANCE_NAME:-mlops-serve}"
KEY_NAME="${KEY_NAME:-mlops-deploy}"
SG_NAME="${SG_NAME:-mlops-serve-sg}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t3.micro}"

if [ ! -f "$HOME/.ssh/mlops_deploy.pub" ]; then
  ssh-keygen -t ed25519 -f "$HOME/.ssh/mlops_deploy" -N "" -C "github-actions-deploy"
fi

if ! aws ec2 describe-key-pairs --key-names "$KEY_NAME" --region "$REGION" >/dev/null 2>&1; then
  aws ec2 import-key-pair \
    --key-name "$KEY_NAME" \
    --public-key-material "fileb://$HOME/.ssh/mlops_deploy.pub" \
    --region "$REGION" >/dev/null
fi

VPC_ID="$(aws ec2 describe-vpcs \
  --filters Name=is-default,Values=true \
  --query 'Vpcs[0].VpcId' \
  --output text \
  --region "$REGION")"

if [ "$VPC_ID" = "None" ] || [ -z "$VPC_ID" ]; then
  echo "No default VPC found in $REGION." >&2
  exit 1
fi

SG_ID="$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=${SG_NAME}" "Name=vpc-id,Values=${VPC_ID}" \
  --query 'SecurityGroups[0].GroupId' \
  --output text \
  --region "$REGION")"

if [ "$SG_ID" = "None" ] || [ -z "$SG_ID" ]; then
  SG_ID="$(aws ec2 create-security-group \
    --group-name "$SG_NAME" \
    --description "MLOps serving security group" \
    --vpc-id "$VPC_ID" \
    --query 'GroupId' \
    --output text \
    --region "$REGION")"
fi

for port in 22 8000; do
  aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp \
    --port "$port" \
    --cidr 0.0.0.0/0 \
    --region "$REGION" >/dev/null 2>&1 || true
done

AMI_ID="$(aws ec2 describe-images \
  --owners 099720109477 \
  --filters \
    "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
    "Name=state,Values=available" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --output text \
  --region "$REGION")"

INSTANCE_ID="$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=${INSTANCE_NAME}" "Name=instance-state-name,Values=pending,running,stopping,stopped" \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text \
  --region "$REGION")"

if [ "$INSTANCE_ID" = "None" ] || [ -z "$INSTANCE_ID" ]; then
  INSTANCE_ID="$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" \
    --security-group-ids "$SG_ID" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${INSTANCE_NAME}}]" \
    --query 'Instances[0].InstanceId' \
    --output text \
    --region "$REGION")"
fi

aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "$REGION"

VM_HOST="$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text \
  --region "$REGION")"
VM_USER="ubuntu"

echo "Waiting for SSH on ${VM_HOST}..."
for _ in {1..30}; do
  if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i "$HOME/.ssh/mlops_deploy" "$VM_USER@$VM_HOST" true >/dev/null 2>&1; then
    break
  fi
  sleep 10
done

ssh -o StrictHostKeyChecking=no -i "$HOME/.ssh/mlops_deploy" "$VM_USER@$VM_HOST" '
  sudo apt update
  sudo apt install -y python3-pip curl
  pip3 install --user \
    fastapi==0.111.0 \
    uvicorn==0.29.0 \
    scikit-learn==1.4.2 \
    joblib==1.4.2 \
    boto3==1.34.106 \
    numpy==1.26.4
  mkdir -p ~/models ~/src ~/.aws
'

scp -o StrictHostKeyChecking=no -i "$HOME/.ssh/mlops_deploy" src/serve.py "$VM_USER@$VM_HOST:~/src/serve.py"
if [ -f "$HOME/.aws/credentials" ]; then
  scp -o StrictHostKeyChecking=no -i "$HOME/.ssh/mlops_deploy" "$HOME/.aws/credentials" "$VM_USER@$VM_HOST:~/.aws/credentials"
fi
if [ -f "$HOME/.aws/config" ]; then
  scp -o StrictHostKeyChecking=no -i "$HOME/.ssh/mlops_deploy" "$HOME/.aws/config" "$VM_USER@$VM_HOST:~/.aws/config"
fi

ssh -o StrictHostKeyChecking=no -i "$HOME/.ssh/mlops_deploy" "$VM_USER@$VM_HOST" "sudo tee /etc/systemd/system/mlops-serve.service >/dev/null <<EOF
[Unit]
Description=MLOps Model Inference Server
After=network.target

[Service]
User=${VM_USER}
WorkingDirectory=/home/${VM_USER}
Environment=\"S3_BUCKET=${BUCKET}\"
Environment=\"AWS_DEFAULT_REGION=${REGION}\"
ExecStart=/usr/bin/python3 /home/${VM_USER}/src/serve.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable mlops-serve
"

echo "INSTANCE_ID=${INSTANCE_ID}"
echo "VM_HOST=${VM_HOST}"
echo "VM_USER=${VM_USER}"
echo "Start service after the first successful pipeline upload:"
echo "ssh -i ~/.ssh/mlops_deploy ${VM_USER}@${VM_HOST} 'sudo systemctl start mlops-serve'"
