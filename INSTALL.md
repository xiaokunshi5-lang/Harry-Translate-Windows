# 环境安装与配置指南（macOS / Windows）

本文档一步一步说明如何在 **macOS** 与 **Windows** 电脑上从零配置「最初版双通道同传系统」所需的全部运行环境。

---

## 前置准备：需要什么？

1. **Python 3.9 ~ 3.12**（推荐 3.9 ~ 3.11，兼容性最佳）
2. **阿里云百炼 API Key**（格式如 `sk-xxxxxxxxxxxxxxxx`），用于调用 `qwen3.8-livetranslate-flash-realtime`
3. **可用麦克风**（电脑内置麦克风或外接 USB/蓝牙麦克风）

---

## 一、macOS 版安装与配置步骤

### 第 1 步：安装底层音频驱动依赖 `portaudio`

Mac 上安装 `PyAudio` 必须先安装 `portaudio` C 语言库，否则 `pip install` 会报错缺少 `portaudio.h`。

打开 **终端（Terminal）**，执行：

```bash
# 如未安装 Homebrew，可先前往 https://brew.sh 安装
brew install portaudio
```

确认安装成功（能看到 `portaudio.h` 路径即成功）：

```bash
ls /opt/homebrew/include/portaudio.h /usr/local/include/portaudio.h 2>/dev/null
```

### 第 2 步：进入项目目录并创建 `.venv` 虚拟环境

假设文件夹放在桌面，命名为 `最初版的同传`：

```bash
cd ~/Desktop/最初版的同传
python3 -m venv .venv
```

### 第 3 步：安装 Python 依赖

> 注意：Apple Silicon（M1/M2/M3/M4）芯片需要指定 Homebrew 的头文件路径来编译安装 `PyAudio`。

```bash
CFLAGS="-I/opt/homebrew/include" LDFLAGS="-L/opt/homebrew/lib" .venv/bin/pip install -r requirements.txt
```

（如果是 Intel 芯片 Mac，将 `/opt/homebrew` 替换为 `/usr/local` 即可。）

验证依赖安装成功：

```bash
.venv/bin/python -c "import pyaudio, fastapi, uvicorn, websockets, websocket, dotenv; print('OK')"
```

### 第 4 步：配置 `.env` 环境变量

如果目录里还没有 `.env`，复制模板创建：

```bash
cp .env.example .env
```

用文本编辑器打开 `.env`，填入你的阿里云百炼 API Key：

```env
DASHSCOPE_API_KEY=sk-替换为你的真实Key
QWEN_REALTIME_WS_URL=wss://llm-0joa7mwnwelaxwgj.cn-beijing.maas.aliyuncs.com/api-ws/v1/realtime?model=qwen3.8-livetranslate-flash-realtime
SAMPLE_RATE=16000
CHUNK_SIZE=3200
```

### 第 5 步：赋予脚本可执行权限并授权麦克风

```bash
chmod +x start.sh 启动同传系统.command 切换API_Key.command switch_key.py
```

首次运行 `./start.sh` 或双击 `启动同传系统.command` 时，系统会弹出 **“‘终端’想访问您的麦克风”**，请务必点击 **「好 / 允许」**（否则可在 `系统设置 -> 隐私与安全性 -> 麦克风` 中手动勾选终端）。

---

## 二、Windows 版安装与配置步骤（Windows 10 / 11）

### 第 1 步：安装 Python（关键勾选 PATH）

1. 前往 [Python 官网](https://www.python.org/downloads/windows/) 下载 **Python 3.10 或 3.11** 安装包。
2. 运行安装程序时，**务必勾选底部的 `Add python.exe to PATH`**，然后点击 `Install Now`。
3. 打开 **PowerShell** 或 **命令提示符（CMD）**，输入以下指令确认安装成功：
   ```powershell
   python --version
   ```

### 第 2 步：进入项目目录并创建 `.venv` 虚拟环境

假设文件夹放在桌面，命名为 `最初版的同传`：

```powershell
cd "$env:USERPROFILE\Desktop\最初版的同传"
python -m venv .venv
```

### 第 3 步：激活虚拟环境并安装依赖

```powershell
.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
```

> **提示**：如果 PowerShell 提示“在此系统上禁止运行脚本”，可改用 **CMD（命令提示符）** 执行 `.venv\Scripts\activate.bat`，或直接不激活环境，用 `.venv\Scripts\pip.exe install -r requirements.txt`。
> Windows 下的 `PyAudio` 会直接下载官方预编译轮子（wheel），通常无需额外安装 C++ 编译器。

### 第 4 步：配置 `.env` 环境变量

1. 在文件夹中复制 `.env.example`，重命名为 `.env`（注意不要变成 `.env.txt`）。
2. 用记事本或 VS Code 打开 `.env`，填入你的 `DASHSCOPE_API_KEY=sk-你的真实Key` 并保存（UTF-8 编码）。

### 第 5 步：开启 Windows 麦克风权限并启动

1. 打开 Windows **设置 -> 隐私和安全性 -> 麦克风**，确保：
   - **麦克风访问权限** 为「开」
   - **允许桌面应用访问你的麦克风** 为「开」
2. 在项目目录运行：
   ```powershell
   .venv\Scripts\python.exe server.py
   ```
3. 看到终端输出 `双通道同传系统已就绪！` 后，手动打开浏览器访问 <http://localhost:8000>。

---

## 三、核心依赖清单说明（`requirements.txt`）

| 依赖包 | 作用 |
| :--- | :--- |
| `fastapi` + `uvicorn` | 本地轻量 Web 服务与 WebSocket 广播网关 |
| `PyAudio` | 跨平台麦克风实时音频采集（16kHz PCM） |
| `websocket-client` + `websockets` | 连接阿里云千问实时同传 WebSocket 通道 |
| `python-dotenv` | 自动读取 `.env` 中的 API Key 与配置 |
