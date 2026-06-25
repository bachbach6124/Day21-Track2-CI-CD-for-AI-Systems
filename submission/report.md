# MLOps Lab Submission Report

Repository: https://github.com/bachbach6124/Day21-Track2-CI-CD-for-AI-Systems

## Ket qua hien tai

- Du lieu `train_phase2.csv` da duoc bo sung vao `train_phase1.csv`.
- Kich thuoc train hien tai: 5996 mau.
- Mo hinh tot nhat: `extra_trees`.
- Sieu tham so:
  - `n_estimators: 200`
  - `max_depth: null`
  - `min_samples_split: 2`
- Ket qua tren `data/eval.csv`:
  - `accuracy: 0.7680`
  - `f1_score: 0.7670`

## Ly do chon mo hinh

RandomForest va mot so cau hinh boosting tren tap phase 1 khong vuot nguong
accuracy 0.70. Sau khi bo sung du lieu moi o phase 2, ExtraTreesClassifier
voi 200 cay dat accuracy 0.7680 va f1_score 0.7670 tren tap eval, vuot nguong
deploy gate 0.70. Cau hinh 200 cay duoc chon vi giu chat luong tot trong khi
model artifact chi khoang 17MB, phu hop hon de deploy tren EC2 free-tier.

## Bang so sanh

| Giai doan | Du lieu train | Mo hinh | accuracy | f1_score |
|---|---:|---|---:|---:|
| Buoc 1/2 | 2998 mau | RandomForest / ExtraTrees thu nghiem | ~0.64 - 0.69 | ~0.64 - 0.68 |
| Buoc 3 | 5996 mau | ExtraTreesClassifier | 0.7680 | 0.7670 |

## Bang chung can chup man hinh

- MLflow UI hien thi it nhat 3 runs.
- GitHub Actions co 4 jobs xanh: Unit Test, Train, Eval, Deploy.
- Cloud Storage co du lieu DVC trong `dvc/` va model trong `models/latest/model.pkl`.
- Ket qua:
  - `curl http://VM_IP:8000/health`
  - `curl -X POST http://VM_IP:8000/predict ...`

## Viec can chay voi AWS credential that

Pipeline hien tai su dung AWS S3 lam DVC/model remote va EC2 lam inference VM.
Ha tang da duoc tao voi cac gia tri:

- AWS account: `815935788575`
- AWS user: `arn:aws:iam::815935788575:user/ai-lab-user`
- Region: `us-east-1`
- S3 bucket: `bachbach-mlops-lab-aws-20260626001024`
- EC2 instance: `i-0accfab1a1a59e23f`
- VM host: `54.197.156.225`
- VM user: `ubuntu`

GitHub Secrets da duoc them:

- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- `AWS_REGION`: region, vi du `us-east-1`
- `S3_BUCKET`: ten bucket
- `VM_HOST`: public IP cua VM
- `VM_USER`: user tren VM
- `VM_SSH_KEY`: private key deploy

Endpoint da kiem tra:

```bash
curl http://54.197.156.225:8000/health
# {"status":"ok"}

curl -X POST http://54.197.156.225:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"features": [7.4, 0.70, 0.00, 1.9, 0.076, 11.0, 34.0, 0.9978, 3.51, 0.56, 9.4, 0]}'
# {"prediction":0,"label":"thap"}
```
