# ✅ Submission Checklist - Lab MLOps CI/CD

## 📦 Before Submitting

### 1. Code & Configuration ✓
- [x] `src/train.py` - Complete with bonus features
- [x] `src/serve.py` - FastAPI endpoints
- [x] `tests/test_train.py` - All tests passing
- [x] `.github/workflows/mlops.yml` - 4-job pipeline
- [x] `params.yaml` - Best hyperparameters
- [x] `requirements.txt` - All dependencies
- [x] `.gitignore` - Properly configured

### 2. Data & Models ✓
- [x] DVC tracking files (*.dvc)
- [x] Data on S3 (train_phase1, eval, train_phase2)
- [x] Model on S3 (models/latest/model.pkl)
- [x] Metrics on S3 (models/latest/metrics.json)

### 3. MLflow Experiments ✓
- [x] At least 3 runs logged
- [x] Different hyperparameters
- [x] All runs have accuracy & f1_score
- [x] Best model identified (ExtraTrees, acc=0.7680)

### 4. CI/CD Pipeline ✓
- [x] GitHub Actions workflow exists
- [x] All 4 jobs configured (Test, Train, Eval, Deploy)
- [x] GitHub Secrets configured
- [x] Latest run successful (all green)

### 5. Deployment ✓
- [x] EC2 instance running
- [x] mlops-serve service active
- [x] Health endpoint working
- [x] Predict endpoint working

### 6. Bonus Features ✓
- [x] Bonus 2: Multi-algorithm (4/4)
- [x] Bonus 3: Performance report (4/4)
- [x] Bonus 4: Model rollback (4/4)
- [x] Bonus 5: Data distribution warning (4/4)

---

## 📸 Screenshots Required

### Screenshot 1: MLflow UI
**Content**: Show at least 3 experiment runs
- [ ] Multiple runs visible
- [ ] Different parameters
- [ ] Accuracy & F1 scores displayed
- [ ] Best run highlighted

**How to capture**:
```bash
mlflow ui --backend-store-uri sqlite:///mlflow.db
# Open http://localhost:5000
# Screenshot the runs table
```

**Filename**: `mlflow-ui-experiments.png`

---

### Screenshot 2: GitHub Actions - All Jobs Green
**Content**: Full pipeline run showing all 4 jobs passing
- [ ] Test job (green checkmark)
- [ ] Train job (green checkmark)
- [ ] Eval job (green checkmark)
- [ ] Deploy job (green checkmark)
- [ ] Timestamp visible

**How to capture**:
1. Go to GitHub repo
2. Click "Actions" tab
3. Click on latest workflow run
4. Screenshot showing all 4 jobs with green checkmarks

**Filename**: `github-actions-success.png`

---

### Screenshot 3: GitHub Actions - Continuous Training
**Content**: Pipeline triggered by data update (Bước 3)
- [ ] Triggered by push event
- [ ] Commit message about data update
- [ ] All jobs completed
- [ ] Timestamp showing automated trigger

**Filename**: `continuous-training-trigger.png`

---

### Screenshot 4: VM Health Check
**Content**: Terminal showing health endpoint test
- [ ] `curl http://54.197.156.225:8000/health`
- [ ] Response: `{"status":"ok"}`
- [ ] Command and output clearly visible

**How to capture**:
```bash
curl http://54.197.156.225:8000/health
# Screenshot terminal output
```

**Filename**: `vm-health-check.png`

---

### Screenshot 5: VM Predict Endpoint
**Content**: Terminal showing prediction test
- [ ] `curl -X POST ...` command
- [ ] Input features (12 values)
- [ ] Response with prediction and label
- [ ] Full command visible

**How to capture**:
```bash
curl -X POST http://54.197.156.225:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"features":[7.4,0.7,0.0,1.9,0.076,11.0,34.0,0.9978,3.51,0.56,9.4,0]}'
# Screenshot terminal output
```

**Filename**: `vm-predict-test.png`

---

### Screenshot 6: AWS S3 Console
**Content**: S3 bucket showing DVC data and models
- [ ] Bucket name visible
- [ ] `data/` folder with CSV files
- [ ] `models/latest/` folder with model.pkl
- [ ] File sizes and timestamps

**How to capture**:
1. Open AWS Console
2. Navigate to S3
3. Open bucket: `bachbach-mlops-lab-aws-20260626001024`
4. Screenshot showing folder structure

**Filename**: `s3-bucket-contents.png`

---

### Screenshot 7: Bonus Features Evidence
**Content**: Showing bonus implementations
- [ ] Performance report (outputs/report.txt)
- [ ] Metrics with class_distribution
- [ ] Multi-algorithm experiments in MLflow
- [ ] Model comparison logs

**How to capture**:
```bash
# Show performance report
cat outputs/report.txt

# Show metrics with distribution
cat outputs/metrics.json | python -m json.tool

# Screenshot both outputs
```

**Filename**: `bonus-features-evidence.png`

---

## 📄 Report (1 Page A4)

### Structure

#### Section 1: Best Hyperparameters (30%)
**Content**:
- Model type: ExtraTrees
- n_estimators: 200
- max_depth: null (unlimited)
- min_samples_split: 2

**Rationale**:
- ExtraTrees provided best accuracy (0.7680) vs RandomForest (0.6420)
- Larger ensemble (200 trees) improved generalization
- Unlimited depth allowed complex decision boundaries
- Tested 5+ combinations via MLflow tracking

#### Section 2: Challenges & Solutions (40%)

**Challenge 1: Model Accuracy Below Threshold**
- Problem: Initial RandomForest only achieved 0.56 accuracy
- Solution: 
  - Experimented with multiple algorithms (Bonus 2)
  - Combined phase1 + phase2 data (Bước 3)
  - Result: Improved to 0.77 accuracy

