# 列车长种子界面：内嵌资源

`data.win` 中的对话项和种子函数由
`analysis/optimization/apply_conductor_seed.csx` 生成。UI 与文案是游戏目录中的
松散文件，加载器会把这里的快照嵌进二进制，并在替换 `data.win` 前自动部署。

## 文件对应关系

```text
ui_seed/npc_left_map_seed.ui   ->  ZS_vanilla/ui/npc_left_map_seed.ui
ui_seed/npc_left_talk.ui       ->  ZS_vanilla/ui/npc_left_talk.ui（只补 map_seed 条目）
ui_seed/language_en.csv        ->  ZS_vanilla/languages/english/english.csv
ui_seed/language_zh.csv        ->  ZS_vanilla/languages/chinese_simplified/chinese_simplified.csv
```

语言 CSV 只包含 `npc.interaction.map_seed` 与 `ui.map_seed.*` 这些种子相关行。
加载器会先移除目标文件里同一命名空间的旧行，再按快照写回，因此重复追加不会
产生重复行，也会把旧文案更新成快照内容；其它 Descriptor 原样保留。

## 部署行为

- `npc_left_map_seed.ui` 内容不同才重写；
- `npc_left_talk.ui` 已经有 `"map_seed"` 条目时完全不动，缺少时才插入；
- 语言 CSV 按上述命名空间替换，并补齐缺失行；
- 部署发生在 `data.win` 替换之前，部署失败时不会留下“对话项存在但页面缺失”的状态；
- `--dry-run` 只生成 `data.win.coop-dry-run`，不修改 UI/CSV；
- `--restore` 只恢复 `data.win`，不会删除已经部署的 UI/CSV。

如果游戏更新改变了 `npc_left_talk.ui` 的 `nextPageDict` 结构，加载器会报错并
停止替换，此时需要把 `"map_seed"` 条目手动合并进新文件，或更新这里的快照。

## 修改流程

1. 修改 `ui_seed` 下的文件；
2. 重新编译加载器，`build.rs` 会自动嵌入新内容；
3. 运行加载器，部署与 `data.win` 替换会一起完成。

不要再用 `cat >>` 手动追加 CSV；重复行会由加载器清理，但手动追加没有意义。
