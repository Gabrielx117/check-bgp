####过滤结果
cat result.1 | grep \/ | sort -n | uniq > result.1s
####对比文件
comm -23 result.1s users
