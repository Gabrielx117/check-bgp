#!/bin/bash
PWD=$(dirname `readlink -f "$0"`)/
cd $PWD
DEBUG="0" # 1 on, 0 off
. $PWD/info.txt
asip="as_iplist"
as_cmd="as_cmd"
device_type='mx960'
######变量定义
mx_cmd="mx960" #MX960命令总文件
ne_cmd="ne40"
result_raw="result_raw"
result="result"

get_as_ip() {
sh ./create_new_command -A $1  > $as_cmd
python ./run.py $as_cmd $loopback  $device_type BGP master $username $passwd > $asip
cat $asip | grep \/ | sort -n | uniq
if [ $DEBUG == 0 ]; then
    rm $as_cmd
fi
}

get_ospf_out(){
###生成MX960所用命令###
sh ./create_new_command -M $asip  > $mx_cmd
###将命令文件分段,拆分成小段
size=100  #分页大小
lines=`cat $mx_cmd | wc -l` #文件总行数
pages=$[ ($lines - 1) / $size + 1 ] #分页数
echo "" > $result_raw
for ((i=0; i<$pages; i++)); do
	s=$[ i * $size + 1 ]
	cat $mx_cmd | tail -n +$s | head -n $size > ${mx_cmd}.$[$i+1]
	python ./run.py ${mx_cmd}.$[$i+1] $loopback  $device_type metric master $username $passwd>> $result_raw
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
}

usage(){
echo "该脚本用于查询CR中对应AS地址段,及冲突路由.
命令格式: check-bgp -参数 AS号

参数包含以下选项:
  -a,   查询该AS所广播路由
  -o,   检查与该AS冲突的OSPF路由
  -h,   输出帮助信息"
}

main(){
  if [ $# -ne 2 ] || [ $1 == '-h' ] ;then
    usage
    exit 1
  fi
  if [[ $2 =~ ^-?[0-9]+$ ]]  ; then    #^-?[0-9]+$ 是表示一个数字的正则（包含负数）
    if [ $2 -gt 65536 ] || [ $2 -lt 1 ];then
      echo "AS号码错误,正确范围为1~65536"
      exit 1
    fi
  else
    echo "AS应为数字"
  	usage
    exit 1
  fi

#  while getopts aoh OPT;do
      case $1 in
          -a)
              get_as_ip $2
              #echo "a"
              ;;
          -o)
              get_as_ip $2
              get_ospf_out
              ;;
          *)
              usage
              exit 1
              ;;
      esac
#  done

}
main $*
