# Veyra for Xbox Remote Play

An Xbox-focused fork of Veyra for Windows 11 and NVIDIA GPUs. It adds a 1440p Remote Play option, keeps sessions alive past the four-hour token limit, fixes Xbox session teardown and controller forwarding, and retains Veyra’s NVIDIA frame generation and video enhancement. The current patch is built on official Veyra 2.2.1.

**[Download the latest stable Xbox/NVIDIA patch](https://github.com/SenjuWoo/Veyra-NRVideo-Xbox/releases/latest)** · [Upstream pull request #274](https://github.com/Likely7/Veyra-NRVideo/pull/274)

## What this fork adds

| Improvement | What it means while playing |
| --- | --- |
| **Auto, 1080p, and 1440p** | Set the stream resolution in the Xbox dialog. Veyra displays the resolution the console delivers. |
| **Native-size software decoding** | If you switch to software decoding, Veyra preserves the decoded resolution, including 1440p. |
| **Independent controller forwarding** | Choose whether Veyra forwards controller input separately from your decoder choice. |
| **Fixed disconnect and reconnect** | Ending a stream clears the previous session from the Xbox dialog so you can connect again. |
| **Responsive automatic reconnect** | Retries after recoverable network or service interruptions without blocking the playback loop. |
| **Sessions longer than four hours** | Renews the Xbox streaming token before it expires, so the console keeps receiving the session keepalive. |
| **Stream health in the log** | Records the delivered frame rate, bitrate, drops and decode time once a minute. |
| **Example presets** | Three presets for a 30 fps game in a 60 fps stream: 90 fps, 120 fps and a native low-latency path. |
| **VRAM protection** | Optional fullscreen protection follows the current Windows GPU budget and keeps the stream active when returning to a window. |

The patch also updates the NVIDIA DLSS Super Resolution runtime. At native 1440p on a 1440p display, you can leave Super Resolution off. Enable frame generation for smoother motion, or leave it off when you want the shortest processing path. The console determines the stream codec and bitrate. One live Series X test delivered H.264 at 2560×1440 and about 59.5 decoded fps. Individual games can render at a lower frame rate.

## Get started

1. Open [Releases](https://github.com/SenjuWoo/Veyra-NRVideo-Xbox/releases), download the patch ZIP under **Assets**, and extract it.
2. Double-click `Install.cmd`. Setup downloads and verifies the official Veyra NVIDIA package and the signed NVIDIA Super Resolution DLL, then creates a separate installation and opens Veyra.
3. Enable Remote Play on your Xbox Series X|S and set its display resolution to 1440p or 4K UHD. In Veyra, open **Xbox**, select **1440p**, and connect. Press **Ctrl+Alt+Shift+S** to check the decoded resolution and bitrate. [Xbox Remote Play resolution requirements](https://news.xbox.com/en-us/2026/09/09/xbox-insiders-october-2026-console-features-3/)

Start with hardware decoding. If a game renders 30 fps and the stream repeats each frame at 60 fps, choose the **60→30 (Adaptive Dedup)** cadence before enabling interpolation, or import one of the presets from the `presets` folder. For a true 60 fps game, use the stream cadence.

See the [setup guide](scripts/xbox-portable/README.md) for installer options. See [upstream Veyra](https://github.com/Likely7/Veyra-NRVideo) and its [original documentation](README_UPSTREAM.md) for the full feature list and PlayStation builds. This fork follows the [project license](LICENSE).
