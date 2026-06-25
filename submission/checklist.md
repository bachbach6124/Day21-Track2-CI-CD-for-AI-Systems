# Submission Checklist

- [x] `src/train.py` hoan thien train, log MLflow, luu metrics va model.
- [x] `src/serve.py` hoan thien `/health` va `/predict`.
- [x] `tests/test_train.py` chay duoc khong can DVC/cloud.
- [x] `.github/workflows/mlops.yml` co 4 jobs: Unit Test, Train, Eval, Deploy.
- [x] `params.yaml` dat cau hinh model tot nhat hien tai.
- [x] DVC da track 3 file du lieu bang `.dvc` pointers.
- [x] Du lieu phase 2 da duoc bo sung vao `train_phase1.csv`.
- [x] Local tests pass: `pytest tests/ -v`.
- [x] Local train dat `accuracy = 0.7680`, qua nguong 0.70.
- [x] Tao SSH deploy key local tai `~/.ssh/mlops_deploy`.
- [x] Chuyen pipeline sang AWS S3/EC2.
- [x] Tao script setup S3 va DVC remote: `scripts/setup_aws_storage.sh`.
- [x] Tao script setup EC2 va systemd service: `scripts/setup_aws_ec2.sh`.
- [x] Tao script them GitHub Secrets cho AWS: `scripts/set_github_secrets_aws.sh`.
- [x] Chay `AWS_REGION=us-east-1 BUCKET=bachbach-mlops-lab-aws-20260626001024 scripts/setup_aws_storage.sh` de thay `s3://YOUR_BUCKET/dvc` va `dvc push`.
- [x] Chay `AWS_REGION=us-east-1 BUCKET=bachbach-mlops-lab-aws-20260626001024 INSTANCE_NAME=mlops-serve-2 INSTANCE_TYPE=t3.small scripts/setup_aws_ec2.sh` de tao/cau hinh EC2 va copy `src/serve.py`.
- [x] Chay `AWS_REGION=us-east-1 BUCKET=bachbach-mlops-lab-aws-20260626001024 VM_HOST=54.197.156.225 VM_USER=ubuntu scripts/set_github_secrets_aws.sh` de them GitHub Secrets.
- [x] Test endpoint tren VM bang `curl`.
- [ ] Push repo len GitHub va lay screenshot Actions.
- [ ] Chup screenshot MLflow UI, Actions, Cloud Storage, curl outputs.

Thong tin hien tai:

- S3 bucket: `bachbach-mlops-lab-aws-20260626001024`
- EC2 instance: `i-0accfab1a1a59e23f`
- VM host: `54.197.156.225`
- VM user: `ubuntu`
- Health check: `curl http://54.197.156.225:8000/health` -> `{"status":"ok"}`
- Predict check: `curl -X POST http://54.197.156.225:8000/predict ...` -> `{"prediction":0,"label":"thap"}`
