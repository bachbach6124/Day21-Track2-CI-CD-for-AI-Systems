import mlflow
import mlflow.sklearn
import pandas as pd
import yaml
import json
import joblib
import os
from sklearn.ensemble import RandomForestClassifier
from sklearn.ensemble import ExtraTreesClassifier
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, f1_score, confusion_matrix, classification_report
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

EVAL_THRESHOLD = 0.70


def build_model(params: dict):
    params = params.copy()
    model_type = params.pop("model_type", "random_forest")

    if model_type == "random_forest":
        return RandomForestClassifier(**params, random_state=42, n_jobs=-1)
    if model_type == "extra_trees":
        return ExtraTreesClassifier(**params, random_state=42, n_jobs=-1)
    if model_type == "gradient_boosting":
        return GradientBoostingClassifier(**params, random_state=42)
    if model_type == "logistic_regression":
        return make_pipeline(
            StandardScaler(),
            LogisticRegression(**params, random_state=42, max_iter=1000),
        )

    raise ValueError(f"Unsupported model_type: {model_type}")


def train(
    params: dict,
    data_path: str = "data/train_phase1.csv",
    eval_path: str = "data/eval.csv",
) -> float:
    """Train a classifier, log metrics to MLflow, and save deploy artifacts."""
    df_train = pd.read_csv(data_path)
    df_eval = pd.read_csv(eval_path)

    X_train = df_train.drop(columns=["target"])
    y_train = df_train["target"]
    X_eval = df_eval.drop(columns=["target"])
    y_eval = df_eval["target"]

    # BONUS 5: Check data distribution and warn about class imbalance
    class_counts = y_train.value_counts()
    total_samples = len(y_train)
    class_distribution = {}
    
    print("\n" + "=" * 60)
    print("DATA DISTRIBUTION ANALYSIS")
    print("=" * 60)
    
    for class_id in [0, 1, 2]:
        count = class_counts.get(class_id, 0)
        percentage = (count / total_samples) * 100
        class_distribution[f"class_{class_id}_percentage"] = percentage
        
        class_name = {0: "Low", 1: "Medium", 2: "High"}[class_id]
        print(f"Class {class_id} ({class_name:6s}): {count:4d} samples ({percentage:5.2f}%)")
        
        # Warning if class < 10%
        if percentage < 10.0:
            warning_msg = f"⚠️  WARNING: Class {class_id} ({class_name}) has only {percentage:.2f}% of samples (< 10% threshold)"
            print(warning_msg)
    
    print("=" * 60 + "\n")

    with mlflow.start_run():
        mlflow.log_params(params)

        model = build_model(params)
        model.fit(X_train, y_train)

        preds = model.predict(X_eval)
        acc = accuracy_score(y_eval, preds)
        f1 = f1_score(y_eval, preds, average="weighted")

        mlflow.log_metric("accuracy", acc)
        mlflow.log_metric("f1_score", f1)
        mlflow.sklearn.log_model(model, "model")

        print(f"Accuracy: {acc:.4f} | F1: {f1:.4f}")

        # BONUS 3: Generate performance report
        cm = confusion_matrix(y_eval, preds)
        report = classification_report(y_eval, preds, target_names=["low", "medium", "high"])
        
        # Create detailed report
        os.makedirs("outputs", exist_ok=True)
        with open("outputs/report.txt", "w") as f:
            f.write("=" * 60 + "\n")
            f.write("WINE QUALITY CLASSIFICATION - PERFORMANCE REPORT\n")
            f.write("=" * 60 + "\n\n")
            
            f.write(f"Model Type: {params.get('model_type', 'random_forest')}\n")
            f.write(f"Overall Accuracy: {acc:.4f}\n")
            f.write(f"Weighted F1-Score: {f1:.4f}\n\n")
            
            f.write("-" * 60 + "\n")
            f.write("CONFUSION MATRIX\n")
            f.write("-" * 60 + "\n")
            f.write("              Predicted\n")
            f.write("              Low  Medium  High\n")
            f.write(f"Actual Low    {cm[0][0]:>4} {cm[0][1]:>6} {cm[0][2]:>6}\n")
            f.write(f"       Medium {cm[1][0]:>4} {cm[1][1]:>6} {cm[1][2]:>6}\n")
            f.write(f"       High   {cm[2][0]:>4} {cm[2][1]:>6} {cm[2][2]:>6}\n\n")
            
            f.write("-" * 60 + "\n")
            f.write("CLASSIFICATION REPORT (Precision, Recall, F1-Score)\n")
            f.write("-" * 60 + "\n")
            f.write(report)
            f.write("\n")

        print("Performance report saved to outputs/report.txt")

        os.makedirs("outputs", exist_ok=True)
        with open("outputs/metrics.json", "w") as f:
            metrics_data = {
                "accuracy": acc, 
                "f1_score": f1,
                "class_distribution": class_distribution  # BONUS 5: Add distribution
            }
            json.dump(metrics_data, f, indent=2)

        os.makedirs("models", exist_ok=True)
        joblib.dump(model, "models/model.pkl", compress=3)

        return acc


if __name__ == "__main__":
    with open("params.yaml") as f:
        params = yaml.safe_load(f)
    train(params)
