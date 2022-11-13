threads=4

rm -r -f -d ./produce/*
rmdir -p produce

mkdir -p ./produce

PROJ='slot_stand_01.scad'
EX1='openscad '$PROJ

declare -a parts

parts+=("$EX1 -o produce/left.stl -D part=\"left\"")
parts+=("$EX1 -o produce/right.stl -D part=\"right\"")
#parts+=("$EX1 -o produce/middle.stl -D part=\"middle\"")

index=0
for (( ; ; ))
do
    count=$(ps aux --no-heading | grep -v grep | grep $PROJ | wc -l)
    if [ "$count" -lt "$threads" ]
    then 
	current=${parts[$index]}
	if [ -z "$current" ]; then break; fi
	index=$((index+1))
	
	echo $current
	$current &
    fi
    sleep 1
done