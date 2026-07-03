#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") <BACKUP_DIR> <KEEP_COUNT>"
  echo "  BACKUP_DIR : Directory path to store backup files"
  echo "  KEEP_COUNT : Number of backup generations to keep (e.g. 30)"
  echo ""
  echo "Example:"
  echo "  $(basename "$0") \"\$HOME/Library/CloudStorage/GoogleDrive-you@example.com/My Drive/backups/db/postgresql-docker\" 30"
  exit 1
}

if [ $# -ne 2 ]; then
  usage
fi

BACKUP_DIR="$1"
KEEP_COUNT="$2"

if ! [[ "${KEEP_COUNT}" =~ ^[0-9]+$ ]]; then
  echo "Error: KEEP_COUNT must be a positive integer." >&2
  usage
fi

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"

mkdir -p "${BACKUP_DIR}"

cd "${PROJECT_DIR}"

set -a
source .env
set +a

BACKUP_FILE="${BACKUP_DIR}/${POSTGRES_DB}_${TIMESTAMP}.dump"

# コンテナ内にダンプを作成
docker compose exec -T postgresql pg_dump \
  -U "${POSTGRES_USER}" \
  -d "${POSTGRES_DB}" \
  -F c \
  -f "/tmp/${POSTGRES_DB}_${TIMESTAMP}.dump"

# コンテナから指定先へコピー
docker compose cp \
  "postgresql:/tmp/${POSTGRES_DB}_${TIMESTAMP}.dump" \
  "${BACKUP_FILE}"

# コンテナ内の一時ファイルを削除
docker compose exec -T postgresql rm \
  "/tmp/${POSTGRES_DB}_${TIMESTAMP}.dump"

echo "Backup created: ${BACKUP_FILE}"

# --- ローテーション処理 ---
cd "${BACKUP_DIR}"
ls -1t ./*.dump 2>/dev/null | tail -n +$((KEEP_COUNT + 1)) | while read -r old_file; do
  echo "Removing old backup: ${old_file}"
  rm -f "${old_file}"
done

echo "Backup rotation completed. Current backup count: $(ls -1 ./*.dump 2>/dev/null | wc -l | tr -d ' ')"