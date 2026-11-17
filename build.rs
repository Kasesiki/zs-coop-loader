use std::{env, fs, path::Path};

fn main() {
    println!("cargo:rerun-if-changed=analysis/optimization");

    let out_dir = env::var("OUT_DIR").expect("OUT_DIR 未设置");
    let dest_path = Path::new(&out_dir).join("generated_globals.rs");

    let mut paths: Vec<_> = fs::read_dir("analysis/optimization")
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

    fs::write(dest_path, code).expect("无法写入 generated_globals.rs");
}
