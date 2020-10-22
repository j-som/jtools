#!/bin/bash
##########################################################################################
## mysql备份脚本
## @author: leizhisong
## @contact: 18628198217@163.com
## last-modified: 2018/11/05
## note：mysql备份优化，通过xtrabackup工具的innobackupex来备份
## root定时任务
##########################################################################################
# 备份日志
inno_log_dir='/data/logs/mysql_backup/'
inno_log_file="${inno_log_dir}inno_log.txt"
server_base_dir='/data/server'
mysql_user="x4game"
mysql_password=$(cat /data/save/mypwd.txt)

if [[ ! -f "${inno_log_file}" ]];then
  mkdir -p ${inno_log_dir}
  touch ${inno_log_file}
fi
echo '' >> ${inno_log_file}
echo '***********************************************************' >> ${inno_log_file}
# 备份位置
backup_dir='/data/backup/mysql/'
if [[ ! -d "${backup_dir}" ]];then
  mkdir -p ${backup_dir}
fi
# 备份时间
backup_time=$(date +%Y%m%d_%H%M%S)
# innobackupex检查
which innobackupex > /dev/null
if [[ $? -ne 0 ]];then
  log_time=$(date +"%Y_%m_%d %H:%M:%S")
  echo "${log_time} no innobackupex installed" >> ${inno_log_file}
  exit 1
fi
# mysql检查
which mysql > /dev/null
if [[ $? -ne 0 ]];then
  log_time=$(date +"%Y_%m_%d %H:%M:%S")
  echo "${log_time} no mysql installed" >> ${inno_log_file}
  exit 2
fi

# 生成备份数据库列表
server_info=''
cd ${inno_log_dir}
mysql -u${mysql_user} -p${mysql_password} -e "show databases;" | grep -E "x4_" | grep -vE 'xlog|center|cross|account|bgp|pay' > ${backup_dir}temp_backup_databases.txt

for database in $(cat ${backup_dir}temp_backup_databases.txt);do
  ls ${server_base_dir} | grep ${database} > /dev/null 2>&1
  if [[ $? -eq 0 ]];then
    server_info="${database} ${server_info}"
  fi
done
if [[ -z "${server_info}" ]];then
    echo "no server mysql database to backup" >> ${inno_log_file}
    exit
fi

log_time=$(date +"%Y_%m_%d %H:%M:%S")
echo "${log_time} ${server_info} ---> backup start...." >> ${inno_log_file}
# 开始备份
mysql_socket=$(grep "^socket" /etc/my.cnf | awk -F'=' '{print $2}' | uniq)
if [[ -z "${mysql_socket}" ]];then
  mysql_socket='/data/database/mysql/mysql.sock'
fi
# 确认是全量备份还是增量备份
weekday=$(date +%w)
flag=0
# 周三全量备份
if [[ "${weekday}" == "3" ]];then
  flag=1
fi
# 若以前没备份过，第一次也全量备份
cd ${backup_dir}
if [[ ! -f full_backup_of_name ]];then
  touch full_backup_of_name
fi
full_backup_name=$(cat full_backup_of_name)
if [[ -z "${full_backup_name}" ]];then
  flag=1
fi

if [[ "${flag}" == "1" ]];then
  echo "${log_time} backup type: full backup" >> ${inno_log_file}
  mkdir -p ${backup_dir}${backup_time}
  innobackupex --defaults-file=/etc/my.cnf --user=${mysql_user} --password=${mysql_password} --socket=${mysql_socket} --no-timestamp --no-lock --databases="${server_info}" ${backup_dir}${backup_time} >> ${inno_log_file} 2>&1
  tail -1 ${inno_log_file} | grep 'completed OK' > /dev/null 2>&1
  if [[ $? -eq 0 ]];then
    echo "${server_info} full backup successful" >> ${inno_log_file}
  else
    echo "${server_info} full backup failed" >> ${inno_log_file}
    exit 3
  fi
  # 记录全量备份目录名
  cd ${backup_dir}
  echo ${backup_time} > full_backup_of_name
else
  echo "${log_time} backup type: incremental backup" >> ${inno_log_file}
  mkdir -p ${backup_dir}inc_${backup_time}
  innobackupex --defaults-file=/etc/my.cnf --incremental --incremental-basedir=${backup_dir}${full_backup_name} --no-timestamp --no-lock --databases="${server_info}" --user=${mysql_user} --password=${mysql_password} --socket=${mysql_socket} ${backup_dir}inc_${backup_time} >> ${inno_log_file} 2>&1
  if [[ $? -eq 0 ]];then
    echo "${server_info} incremental backup successful" >> ${inno_log_file}
  else
    echo "${server_info} incremental backup failed" >> ${inno_log_file}
    exit 4
  fi
fi
# 确保数据一致性，恢复时最后一步执行
#innobackupex --apply-log ${backup_dir}${backup_time} >> ${inno_log_file} 2>&1
#tail -1 ${inno_log_file} | grep 'completed OK' > /dev/null 2>&1
#if [ $? -eq 0 ];then
#  echo "${server_info} verify successful" >> ${inno_log_file}
#else
#  echo "${server_info} verify failed" >> ${inno_log_file}
#  exit 4
#fi
log_time=$(date +"%Y_%m_%d %H:%M:%S")
echo "${log_time} ${server_info} ---> backup end...." >> ${inno_log_file}

# 删除以前的备份
log_time=$(date +"%Y_%m_%d %H:%M:%S")
echo "start to remove old backup, ${log_time}" >> ${inno_log_file}
find ${backup_dir} -maxdepth 1 -type d -name "202*" -mtime +10 >> ${inno_log_file}
find ${backup_dir} -maxdepth 1 -type d -name "202*" -mtime +10 -exec rm -rf {} \;
find ${backup_dir} -maxdepth 1 -type d -name "inc*" -mtime +10 >> ${inno_log_file}
find ${backup_dir} -maxdepth 1 -type d -name "inc*" -mtime +10 -exec rm -rf {} \;
echo "delete old backup files" >> ${inno_log_file}
# 压缩备份文件
#cd ${backup_dir}
#tar -zcvf ${backup_time}.tar.gz ${backup_time} --remove-files > /dev/null 2>&1

echo '***********************************************************' >> ${inno_log_file}