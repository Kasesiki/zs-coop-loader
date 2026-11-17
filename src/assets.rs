// 编译期嵌入的资源。文件内容由 build.rs 生成。
include!(concat!(env!("OUT_DIR"), "/generated_assets.rs"));

pub fn ui_asset(name: &str) -> Option<&'static [u8]> {
    UI_ASSETS
        .iter()
        .find(|asset| asset.name == name)
        .map(|asset| asset.bytes)
}

pub fn csv_asset(name: &str) -> Option<&'static [u8]> {
    CSV_ASSETS
        .iter()
        .find(|asset| asset.name == name)
        .map(|asset| asset.bytes)
}
