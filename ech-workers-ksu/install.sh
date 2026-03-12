#!/system/bin/sh

# ECH Workers KSU 模块安装脚本

# 不使用 set -e，以便在遇到错误时继续执行

MODDIR=${0%/*}
SYSTEM_BIN=/system/bin
ECH_WORKERS_BIN=ech-workers
CONFIG_DIR=/data/adb/ech-workers
SERVICE_SCRIPT=/data/adb/service.d/ech-workers.sh

# 检查并创建必要的目录
echo "[ECH Workers] 正在检查必要的目录..."
mkdir -p "$SYSTEM_BIN"
mkdir -p "$CONFIG_DIR"
mkdir -p "/data/adb/service.d"

# 复制可执行文件到系统目录
echo "[ECH Workers] 正在安装可执行文件..."
if [ -f "$MODDIR/system/bin/$ECH_WORKERS_BIN" ]; then
    cp "$MODDIR/system/bin/$ECH_WORKERS_BIN" "$SYSTEM_BIN/"
    chmod 755 "$SYSTEM_BIN/$ECH_WORKERS_BIN"
    echo "[ECH Workers] 可执行文件安装成功"
else
    echo "[ECH Workers] 错误: 可执行文件不存在"
    exit 1
fi

# 复制 IP 列表文件（如果存在）
echo "[ECH Workers] 正在复制 IP 列表文件..."
if [ -f "$MODDIR/system/bin/chn_ip.txt" ]; then
    cp "$MODDIR/system/bin/chn_ip.txt" "$CONFIG_DIR/"
    echo "[ECH Workers] IPv4 列表复制成功"
else
    echo "[ECH Workers] 警告: IPv4 列表文件不存在，将在运行时下载"
fi

if [ -f "$MODDIR/system/bin/chn_ip_v6.txt" ]; then
    cp "$MODDIR/system/bin/chn_ip_v6.txt" "$CONFIG_DIR/"
    echo "[ECH Workers] IPv6 列表复制成功"
else
    echo "[ECH Workers] 警告: IPv6 列表文件不存在，将在运行时下载"
fi

# 创建服务启动脚本
echo "[ECH Workers] 正在创建服务启动脚本..."
cat > "$SERVICE_SCRIPT" << 'EOF'
#!/system/bin/sh

# ECH Workers 服务启动脚本

ECH_WORKERS_BIN=/system/bin/ech-workers
CONFIG_DIR=/data/adb/ech-workers

# 确保配置目录存在
mkdir -p "$CONFIG_DIR"

# 启动 ECH Workers 服务
$ECH_WORKERS_BIN -l 0.0.0.0:30000 -routing bypass_cn > "$CONFIG_DIR/ech-workers.log" 2>&1 &
echo "[ECH Workers] 服务已启动"
EOF

chmod 755 "$SERVICE_SCRIPT"
echo "[ECH Workers] 服务启动脚本创建成功"

# 启动服务
echo "[ECH Workers] 正在启动服务..."
"$SERVICE_SCRIPT"
echo "[ECH Workers] 服务启动成功"

# 启动 WebUI 服务器
echo "[ECH Workers] 正在启动 WebUI 服务器..."
if [ -f "$MODDIR/webui-server.sh" ]; then
    chmod 755 "$MODDIR/webui-server.sh"
    "$MODDIR/webui-server.sh"
    echo "[ECH Workers] WebUI 服务器启动成功"
else
    echo "[ECH Workers] 警告: WebUI 服务器脚本不存在"
fi

echo "[ECH Workers] 安装完成！"
echo "[ECH Workers] 代理服务已启动，监听地址: 0.0.0.0:30000"
echo "[ECH Workers] 分流模式: 跳过中国大陆"
echo "[ECH Workers] 注意: WebUI 服务可能需要网络连接才能访问"

