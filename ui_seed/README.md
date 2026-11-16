# 列车长种子界面：松散文件快照

`data.win` 中的对话项和种子函数由
`analysis/optimization/apply_conductor_seed.csx` 生成，加载器会自动应用。
种子界面的 UI 与文案是游戏目录中的松散文件，不写入 `data.win`，因此在这里保留
一份可用版本，供游戏更新覆盖后重新部署。

## 文件对应关系

```text
ui_seed/npc_left_map_seed.ui   ->  ZS_vanilla/ui/npc_left_map_seed.ui（新文件）
ui_seed/npc_left_talk.ui       ->  ZS_vanilla/ui/npc_left_talk.ui
ui_seed/language_en.csv        ->  追加到 ZS_vanilla/languages/english/english.csv
ui_seed/language_zh.csv        ->  追加到 ZS_vanilla/languages/chinese_simplified/chinese_simplified.csv
```

`language_*.csv` 只包含新增的 11 行，行号从 `04388` 开始。追加前先确认这些
Descriptor 在当前文件中不存在，避免重复。

## 重新部署

在游戏根目录执行：

```bash
cp coop/ui_seed/npc_left_map_seed.ui ZS_vanilla/ui/npc_left_map_seed.ui
cp coop/ui_seed/npc_left_talk.ui ZS_vanilla/ui/npc_left_talk.ui
cat coop/ui_seed/language_en.csv >> ZS_vanilla/languages/english/english.csv
cat coop/ui_seed/language_zh.csv >> ZS_vanilla/languages/chinese_simplified/chinese_simplified.csv
```

注意：

- 两份 `.ui` 快照对应当前游戏版本。如果游戏更新修改了 `npc_left_talk.ui` 的
  其它内容，不要直接覆盖，改为手动把 `"map_seed"` 条目合并进 `nextPageDict`。
- 追加 CSV 前检查 Descriptor 是否已存在；重复执行 `cat >>` 会产生重复行。
- 追加前确认目标 CSV 以换行结尾，否则第一行会拼到最后一行后面。
- 修改 `data.win` 后需要重启游戏，UI 文件在打开界面时读取。
