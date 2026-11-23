# 保姆级跑通教程：5 分钟在任何电脑上跑起双通道同传

这份教程面向**零基础用户**：只要拿到「最初版的同传」文件夹，跟着下面 6 步走，就能在自己的 Mac 或 Windows 电脑上顺利跑起来。

---

## 第 1 步：获取阿里云百炼 API Key

1. 登录 [阿里云百炼控制台](https://bailian.console.aliyun.com/)。
2. 在右上角或左侧菜单进入 **API-KEY 管理**，点击 **创建我的 API-KEY**。
3. 复制生成的 Key（以 `sk-` 开头的一串字符），妥善保存。
4. 确认账号已开通千问实时同传模型（`qwen3.8-livetranslate-flash-realtime`）且账户余额充足。

---

## 第 2 步：把文件夹放到桌面并配置环境

1. 将「最初版的同传」文件夹放到桌面（路径尽量不要有特殊符号）。
2. 按照 [`INSTALL.md`](./INSTALL.md) 完成对应系统的环境安装：
   - **Mac 用户**：安装 `portaudio` + 创建 `.venv` + 安装 `requirements.txt`
   - **Windows 用户**：安装 Python（勾选 `Add python.exe to PATH`）+ 创建 `.venv` + 安装 `requirements.txt`
3. 确保文件夹中已有 `.env` 文件，并且里面填好了你的 `DASHSCOPE_API_KEY=sk-你的Key`。

> **小技巧**：如果文件夹是别人发给你的、里面已经预先配好了 `.venv` 和 `.env`，Mac 用户可以直接跳到第 3 步双击运行！

---

## 第 3 步：启动同传服务

### Mac 用户
- **最简单方式**：直接双击文件夹里的 **`启动同传系统.command`**。
  > 如果弹出“无法打开，因为来自身份不明的开发者”，请在文件上 **右键 -> 打开**，或到 `系统设置 -> 隐私与安全性` 中点击“仍要打开”。
- **终端方式**：
  ```bash
  cd ~/Desktop/最初版的同传 && ./start.sh
  ```

### Windows 用户
在文件夹中打开 **CMD 或 PowerShell**，输入：
```powershell
.venv\Scripts\python.exe server.py
```

看到类似下面的输出，说明后端服务已经成功跑起来了：
```text
>> [服务启动] 双通道同传系统已就绪！
   • 主控面板:    http://localhost:8000/
   • 中译英大屏:  http://localhost:8000/en  (投屏给外宾看)
   • 英译重大屏:  http://localhost:8000/zh  (投屏给中方看)
   • 左右双栏屏:  http://localhost:8000/split (现场控台对照)
```

---

## 第 4 步：打开浏览器测试收音与翻译

1. 打开 Chrome / Edge / Safari 浏览器，访问：<http://localhost:8000/split>（双栏监看屏）。
2. 对着电脑麦克风说一句中文，例如：**“大家好，欢迎参加今天的会议。”**
3. 观察页面变化：
   - **左侧（中译英通道）** 应实时流式输出英文翻译；
   - **右侧（英译中通道）** 应同步识别中文内容；
4. 再说一句英文测试，例如：**"Hello everyone, nice to meet you."**，确认右侧实时译出中文。

> **注意**：不要关闭刚才启动服务的黑框（终端/命令行窗口），关闭窗口会停止同传服务。用完后在终端按 `Ctrl + C` 即可安全退出。

---

## 第 5 步：会议现场双屏扩展投屏实战

如果你在会议室连接了两台外接大屏（一台给外宾看英文，一台给中方看中文）：

1. **开启扩展模式（不要镜像）**：
   - **Mac**：`系统设置 -> 显示器` -> 将外接显示器设为 **扩展显示器**。
   - **Windows**：按 `Win + P` -> 选择 **扩展**。
2. **拖入对应页面并全屏**：
   - 浏览器开两个窗口：
     - 窗口 1 打开 `http://localhost:8000/en` -> 拖到外宾大屏 -> 按 `F11`（Mac 按 `Control + Command + F`）或点击页面右上角 **全屏模式**。
     - 窗口 2 打开 `http://localhost:8000/zh` -> 拖到中方大屏 -> 全屏展示。
3. **调节字号**：使用页面右上角 **字体 + / -** 按钮，根据会场观看距离调大字号。

---

## 第 6 步：常见报错与一秒排查表

| 报错现象 | 原因 | 解决方法 |
| :--- | :--- | :--- |
| **`fatal error: 'portaudio.h' file not found`**（Mac） | 没装 `portaudio` 或没传编译参数 | 先执行 `brew install portaudio`，再用 `CFLAGS="-I/opt/homebrew/include" LDFLAGS="-L/opt/homebrew/lib" .venv/bin/pip install -r requirements.txt` |
| **说话完全没反应，字幕空白** | 麦克风权限未开或选错输入设备 | 检查系统隐私设置是否允许终端/Python 使用麦克风；检查系统默认输入设备是否为当前麦克风 |
| **提示 `Address already in use`（端口 8000 被占用）** | 上一次的服务还没关掉，或被其他程序占用 | Mac 终端运行 `lsof -ti:8000 \| xargs kill -9` 清理；Windows 运行 `netstat -ano \| findstr :8000` 查 PID 后 `taskkill /PID <PID> /F` |
| **浏览器打得开，但一直不翻译 / 终端报 401/403** | `.env` 中的 `DASHSCOPE_API_KEY` 填错、过期或欠费 | 检查 `.env` 里 `DASHSCOPE_API_KEY=` 后面有没有多余空格或引号；运行 `python switch_key.py "新Key"` 重新校验 |
| **Windows 双击或激活 `.venv` 报脚本执行策略错误** | PowerShell 默认拦截 `.ps1` 脚本 | 直接运行 `.venv\Scripts\python.exe server.py`，无需先执行 `Activate.ps1` |
| **Mac 移动了文件夹位置后 `.venv` 报错** | Python 虚拟环境路径写死了绝对路径 | 删掉旧的 `.venv` 文件夹，按 [`INSTALL.md`](./INSTALL.md) 重新执行 `python3 -m venv .venv` 并装依赖即可 |
