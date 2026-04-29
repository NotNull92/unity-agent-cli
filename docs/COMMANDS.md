# Command Reference

Complete reference of all `unity-agent-cli` commands, flags, and parameters.

---

## Global Flags

These flags work with any command:

| Flag | Description | Default | Example |
|:---|:---|:---|:---|
| `--port` | Select Unity instance by active heartbeat port | Auto-discover | `--port 8091` |
| `--project` | Select Unity instance by project path | Auto-discover | `--project /path/to/project` |
| `--timeout` | Request timeout in milliseconds | `120000` (2 min) | `--timeout 30000` |

---

## editor

Control Unity Editor play mode and asset database.

```bash
unity-agent-cli editor <action> [flags]
```

### play

Enter play mode.

| Flag | Description | Default |
|:---|:---|:---|
| `--wait` | Block until fully entered play mode | `false` |

```bash
unity-agent-cli editor play --wait
```

### stop

Exit play mode.

| Flag | Description | Default |
|:---|:---|:---|
| `--wait` | Block until fully exited play mode | `false` |

```bash
unity-agent-cli editor stop
```

### pause

Toggle pause/resume (play mode only).

```bash
unity-agent-cli editor pause
```

### refresh

Refresh the AssetDatabase.

| Flag | Description | Default |
|:---|:---|:---|
| `--force` | Allow refresh during play mode | `false` |
| `--compile` | Recompile scripts and wait until done | `false` |

```bash
unity-agent-cli editor refresh --force
unity-agent-cli editor refresh --compile
```

**Note**: `refresh` is blocked in play mode unless `--force` is set.

---

## exec

Execute arbitrary C# code inside Unity Editor.

```bash
unity-agent-cli exec "<code>" [flags]
echo '<code>' | unity-agent-cli exec [flags]
```

| Flag | Description | Default |
|:---|:---|:---|
| `--usings` | Add extra using directives (comma-separated) | `""` |
| `--csc` | Path to csc compiler | Auto-detected |
| `--dotnet` | Path to dotnet runtime | Auto-detected |

```bash
# Basic execution
unity-agent-cli exec "return 1+1;"

# Unity API access
unity-agent-cli exec "return Application.dataPath;"

# Pipe to avoid shell escaping
echo 'return EditorSceneManager.GetActiveScene().name;' | unity-agent-cli exec

# Custom usings for ECS
unity-agent-cli exec "return World.All.Count;" --usings Unity.Entities
```

**Default usings**: `System`, `System.Collections.Generic`, `System.IO`, `System.Linq`, `System.Reflection`, `System.Threading.Tasks`, `UnityEngine`, `UnityEngine.SceneManagement`, `UnityEditor`, `UnityEditor.SceneManagement`, `UnityEditorInternal`

**Note**: Use `return` for output. Use `return null;` for void operations.

---

## console

Read, filter, and clear Unity console logs.

```bash
unity-agent-cli console [flags]
```

| Flag | Description | Default |
|:---|:---|:---|
| `--lines` | Limit to N entries | All |
| `--type` | Comma-separated: `error`, `warning`, `log` | `error,warning,log` |
| `--stacktrace` | `none`, `user`, `full` | `user` |
| `--clear` | Clear console after reading | `false` |

```bash
unity-agent-cli console
unity-agent-cli console --lines 20 --type error
unity-agent-cli console --stacktrace full
unity-agent-cli console --clear
```

---

## menu

Execute a Unity menu item by path.

```bash
unity-agent-cli menu "<path>"
```

```bash
unity-agent-cli menu "File/Save Project"
unity-agent-cli menu "Assets/Refresh"
unity-agent-cli menu "Window/General/Console"
```

**Note**: `File/Quit` is blocked for safety.

---

## screenshot

Capture a screenshot of the Unity editor.

```bash
unity-agent-cli screenshot [flags]
```

| Flag | Description | Default |
|:---|:---|:---|
| `--view` | `scene` or `game` | `scene` |
| `--width` | Image width in pixels | `1920` |
| `--height` | Image height in pixels | `1080` |
| `--output_path` | Output path (absolute or relative to project) | `Screenshots/screenshot.png` |

```bash
unity-agent-cli screenshot
unity-agent-cli screenshot --view game
unity-agent-cli screenshot --width 3840 --height 2160
unity-agent-cli screenshot --output_path captures/my_scene.png
```

