# Windows CLI Tool Installation

type: tech/tool-install
generated: 2026-05-03
updated: 2026-05-03
source_logs: [archive/sessions/2026-05-03_gh-CLI-Setup-And-Global-Config.md]

## Step Sequence

1. **Phase 1: Connectivity Check**
   - Test proxy/network: `curl <api-endpoint>` before installing
   - Verify shell environment can reach target service

2. **Phase 2: Install**
   - Use `winget install --id <publisher.tool> --accept-source-agreements --accept-package-agreements`
   - Note: winget installs to Windows PATH, NOT Git Bash (MINGW64) PATH

3. **Phase 3: PATH Fix (Git Bash specific)**
   - Check if tool works in MINGW64 after install
   - If not found: `export PATH="$PATH:<windows-install-path>"` (use forward slashes, quoted)
   - Persist in `~/.bashrc` with `echo 'export PATH="$PATH:<path>"' >> ~/.bashrc`

4. **Phase 4: Authentication**
   - Use `gh auth login -w` for web-based device flow (no PAT needed)
   - Token persists in Windows keyring across restarts

5. **Phase 5: Verify**
   - Run tool with auth: `gh auth status`
   - Run a simple command: `gh repo list --limit 3`

## Tool Checklist

- `winget`: Windows package manager
- `curl`: For connectivity/API testing
- `gh`: GitHub CLI

## Success Criteria

- [ ] Tool found in PATH after new shell session
- [ ] Authentication persists without re-login
- [ ] Basic commands work (`gh repo list`, etc.)

## Common Pitfalls

- Git Bash not inheriting Windows PATH for newly winget-installed tools
  → Prevention: Always check PATH in MINGW64 and add manually if needed
- `gh auth login -p` (PAT mode) asks for token manually, use `-w` instead for web flow
  → Prevention: Default to `-w` web device flow