**Challenge 2: Class Imbalance**
- Problem: Class 2 (High quality) only 19.63% of data
- Solution:
  - Implemented data distribution monitoring (Bonus 5)
  - Used weighted F1-score metric
  - Logged distribution to metrics.json

**Challenge 3: Production Safety**
- Problem: Risk of deploying worse models
- Solution:
  - Implemented model rollback mechanism (Bonus 4)
  - Compare new vs previous accuracy before deploy
  - Skip deployment if accuracy decreases

#### Section 3: Bonus Features (30%)

**Implemented**: 4/5 bonus features (16/20 points)

1. **Multi-Algorithm Support** (Bonus 2)
   - 4 algorithms: RandomForest, ExtraTrees, GradientBoosting, LogisticRegression
   - Easy switching via params.yaml

2. **Performance Report** (Bonus 3)
   - Confusion matrix + precision/recall per class
   - Automatically generated after training
   - Uploaded as GitHub Actions artifact

3. **Model Rollback** (Bonus 4)
   - Compares new vs previous accuracy
   - Prevents deploying worse models
   - Integrated in CI/CD pipeline

4. **Data Distribution Warning** (Bonus 5)
   - Warns if class < 10% of samples
   - Logs distribution to metrics.json
   - Helps detect data quality issues

**Skipped**: Bonus 1 (DagsHub) - focused on other bonuses for better ROI

---

## 📤 Submission Package

### 1. GitHub Repository URL
```
https://github.com/YOUR_USERNAME/YOUR_REPO_NAME
```

Requirements:
- [ ] Repository is public
- [ ] All code committed
- [ ] .github/workflows/mlops.yml present
- [ ] README.md updated
- [ ] Latest commit shows final state

### 2. Screenshots Folder
Organize in zip file: `mlops-lab-screenshots.zip`
```
screenshots/
├── 01-mlflow-ui-experiments.png
├── 02-github-actions-success.png
├── 03-continuous-training-trigger.png
├── 04-vm-health-check.png
├── 05-vm-predict-test.png
├── 06-s3-bucket-contents.png
└── 07-bonus-features-evidence.png
```

### 3. Report Document
- [ ] File: `mlops-lab-report.pdf`
- [ ] Max 1 page A4
- [ ] Sections: Hyperparameters, Challenges, Bonus
- [ ] Professional formatting

### 4. Optional: Demo Video (Extra Credit)
- [ ] 3-5 minutes
- [ ] Shows full pipeline in action
- [ ] Demonstrates continuous training
- [ ] Shows API endpoints working

---

## ✅ Pre-Submission Verification

Run these commands to verify everything works:

### 1. Local Tests
```bash
# Run unit tests
pytest tests/ -v

# Run training
python src/train.py

# Check outputs
ls -la outputs/metrics.json outputs/report.txt models/model.pkl
```

### 2. Bonus Features Test
```bash
./test_all_bonus.sh
```

### 3. DVC Status
```bash
dvc status
dvc push
```

### 4. GitHub Actions
```bash
# Check latest run
gh run list --limit 1
gh run view --log
```

### 5. VM Endpoints
```bash
# Health check
curl http://54.197.156.225:8000/health

# Predict
curl -X POST http://54.197.156.225:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"features":[7.4,0.7,0.0,1.9,0.076,11.0,34.0,0.9978,3.51,0.56,9.4,0]}'
```

---

## 📊 Expected Grading

| Category | Points | Your Score |
|----------|--------|------------|
| MLflow tracking (3+ runs) | 12 | 12 ✓ |
| Metrics logged | 8 | 8 ✓ |
| Analysis | 4 | 4 ✓ |
| DVC setup | 12 | 12 ✓ |
| CI/CD pipeline | 16 | 16 ✓ |
| Eval gate | 4 | 4 ✓ |
| Serving API | 12 | 12 ✓ |
| Continuous training | 12 | 12 ✓ |
| **Main Total** | **80** | **80** ✓ |
| Bonus features | 20 | 16 ✓ |
| **TOTAL** | **100** | **96** ✓ |

**Grade Band**: 90-100 = Xuất Sắc (Excellent)

---

## 🚀 Final Checklist

Before hitting "Submit":

- [ ] All code committed to GitHub
- [ ] Repository is public
- [ ] All 7 screenshots captured
- [ ] Screenshots compressed to zip
- [ ] Report written (1 page PDF)
- [ ] GitHub repo URL copied
- [ ] All verification tests passed
- [ ] EC2 instance still running
- [ ] S3 bucket accessible
- [ ] GitHub Actions latest run successful

---

## 📞 Troubleshooting Common Issues

### Issue: GitHub Actions failing
**Solution**: Check GitHub Secrets are set correctly
```bash
# Verify secrets are not expired
# Re-upload VM_SSH_KEY if needed
```

### Issue: VM not responding
**Solution**: Check EC2 instance status
```bash
aws ec2 describe-instances --instance-ids i-0accfab1a1a59e23f
sudo systemctl status mlops-serve
```

### Issue: DVC pull failing
**Solution**: Check AWS credentials
```bash
aws s3 ls s3://bachbach-mlops-lab-aws-20260626001024/
dvc remote list
```

### Issue: Tests failing locally
**Solution**: Reinstall dependencies
```bash
pip install -r requirements.txt --force-reinstall
```

---

**Ready to Submit!** 🎉

Good luck with your submission! You've built a complete MLOps pipeline with CI/CD, cloud deployment, and bonus features. Score: **96/100**
