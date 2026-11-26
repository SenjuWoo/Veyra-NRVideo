# Veyra Xbox Remote Play for NVIDIA

1. Extract the patch ZIP into its own folder and double-click `Install.cmd`. Setup downloads and verifies the official Veyra 2.2.1 NVIDIA portable package and the signed NVIDIA DLSS Super Resolution DLL, then creates a separate installation. Windows 11 x64 and an NVIDIA GPU are the target.
2. Setup opens Veyra when it finishes. Enable Remote Play on the Series X|S and set its display resolution to 1440p or 4K UHD. Open **Xbox**, select **1440p**, and connect. Use **Ctrl+Alt+Shift+S** to see the decoded resolution and bitrate.
3. Start with hardware decode. For responsive play, use native output with Frame Generation off. For smoother pans, try NVIDIA VFG Medium at 2× and NVIDIA Low Latency On. On a 1440p monitor, reserve super resolution for a 1080p fallback or a deliberate reconstruction effect.

Use the transport frame rate for games rendering 60 unique fps. Use **60→30 (Adaptive Dedup)** when the game repeats each 30 fps frame in a 60 fps stream: it takes the first copy of each picture and skips repeats when the game dips below 30. The Series X tests negotiated H.264. The console controls the stream encoder and bitrate. The Xbox feature and display requirements are documented by [Xbox Wire](https://news.xbox.com/en-us/2026/09/09/xbox-insiders-october-2026-console-features-3/).

## Long sessions

The Xbox streaming token lasts four hours. Veyra renews it five minutes before it expires and again if the service rejects a request, so the session's keepalive continues past that point. Once a minute the log records what the console delivered:

```
[xbox-stats] received=59.9fps decoded=59.9fps video=18.4Mbps dropped=0 decodeErrors=0 keyframeRequests=0 rttMs=2.1 decodeMs=0.15 size=2560x1440 hardware=true
```

The log is `logs/veyra-qml.log` in the installation folder. If the service closes a stream, Veyra reconnects up to three times and continues with fresh frame history.

## Example presets

Setup copies six presets for a 30 fps game streamed at 60 fps to `presets/` in the installation folder. Import them from the preset menu, then set `GTA 6 - Smooth 240` as the default so it loads at start.

| Preset | Frame generation | Cadence | Use it for |
| --- | --- | --- | --- |
| `GTA 6 - Smooth 240` | NVIDIA VFG Medium 8× (240 fps) | 60→30 (Adaptive Dedup) | The default on a high-refresh G-SYNC or FreeSync display. |
| `GTA 6 - Balanced 120` | NVIDIA VFG Medium 4× (120 fps) | 60→30 (Adaptive Dedup) | More GPU headroom: recording, a slower GPU, or a 120/144 Hz display. |
| `GTA 6 - Clean 60` | NVIDIA VFG High 2× (60 fps) | 60→30 (Adaptive Dedup) | The cleanest generated frames, or a 60 fps capture canvas. |
| `GTA 6 - High Quality 90` | NVIDIA VFG High 3× (90 fps) | 60→30 (Adaptive Dedup) | High-quality generation above 60 fps. RTX Video noise reduction is off to make room (27 ms P95 of 33). |
| `GTA 6 - Native Response` | Off | Transport | The shortest processing path, for comparing aiming and steering feel. |
| `GTA 6 - Smooth 240 HDR Input` | NVIDIA VFG Medium 8× (240 fps) | 60→30 (Adaptive Dedup) | An HDR capture-card source: RTX Video HDR off because the input is already HDR. Xbox Remote Play is SDR, so keep Smooth 240 there. |

All keep native 1440p. RTX Video noise reduction and RTX Video HDR are on unless the table says otherwise. Super resolution and DLAA are off: the console already sends 2560×1440, so there is nothing to upscale, and anti-aliasing a compressed stream changes little while costing frame-generation time.

They were measured live on an RTX 4080 SUPER with a 2560×1440 280 Hz G-SYNC Compatible display. Generation cost per 30 fps frame pair, with a 33 ms budget, was 27 ms (P95) at Medium 8×, 18 ms at Medium 4× and 23 ms at High 2×. Capture-to-present latency was the same in all three, about 45 ms (P95), so a higher multiplier adds smoothness, not delay. VFG High above 2× costs 34 to 86 ms at 1440p, more than the budget, so Veyra skips those generated frames and shows the real 30 fps; use Medium for 3× and above. Lower the multiplier on a slower GPU. If the reticle or minimap wobbles in generated frames, turn on **Crosshair and HUD protection** and **Auto HUD lock** in the frame generation panel.

## Setup options

Setup accepts `-Destination`, `-UpstreamZip`, `-DlssSrDll` and `-CopySettingsFrom`. The optional local files must match the pinned hashes. Use a new destination; an existing Veyra installation remains usable independently. `-CopySettingsFrom <old Veyra folder>` copies that folder's presets, settings and LUTs into the new installation:

```
powershell -ExecutionPolicy Bypass -File Install-VeyraXbox.ps1 -CopySettingsFrom "D:\Veyra-2.2.2" -Launch
```

Sign in to Xbox once per Windows account; the sign-in is shared by every Veyra folder.

This build includes Xbox and Moonlight streaming and the NVIDIA, Intel and AMD processing options of the official package. PS5 Remote Play and the DeckLink and Magewell native capture paths are in the original upstream build only. **Check for updates** looks at the official releases. While they are numbered below this build it reports this build as current. If it offers an official version above this one, applying it replaces this player and its Xbox changes; install the matching patch from the releases page instead.

[Veyra Xbox/NVIDIA releases](https://github.com/SenjuWoo/Veyra-NRVideo-Xbox/releases) · [Upstream PR](https://github.com/Likely7/Veyra-NRVideo/pull/274) · [Official base package](https://github.com/Likely7/Veyra-NRVideo/releases/tag/v2.2.1)
