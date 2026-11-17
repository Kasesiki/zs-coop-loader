//! 种子界面与语言文件的自动部署。
//!
//! 对话项由 `apply_conductor_seed.csx` 写进 `data.win`，但 UI 和文案是游戏目录
//! 里的松散文件。这里把 `ui_seed` 的内容嵌进二进制，并在替换 `data.win` 前
//! 幂等地部署：
//! - `npc_left_map_seed.ui` 是新增页面，内容不同才重写；
//! - `npc_left_talk.ui` 只在缺少 `"map_seed"` 条目时插入，不覆盖游戏更新；
//! - 语言 CSV 由内嵌快照接管种子命名空间，清掉重复行和旧文案，其它行保留。

use crate::assets;
use std::collections::HashSet;
use std::fs;
use std::path::{Path, PathBuf};

const MAP_SEED_UI: &str = "npc_left_map_seed.ui";
const TALK_UI: &str = "npc_left_talk.ui";
const ENGLISH_CSV: &str = "language_en.csv";
const CHINESE_CSV: &str = "language_zh.csv";

pub fn deploy(game_dir: &Path) -> Result<(), String> {
    let ui_dir = game_dir.join("ZS_vanilla/ui");
    fs::create_dir_all(&ui_dir)
        .map_err(|error| format!("无法创建 UI 目录 {}：{error}", ui_dir.display()))?;

    let map_seed =
        assets::ui_asset(MAP_SEED_UI).ok_or_else(|| format!("内嵌资源缺少 {MAP_SEED_UI}"))?;
    write_if_changed(&ui_dir.join(MAP_SEED_UI), map_seed)?;

    let talk = assets::ui_asset(TALK_UI).ok_or_else(|| format!("内嵌资源缺少 {TALK_UI}"))?;
    merge_talk(&ui_dir.join(TALK_UI), talk)?;

    deploy_csv(game_dir, "english", ENGLISH_CSV)?;
    deploy_csv(game_dir, "chinese_simplified", CHINESE_CSV)?;
    Ok(())
}

fn deploy_csv(game_dir: &Path, language: &str, asset_name: &str) -> Result<(), String> {
    let target = game_dir
        .join("ZS_vanilla/languages")
        .join(language)
        .join(format!("{language}.csv"));
    if !target.is_file() {
        println!(
            "警告：找不到语言文件 {}，跳过种子文案部署",
            target.display()
        );
        return Ok(());
    }
    let embedded =
        assets::csv_asset(asset_name).ok_or_else(|| format!("内嵌资源缺少 {asset_name}"))?;
    let embedded = std::str::from_utf8(embedded)
        .map_err(|error| format!("{asset_name} 不是 UTF-8：{error}"))?;
    merge_csv(&target, embedded)
}

fn write_if_changed(path: &Path, bytes: &[u8]) -> Result<(), String> {
    if fs::read(path).ok().as_deref() == Some(bytes) {
        return Ok(());
    }
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)
            .map_err(|error| format!("无法创建 {}：{error}", parent.display()))?;
    }

    let temporary = temporary_path(path);
    fs::write(&temporary, bytes)
        .map_err(|error| format!("无法写入 {}：{error}", temporary.display()))?;
    if fs::rename(&temporary, path).is_err() {
        // Windows 不允许 rename 覆盖已存在文件；UI 文件很小，退回复制。
        fs::copy(&temporary, path)
            .map_err(|error| format!("无法替换 {}：{error}", path.display()))?;
        let _ = fs::remove_file(&temporary);
    }
    Ok(())
}

fn merge_talk(path: &Path, fallback: &[u8]) -> Result<(), String> {
    if !path.is_file() {
        return write_if_changed(path, fallback);
    }
    let text = fs::read_to_string(path)
        .map_err(|error| format!("无法读取 {}：{error}", path.display()))?;
    if text.contains("\"map_seed\":") {
        return Ok(());
    }

    let merged = insert_map_seed(&text).ok_or_else(|| {
        format!(
            "{} 里找不到 nextPageDict，游戏更新可能改变了 UI 结构；请手动合并 map_seed 条目",
            path.display()
        )
    })?;
    write_if_changed(path, merged.as_bytes())
}

