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
