#!/usr/bin/env python3
"""
Test script for BONUS 4: Model Rollback
Demonstrates model comparison and deployment decision logic
"""

import json
import os

def test_model_rollback():
    """Test the model rollback mechanism"""
    
    print("\n" + "=" * 70)
    print("BONUS 4: MODEL ROLLBACK TEST")
    print("=" * 70)
    
    # Scenario 1: First deployment (no previous model)
    print("\n📋 SCENARIO 1: First Deployment")
    print("-" * 70)
    prev_acc = 0.0
    new_acc = 0.7680
    print(f"Previous model accuracy: {prev_acc:.4f} (no previous model)")
    print(f"New model accuracy:      {new_acc:.4f}")
    print(f"Decision: DEPLOY (first model)")
    
    # Scenario 2: New model is better
    print("\n📋 SCENARIO 2: New Model is Better")
    print("-" * 70)
    prev_acc = 0.7680
    new_acc = 0.8100
    improvement = new_acc - prev_acc
    print(f"Previous model accuracy: {prev_acc:.4f}")
    print(f"New model accuracy:      {new_acc:.4f}")
    print(f"Improvement:             {improvement:+.4f}")
    if new_acc >= prev_acc:
        print("✅ Decision: DEPLOY (new model is better)")
    
    # Scenario 3: New model is equal
    print("\n📋 SCENARIO 3: New Model is Equal")
    print("-" * 70)
    prev_acc = 0.7680
    new_acc = 0.7680
    improvement = new_acc - prev_acc
    print(f"Previous model accuracy: {prev_acc:.4f}")
    print(f"New model accuracy:      {new_acc:.4f}")
    print(f"Improvement:             {improvement:+.4f}")
    if new_acc >= prev_acc:
        print("✅ Decision: DEPLOY (new model is equal, allow refresh)")
    
    # Scenario 4: New model is worse (ROLLBACK)
    print("\n📋 SCENARIO 4: New Model is Worse (ROLLBACK)")
    print("-" * 70)
    prev_acc = 0.7680
    new_acc = 0.6500
    improvement = new_acc - prev_acc
    print(f"Previous model accuracy: {prev_acc:.4f}")
    print(f"New model accuracy:      {new_acc:.4f}")
    print(f"Improvement:             {improvement:+.4f}")
    if new_acc < prev_acc:
        print("❌ Decision: SKIP DEPLOY (new model is worse)")
        print("⚠️  ROLLBACK: Keep previous model in production")
    
    # Test with actual metrics.json
    print("\n📋 CURRENT MODEL METRICS")
    print("-" * 70)
    if os.path.exists("outputs/metrics.json"):
        with open("outputs/metrics.json") as f:
            current_metrics = json.load(f)
        print(f"Current accuracy:  {current_metrics['accuracy']:.4f}")
        print(f"Current f1_score:  {current_metrics['f1_score']:.4f}")
        
        # Show class distribution (BONUS 5)
        if "class_distribution" in current_metrics:
            print("\nClass Distribution (BONUS 5):")
            dist = current_metrics["class_distribution"]
            for class_id in [0, 1, 2]:
                key = f"class_{class_id}_percentage"
                if key in dist:
                    pct = dist[key]
                    status = "⚠️ IMBALANCED" if pct < 10.0 else "✓"
                    print(f"  Class {class_id}: {pct:5.2f}% {status}")
    else:
        print("No metrics.json found. Run training first.")
    
    print("\n" + "=" * 70)
    print("How it works in GitHub Actions:")
    print("=" * 70)
    print("1. Train job downloads previous metrics.json from S3")
    print("2. Compares new model accuracy with previous accuracy")
    print("3. Sets output: should_deploy=true/false")
    print("4. If should_deploy=false:")
    print("   - Skips S3 upload (keeps old model)")
    print("   - Skips eval job")
    print("   - Skips deploy job")
    print("5. Production continues serving the previous (better) model")
    print("=" * 70 + "\n")

if __name__ == "__main__":
    test_model_rollback()
