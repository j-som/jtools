#! /bin/bash

if [ $# -eq 0 ];
then 
    echo usage svnauto_addndel.sh 'path'
    exit 1
fi

TARGET_DIR=$1

# 增加新增的
ADD_LIST=`svn status $TARGET_DIR | grep ^\? | cut -c 2-1024`
# 删除被删除的
DEL_LIST=`svn status $TARGET_DIR | grep ^\! | cut -c 2-1024`

IFS=$'\n'
for A in $ADD_LIST 
do
    svn add `echo $A | sed -e 's/^[\t ]*//g'`
done
for D in $DEL_LIST 
do
    svn del `echo $D | sed -e 's/^[\t ]*//g'`
done

# if [ -n $2 ];
# then
#     MSG=$2
# else
#     MSG="生成自动提交"
# fi
# # 提交svn
# echo "开始提交SVN"
# echo "==========================="
# svn ci $TARGET_DIR -m "$MSG"
# echo "==========================="
# echo "完成!"