#!/bin/bash
#进入运行目录
PWD=$(dirname `readlink -f "$0"`)/
cd $PWD
######变量定义
iplist='as_iplist'  #待查ip列表文件
mx_cmd="mx960" #MX960命令总文件
ne_cmd="ne40"
result_raw="result_raw"
result="result"
loopback='220.113.135.52'
keyword="metric"
device_type='mx960'
expect_wd='0'
DEBUG="0"
username="xiayu"
passwd="tjgwbn123"
###生成MX960所用命令###
sh ./create_new_command -M $iplist  > $mx_cmd
###将命令文件分段,拆分成小段
size=100  #分页大小
lines=`cat $mx_cmd | wc -l` #文件总行数
pages=$[ ($lines - 1) / $size + 1 ] #分页数
echo "" > $result_raw
for ((i=0; i<$pages; i++)); do
	s=$[ i * $size + 1 ]
	cat $mx_cmd | tail -n +$s | head -n $size > ${mx_cmd}.$[$i+1]
	python ./run.py ${mx_cmd}.$[$i+1] $loopback  $device_type $keyword $expect_wd $username $passwd>> $result_raw
done
####执行python脚本进行数据查询
###与本地ip进行对比,剔除本网用户地址
cat $result_raw | grep \/ | sort -n | uniq | grep -F -v -f  ./users.sorted > $result
###生成NE40查询脚本
sh ./create_new_command -D $result > $ne_cmd
cat $ne_cmd
if [ $DEBUG == 0 ]; then
    rm ${mx_cmd}*  $result_raw  $result
fi
