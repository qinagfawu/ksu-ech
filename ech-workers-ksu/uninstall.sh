#!/system/bin/sh

# ECH Workers KSU 模块卸载脚本

set -e

SYSTEM_BIN=/system/bin
ECH_WORKERS_BIN=ech-workers
CONFIG_DIR=/data/adb/ech-workers
SERVICE_SCRIPT=/data/adb/service.d/ech-workers.sh

# 停止 ECH Workers 服务
echo "[ECH Workers] 正在停止服务..."
pkill -f "$ECH_WORKERS_BIN" || true

# 删除服务启动脚本
echo "[ECH Workers] 正在删除服务启动脚本..."
rm -f "$SERVICE_SCRIPT"

# 删除可执行文件
echo "[ECH Workers] 正在删除可执行文件..."
rm -f "$SYSTEM_BIN/$ECH_WORKERS_BIN"

# 删除配置目录
echo "[ECH Workers] 正在删除配置目录..."
rm -rf "$CONFIG_DIR"

echo "[ECH Workers] 卸载完成！"
