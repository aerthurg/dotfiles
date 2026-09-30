#!/usr/bin/env python3
"""
Waybar Pomodoro Module
A lightweight daemon and CLI controller designed for Waybar in Wayland setups.
"""

import sys
import os
import json
import time
import socket
import threading
import subprocess

# Timing configurations (in seconds)
WORK_TIME = 50 * 60       # 50 minutes
SHORT_BREAK = 2 * 60      # 2 minutes
LONG_BREAK = 5 * 60       # 5 minutes
CYCLES_BEFORE_LONG = 4    # Trigger long break every N work sessions

SOCKET_PATH = "/tmp/waybar_pomodoro.sock"

# JetBrains Nerd Font glyphs
ICON_STOPPED = "󱫌"
ICON_TIMER = "󰔛"

state = {
    "status": "stopped", # stopped, running, paused
    "type": "work",      # work, short_break, long_break
    "time_left": WORK_TIME,
    "completed_cycles": 0
}

def play_beep():
    sound_file = "/usr/share/sounds/freedesktop/stereo/complete.oga"
    if os.path.exists(sound_file):
        for player in ["pw-play", "paplay"]:
            if subprocess.run(["which", player], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0:
                subprocess.Popen([player, sound_file], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                return

    # Fallback sonoro gerando tom senoidal direto via PipeWire
    cmd = (
        "python3 -c \""
        "import numpy as np, sys; "
        "sr = 44100; t = np.linspace(0, 0.25, int(sr*0.25), False); "
        "tone = np.sin(2*np.pi*800*t) * 0.3; "
        "sys.stdout.buffer.write((tone * 32767).astype(np.int16).tobytes())\" "
        "| pw-play --rate 44100 --channels 1 --format s16 -"
    )
    subprocess.Popen(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def notify(title, msg):
    play_beep()
    try:
        subprocess.run(["notify-send", "-u", "normal", "-a", "Pomodoro", title, msg])
    except Exception:
        pass

def advance_cycle():
    if state["type"] == "work":
        state["completed_cycles"] += 1
        if state["completed_cycles"] % CYCLES_BEFORE_LONG == 0:
            state["type"] = "long_break"
            state["time_left"] = LONG_BREAK
            notify("Cycle Completed!", "Time for a long break (5 min). Click to start.")
        else:
            state["type"] = "short_break"
            state["time_left"] = SHORT_BREAK
            notify("Focus Session Done!", "Time for a short break (2 min). Click to start.")
    else:
        state["type"] = "work"
        state["time_left"] = WORK_TIME
        notify("Break Ended!", "Back to work (50 min). Click to start.")
    
    # Pausa a contagem aguardando acionamento manual
    state["status"] = "paused"

def timer_loop():
    while True:
        time.sleep(1)
        if state["status"] == "running":
            state["time_left"] -= 1
            if state["time_left"] <= 0:
                advance_cycle()

def format_output():
    mins, secs = divmod(state["time_left"], 60)
    timer_str = f"{mins:02d}:{secs:02d}"

    if state["status"] == "stopped":
        return json.dumps({
            "text": f"{ICON_STOPPED} 50:00",
            "tooltip": "Pomodoro Idle\nLeft Click: Start/Pause\nRight Click: Reset\nMiddle Click: Skip",
            "class": "stopped"
        })

    icon = ICON_TIMER
    cls = state["type"]
    if state["status"] == "paused":
        cls += " paused"

    type_label = state["type"].replace("_", " ").title()
    tooltip = f"Session: {type_label}\nStatus: {state['status'].capitalize()}\nCompleted Cycles: {state['completed_cycles']}"
    
    return json.dumps({
        "text": f"{icon} {timer_str}",
        "tooltip": tooltip,
        "class": cls
    })

def handle_command(cmd):
    if cmd == "toggle":
        if state["status"] == "running":
            state["status"] = "paused"
        elif state["status"] in ("paused", "stopped"):
            state["status"] = "running"
    elif cmd == "reset":
        state["status"] = "stopped"
        state["type"] = "work"
        state["time_left"] = WORK_TIME
    elif cmd == "skip":
        advance_cycle()
    elif cmd == "status":
        pass

def server():
    if os.path.exists(SOCKET_PATH):
        try:
            os.remove(SOCKET_PATH)
        except OSError:
            pass

    srv = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    srv.bind(SOCKET_PATH)
    srv.listen(5)

    threading.Thread(target=timer_loop, daemon=True).start()

    while True:
        conn, _ = srv.accept()
        data = conn.recv(1024).decode().strip()
        if data:
            handle_command(data)
        out = format_output()
        conn.sendall(out.encode())
        conn.close()

def send_command(cmd):
    try:
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        s.connect(SOCKET_PATH)
        s.sendall(cmd.encode())
        res = s.recv(1024).decode()
        s.close()
        print(res)
    except (ConnectionRefusedError, FileNotFoundError):
        subprocess.Popen([sys.executable, __file__, "daemon"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        time.sleep(0.1)
        send_command(cmd)

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "daemon":
        server()
    elif len(sys.argv) > 1:
        send_command(sys.argv[1])
    else:
        send_command("status")
