# version的值为v5.11、v5.12、v5.13这一类的,不包含rc
version=$1

prev_version=""
next_version=""

find_amd_merge() {
	for line in `cat $1`
	do
		git show $line |grep -iE "drm\/radeon|drm\/amd" >/dev/null 2>&1
		if [ $? -eq 0 ]
		then
			echo $line
		fi
	done
}


# main func
for i in $(seq 1 8)
do
	# 1. 获取版本号
	if [ $i -eq 1 ]
	then
		master_version=`echo $version |grep -Eo ".*\."`	
		minor_version=`echo $version |grep -Eo "\.[0-9]*"|grep -Eo "[0-9]*"`
		prev_version="$master_version$((minor_version-1))"
		next_version="$version-rc1"
	elif [ $i -le 7 ]
	then
		prev_version="$version-rc$((i-1))"
		next_version="$version-rc$i"
	else
		prev_version="$version-rc7"
		next_version="$version"
	fi
	
	echo "-------------------$prev_version -> $next_version------------------------"	
	# 2.获取rc之间所有的merge
	git log  --merges $prev_version..$next_version  --pretty=oneline |cut  -f1 -d ' '  > 1.log

	# 3. 根据这些merge, 查找关于amd gpu的merge
	find_amd_merge ./1.log
done


