#! /bin/bash
# 创建当前代码备份到分支 当前路径必须在 trunk/ 下面

BRANCH_DIR=/root/server/project/branches/stable
TRUNK_DIR=/root/server/project/trunk

echo "分支路径" $BRANCH_DIR

if [ ! -d $BRANCH_DIR ]; then
  echo "该分支不存在"
else
  rsync -ar --exclude output  --exclude *.dump   --exclude branch* --exclude setting --exclude .publish --delete ./ $BRANCH_DIR/
  # cp -R -f ./* $BRANCH_DIR/
  ./svnauto_addndel.sh $BRANCH_DIR
  # # 提交svn
    echo "开始提交SVN"
    echo "==========================="
    svn ci $BRANCH_DIR -m "stable branch commit"
    echo "==========================="
    echo "完成!"
fi