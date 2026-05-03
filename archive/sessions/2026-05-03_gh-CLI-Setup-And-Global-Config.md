# 2026-05-03: gh CLI Setup & Global Config

`tags: #github #gh-cli #config #workflow #windows`

**结论：** 完成 gh CLI 全流程安装配置，确立全局 vs 项目配置的分层策略。

### 操作记录

**gh CLI 安装配置：**
- **连通性测试：** 通过 `curl` 直接调用 GitHub API 成功，确认 shell 代理配置生效
- **安装方式：** `winget install --id GitHub.cli --accept-source-agreements --accept-package-agreements`
- **PATH 问题：** winget 装到 Windows PATH，Git Bash (MINGW64) 未自动继承 → 手动 `export PATH="$PATH:/c/Program Files/GitHub CLI"` 并写入 `~/.bashrc`
- **登录：** `gh auth login -w` (web 方式)，token 存入 Windows keyring
- **账号：** LIU-31415，scopes: `repo`, `gist`, `read:org`

**全局配置：**
- 创建 `~/.claude/CLAUDE.md`，写入称呼"超哥"和事后效率建议习惯
- **配置分层策略：** 全局设置 → `~/.claude/CLAUDE.md`，项目设置 → `项目目录/CLAUDE.md`
- 记忆系统：保存 feedback 规则（事后提效建议、全局 vs 项目配置策略）

### 要点

- Windows 上用 winget 装命令行工具后，Git Bash 可能需要手动加 PATH
- gh 的 token 存 keyring，重启不掉登录
- 没装 gh 时 curl 调 GitHub API 也能用，只是每次要手写完整 URL
