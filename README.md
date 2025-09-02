# k9s Nix Flake

Nix flake để setup k9s với các plugin và cấu hình có sẵn.

## 🚀 Quick Start

### Chạy k9s với cấu hình sẵn có (Fully Automatic!)
```bash
# Automatic - sử dụng Nix store config (read-only, luôn up-to-date)
nix run github:thuanpham582002/nix-k9s

# Alternative - writable config (để customize)  
nix run github:thuanpham582002/nix-k9s#k9s-writable
```

### Clone và phát triển
```bash
git clone https://github.com/thuanpham582002/nix-k9s
cd nix-k9s
nix develop

# Test locally
nix run .#k9s-configured     # Automatic mode
nix run .#k9s-writable       # Writable mode
```

### Sử dụng trong project khác
```nix
{
  inputs = {
    k9s-config.url = "github:thuanpham582002/nix-k9s";
  };
}
```

## 📦 Tính năng

### ⚙️ Cấu hình có sẵn
- **UI Settings**: Mouse support, themes, refresh rates
- **Logger**: Tail 100 lines, 5000 buffer
- **Skin**: Dracula theme
- **Performance**: 2 second refresh rate

### 🔌 Plugins
- **get-all**: Get all resources with less (g) *requires kubectl get-all plugin*
- **dive**: Phân tích Docker images (Shift-I)
- **stern**: Multi-pod log tailing (Ctrl-L)
- **port-forward**: Port forwarding (Shift-F)
- **edit**: Edit resources (e)
- **json**: Export resources as JSON (j)
- **decode-secret**: Decode Kubernetes secrets (x)
- **raw-logs-follow**: Follow logs real-time (Ctrl-G)
- **log-less**: View logs with less pager (Shift-K)
- **log-less-container**: Container logs with less (Shift-L)
- **remove-finalizers**: Remove finalizers (Ctrl-F) ⚠️ DANGEROUS
- **debug-container**: Add debug container (Shift-D) ⚠️ DANGEROUS
- **watch-events**: Watch namespace events (Shift-E)
- **rm-ns**: Remove namespace finalizers (n) ⚠️ DANGEROUS
- **szero-down**: Scale down namespace (Shift-Z) ⚠️ DANGEROUS *requires szero*
- **szero-up**: Scale up namespace (Shift-U) ⚠️ DANGEROUS *requires szero*
- **pvc-debug**: Debug PVC with temporary pod (Shift-P)

### 🎯 Aliases
- `dp` → deployments
- `sts` → statefulsets
- `svc` → services
- `ing` → ingresses
- `cm` → configmaps
- `sec` → secrets
- `pv` → persistentvolumes
- `pvc` → persistentvolumeclaims

### ⌨️ Hotkeys
- `:` → Command mode
- `?` → Help
- `q` → Quit
- `v` → View YAML
- `d` → Describe
- `l` → Logs
- `Ctrl-D` → Delete
- `Ctrl-N/P` → Switch namespaces

## 🛠️ Tools

Development shell bao gồm:
- **k9s**: Kubernetes TUI
- **kubectl**: Kubernetes CLI
- **stern**: Multi-pod log tailing
- **dive**: Docker image explorer
- **helm**: Kubernetes package manager
- **jq**: JSON processor (required for rm-ns plugin)

## 🚀 Usage Examples

### Development workflow
```bash
# Enter development shell
nix develop

# Automatic mode - không cần setup gì!
nix run .#k9s-configured

# Writable mode - nếu muốn customize
nix run .#k9s-writable
```

### 🔄 Automatic vs Writable modes

| Mode | Config Source | Runtime Dirs | Updates | Customizable | Use Case |
|------|---------------|--------------|---------|--------------|----------|
| **k9s-configured** | Nix store overlay | Temp (auto-cleanup) | Automatic | No | Daily use, always latest |
| **k9s-writable** | ~/.config/k9s | Persistent | Manual sync | Yes | Development, customization |

### ✨ Technical Implementation:
- **Overlay mode**: Creates temporary writable overlay from Nix store config
- **Auto-cleanup**: Temporary directories removed on exit
- **No pollution**: No files left in home directory
- **Permission handling**: All runtime directories writable

### In CI/CD
```bash
nix run github:thuanpham582002/nix-k9s -- --context production
```

## 📋 Plugin Dependencies

Một số plugins yêu cầu tools bổ sung:

### Required Tools
- **get-all**: `kubectl get-all` plugin
- **szero-down/szero-up**: `szero` tool from https://github.com/jadolg/szero

### Install Dependencies
```bash
# Install kubectl get-all plugin
kubectl krew install get-all

# Install szero (Go required)
go install github.com/jadolg/szero@latest
```

## 🔧 Customization

### Thêm plugin mới
Edit `flake.nix` trong section `k9sPlugins`:

```yaml
new-plugin:
  shortCut: Shift-N
  confirm: true
  description: "New plugin"
  scopes:
    - pods
  command: your-command
  args:
    - $NAME
```

### Thay đổi theme
Config sẽ được copy vào `~/.config/k9s/config.yaml`:
```yaml
skin: your-theme  # dracula, monokai, etc.
```

## 🎨 Themes có sẵn

k9s hỗ trợ các themes:
- `dracula` (default)
- `monokai`
- `solarized-dark`
- `solarized-light`
- `nord`
- `gruvbox`

## 🤝 Contributing

1. Fork repository
2. Tạo feature branch
3. Commit changes
4. Push và tạo Pull Request

## 📝 License

MIT License