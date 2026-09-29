#!/usr/bin/env python3
"""openEuler Embedded 板卡串口控制台助手（serial-ssh-debug 技能）。

用法:
  serial_console.py peek [SECONDS] [LOGFILE]   # 被动监听串口输出（抓启动日志用）
  serial_console.py exec "CMD1" "CMD2" ...     # 登录（若需要）并执行命令
  serial_console.py send "TEXT"                # 原始发送一行并回显响应 3 秒

环境变量:
  SERIAL_PORT   串口设备，默认 /dev/ttyUSB0
  SERIAL_BAUD   波特率，默认 115200
"""
import sys, time, os
import serial

PORT = os.environ.get("SERIAL_PORT", "/dev/ttyUSB0")
BAUD = int(os.environ.get("SERIAL_BAUD", "115200"))

# shell 提示符匹配模式：openEuler Embedded 默认 root 提示符为
# "hostname ~ #"（~ 与 # 之间有空格），不要只用 "~#" 匹配。
PROMPT_PATS = ["~ #", "~#", " # ", "# "]


def open_port():
    return serial.Serial(PORT, BAUD, timeout=0.3)


def drain(s, seconds, silent=False):
    s.timeout = 0.3
    end = time.time() + seconds
    buf = b""
    while time.time() < end:
        chunk = s.read(4096)
        if chunk:
            buf += chunk
    text = buf.decode("utf-8", errors="replace")
    if not silent and text.strip():
        print(text)
    return text


def read_until(s, patterns, timeout):
    s.timeout = 0.2
    end = time.time() + timeout
    buf = b""
    pats = [p.encode() for p in patterns]
    while time.time() < end:
        chunk = s.read(4096)
        if chunk:
            buf += chunk
            if any(p in buf for p in pats):
                return buf.decode("utf-8", errors="replace")
    return buf.decode("utf-8", errors="replace")


def at_prompt(out):
    return any(p in out for p in PROMPT_PATS)


def login(s):
    """确保处于 root shell。board 默认 root/无密码或用户提供的密码。"""
    out = read_until(s, PROMPT_PATS + ["login:"], 2)
    if at_prompt(out):
        print("[already logged in]")
        return True
    s.write(b"\r\n")
    time.sleep(0.5)
    if at_prompt(drain(s, 2, silent=True)):
        print("[already logged in]")
        return True
    for _ in range(3):
        s.write(b"\r")
        out = read_until(s, ["login:"], 3)
        if "login:" not in out:
            continue
        s.write(b"root\r")
        out = read_until(s, ["Password:", "#", "~"] + PROMPT_PATS, 5)
        if "Password:" in out:
            s.write(b"openEuler@2021\r")
            out = read_until(s, PROMPT_PATS + ["Login incorrect"], 8)
        if at_prompt(out):
            print("[login OK]")
            return True
        out = ""
    return False


def exec_cmds(cmds):
    s = open_port()
    drain(s, 1, silent=True)
    if not login(s):
        print("[FATAL] login failed")
        sys.exit(1)
    for cmd in cmds:
        s.write(b"echo ===BEGIN===; " + cmd.encode() + b"; echo ===END=== $?\r")
        out = read_until(s, ["===END==="], 120)
        print(out.split("===BEGIN===", 1)[-1], end="")
    s.write(b"\r")
    drain(s, 1, silent=True)
    s.close()


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "peek"
    s = open_port()
    if mode == "peek":
        secs = float(sys.argv[2]) if len(sys.argv) > 2 else 5
        print(f"--- peeking {PORT} for {secs}s ---")
        text = drain(s, secs)
        if len(sys.argv) > 3:  # 可选：全量落盘，抓 U-Boot/内核启动日志
            with open(sys.argv[3], "w") as f:
                f.write(text)
            print(f"--- saved to {sys.argv[3]} ---")
    elif mode == "exec":
        exec_cmds(sys.argv[2:])
    elif mode == "send":
        s.write(sys.argv[2].encode() + b"\r")
        drain(s, 3)
    s.close()


if __name__ == "__main__":
    main()
