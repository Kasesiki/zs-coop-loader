# ZERO Sievert 优化加载器

本项目是一个对zero sievert进行全面优化与扩展的项目，目前游戏版本为2026/10/27发布版

readme是真人写的，代码是vibe的，有测试与review

代码组成结构,analysis文件夹负责存放优化方面内容,optimization存放优化用csx脚本

rust作为加载器，负责调用utmt（[UndertaleModTool](https://github.com/UnderminersTeam/UndertaleModTool)）进行在线的反编译与data.win的魔改

程序本身会嵌入csx,csv,ui文件，tool需要外部引用

更多的后续写，想要使用交给ai看源码编译使用，优化部分参考analysis/static_hotspots.md