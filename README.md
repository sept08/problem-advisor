# problem-advisor

A 100-tool thinking toolkit for hard decisions, refactored into an executable advisor.

一个难题顾问：先判断真正卡住的是什么，再从一百个思维工具里挑出能改变结论的那一个。

## 目录

```
problem-advisor/
├── skill/modern-thinking-tools/   # 技能版本：一百个工具的知识库
├── expert/                        # 专家版本：角色、元数据、头像
├── scripts/build-expert.sh        # 构建：合并 → 校验 → 注册 → 打包
└── dist/                          # 导出的上传包
```

三个路径各管一件事：

- **`skill/`** 是技能本体。`SKILL.md` 是按问题信号组织的路由表，`references/` 是十章工具条目，每个工具含「何时调用 / 核心模型 / Agent 程序 / 诊断问题 / 边界与输出」。这一层可以单独作为技能发布。
- **`expert/`** 是专家的源码。`agents/problem-advisor.md` 是角色定义（说话方式、工作流程、拒绝清单），`.codebuddy-plugin/plugin.json` 是市场展示信息，`avatars/` 是头像。
- **`dist/`** 只存打包好的 zip，不入 git（可复现，历史版本以 git tag 为准）。

## 安装与使用

这个工具的使用者是 Agent，不是人。根据你用的 Agent 选择装载方式：WorkBuddy 用专家形态，其他 Agent 用技能形态。

### WorkBuddy：作为专家使用

专家是「角色 + 方法 + 知识库」的打包形态，用户以对话方式召唤，不需要自己挑工具。

- **从市场安装**：专家中心 → 搜索「难题顾问」→ 召唤专家。
- **本地装载**：在仓库根执行 `./scripts/build-expert.sh`。脚本会把 `expert/` 和 `skill/` 合并成完整专家包，装进 WorkBuddy 的专家目录并完成注册，客户端「我的专家」里即可看到。

召唤后直接说你的问题，不用指定用哪个工具——角色会先判断卡在哪，再决定用不用工具、用几个。

### 其他 Agent：作为技能使用

技能是「一段可被调用的方法与知识」，不预设角色，靠 `SKILL.md` 里 `description` 的触发条件让 Agent 自行判断何时加载。

1. 把 `skill/modern-thinking-tools/` **整个目录**复制到所用 Agent 的技能目录：

   | Agent | 用户级目录 | 项目级目录 |
   |---|---|---|
   | WorkBuddy | `~/.workbuddy/skills/` | `<项目>/.workbuddy/skills/` |
   | Claude Code | `~/.claude/skills/` | `<项目>/.claude/skills/` |

2. 目录名保持 `modern-thinking-tools`，与 `SKILL.md` 里的 `name` 字段一致。

3. **`references/` 必须一起复制。** `SKILL.md` 只是路由表，一百个工具的具体条目都在 references 里，缺了它技能就只剩一张目录。

全部是纯 Markdown，没有脚本、没有依赖，复制即完成安装。

如果你的 Agent 不支持技能目录，退一步：把 `SKILL.md` 全文放进系统提示，`references/` 作为可读文件提供给它，并约定先读路由表定位、再读对应章节。

### 两种形态的差别

| | 专家 | 技能 |
|---|---|---|
| 触发方式 | 用户主动召唤 | Agent 按 description 自行判断 |
| 是否带角色口吻 | 有 | 无 |
| 输出约束 | 强（拒绝清单、分级输出写在角色里） | 弱（只有 SKILL.md 的运行规则） |
| 适合 | 有明确难题要谈 | 希望日常对话里被自动增强 |

同一个知识库，两种装载方式决定的是「谁来约束它」：专家靠角色，技能靠触发条件。

## 迭代

改文件，跑一条命令：

```bash
./scripts/build-expert.sh --bump
```

它会做四件事：把 `expert/` 和 `skill/` 合并成完整专家包装进 WorkBuddy 专家目录 → 校验 → 注册 → 在 `dist/` 下生成带版本号的 zip。

跑完客户端里就是新版，可以直接试；`dist/` 里的 zip 拿去开放平台上传。

只是本地试、不准备发版，去掉 `--bump`。`--check` 可以只比对 `skill/` 与安装目录是否一致。

**注意**：`expert/` 里没有 `skills/` 目录，那是构建时从 `skill/` 复制进去的。要改工具内容一律改 `skill/`，不要在 WorkBuddy 安装目录里改，那里是产物，下次构建会被覆盖。

## 发版约定

- 内容有实质改动才 `--bump`，否则平台可能认成同一个包，上传后用户仍是旧版。
- 版本号在 `expert/.codebuddy-plugin/plugin.json` 里，`--bump` 自动递增 patch 位。
- 建议每次发版打一个 tag：`git tag v1.0.1 && git push --tags`。

## 方法来源

判断体系源自万维钢《现代思维工具100讲》。本仓库在此基础上做了重构：为每个工具补齐可执行的调用条件、诊断问题与边界约束，按问题信号重组导航，并把方法论转写为一个可对话的角色。
