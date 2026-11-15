# 已应用优化

## 第二轮：激进视觉优化

当前原始 `data.win` 是第二轮实验版本，新增两项改动：

1. `obj_particles_controller_Step_0` 中的天气、异常和辐射粒子发射改为空操作函数。粒子系统、音频、着色器和其它控制器逻辑仍保留。
2. `obj_bullet_regular_Draw_0` 增加 `sphere_is_visible(x, y, 0, 32)` 裁剪。屏幕外子弹仍然执行 Step 和碰撞，只跳过绘制。

当前第二轮文件哈希：

```text
3dc50e083320e1446927ba1c8e80b567186cafb72df3e9af90547a7d51ad160f
```

第二轮备份目录：

```text
backups/20261115_175432/
```

如需回到第一轮 LOS 缓存版本：

```bash
cp coop/backups/20261115_174509/data.win data.win
```

如需回到第二轮之前的第一轮文件版本：

```bash
cp coop/backups/20261115_175432/data.win data.win
```

## 当前版本

已将独立输出 `data.win.los-cache` 覆盖到游戏目录的原始 `data.win`。

修改内容只有：

```text
gml_GlobalScript_instance_line_of_sight
```

该函数增加了同房间、同坐标、最多两帧的单项 LOS 缓存。房间、观察者坐标
或目标坐标变化时会重新执行 `collision_line`。

## 文件哈希

```text
当前 data.win：
89607d5805618032bb1ae84e156bb54184e0831c7e496a2f27c5d6753f44b53c

原始备份：
95252ac09897e99ca7f10e40e99d25f5c099e67fa912c0f7cabce73f9a7a7daa
```

备份目录：

```text
backups/20261115_174509/
```

其中同时保存了原始 `data.win`、`ZERO Sievert.exe` 和 `SHA256SUMS`。

## 启动状态

UTMT 可以重新读取并反编译修改后的 `data.win`。尝试通过 Proton Experimental
启动时，Wine 初始化阶段收到：

```text
wineserver: bind: Operation not permitted
```

当前受限执行环境无法建立 Wine 本地 socket，因此没有在这里完成游戏窗口
启动。请通过桌面 Steam 启动 AppID `1782120`，它会使用当前修改后的文件。
