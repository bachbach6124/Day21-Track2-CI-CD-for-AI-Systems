# Evidence Package

README yeu cau nop URL repo, chuoi screenshot theo thu tu, va report ngan.
Thu tu anh nen dung:

1. MLflow UI / MLflow runs evidence:
   - `submission/screenshots/01-mlflow-runs.png`
   - Ghi chu: anh nay duoc tao tu `mlflow.db` vi MLflow UI khong chay duoc tren Python 3.14 local.

2. GitHub Actions - MLOps Pipeline xanh:
   - `submission/screenshots/02-github-actions-green.png`
   - Anh ban da chup trong chat: MLOps Pipeline co Unit Test, Train, Eval, Deploy mau xanh.

3. S3 bucket root co `dvc/` va `models/`:
   - `submission/screenshots/03-s3-bucket-root.png`
   - Anh ban da chup trong chat: bucket `bachbach-mlops-lab-aws-20260626001024`.

4. S3 model artifact:
   - `submission/screenshots/04-s3-model-latest.png`
   - Anh ban da chup trong chat: `models/latest/model.pkl`.

5. EC2 instance running:
   - `submission/screenshots/05-ec2-instance-running.png`
   - Anh ban da chup trong chat: `mlops-serve-2`, `t3.small`, running, 3/3 checks passed.

6. Curl endpoint outputs:
   - `submission/screenshots/06-curl-health.png`
   - `submission/screenshots/06-curl-predict.png`
   - Anh ban da chup trong chat:
     - `curl http://54.197.156.225:8000/health` -> `{"status":"ok"}`
     - `curl -X POST http://54.197.156.225:8000/predict ...` -> `{"prediction":0,"label":"thap"}`

7. Continuous training trigger:
   - `submission/screenshots/07-continuous-training-run.png`
   - GitHub Actions run: https://github.com/bachbach6124/Day21-Track2-CI-CD-for-AI-Systems/actions/runs/28189099236
   - Event: `push`
   - Commit: `data: verify continuous training trigger`

Report ngan:

- `submission/report.md`
