# 🛰️ AWK Silent-Shadow Client (Titan v9.5)

> ⚠️ **Disclaimer**
> This project includes powerful remote system interaction capabilities. It must only be used in **authorized environments** such as cybersecurity labs, controlled testing setups, or educational simulations.

---

## 📌 Overview

**AWK Silent-Shadow Client (Titan v9.5)** is a PowerShell-based remote administration client that connects to a remote controller via TCP and executes commands in real time.

It supports file operations, system control, surveillance features, and persistence mechanisms.

---

## 🧠 Architecture

This project follows a **client-controller model**:

* 🖥️ **Client (this script)** runs on the target machine
* 🎯 **Master Controller** runs on the attacker’s machine and:

  * Listens for incoming connections
  * Sends commands
  * Receives data (logs, files, snapshots)

---

## 📚 Table of Contents

* [Features](#-features)
* [Architecture](#-architecture)
* [Installation](#-installation)
* [Configuration](#-configuration)
* [Attacker Setup](#-attacker-setup)
* [Usage](#-usage)
* [Command Reference](#-command-reference)
* [Examples](#-examples)
* [Dependencies](#-dependencies)
* [Troubleshooting](#-troubleshooting)
* [Security Notice](#-security-notice)
* [License](#-license)
* [Author](#-author)

---

## ⚙️ Features

### 🔌 Remote Access

* TCP-based communication
* Persistent command execution loop
* Real-time response system

### ⌨️ Keystroke Monitoring

* Captures keyboard input via Windows API
* Sends logs to remote controller

### 📁 File Management

* File discovery across user directories
* File exfiltration (Base64 encoded transfer)
* File upload and execution

### 📸 Capture Capabilities

* Webcam snapshot capture
* Clipboard image extraction

### 🖥️ System Interaction

* Execute arbitrary PowerShell commands
* Navigate file system
* Retrieve system and network information

### 🔊 Hardware Control

* Volume manipulation
* Audio playback support

### 🔁 Persistence

* Registry autorun entry creation

### 💥 System Control

* Forced shutdown
* Fullscreen overlay display

---

## 🛠️ Installation

### Requirements

* Windows OS
* PowerShell 5+
* .NET Framework

### Steps

```powershell id="c2x8kp"
# Allow script execution (temporary)
Set-ExecutionPolicy Bypass -Scope Process

# Run the script
.\client.ps1
```

---

## 🔧 Configuration

Before running the client, configure the connection settings:

```powershell id="8z4qtm"
$AttackerIP = "<CONTROLLER_IP>"
$AttackerPort = 4444
```

| Variable       | Description                          |
| -------------- | ------------------------------------ |
| `AttackerIP`   | IP address of the controller machine |
| `AttackerPort` | Port used for communication          |

---

## 🎯 Attacker Setup

### Master Controller Script

A **separate master controller script** must be running on the attacker’s machine.

Responsibilities:

* Listen on the configured port
* Accept incoming client connections
* Send commands to the client
* Receive:

  * Command output
  * Keystrokes
  * Files (Base64 encoded)
  * Snapshots

> ℹ️ Firewall and network configuration should be handled separately.

---

## 🚀 Usage

1. Start the **master controller** on attacker machine
2. Configure connection settings in client script
3. Run the client on the target system
4. Wait for connection
5. Send commands from controller

---

## 🧾 Command Reference

### 📂 File Operations

| Command            | Description                          |
| ------------------ | ------------------------------------ |
| `find`             | Search Desktop & Documents for files |
| `pull <file_name>` | Retrieve file from system            |
| `push <full_path>` | Upload file to target system         |

---

### 🖥️ System Navigation

| Command        | Description             |
| -------------- | ----------------------- |
| `ls`           | List directory contents |
| `cd <dir>`     | Change directory        |
| `pwd`          | Print current directory |
| `mkdir <name>` | Create folder           |

---

### 📊 System Info

| Command      | Description           |
| ------------ | --------------------- |
| `whoami`     | Current user          |
| `ipconfig`   | Network configuration |
| `cat <file>` | Read file             |

---

### 📸 Surveillance

| Command | Description          |
| ------- | -------------------- |
| `snap`  | Capture webcam image |

---

### ⚙️ Execution & Persistence

| Command          | Description            |
| ---------------- | ---------------------- |
| `exec <file>`    | Execute file from temp |
| `persist <file>` | Enable persistence     |

---

### 🔊 Hardware

| Command | Description             |
| ------- | ----------------------- |
| `audio` | Max volume + play audio |

---

### 💣 System Control

| Command | Description              |
| ------- | ------------------------ |
| `boom`  | Display image + shutdown |
| `exit`  | Close session            |

---

## 💡 Examples

### 📥 Pull File

```text id="m1v7za"
pull report.pdf
```

### 📤 Push File

```text id="p8x2wr"
push C:\Users\User\Desktop\payload.exe
```

### 📸 Take Snapshot

```text id="z6k9dn"
snap
```

### ⚙️ Execute File

```text id="r4q1ty"
exec payload.exe
```

---

## 📦 Dependencies

* `System.Windows.Forms`
* `System.Drawing`
* Windows APIs:

  * `user32.dll`
  * `avicap32.dll`
* COM:

  * `WMPlayer.OCX`

---

## 🛠️ Troubleshooting

| Issue                     | Solution                     |
| ------------------------- | ---------------------------- |
| Cannot connect            | Check IP/port configuration  |
| No connection from client | Ensure controller is running |
| Commands not working      | Verify execution policy      |
| Snapshot fails            | Ensure camera permissions    |
| No audio                  | Check file path/device       |

---

## 🔐 Security Notice

This tool includes capabilities such as:

* Keystroke capture
* File exfiltration
* Persistence mechanisms

❗ Unauthorized use may violate laws and regulations.

Use only in:

* Authorized penetration testing
* Security research labs
* Educational environments

---

## 📜 License

This project is licensed under the **GNU General Public License (GPL)**.

---

## 👤 Author

**ABDUL WASAY KHAN**

---
