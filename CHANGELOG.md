# Xbox/NVIDIA fork changelog

## 2.2.2

- Xbox Remote Play retries on the session thread after recoverable disconnects. The playback loop stays responsive through the retry delays and resumes with fresh frame history.
- Fullscreen VRAM protection uses the current Windows GPU budget as well as sustained memory growth. It preserves the stream and processing settings when returning to a window. The watchdog defers rebuilds when there is insufficient headroom.
- Capture audio diagnostics summarize frequent clock-mode transitions without changing audio sync.
- Running `Install.cmd` launches the installed app automatically.

## 2.2.1

- Added Auto, 1080p, and 1440p Xbox Remote Play requests and native-size software decoding.
- Fixed Xbox controller forwarding and session teardown. Updated the bundled DLSS Super Resolution dependency.
