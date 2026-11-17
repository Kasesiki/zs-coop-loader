// 编译期把 analysis/optimization/*.csx 的内容嵌入二进制，运行时不再读取仓库文件。
include!(concat!(env!("OUT_DIR"), "/generated_globals.rs"));
