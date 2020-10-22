#! /bin/bash
# 备份数据库

GAMES=(
    c1_center_1
    c1_debug_1
)
for GAME in ${GAMES[@]}
do
echo "backup $GAME begin"
echo /data/server/$GAME/server/gctl backup
echo  "backup $GAME finish"
echo 
done

