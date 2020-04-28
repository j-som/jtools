#### HOWTO make_webgame_cfg.esh
1. 这是一个escript运行的脚本。首先要安装好erlang环境，脚本支持的erl版本为9.3(OTP20.3) 
2. 设置好脚本里面的路径和环境变量
- PROJECT_ROOT OUTPUT_SRC_PATH INCLUDE_PATH
项目路径 关系到erl和hrl输出路径  
- INCLUDE_FILE_NAME 头文件的名称 所有的配置表都会包含该头文件，该头文件定义了配置表的record定义
- XLSX_PATH 配置表的路径
一个xlsx文件对应生成一个erl文件 erl文件名会去掉前面的t_(假如有的话)
一个sheet表名对应生成一个record record名会去掉前面的t_(假如有的话)
配置表结构：  
第一行：直到有一个单元格为空，之前的每个单元格为一个字段名  
从第二行开始，直到有一行的第一个单元格为空为止为数据内容
第一列为主键，用于get_**(Id) -> term()的Id. 
其中数据默认能解释为数字的，优先解释为数字
否则如果是x\[,y...\]#m\[,n...\],会解释为数组\[x,m\](数组元素为简单类型)或\[{x,y...},{m,n...}\]
