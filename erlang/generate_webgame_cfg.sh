#! /bin/bash

# 更新excel目录svn
# echo "请确保excel分支目录在client/project/Plan/下面"
read -p "请输入client/project/Plan/下的配置表文件夹名称(直接回车为excel)" EXCEL
if [ -z $EXCEL ];then 
    EXCEL=excel 
fi

XLSX_PATH=$HOME/work/client/project/Plan/$EXCEL
if [ -d $XLSX_PATH ];
then
    svn up $XLSX_PATH --force
    svn up include/$HRL_NAME  $OUTPUT_PATH --force
else
    echo "错误！没有$EXCEL分支"
    exit 1
fi

TRUNK_PATH=$HOME/server/project/trunk
OUTPUT_PATH=$TRUNK_PATH/src/webgame/cfg
HRL_NAME=webgame_config.hrl
EBIN_PATH=$TRUNK_PATH/ebin
AUTO_SVN=$(cd "$(dirname "$0")";pwd)/svnauto_addndel.sh
# 进入服务端项目根目录
cd $TRUNK_PATH

rm -f $TRUNK_PATH/src/webgame/cfg/webgame_cfg_*

ERL=/data/sbin/erlang/20.3/bin/erl
# /data/sbin/erlang/20.3/bin/erl -pa /root/server/project/trunk/ebin -eval "cfgmk:make_webgame_cfg(\"/root/work/client/project/Plan/excel\", \"/root/server/project/trunk/include\", \"webgame_config.hrl\", \"/root/server/project/trunk/src/webgame/cfg\")." -s init stop
echo "开始生成配置"
$ERL -pa $EBIN_PATH  -noinput -eval "cfgmk:make_webgame_cfg(\"$XLSX_PATH\", \"$TRUNK_PATH/include\", \"$HRL_NAME\", \"$OUTPUT_PATH\")." -s init stop

$AUTO_SVN $TRUNK_PATH/src/webgame/cfg

# 提交svn
echo "开始提交SVN"
echo "==========================="
svn ci $TRUNK_PATH/include/$HRL_NAME  $OUTPUT_PATH -m "配置生成自动提交"
echo "==========================="
echo "完成!"

