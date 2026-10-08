#!/bin/bash
# mambonami/scripts/deploy.sh – systemd version

# ~/apps/mambonami/scripts/deploy.sh
# sudo journalctl -u gunicorn -f
# sudo journalctl -u fastapi -f

set -e

PROJECT_DIR="/home/dante/apps/mambonami"
BACKEND_DIR="$PROJECT_DIR/backend"
DJANGO_DIR="$BACKEND_DIR/django_admin"
VENV_DIR="$BACKEND_DIR/venv"
MANAGE_PY="$DJANGO_DIR/manage.py"
BACKUP_DIR="$PROJECT_DIR/backups"
DB_NAME="mambonami"
REQUIREMENTS="$BACKEND_DIR/requirements/prod.txt"

echo "🚀 Starting deployment for MAMBONAMI (systemd)..."

cd "$PROJECT_DIR" || { echo "❌ Project directory not found"; exit 1; }

# Gunicorn/Django must see the workspace root so `shared` is importable.
export PYTHONPATH="$PROJECT_DIR:$DJANGO_DIR${PYTHONPATH:+:$PYTHONPATH}"
export DJANGO_SETTINGS_MODULE="config.settings.prod"

# Git pull
echo "📦 Pulling latest code..."
git pull origin main || echo "⚠️  Git pull failed – continuing with current code"

# Backup directory
mkdir -p "$BACKUP_DIR"

# Check database existence
if ! sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
    echo "❌ Database '$DB_NAME' does not exist. Aborting."
    exit 1
fi

# Backup database
echo "💾 Creating database backup..."
BACKUP_FILE="$BACKUP_DIR/mambonami_backup_$(date +%Y%m%d_%H%M%S).dump"
sudo -u postgres pg_dump -Fc "$DB_NAME" > "$BACKUP_FILE" || {
    echo "❌ Database backup failed! Aborting deployment."
    exit 1
}
echo "✅ Database backup saved to: $BACKUP_FILE"

# Keep only last 10 backups
ls -1t "$BACKUP_DIR"/mambonami_backup_*.dump 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true

# Update dependencies
echo "📦 Updating Python dependencies..."
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install -r "$REQUIREMENTS"

# Migrate
echo "🗄️  Running database migrations..."
"$VENV_DIR/bin/python" "$MANAGE_PY" migrate

# Collect static
echo "📁 Collecting static files..."
"$VENV_DIR/bin/python" "$MANAGE_PY" collectstatic --noinput

# Restart services
echo "🔄 Restarting Gunicorn..."
sudo systemctl restart gunicorn
echo "🔄 Restarting FastAPI..."
sudo systemctl restart fastapi
echo "🔄 Restarting Celery..."
sudo systemctl restart celery
echo "🔄 Reloading Nginx..."
sudo nginx -t
sudo systemctl reload nginx

# Status check
echo "✅ Deployment complete! Checking service statuses..."
sudo systemctl status gunicorn --no-pager --lines=0
sudo systemctl status fastapi --no-pager --lines=0
sudo systemctl status celery --no-pager --lines=0
sudo systemctl status nginx --no-pager --lines=0

echo "🎉 All services restarted successfully."
