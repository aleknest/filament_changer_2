threads=2

rm -r -f -d ./produce/*
rmdir -p produce

mkdir -p ./produce
mkdir -p ./produce/bearings
mkdir -p ./produce/pulley
mkdir -p ./produce/frontier
mkdir -p ./produce/mk8
mkdir -p ./produce/carriage
mkdir -p ./produce/stand
mkdir -p ./produce/filament_fix

PROJ='fchanger_09.scad'
EX1='openscad '$PROJ

declare -a parts

parts+=("$EX1 -o produce/pulley/motor_pulley.stl -D part=\"motor_pulley\"")

parts+=("$EX1 -o produce/stand/cutterswitch1.stl -D part=\"cutterswitch1\"")
parts+=("$EX1 -o produce/stand/cutterswitch2.stl -D part=\"cutterswitch2\"")
parts+=("$EX1 -o produce/stand/cutter_big_gear.stl -D part=\"cutter_big_gear\"")
parts+=("$EX1 -o produce/stand/cutter_small_gear.stl -D part=\"cutter_small_gear\"")
parts+=("$EX1 -o produce/stand/stand_channel.stl -D part=\"stand_channel\"")
parts+=("$EX1 -o produce/stand/stand_top.stl -D part=\"stand_top\"")
parts+=("$EX1 -o produce/stand/stand_bottom_channel.stl -D part=\"stand_bottom_channel\"")
parts+=("$EX1 -o produce/stand/stand_channel_magnet.stl -D part=\"stand_channel_magnet\"")
parts+=("$EX1 -o produce/stand/stand_ss443_top.stl -D part=\"stand_ss443_top\"")
parts+=("$EX1 -o produce/stand/stand_ss443_bottom.stl -D part=\"stand_ss443_bottom\"")
parts+=("$EX1 -o produce/stand/stand_left.stl -D part=\"stand_left\"")
parts+=("$EX1 -o produce/stand/stand_right.stl -D part=\"stand_right\"")

parts+=("$EX1 -o produce/carriage/carriage_top.stl -D part=\"carriage_top\"")
parts+=("$EX1 -o produce/carriage/carriage_top_plus2mm.stl -D part=\"carriage_top\" -D carriage_filament_corr=2")
parts+=("$EX1 -o produce/carriage/carriage_bottom.stl -D part=\"carriage_bottom\"")
parts+=("$EX1 -o produce/carriage/carriage_rod_fix_left.stl -D part=\"left_rod_fix\"")
parts+=("$EX1 -o produce/carriage/carriage_rod_fix_right.stl -D part=\"right_rod_fix\"")
parts+=("$EX1 -o produce/carriage/carriage_sensor.stl -D part=\"carriage_optosensor\"")

parts+=("$EX1 -o produce/filament_fix/frontier_filament_fix.stl -D part=\"frontier_filament_fix\"")
parts+=("$EX1 -o produce/filament_fix/carriage_filament_fix.stl -D part=\"carriage_filament_fix\"")
parts+=("$EX1 -o produce/filament_fix/filament_fix_nut.stl -D part=\"filament_fix_nut\"")

parts+=("$EX1 -o produce/frontier/frontier_top.stl -D part=\"frontier_top\"")
parts+=("$EX1 -o produce/frontier/frontier_main.stl -D part=\"frontier_main\"")
parts+=("$EX1 -o produce/frontier/frontier_thrash.stl -D part=\"frontier_thrash\"")
parts+=("$EX1 -o produce/frontier/frontier_t8_fix.stl -D part=\"frontier_t8_fix\"")
parts+=("$EX1 -o produce/frontier/frontier_rod_left.stl -D part=\"frontier_rod_left\"")
parts+=("$EX1 -o produce/frontier/frontier_rod_right.stl -D part=\"frontier_rod_right\"")
parts+=("$EX1 -o produce/frontier/frontier_sensor.stl -D part=\"frontier_sensor\"")

parts+=("$EX1 -o produce/bearings/LM8LUU.stl -D part=\"lm8luu\"")
parts+=("$EX1 -o produce/bearings/LM8UU.stl -D part=\"lm8uu\"")
parts+=("$EX1 -o produce/bearings/LM8LUU_to_7rod.stl -D part=\"lm8luu_to_7rod\"")
parts+=("$EX1 -o produce/bearings/LM8UU_to_7rod.stl -D part=\"lm8uu_to_7rod\"")
parts+=("$EX1 -o produce/bearings/LM8UU_to_5rod.stl -D part=\"lm8uu_to_5rod\"")
parts+=("$EX1 -o produce/bearings/LM8LUU_to_5rod.stl -D part=\"lm8luu_to_5rod\"")

parts+=("$EX1 -o produce/mk8/mk8_cap.stl -D part=\"mk8_cap\"")
parts+=("$EX1 -o produce/mk8/mk8_small_gear.stl -D part=\"mk8_small_gear\"")
parts+=("$EX1 -o produce/mk8/mk8_big_gear.stl -D part=\"mk8_big_gear\"")
parts+=("$EX1 -o produce/mk8/mk8_body.stl -D part=\"mk8_body\"")
parts+=("$EX1 -o produce/mk8/mk8_endstop_half1.stl -D part=\"mk8_endstop_half1\"")
parts+=("$EX1 -o produce/mk8/mk8_endstop_half2.stl -D part=\"mk8_endstop_half2\"")
parts+=("$EX1 -o produce/mk8/mk8_small_spacer.stl -D part=\"mk8_spacer_gear\"")

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