#!/bin/bash

##########################################################################################
## @name:mnesia_backup.sh
## @author: leizhisong
## @contact: 18628198217@163.com
## last-modified: 2019/08/5
## note：mnesia backup
##########################################################################################

server_dir='/data/server/'
log_dir='/data/logs/mnesia_backup/'
log_file='mnesia_backup.log'

cd ${log_dir} || mkdir -p ${log_dir}
cd ${server_dir} || exit
# 如果没有目录存在
ls | grep -vE 'xlog|account|bgp|pay|router' | grep -E 'x4|p1|p2' > /dev/null 2>&1
if [[ $? -ne 0 ]];then
    echo "no server need to backup" >> ${log_dir}${log_file}
    exit
fi

# 排除xlog|iftest|account|bgp|pay
for server in $(ls | grep -vE 'xlog|account|bgp|pay|iftest|router' | grep -E 'x4|p1|p2');do
  cd ${server_dir}
  if [[ ! -d "${server}/server" ]];then
    continue
  fi
  cd ${server}/server
  ./gctl backup >> ${log_dir}${log_file} 2>&1
  if [[ $? -ne 0 ]];then
    echo "${server} backup failed." >> ${log_dir}${log_file} 2>&1
  fi
  pwd
done

# 清除30天前的备份
backup_dir='/data/backup/database'
if [[ -d "${backup_dir}" ]];then
    cd ${backup_dir}
    find ${backup_dir} -type f -mtime +15 -exec rm -f {} \;
fi
