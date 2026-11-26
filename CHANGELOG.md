# Xbox/NVIDIA fork changelog

## Unreleased

- Builds without the CUDA driver headers compile again (upstream regression in `VfgBackend::capture`; also proposed upstream). The released 2.2.3 player is built with those headers and is unaffected.
- The setup guide explains that an official release numbered above the fork, applied from Check for updates, replaces the fork's player.
- `SHA256SUMS.txt` uses LF line endings, so `sha256sum -c` verifies the ZIP on any system. The 2.2.3 release asset was replaced with the LF copy; the checksum itself is unchanged.
- Repository: Dependabot checks the GitHub Actions versions weekly (`.github/dependabot.yml`). No workflow changes.
- Security: the 22 CodeQL findings are fixed in the source (wide index and energy arithmetic in the player, tests and the vendored SoundTouch, wide-string formats in the virtual camera setup, a bounded content type in the test server, a random prototype id). Casts only; the player's behaviour is unchanged. `main` is branch-protected (no force push or deletion).
- The G-SYNC profile check links again: its test fakes the VSync diagnostic that the controller now calls (an upstream test gap).
- README: merged upstream's warning about the `veyra-nrv[.]com` impersonation site and added the fork's download guidance.

## 2.2.3

- Based on official Veyra 2.2.1: the two 60→30 cadence modes, reticle and HUD protection for frame generation, video denoise, NVIDIA Image Scaling, original-picture capture start and the GPU cost reductions. Setup now uses the 2.2.1 NVIDIA package as its base.
- Xbox sessions longer than four hours keep their keepalive. The streaming token is renewed five minutes before it expires and after a rejected request. In a five-hour field session the keepalive was rejected from 4 h 05 min and the console closed the stream 55 minutes later.
- The log records the received and decoded frame rate, bitrate, drops and decode time of the Xbox stream once a minute.
- Software decoding uses upstream's native-size decoder path.
- The patch contains only the player and two QML files. The launcher, update worker, shaders, virtual camera and runtime DLLs are the official 2.2.1 files. The build now includes AMD FRC, the libass subtitle renderer and RIFE.
- Three presets for a 30 fps game in a 60 fps stream are included. `GTA 6 - Native Response` no longer stores an out-of-range frame generation multiplier, which stopped Veyra from saving its session while that preset was active.
- Setup can copy presets, settings and LUTs from an earlier installation with `-CopySettingsFrom`.

## 2.2.2

- Xbox Remote Play retries on the session thread after recoverable disconnects. The playback loop stays responsive through the retry delays and resumes with fresh frame history.
- Fullscreen VRAM protection uses the current Windows GPU budget as well as sustained memory growth. It preserves the stream and processing settings when returning to a window. The watchdog defers rebuilds when there is insufficient headroom.
- Capture audio diagnostics summarize frequent clock-mode transitions without changing audio sync.
- Running `Install.cmd` launches the installed app automatically.

## 2.2.1

- Added Auto, 1080p, and 1440p Xbox Remote Play requests and native-size software decoding.
- Fixed Xbox controller forwarding and session teardown. Updated the bundled DLSS Super Resolution dependency.
