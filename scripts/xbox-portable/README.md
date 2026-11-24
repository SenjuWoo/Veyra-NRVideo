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

Setup copies three presets for a 30 fps game streamed at 60 fps to `presets/` in the installation folder. Import them from the preset menu.

| Preset | Frame generation | Cadence | Use it for |
| --- | --- | --- | --- |
| `GTA 6 V9` | NVIDIA VFG Medium 3× (90 fps) | 60→30 (Adaptive Dedup) | The default. Anti-aliasing, noise reduction and RTX Video HDR on, super resolution off. |
| `GTA 6 V9 - Smooth 120` | NVIDIA VFG Medium 4× (120 fps) | 60→30 (Adaptive Dedup) | Fast pans and driving. Go back to V9 if HUD edges or pacing look better at 3×. |
| `GTA 6 - Native Response` | Off | Transport | The shortest processing path, for comparing aiming and steering feel. |

They were tuned on an RTX 4080 SUPER with a 1440p HDR display. On a 2560×1440, 30 fps test clip the first two submitted 90 and 120 fps with a processing p95 of about 18 ms and 21 to 23 ms. Lower the multiplier or switch NR off on a slower GPU. If the reticle or minimap wobbles in generated frames, turn on **Crosshair and HUD protection** and **Auto HUD lock** in the frame generation panel.

## Setup options

Setup accepts `-Destination`, `-UpstreamZip`, `-DlssSrDll` and `-CopySettingsFrom`. The optional local files must match the pinned hashes. Use a new destination; an existing Veyra installation remains usable independently. `-CopySettingsFrom <old Veyra folder>` copies that folder's presets, settings and LUTs into the new installation:

```
powershell -ExecutionPolicy Bypass -File Install-VeyraXbox.ps1 -CopySettingsFrom "D:\Veyra-2.2.2" -Launch
```

Sign in to Xbox once per Windows account; the sign-in is shared by every Veyra folder.

This build includes Xbox and Moonlight streaming and the NVIDIA, Intel and AMD processing options of the official package. PS5 Remote Play and the DeckLink and Magewell native capture paths are in the original upstream build only. The version number stays above upstream's, so **Check for updates** reports this build as current; install the next patch from the releases page.

[Veyra Xbox/NVIDIA releases](https://github.com/SenjuWoo/Veyra-NRVideo/releases) · [Upstream PR](https://github.com/Likely7/Veyra-NRVideo/pull/274) · [Official base package](https://github.com/Likely7/Veyra-NRVideo/releases/tag/v2.2.1)
