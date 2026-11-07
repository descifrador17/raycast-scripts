#!/usr/bin/env python3

# Dependency: yt-dlp + ffmpeg
# Install via Homebrew: brew install yt-dlp ffmpeg

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Reel Downloader
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🎬
# @raycast.argument1 { "type": "text", "placeholder": "Reel URL" }
# @raycast.packageName Instagram

# Documentation:
# @raycast.description Download an Instagram reel/post video to ~/Downloads

import os
import subprocess
import sys

# Raycast runs scripts without the shell profile, so Homebrew isn't on PATH
os.environ["PATH"] = "/opt/homebrew/bin:/usr/local/bin:" + os.environ.get("PATH", "")

url = sys.argv[1].strip()
if "instagram.com/" not in url:
    print("Not an Instagram URL")
    sys.exit(1)

try:
    result = subprocess.run(
        [
            "yt-dlp",
            # H.264/AAC plays in QuickTime and shares cleanly; IG's top tier is VP9
            "-S", "vcodec:h264,res,acodec:aac",
            "-o", os.path.expanduser("~/Downloads/%(id)s.%(ext)s"),
            "--print", "after_move:filepath",
            "--", url,
        ],
        capture_output=True,
        text=True,
    )
except FileNotFoundError:
    print("yt-dlp not found: brew install yt-dlp")
    sys.exit(1)

files = result.stdout.splitlines()
if result.returncode != 0 or not files:
    errors = result.stderr.strip().splitlines()
    # first sentence only; yt-dlp errors are paragraphs, too long for a HUD
    print(errors[-1].split(". ")[0] if errors else "Download failed")
    sys.exit(1)

if len(files) == 1:
    print(f"Saved {os.path.basename(files[0])} to Downloads")
else:
    print(f"Saved {len(files)} videos to Downloads")
