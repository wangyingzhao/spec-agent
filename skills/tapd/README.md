# TAPD 技能包

**书虫**（TAPD Agent）— 负责项目管理，对接 Internal TAPD 平台，支持查询和操作需求、缺陷、迭代。

## 指令

| 文件 | 触发方式 | 职责 |
|------|---------|------|
| `commands/tapd.md` | `/tapd` | 需求/缺陷/迭代的查询与操作 |

## 快速使用

```bash
# 查看我的进行中需求
/tapd story list

# 查看需求详情
/tapd story detail <id>

# 查询当前迭代
/tapd iter list

# 查看缺陷列表
/tapd bug list --status open

# 帮助
/tapd help
```

## 凭证配置

凭证由 `./init.sh` 自动写入 `~/.claude/tapd.env`（权限 600，不进 git）：

```bash
TAPD_API_USER=<your-tapd-user>
TAPD_API_PASSWORD=xxx               # 已由 init.sh 预填
TAPD_API_BASE_URL=https://tapd-api.example.com/tapd
TAPD_WORKSPACE_ID=32164738          # 已预填（EP Flow 项目）
TAPD_USER_NICK=                     # ← 填入你的 TAPD 昵称（用于过滤我的需求）
```

执行 `./init.sh` 后，**只需补充 `TAPD_USER_NICK`**。

## 子命令速查

| 子命令 | 说明 |
|--------|------|
| `story list` | 查询需求列表（默认：我的进行中） |
| `story detail <id>` | 需求详情 |
| `story create` | 创建需求 |
| `story update <id>` | 更新需求 |
| `bug list` | 查询缺陷列表 |
| `bug detail <id>` | 缺陷详情 |
| `bug create` | 创建缺陷 |
| `bug update <id>` | 更新缺陷 |
| `iter list` | 迭代列表 |
| `iter detail <id>` | 迭代详情及需求 |
| `help` | 显示帮助 |

## 详细文档

见 [QUICKSTART.md TAPD 章节](../../docs/QUICKSTART.md)。