/// 在 `nextPageDict = { ... }` 的闭合花括号前插入种子页面。
fn insert_map_seed(text: &str) -> Option<String> {
    let dict = text.find("nextPageDict")?;
    let open = dict + text[dict..].find('{')?;
    let close = matching_brace(text, open)?;

    let line_start = text[..close].rfind('\n').map_or(0, |index| index + 1);
    let closing_indent = &text[line_start..close];
    let indent = if closing_indent.chars().all(char::is_whitespace) {
        closing_indent
    } else {
        "\t"
    };

    let newline = if text.contains("\r\n") { "\r\n" } else { "\n" };
    let entry = format!(
        "{indent}\"map_seed\":  {{ {newline}\
         {indent}\tfull_screen : \tfalse,{newline}\
         {indent}\tleft_frame : \t\"ZS_vanilla/ui/npc_left_map_seed.ui\",{newline}\
         {indent}\tright_frame : \t\"ZS_vanilla/ui/npc_right_talk.ui\",{newline}\
         {indent}}},{newline}"
    );

    let mut output = String::with_capacity(text.len() + entry.len());
    output.push_str(&text[..line_start]);
    output.push_str(&entry);
    output.push_str(&text[line_start..]);
    Some(output)
}

fn matching_brace(text: &str, open: usize) -> Option<usize> {
    let bytes = text.as_bytes();
    let mut depth = 0usize;
    let mut index = open;
    let mut in_string = false;
    let mut escaped = false;
    let mut line_comment = false;
    let mut block_comment = false;

    while index < bytes.len() {
        let byte = bytes[index];
        if line_comment {
            line_comment = byte != b'\n';
            index += 1;
            continue;
        }
        if block_comment {
            if byte == b'*' && bytes.get(index + 1) == Some(&b'/') {
                block_comment = false;
                index += 2;
            } else {
                index += 1;
            }
            continue;
        }
        if in_string {
            if escaped {
                escaped = false;
            } else if byte == b'\\' {
                escaped = true;
            } else if byte == b'"' {
                in_string = false;
            }
            index += 1;
            continue;
        }

        match byte {
            b'"' => in_string = true,
            b'/' if bytes.get(index + 1) == Some(&b'/') => {
                line_comment = true;
                index += 2;
                continue;
            }
            b'/' if bytes.get(index + 1) == Some(&b'*') => {
                block_comment = true;
                index += 2;
                continue;
            }
            b'{' => depth += 1,
            b'}' => {
                depth = depth.checked_sub(1)?;
                if depth == 0 {
                    return Some(index);
                }
            }
            _ => {}
        }
        index += 1;
    }
    None
}

fn merge_csv(path: &Path, embedded: &str) -> Result<(), String> {
    let text = fs::read_to_string(path)
        .map_err(|error| format!("无法读取 {}：{error}", path.display()))?;
    let merged = merge_csv_text(&text, embedded);
    write_if_changed(path, merged.as_bytes())
}

fn merge_csv_text(text: &str, embedded: &str) -> String {
    let (bom, body) = text
        .strip_prefix('\u{feff}')
        .map_or(("", text), |body| ("\u{feff}", body));
    let newline = if body.contains("\r\n") { "\r\n" } else { "\n" };

    let rows: Vec<&str> = embedded
        .lines()
        .filter(|line| !line.trim().is_empty())
        .collect();
    let managed: HashSet<String> = rows.iter().filter_map(|row| descriptor(row)).collect();

    // 种子命名空间由加载器维护：先移除旧行（包括手工追加产生的重复行），
    // 再按内嵌快照写回。其它 Descriptor 原样保留。
    let lines: Vec<&str> = body
        .lines()
        .filter(|line| descriptor(line).is_none_or(|descriptor| !managed.contains(&descriptor)))
        .collect();

    let mut present: HashSet<String> = lines.iter().filter_map(|line| descriptor(line)).collect();
    let mut output = String::with_capacity(text.len() + embedded.len());
    output.push_str(bom);
    let mut first = true;
    for line in lines {
        if !first {
            output.push_str(newline);
        }
        output.push_str(line);
        first = false;
    }
    for row in rows {
        let Some(descriptor) = descriptor(row) else {
            continue;
        };
        if !present.insert(descriptor) {
            continue;
        }
        if !first {
            output.push_str(newline);
        }
        output.push_str(row);
        first = false;
    }

    if !first {
        output.push_str(newline);
    }
    output
}

fn descriptor(line: &str) -> Option<String> {
    let mut fields = line.split(',');
    let first = fields.next()?.trim();
    if first.is_empty() || !first.chars().all(|ch| ch.is_ascii_digit()) {
        return None;
    }
    fields.next().map(|field| field.trim().to_owned())
}

