#!/system/bin/sh

# ECH Workers KSU 模块安装脚本

set -e

MODDIR=${0%/*}
SYSTEM_BIN=/system/bin
ECH_WORKERS_BIN=ech-workers

# 复制可执行文件到系统目录
echo "[ECH Workers] 正在安装可执行文件..."
cp "$MODDIR/system/bin/$ECH_WORKERS_BIN" "$SYSTEM_BIN/"
chmod 755 "$SYSTEM_BIN/$ECH_WORKERS_BIN"

# 创建配置目录
echo "[ECH Workers] 正在创建配置目录..."
mkdir -p /data/adb/ech-workers
chmod 755 /data/adb/ech-workers

# 下载 IP 列表文件
echo "[ECH Workers] 正在下载 IP 列表文件..."
curl -L -o /data/adb/ech-workers/chn_ip.txt "https://raw.githubusercontent.com/mayaxcn/china-ip-list/refs/heads/master/chn_ip.txt" || echo "[ECH Workers] IPv4 列表下载失败"
curl -L -o /data/adb/ech-workers/chn_ip_v6.txt "https://raw.githubusercontent.com/mayaxcn/china-ip-list/refs/heads/master/chn_ip_v6.txt" || echo "[ECH Workers] IPv6 列表下载失败"

# 创建服务启动脚本
echo "[ECH Workers] 正在创建服务启动脚本..."
cat > /data/adb/service.d/ech-workers.sh << 'EOF'
#!/system/bin/sh

# ECH Workers 服务启动脚本

ECH_WORKERS_BIN=/system/bin/ech-workers
CONFIG_DIR=/data/adb/ech-workers

# 等待网络就绪
while [ ! -f /sys/class/net/wlan0/operstate ] || [ "$(cat /sys/class/net/wlan0/operstate)" != "up" ]; do
    sleep 1
done

# 启动 ECH Workers 服务
$ECH_WORKERS_BIN -l 0.0.0.0:30000 -routing bypass_cn > $CONFIG_DIR/ech-workers.log 2>&1 &
echo "[ECH Workers] 服务已启动"
EOF

chmod 755 /data/adb/service.d/ech-workers.sh

# 启动服务
echo "[ECH Workers] 正在启动服务..."
/data/adb/service.d/ech-workers.sh

# 启动 WebUI 服务器
echo "[ECH Workers] 正在启动 WebUI 服务器..."
$MODDIR/webui-server.sh

echo "[ECH Workers] 安装完成！"
echo "[ECH Workers] 代理服务已启动，监听地址: 0.0.0.0:30000"
echo "[ECH Workers] WebUI 服务已启动，访问地址: http://localhost:8080"
echo "[ECH Workers] 分流模式: 跳过中国大陆"
