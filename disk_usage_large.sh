#http://rimuhosting.com/knowledgebase/linux/misc/where-has-all-my-disk-space-gone
sudo du -ax --max-depth=3 / | sort -n | awk '{if($1 > 102400) print $1/1024 "MB" " " $2 }'
