# Veyra Xbox Remote Play for NVIDIA

1. Extract the patch ZIP into its own folder and double-click `Install.cmd`. Setup downloads and verifies the official Veyra NVIDIA portable package and signed NVIDIA DLSS Super Resolution DLL, then creates a separate installation. Windows 11 x64 and an NVIDIA GPU are the target.
2. Setup opens Veyra when it finishes. Enable Remote Play on the Series X|S and set its display resolution to 1440p or 4K UHD. Open **Xbox**, select **1440p**, and connect. Use **Ctrl+Alt+Shift+S** to see the decoded resolution and bitrate.
3. Start with hardware decode. For responsive play, use native output with Frame Generation off. For smoother pans, try NVIDIA VFG Medium at 2× and NVIDIA Low Latency On. On a 1440p monitor, reserve super resolution for a 1080p fallback or a deliberate reconstruction effect.

Use the transport frame rate for games rendering 60 unique fps. Use 60→30 only when the game actually repeats each 30 fps frame in a 60 fps stream. The Series X test negotiated H.264. The service controls the stream encoder and bitrate. The Xbox feature and display requirements are documented by [Xbox Wire](https://news.xbox.com/en-us/2026/09/09/xbox-insiders-october-2026-console-features-3/).

Setup accepts `-Destination`, `-UpstreamZip` and `-DlssSrDll`. The optional local files must match the same pinned hashes. Use a new destination. An existing Veyra installation remains usable independently. This focused build includes Xbox and Moonlight streaming. PS5 Remote Play, AMD FRC and the external libass renderer are available in the original upstream build.

[Veyra Xbox/NVIDIA releases](https://github.com/SenjuWoo/Veyra-NRVideo/releases) · [Upstream PR](https://github.com/Likely7/Veyra-NRVideo/pull/274) · [Official base package](https://github.com/Likely7/Veyra-NRVideo/releases/tag/v2.2.0)
