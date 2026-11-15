use std::fs;
use std::path::{Path, PathBuf};

fn active_backup(coop_dir: &Path) -> PathBuf {
    coop_dir.join("backups/active/data.win")
}

pub fn replace(coop_dir: &Path, game_data: &Path, generated: &Path) -> Result<(), String> {
    if !game_data.is_file() {
        return Err(format!("找不到游戏 data.win：{}", game_data.display()));
    }
    if !generated.is_file() {
        return Err(format!("找不到生成文件：{}", generated.display()));
    }
    let backup = active_backup(coop_dir);
    if !backup.is_file() {
        fs::create_dir_all(backup.parent().ok_or("无法创建备份目录")?)
            .map_err(|error| format!("创建备份目录失败：{error}"))?;
        fs::copy(game_data, &backup).map_err(|error| format!("保存活动备份失败：{error}"))?;
    }
    let temporary = game_data.with_extension("win.coop-tmp");
    fs::copy(generated, &temporary).map_err(|error| format!("复制生成文件失败：{error}"))?;
    fs::rename(&temporary, game_data).map_err(|error| format!("替换 data.win 失败：{error}"))?;
    Ok(())
}

pub fn restore(coop_dir: &Path, game_data: &Path) -> Result<(), String> {
    let backup = active_backup(coop_dir);
    if !backup.is_file() {
        return Err(format!("找不到活动备份：{}", backup.display()));
    }
    let temporary = game_data.with_extension("win.restore-tmp");
    fs::copy(&backup, &temporary).map_err(|error| format!("复制恢复文件失败：{error}"))?;
    fs::rename(&temporary, game_data).map_err(|error| format!("恢复 data.win 失败：{error}"))?;
    fs::remove_file(&backup).map_err(|error| format!("删除活动备份失败：{error}"))?;
    println!("已恢复：{}", game_data.display());
    Ok(())
}
