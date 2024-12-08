#usage sh update.sh /user/local "^DocumentRoot \".\+\"" "<Directory \"/mnt/data/lizhi/gitlab\">"
conf=$1
regex=$2
text=$3

echo conf = $conf
echo regex = $regex
echo text = $text

index=`grep -n "$regex" $conf | cut -f1 -d: | head -n 1`

echo index = $index

index=$(($index + 1))

echo index = $index

next=${index}p

echo next = $next

echo update line ${index} "$text"
sed -i "${index}s#^.*\$#${text}#g" $conf

