#!/system/bin/sh

# ECH Workers KSU 模块升级脚本

set -e

MODDIR=${0%/*}
SYSTEM_BIN=/system/bin
ECH_WORKERS_BIN=ech-workers
SERVICE_SCRIPT=/data/adb/service.d/ech-workers.sh

# 停止 ECH Workers 服务
echo "[ECH Workers] 正在停止服务..."
pkill -f "$ECH_WORKERS_BIN" || true

# 更新可执行文件
echo "[ECH Workers] 正在更新可执行文件..."
cp "$MODDIR/system/bin/$ECH_WORKERS_BIN" "$SYSTEM_BIN/"
chmod 755 "$SYSTEM_BIN/$ECH_WORKERS_BIN"

# 重启服务
echo "[ECH Workers] 正在重启服务..."
"$SERVICE_SCRIPT"

echo "[ECH Workers] 升级完成！"
