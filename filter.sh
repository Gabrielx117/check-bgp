####过滤结果####对比文件
cat "$1" | grep \/ | sort -n | uniq | grep -F -v -f  users.sorted
