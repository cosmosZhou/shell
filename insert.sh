#usage sh insert.sh /user/local "<IfModule dir_module>" "    DirectoryIndex index.php index.html"  
conf=$1
regex=$2
text=$3

echo conf = $conf
echo regex = $regex
echo text = $text

index=`grep -n "$regex" $conf | cut -f1 -d:`

echo index = $index

index=$(($index + 1))

echo index = $index

next=${index}p

echo next = $next

next=`sed -n $next $conf`

echo next = $next
echo text = $text 
echo next length = ${#next}
echo text length = ${#text}

if [ "$next" = "$text" ]; then
	echo "$text" already added
else
	echo adding "$text"
	echo sed -i "'""${index}i ${text}""'" $conf
	sed -i "${index}i $text" $conf
	leadingSpaces=`echo "$text" | grep -Eo "^\s*"`
	echo leadingSpaces length = ${#leadingSpaces}

	if [ -n "$leadingSpaces" ]; then
		sed -i "${index}s/^/${leadingSpaces}/g" $conf
	fi
	
fi

