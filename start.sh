#!/bin/bash

# 获取当前脚本所在目录
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

echo "=========================================================="
echo "    会议实时双向双屏同传系统 (Qwen3.8-LiveTranslate)      "
echo "=========================================================="

# 检查虚拟环境
if [ ! -d ".venv" ]; then
    echo ">> [错误] 未检测到 .venv 虚拟环境，请先初始化环境。"
    exit 1
fi

# 检查 .env 文件
if [ ! -f ".env" ]; then
    echo ">> [错误] 未检测到 .env 配置文件，请创建并配置 DASHSCOPE_API_KEY。"
    exit 1
fi

echo ">> 正在启动双通道同传服务..."
echo "   • 主控面板:    http://localhost:8000/"
echo "   • 中译英大屏:  http://localhost:8000/en   (面向外宾)"
echo "   • 英译重大屏:  http://localhost:8000/zh   (面向中方)"
echo "   • 左右双栏屏:  http://localhost:8000/split (现场监看)"
echo "----------------------------------------------------------"

# 自动在默认浏览器打开主控面板
(sleep 2 && open "http://localhost:8000") &

# 启动同传服务
.venv/bin/python server.py
