use std::fs;
use std::path::{Path, PathBuf};

pub fn original_backup(game_data: &Path) -> PathBuf {
    game_data.with_file_name("data_original_backup.win")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn original_survives_repeated_optimization_and_restore() {
        let directory = std::env::temp_dir().join(format!("zs-backup-test-{}", std::process::id()));
        fs::create_dir(&directory).unwrap();
        let game = directory.join("data.win");
        fs::write(&game, b"original").unwrap();
        let original = ensure_original(&game).unwrap();
        assert!(fs::metadata(&original).unwrap().permissions().readonly());
        for _ in 0..2 {
            let output = directory.join("output.win");
            fs::write(&output, b"optimized").unwrap();
            replace(&game, &output).unwrap();
            assert_eq!(
                fs::read(ensure_original(&game).unwrap()).unwrap(),
                b"original"
            );
            restore(&game).unwrap();
            assert_eq!(fs::read(&game).unwrap(), b"original");
            assert!(original.is_file());
        }
        fs::remove_dir_all(directory).unwrap();
    }
}

pub fn ensure_original(game_data: &Path) -> Result<PathBuf, String> {
    if !game_data.is_file() {
        return Err(format!("找不到游戏 data.win：{}", game_data.display()));
    }
    let backup = original_backup(game_data);
    if !backup.is_file() {
        fs::copy(game_data, &backup).map_err(|error| format!("创建原始备份失败：{error}"))?;
        println!("已创建只读原始备份：{}", backup.display());
    }
    set_read_only(&backup)?;
    Ok(backup)
}

pub fn replace(game_data: &Path, generated: &Path) -> Result<(), String> {
    if !generated.is_file() {
        return Err(format!("找不到生成文件：{}", generated.display()));
    }
    fs::rename(generated, game_data).map_err(|error| format!("替换 data.win 失败：{error}"))?;
    Ok(())
}

pub fn restore(game_data: &Path) -> Result<(), String> {
    let backup = original_backup(game_data);
    if !backup.is_file() {
        return Err(format!("找不到原始备份：{}", backup.display()));
    }
    let temporary = game_data.with_extension("win.restore-tmp");
    fs::copy(&backup, &temporary).map_err(|error| format!("复制恢复文件失败：{error}"))?;
    fs::rename(&temporary, game_data).map_err(|error| format!("恢复 data.win 失败：{error}"))?;
    println!("已恢复：{}", game_data.display());
    Ok(())
}

#[cfg(unix)]
fn set_read_only(path: &Path) -> Result<(), String> {
    use std::os::unix::fs::PermissionsExt;
    let mut permissions = fs::metadata(path)
        .map_err(|error| format!("读取备份权限失败：{error}"))?
        .permissions();
    permissions.set_mode(0o444);
    fs::set_permissions(path, permissions).map_err(|error| format!("设置备份只读失败：{error}"))
}

#[cfg(not(unix))]
fn set_read_only(path: &Path) -> Result<(), String> {
    let mut permissions = fs::metadata(path)
        .map_err(|error| format!("读取备份权限失败：{error}"))?
        .permissions();
    permissions.set_readonly(true);
    fs::set_permissions(path, permissions).map_err(|error| format!("设置备份只读失败：{error}"))
}
