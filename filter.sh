####过滤结果####对比文件
cat result.tmp | grep \/ | sort -n | uniq | grep -F -v -f  users.sorted
