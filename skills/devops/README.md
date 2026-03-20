# DevOps 技能包

**信鸽**（DevOps Agent）— 负责 CI/CD 流水线与应用发布，对接 Bilibili EP Agileflow 平台。

## 指令

| 文件 | 触发方式 | 职责 |
|------|---------|------|
| `commands/deploy.md` | `/devops:deploy` | 一键构建并发布（caster 平台） |
| `commands/pipeline.md` | `/devops:pipeline` | 流水线查询与状态跟踪 |

## 快速使用

```bash
# 一键发布（全默认：从 env.properties 取 appid，当前 git 分支，uat 环境）
/devops:deploy

# 发布到 prod
/devops:deploy --env prod

# 查看发布进度
/devops:pipeline status <appid>
```

## 凭证配置

凭证存放于 `~/.claude/agileflow.env`（由 `./init.sh` 自动创建，权限 600，不进 git）。
前三项已预填，**只需补填 Cookie**：

```bash
# 以下三项已由 init.sh 预填，无需修改（pipeline 指令使用）
AGILEFLOW_CLIENT_ID=97322054661
AGILEFLOW_CLIENT_SECRET=d8853ef964dc47308c12de10d48b7819
AGILEFLOW_PERM_CODE=ee_platform
AGILEFLOW_COOKIE=   # ← deploy 指令使用，从浏览器登录后复制
```

## 安全机制

- **发布前检查**：自动检测是否有正在进行中的发布流水线，有则阻止，避免重复发布
- **加 `--force`**：跳过进行中检查，强制发布
- **声明式构建保护**：检测到 `declarative_mode=1` 时自动停止，引导至页面操作

## 详细文档

见 [QUICKSTART.md DevOps 章节](../../docs/QUICKSTART.md#devops-指令devops)。
