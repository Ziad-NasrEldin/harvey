# Harvey for macOS

A local AppKit/WebKit window for Harvey's dashboard. Launching the app starts the dashboard on loopback port 15555. Quitting stops that dashboard process. The sales heartbeat is controlled separately inside Harvey.

Install the Python dependencies in the repository's `.venv`, then run `macos/install.sh`. The installer embeds this checkout's path into the app; keep the checkout in place or reinstall after moving it. A Harvey-only Codex CLI can be linked at `.venv/bin/codex`. Credentials, tokens, database, product training and local configuration remain excluded from Git.

The app is locally signed, not notarized. Artwork source: `render-icon.swift`; shared icon: `../assets/harvey.png`.
