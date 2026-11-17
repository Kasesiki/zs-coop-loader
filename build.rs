//! 编译期资源打包。
//!
//! 这里做两件事：
//! 1. 把 `analysis/optimization/*.csx` 嵌成字符串；
//! 2. 把 `ui_seed` 下的 UI 与语言 CSV 嵌成字节。
//!
//! UTMT 保持外部引用：它体积大，解压缓存反而累赘，启动时从
//! `coop/tool/utmt/UndertaleModCli` 调用即可。

use std::env;
use std::fs;
use std::path::{Path, PathBuf};

const SCRIPT_ROOT: &str = "analysis/optimization";
const SEED_ROOT: &str = "ui_seed";

fn main() {
    println!("cargo:rerun-if-changed={SCRIPT_ROOT}");
    println!("cargo:rerun-if-changed={SEED_ROOT}");

    let out_dir = PathBuf::from(env::var("OUT_DIR").expect("OUT_DIR 未设置"));
    write_scripts(&out_dir);
    write_assets(&out_dir);
}

fn write_scripts(out_dir: &Path) {
    let mut paths: Vec<_> = fs::read_dir(SCRIPT_ROOT)
        .expect("无法读取 analysis/optimization")
        .flatten()
        .map(|entry| entry.path())
        .filter(|path| path.extension().is_some_and(|ext| ext == "csx"))
        .collect();
    paths.sort();

    let mut code = String::from("// 由 build.rs 生成，不要手动修改。\n");
    for path in paths {
        let stem = path
            .file_stem()
            .and_then(|stem| stem.to_str())
            .expect("脚本文件名不是有效 UTF-8");
        assert!(
            stem.chars()
                .all(|ch| ch.is_ascii_alphanumeric() || ch == '_'),
            "脚本文件名只能包含 ASCII 字母、数字和下划线：{stem}"
        );
        let source = fs::read_to_string(&path).expect("无法读取脚本");
        code.push_str(&format!(
            "#[allow(non_upper_case_globals, dead_code)]\npub static {stem}: &str = {source:?};\n"
        ));
    }

    fs::write(out_dir.join("generated_globals.rs"), code).expect("无法写入 generated_globals.rs");
}

fn write_assets(out_dir: &Path) {
    let mut ui = Vec::new();
    let mut csv = Vec::new();

    if let Ok(entries) = fs::read_dir(SEED_ROOT) {
        let mut paths: Vec<_> = entries.flatten().map(|entry| entry.path()).collect();
        paths.sort();
        for path in paths {
            let Some(ext) = path.extension().and_then(|ext| ext.to_str()) else {
                continue;
            };
            let Some(name) = path.file_name().and_then(|name| name.to_str()) else {
                continue;
            };
            let target = match ext {
                "ui" => &mut ui,
                "csv" => &mut csv,
                _ => continue,
            };
            let absolute = fs::canonicalize(&path).expect("无法规范化 ui_seed 文件路径");
            let static_name = format!(
                "ASSET_{}",
                name.chars()
                    .map(|ch| if ch.is_ascii_alphanumeric() { ch } else { '_' })
                    .collect::<String>()
                    .to_ascii_uppercase()
            );
            let bytes = format!(
                "#[allow(dead_code)]\npub static {static_name}: &[u8] = include_bytes!({absolute:?});\n"
            );
            target.push((name.to_owned(), static_name, bytes));
        }
    }

    let mut code = String::from(
        "// 由 build.rs 生成，不要手动修改。\n\
         pub struct SeedAsset {\n\
         \x20   pub name: &'static str,\n\
         \x20   pub bytes: &'static [u8],\n\
         }\n",
    );
    for (_, _, bytes) in ui.iter().chain(csv.iter()) {
        code.push_str(bytes);
    }
    for (list_name, entries) in [("UI_ASSETS", &ui), ("CSV_ASSETS", &csv)] {
        code.push_str(&format!("pub static {list_name}: &[SeedAsset] = &[\n"));
        for (name, static_name, _) in entries {
            code.push_str(&format!(
                "    SeedAsset {{ name: {name:?}, bytes: {static_name} }},\n"
            ));
        }
        code.push_str("];\n");
    }

    fs::write(out_dir.join("generated_assets.rs"), code).expect("无法写入 generated_assets.rs");
}
