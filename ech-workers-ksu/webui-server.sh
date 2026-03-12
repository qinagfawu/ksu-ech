#!/system/bin/sh

# ECH Workers WebUI 服务器脚本

set -e

MODDIR=${0%/*}
WEBUI_DIR="$MODDIR/webui"
CONFIG_DIR="/data/adb/ech-workers"
ECH_WORKERS_BIN="/system/bin/ech-workers"

# 确保配置目录存在
mkdir -p "$CONFIG_DIR"

# 启动 WebUI 服务器
echo "[ECH Workers] 正在启动 WebUI 服务器..."

# 使用 busybox httpd 或 Python 启动服务器
if command -v busybox > /dev/null; then
    # 使用 busybox httpd
    busybox httpd -p 8080 -h "$WEBUI_DIR"
    echo "[ECH Workers] WebUI 服务器已启动，监听端口: 8080"
elif command -v python3 > /dev/null; then
    # 使用 Python 3
    python3 -m http.server 8080 --directory "$WEBUI_DIR" > "$CONFIG_DIR/webui.log" 2>&1 &
    echo "[ECH Workers] WebUI 服务器已启动，监听端口: 8080"
elif command -v python > /dev/null; then
    # 使用 Python 2
    python -m SimpleHTTPServer 8080 --directory "$WEBUI_DIR" > "$CONFIG_DIR/webui.log" 2>&1 &
    echo "[ECH Workers] WebUI 服务器已启动，监听端口: 8080"
else
    echo "[ECH Workers] 无法启动 WebUI 服务器，未找到 busybox 或 Python"
    exit 1
fi

# 创建 API 处理脚本
echo "[ECH Workers] 正在创建 API 处理脚本..."
cat > "$WEBUI_DIR/api.sh" << 'EOF'
#!/system/bin/sh

CONFIG_DIR="/data/adb/ech-workers"
ECH_WORKERS_BIN="/system/bin/ech-workers"
CONFIG_FILE="$CONFIG_DIR/config.json"

# 确保配置目录存在
mkdir -p "$CONFIG_DIR"

# 确保配置文件存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo '{"serverAddr": "", "listenAddr": "0.0.0.0:30000", "token": "", "routingMode": "bypass_cn"}' > "$CONFIG_FILE"
fi

# 处理 API 请求
case "$1" in
    "status")
        # 检查服务状态
        if pgrep -f "$ECH_WORKERS_BIN" > /dev/null; then
            echo '{"running": true}'
        else
            echo '{"running": false}'
        fi
        ;;
    "start")
        # 启动服务
        if pgrep -f "$ECH_WORKERS_BIN" > /dev/null; then
            echo '{"success": false, "error": "服务已运行"}'
            exit 1
        fi
        
        # 读取配置
        SERVER_ADDR=$(jq -r '.serverAddr' "$CONFIG_FILE")
        LISTEN_ADDR=$(jq -r '.listenAddr' "$CONFIG_FILE")
        TOKEN=$(jq -r '.token' "$CONFIG_FILE")
        ROUTING_MODE=$(jq -r '.routingMode' "$CONFIG_FILE")
        
        if [ -z "$SERVER_ADDR" ]; then
            echo '{"success": false, "error": "服务端地址未配置"}'
            exit 1
        fi
        
        # 启动服务
        $ECH_WORKERS_BIN -f "$SERVER_ADDR" -l "$LISTEN_ADDR" -token "$TOKEN" -routing "$ROUTING_MODE" > "$CONFIG_DIR/ech-workers.log" 2>&1 &
        echo '{"success": true}'
        ;;
    "stop")
        # 停止服务
        pkill -f "$ECH_WORKERS_BIN" || true
        echo '{"success": true}'
        ;;
    "save-config")
        # 保存配置
        read -r JSON
        echo "$JSON" > "$CONFIG_FILE"
        echo '{"success": true}'
        ;;
    "load-config")
        # 加载配置
        if [ -f "$CONFIG_FILE" ]; then
            echo '{"success": true, "config": '$(cat "$CONFIG_FILE")'}'
        else
            echo '{"success": false, "error": "配置文件不存在"}'
        fi
        ;;
    *)
        echo '{"success": false, "error": "未知命令"}'
        ;;
esac
EOF

chmod 755 "$WEBUI_DIR/api.sh"

echo "[ECH Workers] WebUI 服务已配置完成！"
echo "[ECH Workers] 访问地址: http://localhost:8080"
