#!/usr/bin/env python3
"""
Test DagsHub MLflow Connection (Bonus 1)
Verifies that MLflow can connect to DagsHub remote tracking server
"""

import os
import sys

def test_dagshub_connection():
    """Test connection to DagsHub MLflow tracking server"""
    
    print("\n" + "=" * 60)
    print("🎁 BONUS 1: Testing DagsHub MLflow Connection")
    print("=" * 60 + "\n")
    
    # Check environment variables
    required_vars = [
        'MLFLOW_TRACKING_URI',
        'MLFLOW_TRACKING_USERNAME',
        'MLFLOW_TRACKING_PASSWORD'
    ]
    
    missing_vars = []
    for var in required_vars:
        value = os.environ.get(var)
        if value:
            # Mask password
            if 'PASSWORD' in var or 'TOKEN' in var:
                display_value = value[:4] + '*' * (len(value) - 4)
            else:
                display_value = value
            print(f"✓ {var}: {display_value}")
        else:
            print(f"✗ {var}: NOT SET")
            missing_vars.append(var)
    
    if missing_vars:
        print(f"\n❌ Missing environment variables: {', '.join(missing_vars)}")
        print("\nPlease set them using:")
        print("  export MLFLOW_TRACKING_URI=https://dagshub.com/<user>/<repo>.mlflow")
        print("  export MLFLOW_TRACKING_USERNAME=<username>")
        print("  export MLFLOW_TRACKING_PASSWORD=<token>")
        return False
    
    # Try to import mlflow
    try:
        import mlflow
        print("\n✓ MLflow imported successfully")
    except ImportError:
        print("\n✗ MLflow not installed")
        print("  pip install mlflow")
        return False
    
    # Test connection
    try:
        print("\n" + "-" * 60)
        print("Testing connection to DagsHub...")
        print("-" * 60)
        
        tracking_uri = os.environ.get('MLFLOW_TRACKING_URI')
        mlflow.set_tracking_uri(tracking_uri)
        
        # Try to get or create experiment
        experiment_name = "dagshub-connection-test"
        experiment = mlflow.get_experiment_by_name(experiment_name)
        
        if experiment is None:
            experiment_id = mlflow.create_experiment(experiment_name)
            print(f"✓ Created experiment: {experiment_name}")
        else:
            experiment_id = experiment.experiment_id
            print(f"✓ Found experiment: {experiment_name}")
        
        # Create a test run
        with mlflow.start_run(experiment_id=experiment_id, run_name="connection-test"):
            mlflow.log_param("test", "dagshub_connection")
            mlflow.log_metric("test_metric", 1.0)
            print("✓ Logged test parameters and metrics")
            
            run = mlflow.active_run()
            run_id = run.info.run_id
            print(f"✓ Run ID: {run_id}")
        
        print("\n" + "=" * 60)
        print("✅ SUCCESS: Connected to DagsHub!")
        print("=" * 60)
        print(f"\nView your experiment at:")
        print(f"  {tracking_uri.replace('.mlflow', '')}")
        print("\n")
        
        return True
        
    except Exception as e:
        print("\n" + "=" * 60)
        print("❌ FAILED: Could not connect to DagsHub")
        print("=" * 60)
        print(f"\nError: {e}")
        print("\nTroubleshooting:")
        print("1. Check your credentials are correct")
        print("2. Verify the tracking URI format:")
        print("   https://dagshub.com/<username>/<repo>.mlflow")
        print("3. Make sure you have internet connection")
        print("4. Check DagsHub is accessible: https://dagshub.com")
        print("\n")
        return False


def test_local_vs_remote():
    """Compare local SQLite tracking vs DagsHub remote tracking"""
    
    print("\n" + "=" * 60)
    print("📊 Comparison: Local vs Remote Tracking")
    print("=" * 60 + "\n")
    
    tracking_uri = os.environ.get('MLFLOW_TRACKING_URI', 'sqlite:///mlflow.db')
    
    if 'dagshub.com' in tracking_uri:
        print("Current Mode: 🌐 REMOTE (DagsHub)")
        print(f"  URI: {tracking_uri}")
        print("\n✅ Advantages:")
        print("  • Accessible from anywhere")
        print("  • Team collaboration")
        print("  • No local storage needed")
        print("  • Automatic backups")
        print("  • Beautiful UI")
        print("\n⚠️  Considerations:")
        print("  • Requires internet connection")
        print("  • Credentials management")
    else:
        print("Current Mode: 💻 LOCAL (SQLite)")
        print(f"  URI: {tracking_uri}")
        print("\n✅ Advantages:")
        print("  • No internet required")
        print("  • Fast local access")
        print("  • No credentials needed")
        print("\n⚠️  Limitations:")
        print("  • Only accessible locally")
        print("  • No team collaboration")
        print("  • Manual backups needed")
    
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    # Test connection
    success = test_dagshub_connection()
    
    # Show comparison
    test_local_vs_remote()
    
    sys.exit(0 if success else 1)
