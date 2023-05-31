#!/usr/bin/env bash


# 其他Paas保活
PAAS1_URL=

[ ! -e cloudflared ] && wget -O cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && chmod +x cloudflared
# 启用 Argo，并输出节点日志
./cloudflared tunnel --url http://localhost:8080 --no-autoupdate > argo.log 2>&1 &
sleep 5 && argo_url=$(cat argo.log | grep -oE "https://.*[a-z]+cloudflare.com" | sed "s#https://##")

echo qwfwer${argo_url}dgjsays

# Paas保活
generate_keeplive() {
  cat > paaslive.sh << EOF
#!/usr/bin/env bash

# 传参
PAAS1_URL=${PAAS1_URL}
PAAS2_URL=${PAAS2_URL}
PAAS3_URL=${PAAS3_URL}
PAAS4_URL=${PAAS4_URL}
PAAS5_URL=${PAAS5_URL}
PAAS6_URL=${PAAS6_URL}

# 判断变量并保活

if [[ -z "\${PAAS1_URL}" && -z "\${PAAS2_URL}" && -z "\${PAAS3_URL}" && -z "\${PAAS4_URL}" && -z "\${PAAS5_URL}" && -z "\${PAAS6_URL}" ]]; then
    echo "所有变量都不存在，程序退出。"
    exit 1
fi

function handle_error() {
    # 处理错误函数
    echo "连接超时"
    sleep 10
}

while true; do
    for var in 1 2 3 4 5 6
    do
        url_var="PAAS\${var}_URL"
        url=\${!url_var}
        if [[ -n "\${url}" ]]; then
            count=0
            while true; do
                curl --connect-timeout 10 -k "\${url}" || (handle_error;continue)
				echo 请求主页成功。
                break
            done
        fi
    done
    sleep 20m
done
EOF
}
generate_keeplive
[ -e paaslive.sh ] && nohup bash paaslive.sh >/dev/null 2>&1 &

