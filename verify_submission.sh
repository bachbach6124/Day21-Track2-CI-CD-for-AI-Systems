#!/bin/bash
# Submission Verification Script
# Run this before submitting to ensure everything is ready

set -e

echo "=========================================="
echo "🔍 MLOps Lab - Submission Verification"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS=0
FAIL=0

check_pass() {
    echo -e "${GREEN}✓ $1${NC}"
    ((PASS++))
}

check_fail() {
    echo -e "${RED}✗ $1${NC}"
    ((FAIL++))
}

check_warn() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

echo "=========================================="
echo "📁 1. CHECKING FILES"
echo "=========================================="

# Check critical files
files=(
    "src/train.py"
    "src/serve.py"
    "tests/test_train.py"
    ".github/workflows/mlops.yml"
    "params.yaml"
    "requirements.txt"
    ".gitignore"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        check_pass "$file exists"
    else
        check_fail "$file missing"
    fi
done

echo ""
echo "=========================================="
echo "📊 2. CHECKING OUTPUTS"
echo "=========================================="

# Check output files
if [ -f "outputs/metrics.json" ]; then
    check_pass "metrics.json exists"
    
    # Check if contains required fields
    if grep -q "accuracy" outputs/metrics.json && grep -q "f1_score" outputs/metrics.json; then
        check_pass "metrics.json has accuracy & f1_score"
    else
        check_fail "metrics.json missing required fields"
    fi
    
    # Check for bonus feature (class_distribution)
    if grep -q "class_distribution" outputs/metrics.json; then
        check_pass "BONUS 5: class_distribution in metrics.json"
    else
        check_warn "BONUS 5: class_distribution not in metrics.json"
    fi
else
    check_fail "outputs/metrics.json missing"
fi

if [ -f "outputs/report.txt" ]; then
    check_pass "BONUS 3: report.txt exists"
else
    check_warn "BONUS 3: report.txt missing"
fi

if [ -f "models/model.pkl" ]; then
    size=$(ls -lh models/model.pkl | awk '{print $5}')
    check_pass "model.pkl exists (size: $size)"
else
    check_fail "models/model.pkl missing"
fi

echo ""
echo "=========================================="
echo "🗄️ 3. CHECKING DVC FILES"
echo "=========================================="

dvc_files=(
    "data/train_phase1.csv.dvc"
    "data/eval.csv.dvc"
    "data/train_phase2.csv.dvc"
)

for file in "${dvc_files[@]}"; do
    if [ -f "$file" ]; then
        check_pass "$file exists"
    else
        check_fail "$file missing"
    fi
done

echo ""
echo "=========================================="
echo "🧪 4. RUNNING TESTS"
echo "=========================================="

# Activate venv if exists
if [ -d ".venv" ]; then
    source .venv/bin/activate
    check_pass "Virtual environment activated"
else
    check_warn "Virtual environment not found"
fi

# Run pytest
if command -v pytest &> /dev/null; then
    echo "Running pytest..."
    if pytest tests/ -v --tb=short &> /dev/null; then
        check_pass "All unit tests passed"
    else
        check_fail "Some unit tests failed"
        pytest tests/ -v --tb=short
    fi
else
    check_warn "pytest not installed"
fi

echo ""
echo "=========================================="
echo "🔬 5. CHECKING MLflow"
echo "=========================================="

if [ -f "mlflow.db" ]; then
    check_pass "MLflow database exists"
    
    # Count experiments
    if [ -d "mlruns/0" ]; then
        run_count=$(find mlruns/0 -mindepth 1 -maxdepth 1 -type d ! -name "meta.yaml" | wc -l)
        if [ "$run_count" -ge 3 ]; then
            check_pass "MLflow has $run_count runs (required: >= 3)"
        else
            check_fail "MLflow has only $run_count runs (required: >= 3)"
        fi
    fi
else
    check_fail "mlflow.db not found"
fi

echo ""
echo "=========================================="
echo "🎁 6. CHECKING BONUS FEATURES"
echo "=========================================="

# Bonus 2: Multi-algorithm
if grep -q "model_type" src/train.py && grep -q "build_model" src/train.py; then
    check_pass "BONUS 2: Multi-algorithm support detected"
else
    check_warn "BONUS 2: Multi-algorithm support not detected"
fi

# Bonus 3: Performance report
if grep -q "confusion_matrix" src/train.py && grep -q "classification_report" src/train.py; then
    check_pass "BONUS 3: Performance report code detected"
else
    check_warn "BONUS 3: Performance report code not detected"
fi

# Bonus 4: Model rollback
if grep -q "should_deploy" .github/workflows/mlops.yml && grep -q "compare_metrics" .github/workflows/mlops.yml; then
    check_pass "BONUS 4: Model rollback logic detected"
else
    check_warn "BONUS 4: Model rollback logic not detected"
fi

# Bonus 5: Data distribution
if grep -q "class_distribution" src/train.py && grep -q "WARNING" src/train.py; then
    check_pass "BONUS 5: Data distribution warning detected"
else
    check_warn "BONUS 5: Data distribution warning not detected"
fi

echo ""
echo "=========================================="
echo "☁️ 7. CHECKING CLOUD RESOURCES"
echo "=========================================="

# Check if AWS CLI is available
if command -v aws &> /dev/null; then
    check_pass "AWS CLI installed"
    
    # Try to list S3 bucket (if credentials are configured)
    if [ ! -z "$S3_BUCKET" ] || grep -q "S3_BUCKET" .env 2>/dev/null; then
        check_pass "S3_BUCKET configured"
    else
        check_warn "S3_BUCKET not set (check .env or GitHub Secrets)"
    fi
else
    check_warn "AWS CLI not installed"
fi

# Check VM endpoint (if configured)
if [ -f "submission/checklist.md" ]; then
    VM_HOST=$(grep "VM host:" submission/checklist.md | awk '{print $3}' | head -1)
    if [ ! -z "$VM_HOST" ]; then
        echo "Testing VM endpoint: $VM_HOST:8000/health"
        if curl -sf "http://$VM_HOST:8000/health" &> /dev/null; then
            check_pass "VM /health endpoint responding"
        else
            check_fail "VM /health endpoint not responding"
        fi
    else
        check_warn "VM host not found in checklist"
    fi
else
    check_warn "submission/checklist.md not found"
fi

echo ""
echo "=========================================="
echo "📦 8. CHECKING GIT STATUS"
echo "=========================================="

if [ -d ".git" ]; then
    check_pass "Git repository initialized"
    
    # Check if there are uncommitted changes
    if [ -z "$(git status --porcelain)" ]; then
        check_pass "No uncommitted changes"
    else
        check_warn "You have uncommitted changes:"
        git status --short | head -10
    fi
    
    # Check remote
    if git remote -v | grep -q "github.com"; then
        check_pass "GitHub remote configured"
    else
        check_fail "GitHub remote not configured"
    fi
else
    check_fail "Not a git repository"
fi

echo ""
echo "=========================================="
echo "📄 9. CHECKING DOCUMENTATION"
echo "=========================================="

docs=(
    "README.md"
    "BONUS_FEATURES.md"
    "FINAL_SUMMARY.md"
    "SUBMISSION_CHECKLIST.md"
)

for doc in "${docs[@]}"; do
    if [ -f "$doc" ]; then
        check_pass "$doc exists"
    else
        check_warn "$doc not found"
    fi
done

echo ""
echo "=========================================="
echo "📊 SUMMARY"
echo "=========================================="

echo ""
echo -e "${GREEN}Passed checks: $PASS${NC}"
echo -e "${RED}Failed checks: $FAIL${NC}"

echo ""
if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}=========================================="
    echo "✅ READY TO SUBMIT!"
    echo "==========================================${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Capture required screenshots (see SUBMISSION_CHECKLIST.md)"
    echo "2. Write 1-page report"
    echo "3. Commit and push all changes to GitHub"
    echo "4. Verify GitHub Actions runs successfully"
    echo "5. Submit repo URL + screenshots + report"
    echo ""
    echo "Expected Score: 96/100 (80 main + 16 bonus)"
else
    echo -e "${RED}=========================================="
    echo "⚠️  FIX ISSUES BEFORE SUBMITTING"
    echo "==========================================${NC}"
    echo ""
    echo "Please fix the failed checks above before submitting."
fi

echo ""
echo "=========================================="
echo "🔗 USEFUL COMMANDS"
echo "=========================================="
echo ""
echo "View MLflow UI:"
echo "  mlflow ui --backend-store-uri sqlite:///mlflow.db"
echo ""
echo "Test bonus features:"
echo "  ./test_all_bonus.sh"
echo ""
echo "Check GitHub Actions:"
echo "  gh run list --limit 5"
echo ""
echo "Test VM endpoints:"
echo "  curl http://\$VM_HOST:8000/health"
echo "  curl -X POST http://\$VM_HOST:8000/predict -H 'Content-Type: application/json' -d '{\"features\":[...]}'"
echo ""
echo "=========================================="
