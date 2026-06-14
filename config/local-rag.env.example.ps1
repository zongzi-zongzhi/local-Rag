# Copy this file to local-rag.env.ps1 and edit paths for your machine.

# BASE_DIR is kept for compatibility.
$env:BASE_DIR = "D:\Your\Documents"

# BASE_DIRS is the multi-folder source of truth.
$env:BASE_DIRS = '["D:\\Your\\Documents","E:\\More\\Documents"]'

$env:DB_PATH = "D:\GitHub\local-Rag\lancedb"
$env:CACHE_DIR = "D:\GitHub\local-Rag\models"