---

## reserialize

Force reserialize assets (rewrite YAML/JSON with current Unity version).

```bash
unity-agent-cli reserialize [path...]
```

```bash
# Reserialize entire project
unity-agent-cli reserialize

# Reserialize specific assets
unity-agent-cli reserialize Assets/Scenes/Main.unity
unity-agent-cli reserialize Assets/Prefabs/A.prefab Assets/Prefabs/B.prefab
```

---

## test

Run Unity Test Framework tests.

```bash
unity-agent-cli test [flags]
```

| Flag | Description | Default |
|:---|:---|:---|
| `--mode` | `EditMode` or `PlayMode` | `EditMode` |
| `--filter` | Filter by namespace, class, or full test name | `""` |
| `--wait` | Wait for PlayMode tests to complete | `false` (EditMode: always waits) |

```bash
# EditMode tests (synchronous)
unity-agent-cli test

# PlayMode tests (asynchronous, requires --wait)
unity-agent-cli test --mode PlayMode --wait

# Filtered tests
unity-agent-cli test --filter MyNamespace.MyClass
```

**PlayMode behavior**: Returns `"running"` immediately. Results are written to `~/.unity-agent-cli/status/test-results-<port>.json`. The CLI polls this file when `--wait` is set.

---

## profiler

Control the Unity Profiler.

```bash
unity-agent-cli profiler <action> [flags]
```

| Action | Description |
|:---|:---|
| `hierarchy` | Show top-level profiler samples |
| `enable` | Start profiler recording |
| `disable` | Stop profiler recording |
| `status` | Show profiler state |
| `clear` | Clear all captured frames |

**Hierarchy flags**:

| Flag | Description | Default |
|:---|:---|:---|
| `--depth` | Recursive depth (0=unlimited) | `1` |
| `--root` | Set root by name (substring match) | `""` |
| `--frames` | Average over last N frames | `1` |
| `--parent` | Drill into item by ID | `0` |
| `--min` | Filter items below threshold (ms) | `0` |
| `--sort` | `total` or `self` | `total` |

```bash
unity-agent-cli profiler hierarchy
unity-agent-cli profiler hierarchy --depth 5 --frames 30
unity-agent-cli profiler enable
```

---

## list

List all registered tools with their parameter schemas.

```bash
unity-agent-cli list
```

Useful for discovering custom tools added to the project.

---

## status

Show current Unity Editor state.

```bash
unity-agent-cli status
```

**Output example**:
```json
{
  "state": "ready",
  "compiling": false,
  "compileErrors": false,
  "projectPath": "/Users/admin/Unity/MyProject",
  "processId": 12345,
  "port": 8090
}
```

---

## update

Self-update the CLI binary from GitHub releases.

```bash
unity-agent-cli update [flags]
```

| Flag | Description | Default |
|:---|:---|:---|
| `--check` | Check for updates without installing | `false` |

```bash
unity-agent-cli update --check
unity-agent-cli update
```

---

## version

Show CLI version.

```bash
unity-agent-cli version
```

---

## asset-config

Manage asset configuration (interactive TUI or command-based).

```bash
unity-agent-cli asset-config <subcommand>
```

| Subcommand | Description |
|:---|:---|
| (no args) | Interactive checkbox UI |
| `list` | List all assets with status |
| `enable <id>` | Enable an asset |
| `disable <id>` | Disable an asset |
| `detect` | Auto-detect installed assets (requires Unity) |

| Flag | Description | Default |
|:---|:---|:---|
| `--json` | Output enabled assets as JSON | `false` |

---

## Custom Tool Invocation

Any `[UnityCliTool]` class can be called directly by its snake_case name:

```bash
# Call a custom tool directly
unity-agent-cli my_custom_tool

# Call with parameters
unity-agent-cli my_custom_tool --params '{"key":"value"}'
```

Use `unity-agent-cli list` to discover available tools.

---

## Related Documentation

- [`GO_CLI.md`](GO_CLI.md) — Go CLI internals
- [`CSHARP_CONNECTOR.md`](CSHARP_CONNECTOR.md) — C# connector internals
- [`CUSTOM_TOOLS.md`](CUSTOM_TOOLS.md) — Writing custom tools
