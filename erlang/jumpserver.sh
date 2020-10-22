#! /bin/bash
# 将代码推送到jumpserver 游戏服
run_dir=/data/server/c1_release_10001/server
target_dir=/data/c1_release_1

rsync -e "ssh -p22" -aPzv --delete ${run_dir} yunwei@120.78.152.59:${target_dir}/

if [[ $? -ne 0 ]];
then
    echo "upload files failed"
    exit 3
fi