fn temporary_path(path: &Path) -> PathBuf {
    let name = path
        .file_name()
        .and_then(|name| name.to_str())
        .unwrap_or("asset");
    path.with_file_name(format!(".{name}.coop-tmp-{}", std::process::id()))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn inserts_map_seed_before_dict_close() {
        let text = "build UiBox {\n\tnextPageDict = {\n\t\t\"heal\": {},\n\t}\n}\n";
        let merged = insert_map_seed(text).expect("dict");
        assert!(merged.contains("\"map_seed\""));
        assert!(merged.find("\"map_seed\"").unwrap() < merged.find("\t}\n}").unwrap());
        assert!(merged.contains("\"heal\": {}"));
    }

    #[test]
    fn inserts_into_the_real_talk_snapshot() {
        let text = include_str!("../ui_seed/npc_left_talk.ui");
        let merged = insert_map_seed(text).expect("real nextPageDict");
        assert_eq!(merged.matches("\"map_seed\":").count(), 2);
        assert!(merged.contains("\"enter_cc_base\""));
        if text.contains("\r\n") {
            assert_eq!(merged.matches("\r\n").count(), merged.matches('\n').count());
        }
    }

    #[test]
    fn csv_merge_is_idempotent_and_drops_old_duplicates() {
        let text = "04388,npc.interaction.map_seed,User Interface,64,Old\n\
                    04388,npc.interaction.map_seed,User Interface,64,New\n\
                    99999,other.key,User Interface,64,Keep\n";
        let embedded = "04388,npc.interaction.map_seed,User Interface,64,New\n\
                        04390,ui.map_seed.hint,User Interface,512,Hint\n";
        let once = merge_csv_text(text, embedded);
        assert_eq!(once.matches("npc.interaction.map_seed").count(), 1);
        assert!(once.contains("New"));
        assert!(!once.contains("Old"));
        assert!(once.contains("other.key"));
        assert!(once.contains("ui.map_seed.hint"));
        assert_eq!(merge_csv_text(&once, embedded), once);
    }

    #[test]
    fn deploy_is_idempotent_on_a_game_tree() {
        let root = std::env::temp_dir().join(format!(
            "zs-seed-ui-test-{}-{}",
            std::process::id(),
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_nanos()
        ));
        let ui = root.join("ZS_vanilla/ui");
        let english = root.join("ZS_vanilla/languages/english");
        let chinese = root.join("ZS_vanilla/languages/chinese_simplified");
        fs::create_dir_all(&ui).unwrap();
        fs::create_dir_all(&english).unwrap();
        fs::create_dir_all(&chinese).unwrap();
        fs::write(
            ui.join(TALK_UI),
            "build UiBox {\n\tnextPageDict = {\n\t\t\"heal\": {},\n\t}\n}\n",
        )
        .unwrap();
        fs::write(
            english.join("english.csv"),
            "04388,npc.interaction.map_seed,User Interface,64,Old\n\
             04388,npc.interaction.map_seed,User Interface,64,New\n\
             99999,other.key,User Interface,64,Keep\n",
        )
        .unwrap();
        fs::write(chinese.join("chinese_simplified.csv"), "").unwrap();

        deploy(&root).unwrap();
        let talk = fs::read_to_string(ui.join(TALK_UI)).unwrap();
        assert!(talk.contains("\"map_seed\""));
        assert!(talk.contains("\"heal\": {}"));
        assert!(ui.join(MAP_SEED_UI).is_file());
        let csv = fs::read_to_string(english.join("english.csv")).unwrap();
        assert_eq!(csv.matches("npc.interaction.map_seed").count(), 1);
        assert!(csv.contains("ui.map_seed.hint"));
        assert!(csv.contains("other.key"));

        let before = (
            fs::read(ui.join(TALK_UI)).unwrap(),
            fs::read(ui.join(MAP_SEED_UI)).unwrap(),
            fs::read(english.join("english.csv")).unwrap(),
        );
        deploy(&root).unwrap();
        let after = (
            fs::read(ui.join(TALK_UI)).unwrap(),
            fs::read(ui.join(MAP_SEED_UI)).unwrap(),
            fs::read(english.join("english.csv")).unwrap(),
        );
        assert_eq!(before, after);
        fs::remove_dir_all(root).unwrap();
    }
}
