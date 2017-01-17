#!/bin/bash
######变量定义
iplist='./iplist.gwbn'  #待查ip列表文件
mx_cmd="./mx960.cmd" #MX960命令总文件
ne_cmd="./ne40.cmd"
###生成MX960所用命令###
sh ./create_new_command $iplist -M > $mx_cmd
###将命令文件分段,拆分成小段
size=100  #分页大小
lines=`cat $mx_cmd | wc -l` #文件总行数
pages=$[ ($lines - 1) / $size + 1 ] #分页数
for ((i=0; i<$pages; i++)); do
	s=$[ i * $size + 1 ]
	cat $mx_cmd | tail -n +$s | head -n $size > ${mx_cmd}.$[$i+1]
done

####执行python脚本进行数据查询
python ./route.py 1 2 > result.1t 

###与本地ip进行对比,剔除本网用户地址
cat result.1t | grep \/ | sort -n | uniq | grep -F -v -f  ./users.sorted > result.1

###生成NE40查询脚本
sh ./create_new_command ./result.1 -N > $ne_cmd
cat $ne_cmd
