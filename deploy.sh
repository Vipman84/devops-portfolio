#!/bin/bash
set -e
REPO_DIR="$HOME/devops-portfolio"
SITE_DIR="$REPO_DIR/site"
TARGET_IP="45.90.218.165"
TARGET_USER="root"
TARGET_PATH="/var/www/textbook"

echo "=== Pulling latest changes from GitHub ==="
cd "$REPO_DIR"
git pull origin main

echo "=== Building Hugo site ==="
cd "$SITE_DIR"
hugo --minify

echo "=== Packaging and deploying ==="
tar -czf public.tar.gz public/
scp public.tar.gz ${TARGET_USER}@${TARGET_IP}:${TARGET_PATH}/
ssh ${TARGET_USER}@${TARGET_IP} "cd ${TARGET_PATH} && rm -rf html && tar -xzf public.tar.gz && mv public html && rm public.tar.gz"

echo "=== Done! Site updated. ==="
