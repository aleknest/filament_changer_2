use <../../../_utils_v2/_round/polyround.scad>
use <../../../_utils_v2/fillet.scad>
use <../../../_utils_v2/deb.scad>
use <../../../_utils_v2/Getriebe.scad>
use <../../../_utils_v2/m3-m8.scad>
use <../../../_utils_v2/slot.scad>
use <../../../_utils_v2/rods.scad>
use <proto.scad>
use <thumbs.scad>
use <pc4.scad>
use <ss443a.scad>;
use <pc4fitting.scad>

part="";
mk8_position=0;//12;
cutter_angle=17;//-20,20;

function vector_sum (v1,v2)=[v1.x+v2.x,v1.y+v2.y,v1.z+v2.z];
function vec_add (v1,v2)=[v1.x+v2.x,v1.y+v2.y,v1.z+v2.z];

function vector_sub (v1,v2)=[v1.x-v2.x,v1.y-v2.y,v1.z-v2.z];
function vec_sub (v1,v2)=[v1.x-v2.x,v1.y-v2.y,v1.z-v2.z];

function vector_replace (v,index,value)=[for (i=[0:2]) index==i?value:v[i]];
function tr_sum (vc,v2)=[vector_sum (vc[0],v2),vc[1]];
function tr_sub (vc,v2)=[vector_sub (vc[0],v2),vc[1]];
function tr_replace (vc,index,value)=[vector_replace(vc[0],index,value),vc[1]];
module translate_rotate(tr) 
{
	for (i=[0:$children-1]) 
		translate (tr[0])
		rotate(tr[1])
			children(i);
}
module centered_rotate(tr)
{
    for (i=[0:$children-1])
    {
		translate (tr[0])
		rotate (tr[1])
		translate ([-tr[0].x,-tr[0].y,-tr[0].z])
	    	children(i);
    }
}
module lgroove (w)
{
	groove(w);
}
// outer,height,inner
bearings = [
 [10,4,5] //mr105zz
,[11,5,5] //685zz
,[10,4,3] //623zz
,[9,3,5] //mr95
];
bearing685=bearings[1];

filament_dia = 1.75;
filament_dia_offset=0.3;
filament_diameter=filament_dia+filament_dia_offset*2;
filament_melt_diameter=3;
filament_carriage_diameter=3.5;

mk8_gear=[9,11,-8];//diameter,height,offset
mk8_gear_tr=[[mk8_gear[2],0,mk8_gear[0]/2],[0,90,0]];//translate, rotate

//eingriffswinkel,schraegungswinkel,offset from mk8 gear, shaft height
mk8_transmission=[20,30,2,7.97];
mk8_transmission_small=[26,3,20,8,1];//diameter,height,diameter of fix body, fix screw height, наезд на мк8 шестерню
//diameter,height,diameter of fix body, fix screw height
mk8_transmission_big=[ceil(nema17_dim()-(mk8_transmission_small[0]-mk8_gear[0])+8),mk8_transmission_small[1],20,8];

mk8_transmission_small_tr=[vector_sum(mk8_gear_tr[0],[mk8_transmission_small[4],0,0]),vector_sum(mk8_gear_tr[1],[0,180,0])];
mk8_transmission_big_tr=[
	vector_sum(mk8_transmission_small_tr[0],[-mk8_transmission_big[1],0,mk8_transmission_small[0]/2+mk8_transmission_big[0]/2])
	,[0,90,0]];
	
if (part=="") deb (str("mk8 transmission ratio = ",mk8_transmission_big[0]/mk8_transmission_small[0]));

mk8_nema_tr=[vector_sum(mk8_transmission_big_tr[0],[10,0,0]),[0,-90,0]];
mk8_nema_corr=[8.6,0,0];

mk8_bearing_index=0;
mk8_bearing_offs=0.6;
mk8_bearing_left_tr=[
	 vector_sum(mk8_transmission_small_tr[0],[-mk8_transmission_small[1]-mk8_transmission[3]-mk8_bearing_offs,0,0])
	,mk8_transmission_small_tr[1]];
mk8_bearing_right_tr=[
	 vector_sum(mk8_gear_tr[0],[mk8_gear[1]+mk8_bearing_offs,0,0])
	,vector_sum(mk8_gear_tr[1],[0,0,0])];
	
mk8_bearingfixer_left_dim=[bearings[mk8_bearing_index].x+2,bearings[mk8_bearing_index].y+1];
mk8_bearingfixer_left_tr=mk8_bearing_left_tr;

mk8_bearingfixer_right_dim=[bearings[mk8_bearing_index].x+2,bearings[mk8_bearing_index].y+1];
mk8_bearingfixer_right_tr=mk8_bearing_right_tr;

mk8_body_dim_add=[0,18,0];
mk8_body_dim_add_symmetry=[0,12,2];
mk8_body_dim=vector_sum(vector_sum([
	mk8_bearingfixer_right_tr[0].x-mk8_bearingfixer_left_tr[0].x+mk8_bearingfixer_left_dim[1]+mk8_bearingfixer_right_dim[1]
	,nema17_dim(),nema17_dim()],mk8_body_dim_add_symmetry),mk8_body_dim_add);
mk8_body_tr=[
	 [mk8_bearingfixer_left_tr[0].x-mk8_bearingfixer_left_dim[1]-mk8_body_dim_add_symmetry.x/2
		,mk8_nema_tr[0].y-nema17_dim()/2-mk8_body_dim_add_symmetry.y/2
		,mk8_nema_tr[0].z-nema17_dim()/2-mk8_body_dim_add_symmetry.z/2]
	,[0,0,0]];

carriage_bearing_index=2;
carriage_bearing_tr=[
	//[-bearings[carriage_bearing_index][1]/2,0,-bearings[carriage_bearing_index][0]/2-filament_dia/2+filament_dia_offset]
	[-bearings[carriage_bearing_index][1]/2,0,-bearings[carriage_bearing_index][0]/2-filament_dia/2+filament_dia_offset]
	,[0,90,0]];
	
carriage_dim_add=[-4,0,2];
carriage_dim_add_symmetry=[0,0,0];
carriage_dim=vector_sum(vector_sum([mk8_body_dim.x,54,27],carriage_dim_add_symmetry),carriage_dim_add);
carriage_tr=[[mk8_body_tr[0].x-carriage_dim_add_symmetry.x/2-carriage_dim_add.x
			,-carriage_dim.y/2-carriage_dim_add_symmetry.y/2-carriage_dim_add.y
			,-carriage_dim.z-carriage_dim_add_symmetry.z/2]
			,[0,0,0]];
if (part=="") deb (str("carriage width = ",carriage_dim.x, ", length = ", carriage_dim.y));

luu8=[24,15+0.2];// diff,diameter
luu8_tr=[[carriage_tr[0].x,0,-17],[0,90,0]];

lm8screw_xoffset=15/2+1.5;

slot_up=30;
slot_tr=[[50,50,-45+slot_up],[0,0,90]];

mk8_stand_thickness=6;
rods=[60-8,5,120];//diff,diameter, up rod,length
mk8_stand_slot=[rods[0]/2+18,10,24,[[48-slot_up,40],[63+5,10-2],[10,40]]];//slot offset,screw offset,fix rods offset, parts (height,width)
rods_tr=[[mk8_body_tr[0].x+mk8_body_dim.x/2
		,slot_tr[0].y-10
		,slot_tr[0].z+mk8_stand_thickness
		],[0,0,0]];
mk8_stand_dim=[rods[0]+mk8_stand_slot[0]*2,40,mk8_stand_thickness];
mk8_stand_tr=[vector_replace(vector_sum(rods_tr[0],[-rods[0]/2-mk8_stand_slot[0],0,-mk8_stand_thickness]),1,slot_tr[0].y-20)
			,[0,0,0]];
rods_up=4+5;//mk8_stand_slot[3][0].x+mk8_stand_slot[3][1].x+mk8_stand_slot[3][2].x-rods[2]-0.4;
rod_screws=[6+1];//length,offset from bottom
		
t8_nema_add_z=10;
t8nut_tr=[vector_replace(vector_replace(vector_sum(mk8_body_tr[0],[0,0,14+t8_nema_add_z]),0,rods_tr[0].x),1,rods_tr[0].y)
	,[0,0,0]];
t8_nema_tr=[vector_sum(rods_tr[0]
	,[0,0,mk8_stand_slot[3][0].x+mk8_stand_slot[3][1].x+mk8_stand_slot[3][2].x+t8_nema_add_z]
	),[0,180,0]];	

eingriffswinkel=20+10;
gear_big_steigungswinkel=10;
gear_big_modul=1;
gear_big_d=80;//73 in proto
gear_small_d=3;
gear_big_h=8;
gear_small_h=30;
small_gear_r = gear_small_d/(2*sin(gear_big_steigungswinkel));				

cutter_tr=[[-54,mk8_stand_tr[0].y+33,0],[90,0,180]];
cutter_nema_tr=[[rods_tr[0].x-rods[0]/2-mk8_stand_slot[2],cutter_tr[0].y,gear_big_d/2+small_gear_r],[0,90,0]];
cutter_bearing_index=2;
cutter_angles=[60,123];//cut big gear
cutter_work_angles=[-20,20];
cutter_work_angles_add=-10;

blade_thickness = 0.50;
blade_tr=[[-19,0,0],[0,0,90]];
blade_count=1;

cutter_endstopblock_tr=[[3+5,cutter_nema_tr[0].y-5,-8],[0,0,0]];
cutter_endstopblock_dim=[24,16,30];

//cutter_endstop_tr=[[36-0.6,cutter_nema_tr[0].y-2.9,1.51],[0,0,0]];
//cutter_endstop_tr=[[30.7,cutter_nema_tr[0].y-2.9,10.91-1],[0,-11-3,0]];
cutter_endstop_tr=[[30.7,cutter_nema_tr[0].y-2.9,10.91-0.5],[0,-11-3,0]];
cutter_switch_add_height=2;

mk8_endstop_body_dim=[28,10,mk8_stand_slot[3][2].x];
mk8_endstop_body_tr=[vector_sum(t8_nema_tr[0],[0,-nema17_dim()/2,-mk8_stand_slot[3][2].x-t8_nema_add_z]),[180,0,0]];
mk8_endstop=[vector_sum(mk8_endstop_body_tr[0],[-15,-2,5+1]),mk8_endstop_body_tr[1]];

stand_sensor_tr=[[0,mk8_stand_tr[0].y+20,0],[90,0,0]];

//rod_length=420, slot_length=409;
left_rod_offset = -31.8;
left_rod_block_thickness=5;
led_rod_rodin = 17;//20;
left_rod_out=13+5;//16;
left_rod_m5screw_offset=7;
left_rod_bottom=6;

left_rod_fix_rod=[vector_sum(luu8_tr[0],[left_rod_offset+1.4-left_rod_block_thickness
				,0,0]),luu8_tr[1]];
left_rod_fix_belt=[vector_sum(luu8_tr[0],[left_rod_offset-20-left_rod_block_thickness
										,0,0]),luu8_tr[1]];
left_rod_fix_nema_tr=[vector_sum(luu8_tr[0],[left_rod_offset-20-left_rod_block_thickness
											,18.4,-13/2]),[90,-90,0]];
left_rod_block_cut=(slot_tr[0].z-20-left_rod_block_thickness)-(left_rod_fix_nema_tr[0].z-nema17_dim()/2);

left_rod_fix_block_y=left_rod_fix_rod[0].y-luu8[0]/2-8/2-8;
left_rod_fix_block_l=slot_tr[0].y-left_rod_fix_block_y-20;
left_rod_fix_block_trt=[
	left_rod_fix_rod[0].x
	,left_rod_fix_block_y
	,left_rod_fix_nema_tr[0].z+nema17_dim()/2
];
left_rod_fix_block_dim=[nema17_dim()+left_rod_bottom,left_rod_fix_block_l,led_rod_rodin+1];

idler = [13,9.8,8.55];
left_rod_fix_idler_tr=[[
	 left_rod_fix_block_trt.x+left_rod_fix_block_dim.z/2
	,left_rod_fix_belt[0].y
	, left_rod_fix_nema_tr[0].z-nema17_dim()/2+idler[0]/2-left_rod_bottom]
	,[-90,0,0]];
left_rod_fix_idler2_tr=[[
	left_rod_fix_idler_tr[0].x,
	left_rod_fix_idler_tr[0].y,
	left_rod_fix_nema_tr[0].z,
],left_rod_fix_idler_tr[1]];

carriage_optical_switch_tr=[[
	 0
	,0
	,carriage_tr[0].z+2],[0,0,-90]];

frontier_filament_max_d=8;
frontier_filament_max_height=12;
frontier_filament_height=100;
frontier_global_tr=[[0,(slot_tr[0].y+20)+2,0],[0,0,0]];
frontier_global_y=60;
frontier_z_diff=19;
global_dim=[18+20,42+18,20];

frontier_dim_add=[20,frontier_global_y-global_dim.y,42];
frontier_dim=vector_sum(global_dim,frontier_dim_add);

frontier_tr=tr_sub(tr_sum(frontier_global_tr,[-global_dim.x/2,0,-global_dim.z/2])
				,[frontier_dim_add.x,0,frontier_dim_add.z]);
frontier_path_tr=[vector_sum(frontier_global_tr[0],[0,-0.01,0]),[-90,0,0]];
frontier_pc4_tr=[vector_sum(frontier_global_tr[0],[0,global_dim.y+0.01,0]),[-90,0,0]];

frontier_t8nut_dd=22.5;
frontier_t8cut_offset=6;
frontier_t8cut_width=15-2;
frontier_t8_screw_diameter=11;
frontier_bearing_diff=41;
frontier_axis_tr=[vector_replace(vector_sum(frontier_tr[0],[frontier_dim.x+0.01,frontier_dim.y/2,0]),2,slot_tr[0].z-25)
				,[0,-90,0]];
frontier_t8nut_tr=[vector_replace(frontier_axis_tr[0],0,14),[0,90,0]];

frontier_thrash_thickness=2;
frontier_left_add=9;
frontier_thrash_dim=[frontier_dim_add.x-frontier_thrash_thickness+frontier_left_add
					,global_dim.y-frontier_thrash_thickness*2
					,frontier_dim.z-(frontier_axis_tr[0].z-frontier_tr[0].z)-12];
frontier_thrash_tr=[[frontier_tr[0].x+frontier_thrash_thickness
					,frontier_tr[0].y+frontier_thrash_thickness
					,frontier_tr[0].z+(frontier_dim.z-frontier_thrash_dim.z+0.01)
					],[0,0,0]];
if (part=="") deb (str("frontier thrash dimension = ",frontier_thrash_dim));

frontier_nema_tr=[vector_sum(frontier_axis_tr[0],[30,0,0]),[0,-90,0]];
frontier_rods_diameter=[[7.1,7.1],[7.1,7.1]];
frontier_rod_top_thickness=4;
frontier_rod_thickness=18;
frontier_rod_outer=10;
frontier_rod_dim_z=frontier_rod_top_thickness+(slot_tr[0].z-frontier_nema_tr[0].z)+nema17_dim()/2;
frontier_rod_tr=tr_replace(tr_sum(slot_tr,[0,-20,-frontier_rod_dim_z+frontier_rod_top_thickness]),0,frontier_nema_tr[0].x);
frontier_rod_dim=[frontier_nema_tr[0].y-frontier_rod_tr[0].y+frontier_bearing_diff/2+frontier_rod_outer
				,frontier_rod_thickness
				,frontier_rod_dim_z];

frontiercarriage_flag_width=15.6;
frontiercarriage_flag_thickness=1.2;
frontiercarriage_flag_height=4;
frontiercarriage_flag_tr=tr_sum(tr_replace(frontier_tr,0,0)
	,[-frontiercarriage_flag_width/2,frontier_dim.y/2,-frontiercarriage_flag_height]);

frontier_switch_tr=[[
	 0
	,frontiercarriage_flag_tr[0].y+frontiercarriage_flag_thickness/2
	,frontiercarriage_flag_tr[0].z+2],[0,0,90]];
	
cutter_big_gear_add=false;	
	
module mk8_proto()
{	
	translate (mk8_nema_corr)
	translate_rotate(mk8_nema_tr)
	rotate ([0,0,-90])
		proto_nema17();
	
	translate_rotate(mk8_gear_tr)
		proto_mk8gear();

	for (t=[mk8_bearing_left_tr,mk8_bearing_right_tr])
		translate_rotate (t)
			proto_bearing(mk8_bearing_index);
	
	translate_rotate (t8nut_tr)
	color ("#ff4040")
		import ("proto/t8nut.stl");
	
	for (x=[-1,1])
	{
		translate ([x*rods[0]/2,0,0])
		translate(vector_replace(rods_tr[0],2,mk8_body_tr[0].z))
		translate([0,0,mk8_body_dim.z/2])
			proto_lm8luu();
	}
}

module filament_proto()
{
	h=200;
	color ("red")
	translate_rotate ([[0,h/2,0],[90,0,0]])
		cylinder (d=1.75,h=h,$fn=20);
}

module carriage_proto()
{
	color ("#E655FF")
	translate_rotate (slot_tr)
	translate ([0,0,-10])
		import ("proto/40x20x100VSlotExtrusion.stl");
	translate_rotate (carriage_bearing_tr)
		proto_bearing(carriage_bearing_index);
	for (y=[-1,1])
		translate([carriage_dim.x/2,luu8[0]/2*y,0])
		translate_rotate(luu8_tr)
		{
			proto_lm8uu();
			translate([0,0,-carriage_dim.x/2-5])
		 		rod8mm(length=carriage_dim.x+10);
		}
}

module carriage_opto_proto()
{
	color ("#EEF000")
	translate_rotate (carriage_optical_switch_tr)
		proto_optical_switch();
	
	color ("#E655FF")
	translate_rotate (slot_tr)
	translate ([0,0,-10])
		import ("proto/40x20x100VSlotExtrusion.stl");
}


module mk8_stand_proto()
{
	translate_rotate (mk8_endstop)
	color ("orange")
	rotate ([-90,0,0])
	translate ([8.5,0.75,7])
	rotate ([-90,0,90])
		import ("proto/switch2.stl");
	
	color ("#E655FF")
	translate_rotate (slot_tr)
	translate ([0,0,-10])
		import ("proto/40x20x100VSlotExtrusion.stl");

	color ("#AA4490")
	for (x=[-1,1])
	{
		translate ([x*rods[0]/2,0,rods_up])
		translate_rotate (rods_tr)
			cylinder (d=rods[1],h=rods[2],$fn=40);
	}
	
	translate_rotate(t8_nema_tr)
	{
		proto_nema17();
		
		color ("#990000")
		translate ([0,0,9])
		rotate ([90,0,90])
			import("proto/Flexible_Shaft_Coupling.stl");
		
		color ("#44AA90")
		translate ([0,0,24])
			cylinder (d=8,h=60,$fn=40);
	}
}

function ss443a_fix_coords(dim,yy,xadd=0) = [5+xadd,dim.y/2+(dim.y/2-1.8)*yy,dim.z];

module ss443a_fd(op="cut")
{
	g_tr=[0,52,0];
	filament_diameter=1.75;
	filament_hole=3;
	
	ballr=3.9;
	ball=ballr+0.8;
	ptfe_diameter_needed=6;//5.2;
	ptfe_diameter=ball>ptfe_diameter_needed?ball:ptfe_diameter_needed;
	ptfe_height=19.7+4-ball;
	ball_up=(ball-filament_hole)/2+filament_diameter/2;
	
	ss443a_tr=[[0,0,ball_up+ptfe_height+ball/2+2],[90,0,180]];
	
	ss443a_box_dim=[8,14,3];
	ss443a_box_dim_sub=[0,2,0];
	ss443a_box_tr=[vec_add(ss443a_tr[0],[ss443a_box_dim.y/2,-ss443a_box_dim.x+4,0]),[0,0,90]];
	
	inner_d=3.4;
	inner_cut=4;
	inner_offset=0.3;
	inner_o2i=2.0;//1.2;
	inner_magnet=[1.7-0.1,5];
	inner_dd=ptfe_diameter-inner_offset*2;
	inner_hh=ptfe_height+ball/2-inner_cut;
	
	if (op=="proto")
	{
		translate_rotate (ss443a_tr)
			protoSS443A();
		color("lime")
		translate ([0,0,ball_up])
			sphere (d=ball,$fn=60);
	}
	if (op=="spring")
	{
		height=0.3;
		translate (g_tr)
		{
			difference()
			{
				union()
				{
					hull()
					for (yy=[-1,1])
					{
						translate_rotate (ss443a_box_tr)
						translate (ss443a_fix_coords(ss443a_box_dim,yy))
						rotate ([180,0,0])
						{
							cylinder (d=5,h=height,$fn=60);
						}
					}
					translate_rotate (ss443a_box_tr)
					translate (ss443a_fix_coords(ss443a_box_dim,0))
					translate ([0,0,-height])
						cylinder (d=ptfe_diameter+0.8*2,h=height,$fn=60);
				}
				translate_rotate (ss443a_box_tr)
				translate (ss443a_fix_coords(ss443a_box_dim,0))
				translate ([0,0,-height-0.1])
				{
					cylinder (d=inner_magnet[0],h=height+0.2,$fn=60);
					
					rays=8;
					angle=360/rays;
					rays_dim=[0.4,2.4];
					for (a=[0:rays-1])
						rotate ([0,0,a*angle])
						translate ([-rays_dim.x/2,0,0])
							cube([rays_dim.x,rays_dim.y,height+0.2]);
				}
				
				for (yy=[-1,1])
				{
					translate_rotate (ss443a_box_tr)
					translate (ss443a_fix_coords(ss443a_box_dim,yy))
					translate ([0,0,0.1])
					rotate ([180,0,0])
					{
						cylinder (d=3.6,h=height+0.2,$fn=60);
					}
				}
			}
		}
	}
	if (op=="inner")
	{	
		translate (g_tr)
		{
			translate ([0,0,ball_up])
			difference()
			{
				inner_d_diff=(inner_dd-inner_d)/1;
				diff=0.2;
				bround=[0.8,2];
				points=[
					 [0,0,0]
					,[inner_dd/2,0,bround[0]]
					,[inner_dd/2,inner_o2i,bround[1]]
				
					,[inner_d/2,inner_o2i+inner_d_diff,4]
					,[inner_d/2,inner_hh-inner_o2i-inner_d_diff,4]
				
					,[inner_dd/2-diff,inner_hh-inner_o2i,bround[1]]
					,[inner_dd/2-diff,inner_hh,bround[0]]
					,[0,inner_hh,0]
				];
				translate ([0,0,inner_hh])
				rotate ([180,0,0])
				rotate_extrude($fn=100)
					polygon(polyRound(points,20));
				
				translate ([0,0,inner_hh-inner_magnet[1]+0.01])
					cylinder (d=inner_magnet[0],h=inner_magnet[1],$fn=60);
			}
		}
	}
	if (op=="cut")
	{
		translate (g_tr)
		{
			translate ([0,-30,0])
			rotate ([-90,0,0])
				cylinder (d=filament_hole,h=60,$fn=40);
			
			translate ([0,0,ball_up])
			hull()
			{
				sphere (d=ball,$fn=60);
				cylinder (d=ptfe_diameter,h=ptfe_height+ball/2,$fn=60);
			}
		}
	}
	if (op=="add")
	{
		translate (g_tr)
		fillet (r=0.6,steps=16)
		{
			hull()
			for (yy=[-1,1])
			{
				translate_rotate (ss443a_box_tr)
				translate (ss443a_fix_coords(ss443a_box_dim,yy))
				rotate ([180,0,0])
				{
					up=4.99;
					translate ([0,0,10-up])
						cylinder (d=5,h=20+up,$fn=60);
				}
			}
			translate ([-7.7,-5,8])
				cube ([15.4,10,1]);
		}
		
		translate (g_tr)
		fillet (r=0.8,steps=16)
		{
			translate ([0,0,ball_up])
			translate ([0,0,ball/2])
				cylinder (d=ptfe_diameter+0.8*2,h=ptfe_height-0.01,$fn=60);
			translate ([-5,-5,8])
				cube ([10,10,1]);
		}
	}
	if (op=="main")
	{
		difference() 
		{
			union()
			{
				proto();
				ss443a_fd(op="add");
			}
			ss443a_fd();
			ss443a_fd(op="ss443_box_fix");
		}
	}
	if (op=="ss443_box")
	{
		difference()
		{
			translate (g_tr)
			difference()
			{
				union()
				{
					rr=2;
					dim=vec_sub(ss443a_box_dim,[ss443a_box_dim_sub.x*2,ss443a_box_dim_sub.y*2,ss443a_box_dim_sub.z]);
					translate_rotate (ss443a_box_tr)
					translate (ss443a_box_dim_sub)
					linear_extrude(dim.z)
						polygon(polyRound([
							 [0,0,rr]
							,[dim.x,0,rr]
							,[dim.x,dim.y,rr]
							,[0,dim.y,rr]
						],10));
					for (yy=[-1,1])
						translate_rotate (ss443a_box_tr)
						translate (ss443a_fix_coords(ss443a_box_dim,yy))
						rotate ([180,0,0])
							cylinder (d=6,h=ss443a_box_dim.z,$fn=40);
				}
				translate_rotate (ss443a_tr)
					SS443A(SS443A_out=10,SS443A_yout=0,SS443A_yout_addthickness=0, wire_cut=[0,0]);
			}
			ss443a_fd(op="ss443_box_fix");
		}
	}
	if (op=="ss443_box_cut")
	{
		difference()
		{
			translate (g_tr)
			translate_rotate (ss443a_box_tr)
			translate ([-10,-10,1.85])
				cube(vec_add(ss443a_box_dim,[20,20,0]));
		}
	}
	if (op=="ss443_box_top")
	{
		intersection()
		{
			ss443a_fd(op="ss443_box");
			translate ([0,0,0.1])
				ss443a_fd(op="ss443_box_cut");
		}
	}
	if (op=="ss443_box_bottom")
	{
		difference()
		{
			ss443a_fd(op="ss443_box");
			ss443a_fd(op="ss443_box_cut");
		}
	}
	if (op=="ss443_box_fix")
	{
		translate (g_tr)
		for (yy=[-1,1])
			translate_rotate (ss443a_box_tr)
			translate (ss443a_fix_coords(ss443a_box_dim,yy))
			rotate ([180,0,0])
			{
				translate ([0,0,-0.01])
					cylinder (d=3.1-0.1,h=40,$fn=20);
			}
	}
}

module motor_pulley()
{
	include <motor_pulley.scad>
}

module belt (length,smooth=false)
{
	belt_h=0.83;
	belt_h_m=belt_h+0.3;
	belt_width=7;

	translate ([-belt_h_m,-belt_width/2,0])	
	{
		cube ([belt_h_m,belt_width,length]);
		if (smooth)
		{
			hull()
			for (z=[0,length])
				translate ([0,0,z])
				rotate ([-90,0,0])
					cylinder (d=1.1,h=belt_width,$fn=6);
		}
		else
		for (z=[0:2:length])
			translate ([0,0,z])
			rotate ([-90,0,0])
				cylinder (d=1.1,h=belt_width,$fn=6);
	}
}

module belt_cut(length)
{
	rotate ([0,0,180])
	{
		belt_h=6;
		belt_width=10;
	
		translate ([-belt_h/2,-belt_width/2,0])	
		{
			cube ([belt_h,belt_width,length]);
		}
	}
}

module rod_fix(is_motor=true,rod_trouth=false)
{
	slot_cube_dim=[40+left_rod_block_thickness*2
			,left_rod_block_thickness+left_rod_out
			,20+left_rod_block_thickness*2+left_rod_block_cut+left_rod_bottom];
	slot_cube_trt=[-20-left_rod_block_thickness
				,100-slot_cube_dim.y+left_rod_block_thickness
				,-20-left_rod_block_thickness-left_rod_block_cut-left_rod_bottom];
	slot_offs=0.2;
	idler_offs=[1,1];
	rod_out_diff=left_rod_out-13;
	
	union()
	{
		difference()
		{
			union()
			{
				difference()
				{
					union()
					{
						nema_add=2;
						if (is_motor)
						translate_rotate(left_rod_fix_nema_tr)
						linear_extrude(left_rod_block_thickness)
							polygon (polyRound([
								 [-nema17_dim()/2-left_rod_bottom,-nema_add-nema17_dim()/2,0]
								,[-nema17_dim()/2-left_rod_bottom,nema17_dim()/2,4]
								,[nema17_dim()/2,nema17_dim()/2,4]
								,[nema17_dim()/2,-nema_add-nema17_dim()/2,0]
							],1));
						
						translate(left_rod_fix_block_trt)
						rotate(left_rod_fix_rod[1])
						{
							linear_extrude(left_rod_fix_block_dim.z)
							polygon(polyRound([
								 [0,0,6]
								,[0,left_rod_fix_block_dim.y,11]
								,[left_rod_fix_block_dim.x,left_rod_fix_block_dim.y,0]
								,[left_rod_fix_block_dim.x,0,12]
							],1));
						}
						
						translate_rotate (slot_tr)
						translate (slot_cube_trt)
							cube (slot_cube_dim);
					}
					
					if (is_motor)
					translate_rotate(left_rod_fix_nema_tr)
						nema17_cut(shaft=false,main_cyl=true,washers=true,main_cyl_length=100,nema17_cut=false);
					
					for (y=[-1,1])
						translate([0,luu8[0]/2*y,0])
						translate_rotate(left_rod_fix_rod)
						{
							zz=rod_trouth?-1:1;
							translate ([0,0,zz])
							{
								dd=8+0.2+0.2;
								cylinder(d=dd,h=80,$fn=60);
								if (rod_trouth)
									sphere (d=dd,$fn=60);
							}
							translate ([0,0,led_rod_rodin/2])
							rotate ([0,-90,0])
							{
								screw=8+1+8/2;
									cylinder (d=m3_screw_diameter(),h=screw+0.1,$fn=40);
								translate ([0,0,screw])
									cylinder (d=m3_washer_diameter(),h=100,$fn=40);
								rotate ([0,0,-90])
								translate ([0,0,7])
									m3_square_nut();
							}
						}
						
					translate_rotate(left_rod_fix_belt)
						belt_cut(length=100);
					
					add=40;
					translate_rotate (slot_tr)
					translate ([0,-rod_out_diff,-10])
					{
						translate ([-20-slot_offs,0,-10-slot_offs-add])
							cube ([40+slot_offs*2,100,20+slot_offs*2+add]);
					}

					translate_rotate (slot_tr)
					translate ([-left_rod_block_thickness
								,left_rod_block_thickness-slot_cube_dim.y+rod_out_diff
								,-10+left_rod_block_thickness])
					{
						dim=[left_rod_block_thickness,100,20+slot_offs*2+add];
						translate ([-20-slot_offs,0,-10-slot_offs-add])
						{
							cube (dim);
							linear_extrude(dim.z)
								polygon(polyRound([
									 [0,0,0]
									,[dim.x*2,0,0]
									,[dim.x*2,dim.y,5]
									,[0,dim.y,0]
								],1));
						}
					}
					
					translate_rotate (left_rod_fix_idler_tr)
					{
						idler_h=idler[2]+idler_offs[0]*2;
						
						hull()
						for (x=[-1,1])
						translate ([10*x,0,-idler_h/2])
							cylinder (d=idler[0]+idler_offs[1]*2,h=idler_h,$fn=60);
					}
					
					if (!is_motor)
					{
						translate_rotate(left_rod_fix_idler2_tr)
						{
							idler_h=idler[2]+idler_offs[0]*2;
						
							hull()
								for (x=[-1,1])
								translate ([10*x,0,-idler_h/2])
									cylinder (d=idler[0]+idler_offs[1]*4,h=idler_h,$fn=60);
							hull()
							for (z=[0,1])
								translate ([-idler[0]/2,z*100,-idler_h/2])
									cylinder (d=idler[0],h=idler_h,$fn=60);
						}
					}
				}
				translate_rotate (slot_tr)
				translate (slot_cube_trt)
				{
					for (i=[0,1])
					translate ([left_rod_block_thickness-slot_offs+10+i*20
							,slot_cube_dim.y
							,slot_cube_dim.z-left_rod_block_thickness+slot_offs])
					rotate ([90,-90,0])
						lgroove (slot_cube_dim.y);
					translate ([left_rod_block_thickness-slot_offs
								,rod_out_diff
								,slot_cube_dim.z-left_rod_block_thickness+slot_offs-10])
					rotate ([-90,180,0])
						lgroove (slot_cube_dim.y-rod_out_diff);
					translate ([left_rod_block_thickness+40+slot_offs,0,slot_cube_dim.z-left_rod_block_thickness+slot_offs-10])
					rotate ([-90,0,0])
						lgroove (slot_cube_dim.y);
				}
				
				translate_rotate(left_rod_fix_idler_tr)
					for (m=[0,1])
					mirror([0,0,m])
					translate ([0,0,-idler[2]/2-idler_offs[0]])
						cylinder (d2=3+2,d1=3+2+idler_offs[0]*2,h=idler_offs[0],$fn=60);
				if (!is_motor)
				translate_rotate(left_rod_fix_idler2_tr)
					for (m=[0,1])
					mirror([0,0,m])
					translate ([0,0,-idler[2]/2-idler_offs[0]])
						cylinder (d2=3+2,d1=3+2+idler_offs[0]*2,h=idler_offs[0],$fn=60);
			}
			translate_rotate (slot_tr)
			translate (slot_cube_trt)
			{
				for (i=[0,1])
					translate ([left_rod_block_thickness+10+20*i,left_rod_m5screw_offset,-slot_cube_trt.z+4])
					rotate ([180,0,0])
						m5n_screw_washer(thickness=6, diff=0.1, washer_out=20);
				
				translate ([left_rod_block_thickness+40+4,left_rod_m5screw_offset,-slot_cube_trt.z-10+slot_offs])
				rotate ([0,-90,0])
					m5n_screw_washer(thickness=6, diff=0.1, washer_out=20);
				
				if (!is_motor)
				for (i=[0,1])
					translate ([left_rod_block_thickness+10+20*i,slot_cube_dim.y-(left_rod_block_thickness-4),-slot_cube_trt.z-10])
					rotate ([90,0,0])
						m5n_screw_washer(thickness=6+rod_out_diff, diff=0.1, washer_out=20);
			}
			translate_rotate (left_rod_fix_idler_tr)
			{
				screw=25;
				translate ([0,0,-screw/2+1])
				{
					cylinder (d=m3_screw_diameter(),h=screw+1,$fn=20);
					translate ([0,0,-50+0.01])
						cylinder (d=m3_washer_diameter(),h=50,$fn=40);
					translate ([0,0,screw-3])
					rotate ([0,0,-90])
						m3_square_nut();
				}
			}		
			if (!is_motor)
			translate_rotate(left_rod_fix_idler2_tr)
			{
				screw=40;
				translate ([0,0,-screw/2+1])
				{
					cylinder (d=m3_screw_diameter(),h=screw+1,$fn=20);
					translate ([0,0,-50+0.01])
						cylinder (d=m3_washer_diameter(),h=50,$fn=40);
					translate ([0,0,screw-3])
					rotate ([0,0,-90])
						m3_square_nut();
				}
			}
			
		}
		translate_rotate (slot_tr)
		translate (slot_cube_trt)
		{
			if (!is_motor)
			for (i=[0,1])
				translate ([left_rod_block_thickness+10+20*i,slot_cube_dim.y-(left_rod_block_thickness-4),-slot_cube_trt.z-10])
				rotate ([90,0,0])
					m5n_screw_washer_add();
		}
	}
}

module left_rod_fix()
{
	rod_fix(rod_trouth=true);
}

module right_rod_fix()
{
	mirror([1,0,0])
		rod_fix(is_motor=false,rod_trouth=true);
}

module left_rod_fix_proto()
{
	translate_rotate(left_rod_fix_nema_tr)
	{
		proto_nema17();
		proto_nema17_pulley_GT2T16();
	}
	
	color ("maroon")
	translate_rotate(left_rod_fix_belt)
	rotate ([0,0,180])
		belt (length=100);
	
	color ("#E655FF")
	translate_rotate (slot_tr)
	translate ([0,0,-10])
		import ("proto/40x20x100VSlotExtrusion.stl");
	
	for (y=[-1,1])
		translate([1,luu8[0]/2*y,0])
		translate_rotate(left_rod_fix_rod)
		{
			translate([0,0,0])
		 		rod8mm(length=carriage_dim.x+10);
		}
		
	color ("#AAFF66")
	translate_rotate (left_rod_fix_idler_tr)
	{
		translate ([0,0,-idler[2]/2])
			cylinder (d=idler[1],h=idler[2],$fn=50);
		translate ([0,0,-idler[2]/2])
			cylinder (d=idler[0],h=1,$fn=50);
		translate ([0,0,idler[2]/2-1])
			cylinder (d=idler[0],h=1,$fn=50);
	}
	color ("maroon")
	translate ([0,0,-idler[2]/2-1])
	translate (left_rod_fix_idler_tr[0])
	rotate ([0,90,0])
		belt(length=100);
}

module mk8gear_cut(offs=0)
{
	translate (mk8gear_trans)
	rotate (mk8gear_rot)
	rotate ([-90,0,0])
		cylinder (d=mk8_gear[0]+offs*2,h=mk8_gear[1]+10,$fn=80);
}

module bearing_body(index,offs=0)
{
	difference()
	{
		translate ([0,0,-offs])
			cylinder(d=bearings[index][0]+offs*2,h=bearings[index][1]+offs*2,$fn=80);
		if (offs==0)
		translate([0,0,-0.1])
			cylinder(d=bearings[index][2],h=bearings[index][1]+0.2,$fn=80);
	}
}

module bearing_stand(index,offs=0)
{
	dd=bearings[index][2]+1;
	translate ([0,0,-offs-0.1])
		cylinder(d1=dd+offs*2,d2=dd,h=offs,$fn=80);
	translate ([0,0,bearings[index][1]+0.1])
		cylinder(d2=dd+offs*2,d1=dd,h=offs,$fn=80);
}

module proto_bearing(index)
{
	color ("#22AAFF")
		bearing_body(index=index);
}

module mk8_cut(offs,add=false)
{
	if (add)
	{
		translate ([0,0,-offs])
		translate ([0,0,mk8_gear[1]+offs*2])
			cylinder (d=mk8_gear[0]+offs*2,h=0.2,$fn=40);
	}
	else
	{
		translate ([0,0,-offs])
			cylinder (d=mk8_gear[0]+offs*2,h=mk8_gear[1]+offs*2,$fn=40);
	}
}

module mk8_small_gear(op=1)
{
	screw=mk8_transmission_small[3];
	nema17_d=5.4;
	mk8_cut_offs=1;
	hh=mk8_transmission_small[1]+mk8_transmission[3];
	if (op==1)
	{
		union()
		{
			offs=0.5;
			difference()
			{
				union()
				{
					pfeilrad (modul=1
							, zahnzahl=mk8_transmission_small[0]
							, breite=mk8_transmission_small[1]
							, bohrung=0.1
							, eingriffswinkel=mk8_transmission[0]
							, schraegungswinkel=mk8_transmission[1]
							, optimiert=false);
					translate ([0,0,mk8_transmission_small[1]-0.01])
						cylinder (d=mk8_transmission_small[2],h=hh-mk8_transmission_small[1],$fn=80);
				}
				translate ([0,0,-0.1])
					cylinder (d=nema17_d,h=hh+0.2,$fn=80);
				
				hscrew=screw+5/2;
				for (a=[90+0,90+180])
					translate ([0,0,mk8_transmission_small[1]+mk8_transmission[3]/2])
					rotate ([0,90,a])
					{
						washer_offs=-0.5-0.7;//0.5 washer+0.7 spring
						cylinder (d=m3_screw_diameter(),h=hscrew,$fn=80);
						translate ([0,0,5/2+screw+washer_offs])
						{
							//cylinder (d=m3_washer_diameter(),h=20,$fn=80);
							translate ([-m3_washer_diameter()/2,-m3_washer_diameter(),0])
								cube ([m3_washer_diameter(),m3_washer_diameter()*2,m3_cap_h()+2]);
						}
						translate ([0,0,5/2+screw+washer_offs])
							cylinder (d=m3_cap_diameter(),h=m3_cap_h()+2,$fn=80);
						translate ([0,0,5/2+1])
						rotate ([0,0,90])
							m3_square_nut();
					}
				translate ([0,0,mk8_cut_offs])
				translate ([0,0,-mk8_gear[1]+mk8_transmission_small[4]-offs])
					mk8_cut(offs=offs);
			}
			translate ([0,0,mk8_cut_offs])
			translate ([0,0,-mk8_gear[1]+mk8_transmission_small[4]-offs])
				mk8_cut(offs=offs,add=true);
		}
	}
	if (op==2 || op==3)
	{
		offs=[1,1];
		add=op==2?0:10;
		dd=max(mk8_transmission_small[0]+2.1,mk8_transmission_small[2])+offs.x*2;
		translate ([0,0,-offs.y])
			cylinder (d=dd,h=mk8_transmission_small[1]+mk8_transmission[3]+offs.x*2+add,$fn=60);
	}
}

module cap_cube1 (dim,d)
{
	//#cube(dim);
	nd=[dim.x-d,dim.y-d,dim.z-d/2];
	difference()
	{
		translate ([d/2,d/2,0])
		minkowski()
		{
			cube(nd);
			sphere(d=d,$fn=20);
		}
		translate ([0,0,-dim.z])
			cube(dim);
	}
}

module cap_cube2 (dim,d)
{
	//#cube(dim);
	nd=[dim.x-d,dim.y-d,dim.z-d/2];
	difference()
	{
		translate ([d/2,d/2,d/2])
		minkowski()
		{
			cube(nd);
			sphere(d=d,$fn=20);
		}
	}
}

module mk8_big_gear(op=1)
{
	screw=mk8_transmission_big[3];
	nema17_d=5.4;
	hh=mk8_transmission_small[1]+mk8_transmission[3];
	if (op==1)
	{
		difference()
		{
			union()
			{
				mirror([0,0,0])			
				pfeilrad (modul=1
						, zahnzahl=mk8_transmission_big[0]
						, breite=mk8_transmission_big[1]
						, bohrung=0.1
						, eingriffswinkel=mk8_transmission[0]
						, schraegungswinkel=mk8_transmission[1]
						, optimiert=false);
				translate ([0,0,mk8_transmission_small[1]-0.01])
					cylinder (d=mk8_transmission_big[2],h=hh-mk8_transmission_small[1],$fn=80);
			}
			difference()
			{
				translate ([0,0,-0.1])
					cylinder (d=nema17_d,h=hh+0.2,$fn=80);
				translate ([-10,2.1,10-8])
					cube ([20,20,60]);
			}
			hscrew=screw+5/2;
			for (a=[0,180])
			translate ([0,0,mk8_transmission_small[1]+mk8_transmission[3]/2])
			rotate ([0,90,90+a])
			{
				washer_offs=-0.5-0.7;//0.5 washer+0.+7 spring
				cylinder (d=m3_screw_diameter(),h=hscrew,$fn=80);
				translate ([0,0,5/2+screw+washer_offs])
				{
					translate ([-m3_washer_diameter()/2,-m3_washer_diameter()/2,0])
						cube ([m3_washer_diameter(),m3_washer_diameter(),m3_cap_h()+2]);
				}
				translate ([0,0,5/2+screw+washer_offs])
					cylinder (d=m3_cap_diameter(),h=m3_cap_h()+2,$fn=80);
				translate ([0,0,5/2+1])
				rotate ([0,0,90])
					m3_square_nut();
			}
		}
	}
	offs=[1,1];
	corr=4;
	dd=max(mk8_transmission_big[0]+2.1,mk8_transmission_big[2])+offs.x*2;
	hc=mk8_transmission_big[1]+mk8_transmission[3]+offs.x*2+corr;
	if (op==2)
	{
		translate ([0,0,-offs.y])
		hull()
		{
			for (x=[-80,80])
			translate ([x,0,-corr])
				cylinder (d=dd,h=hc,$fn=60);
		}
	}
	if (op==3)
	{
		offs_cap=[-0.25,1];
		thickness=2;
		dim_cap=[
			 [[dd+offs_cap[0]*2,hc+offs_cap[0]*2,4],0,false]
			,[[dd+offs_cap[1]*2,hc+offs_cap[1]*2,2],4,true]
		];
		dim_cap_cut=[
			 [[dd+offs_cap[0]*2-thickness*2,hc+offs_cap[0]*2-thickness*2,4+1],-1]
		];
		difference()
		{
			union()
			for (d=dim_cap)
				translate ([-d[0].x/2,-d[0].y/2,d[1]])
					if(d[2])
						cap_cube1(d[0],2);
					else
						cap_cube2(d[0],2);
			
			for (d=dim_cap_cut)
				translate ([-d[0].x/2,-d[0].y/2,d[1]])
					cube (d[0]);
		}
	}
}
module mk8_cap()
{
	mk8_big_gear(op=3);
}

module nema17_cut(add=false
				,shaft=true
				,fix=true
				,main_cyl=false
				,main_cyl_length=24
				,main=true
				,washers=false
				,bighole=false
				,shaft_offset=0
				,shaft_length=40
				,screw_length=8
				,hull_body=[[0,0,0]]
				,nema17_cut=true
	)
{
	nema17_dim=42.3+0.2;
	screw=screw_length-4;
	if (add)
	{
		for (x=[-1:2:1])
			for (y=[-1:2:1])
				translate ([31/2*x,31/2*y,-0.01+screw-0.4])
				{
					cylinder (d=m3_washer_diameter(),h=0.4,$fn=20);
				}
	}
	else
	{
		if (main)
		{
			cut=nema17_cut?3:0;
			
			for (h=hull_body)
			hull()
			translate(h)
			rotate ([0,180,0])
			linear_extrude(80)
				polygon(polyRound([
					 [-nema17_dim/2,-nema17_dim/2,cut]
					,[-nema17_dim/2,nema17_dim/2,cut]
					,[nema17_dim/2,nema17_dim/2,cut]
					,[nema17_dim/2,-nema17_dim/2,cut]
				],1));
			translate ([0,0,-0.1])
				cylinder (d=22+0.6,h=2.2,$fn=60);
		}
		
		if (main_cyl)
			translate ([0,0,-0.1])
				cylinder (d=24,h=main_cyl_length,$fn=60);
		
		difference()
		{
			cylinder (d=(bighole?5.4:5.2)+shaft_offset*2,h=shaft_length,$fn=60);
			if (shaft)
				translate ([-10,2.1,10])
					cube ([20,20,60]);
		}
		
		if (fix)
			for (x=[-1:2:1])
				for (y=[-1:2:1])
					translate ([31/2*x,31/2*y,-0.01])
					{
						cylinder (d=m3_screw_diameter(),h=screw,$fn=20);
						translate ([0,0,screw-0.01])
							cylinder (d=washers?m3_washer_diameter():m3_cap_diameter(),h=60,$fn=20);			
					}
	}
}

module mk8_body_bottom(offs=0,part=0)
{
	corr=11;
	rf=14+10;
	bearing_power=0;
	union()
	{
		if (part==0 || part==1)
		union()
		{
			dd=mk8_bearingfixer_left_dim[0]+offs*2;
			hh=mk8_bearingfixer_left_dim[1]+offs*2;
			fillet (r=rf,steps=16)
			{
				hull()
				for (z=[0,20])
				{
					translate ([offs,0,z])
					translate_rotate(mk8_bearingfixer_left_tr)
						cylinder (d=dd,h=hh,$fn=80);
				}
				dim=vector_sum(vector_replace(vector_replace(mk8_body_dim,2,0.1),0,mk8_bearingfixer_right_dim[1]),[offs*2,0,0]);
				translate ([-offs,0,0])
				translate(vector_sum(mk8_body_tr[0],[0,corr,0]))
					cube(vector_sum(dim,[0,-corr,0]));
			}
			
			translate ([-hh,0,0])
			translate_rotate(mk8_bearingfixer_left_tr)
				cylinder (d1=dd,d2=dd-bearing_power,bearing_power,$fn=80);
		}
		
		if (part==0 || part==2)
		union()
		{
			dd=mk8_bearingfixer_right_dim[0]+offs*2;
			hh=mk8_bearingfixer_right_dim[1]+offs*2;
			dim2=vector_sum(vector_replace(vector_replace(mk8_body_dim,2,0.1),0,mk8_bearingfixer_right_dim[1]),[offs*2,0,0]);
			if (part==0)
			{
				fillet (r=rf,steps=16)
				{
					hull()
					for (z=[0,20])
					{
						translate ([-offs,0,z])
						translate_rotate(mk8_bearingfixer_right_tr)
							cylinder (d=dd,h=hh,$fn=80);
					}
					translate ([offs,0,0])
					translate([mk8_body_dim.x-dim2.x,0,0])
					translate(vector_sum(mk8_body_tr[0],[0,corr,0]))
						cube(vector_sum(dim2,[0,-corr,0]));
				}
				
				translate ([hh,0,0])
				translate_rotate(mk8_bearingfixer_right_tr)
					cylinder (d1=dd,d2=dd-bearing_power,bearing_power,$fn=80);
				
				add=1.8;
				translate ([offs,7,0])
				translate([mk8_body_dim.x-dim2.x,0,0])
				translate(vector_sum(mk8_body_tr[0],[0,corr,0]))
				rotate ([0,45,0])
				translate ([-add,0,-add])
					cube([add*2,18,add*2]);
			}
			else
			{
				hull()
				for (z=[0,20])
				{
					translate ([-offs,0,z])
					translate_rotate(mk8_bearingfixer_right_tr)
						cylinder (d=dd,h=hh,$fn=80);
				}
			}
		}
	}
}

module mk8_body_middle(big_lm8)
{
	dd1=15+2;
	translate ([-rods[0]/2,-big_lm8/2,0])
	translate(vector_replace(rods_tr[0],2,mk8_body_tr[0].z))
		cube ([rods[0],dd1/2+big_lm8/2,mk8_body_dim.z]);
}

module mk8_body_cube(dim)
{
	cut=4;
	linear_extrude(dim.z)
		polygon(polyRound([
			 [0,0,cut]
			,[0,dim.y,0]
			,[dim.x,dim.y,0]
			,[dim.x,0,cut]
		],10));
}

module mk8_body()
{
	lm8screw=16;
	big_lm8=15+10;
	t8nut_offset=4;
	union()
	{
		difference()
		{
			union()
			{
				mk8_body_bottom();
				
				for (x=[-1,1])
				for (z=[-1,1])
				{
					translate ([x*rods[0]/2,0,0])
					translate(vector_replace(rods_tr[0],2,mk8_body_tr[0].z))
					translate([0,0,mk8_body_dim.z/2])
					{
						translate_rotate ([[lm8screw_xoffset*x,-lm8screw/2,(45/2-lm8luu_groove()-0.5)*z],[-90,-90*x,0]])
							cylinder (d=9,h=13,$fn=60);
					}
				}
				
				fillet(r=6,steps=16)
				{
					corr=[0,-7,0];
					translate_rotate(tr_sub(mk8_body_tr,corr))
						mk8_body_cube(vector_sum(mk8_body_dim,corr));
					mk8_body_middle(big_lm8);
				}
	
				union()
				{		
					lm8cut=1;	
					for (x=[-1:1])
						fillet(r=1,steps=8)
						{
							translate ([x*rods[0]/2,0,0])
							translate(vector_replace(rods_tr[0],2,mk8_body_tr[0].z))
							{
								difference()
								{
									cylinder (d=big_lm8,h=mk8_body_dim.z,$fn=60);
									translate ([-big_lm8/2,big_lm8/2-lm8cut,-0.1])
										cube ([big_lm8,big_lm8,mk8_body_dim.z+0.2]);
								}
							}
		
							mk8_body_middle(big_lm8);
						}
				}
			}
	
			for (x=[-1,1])
			{
				translate ([x*rods[0]/2,0,0])
				translate(vector_replace(rods_tr[0],2,mk8_body_tr[0].z))
				translate([0,0,(mk8_body_dim.z-100)/2])
				{
					cylinder (d=15+0.2,h=100,$fn=60);
					th=1;
					rotate ([0,0,-90+x*90])
					translate([0,-th/2,0])
						cube ([60,th,100]);
				}
			}
			
			translate_rotate (rods_tr)
				cylinder (d=11,h=130,$fn=40);
			
			translate_rotate (t8nut_tr)
			hull()
			{
				dd=30;
				cylinder (d=dd,h=130,$fn=60);
				translate ([0,20,0])
					cylinder (d=dd,h=130,$fn=60);
			}
			translate_rotate (t8nut_tr)
			translate([0,0,-7])
			rotate ([0,180,0])
			hull()
			{
				dd=30;
				cylinder (d=dd,h=130,$fn=60);
				translate ([0,20,0])
					cylinder (d=dd,h=130,$fn=60);
			}
			
			for (a=[0:3])
				translate (vector_replace(rods_tr[0],2,t8nut_tr[0].z))
				rotate ([0,0,a*90])
				translate_rotate ([[16/2,0,0],[0,180,90]])		
				{
					m3_screw(h=100);
					translate ([0,0,t8nut_offset])
					{
						m3_nut_inner();
						translate ([0,0,m3_nut_h()-0.01])
							m3_nut(h=100);
					}
				}
			
			translate_rotate(mk8_transmission_small_tr)	mk8_small_gear(op=2);
			translate_rotate(mk8_transmission_big_tr) mk8_big_gear(op=2);
			translate (mk8_nema_corr)
			translate_rotate(mk8_nema_tr)
				nema17_cut(shaft=false,main_cyl=true,main_cyl_length=100,hull_body=[[0,0,0],[0,-20,0],[20,0,0]]);
			
			mk8_bearing_offs2=-0.6-1;
			translate([mk8_bearing_offs2,0,0])
			translate_rotate(mk8_bearingfixer_left_tr)
				bearing_body(index=mk8_bearing_index,offs=0.4-0.2);
			translate([-mk8_bearing_offs2,0,0])
			translate_rotate(mk8_bearingfixer_right_tr)
				bearing_body(index=mk8_bearing_index,offs=0.4-0.2);
				
			translate_rotate(mk8_bearingfixer_left_tr)
			rotate ([0,180,0])
			translate ([0,0,-20])
				cylinder (d=bearings[mk8_bearing_index][0]-1,h=100,$fn=40);

			for (x=[-1,1])
			for (z=[-1,1])
			{
				translate ([x*rods[0]/2,0,0])
				translate(vector_replace(rods_tr[0],2,mk8_body_tr[0].z))
				translate([0,0,mk8_body_dim.z/2])
				{
					translate_rotate ([[lm8screw_xoffset*x,-lm8screw/2,(45/2-lm8luu_groove()-0.5)*z],[-90,-90*x,0]])
					{
						m3_screw(h=lm8screw,cap_out=20);
						translate ([0,0,lm8screw-3])
						rotate ([0,0,0])
							m3_square_nut_planar();
					}
				}
			}
		}
	}
	for (a=[0:3])
		translate (vector_replace(rods_tr[0],2,t8nut_tr[0].z))
		rotate ([0,0,a*90])
		translate_rotate ([[16/2,0,0],[0,180,90]])		
		{
			cylinder(d=4.9,h=0.4,$fn=20);
		}
}

carriage_ang=[[-90,-90]];
module carriage_filament_fix()
{
	difference()
	{
		pc4_add(fix_cyl_angles=carriage_ang);
		pc4_sub(fix_cyl_angles=carriage_ang);
	}
}

module carriage(is_top=true)
{
	offs=1+0.4;
	offs_jitter=[3,0.4,1];
	bearing_screw=10;
	screw=16;
	nut_offs=2;
	screw_in=9;
	screw_offs=[2.6,4];
	pc4_out=pc4_01_H()-0.01;
	belt_fix_offset=9;
	carriage_bottom_cut=4;
	belt_fix_screw=8;
	union()
	{
		difference()
		{
			union()
			{
				difference()
				{
					union()
					{
						fdtube=filament_diameter+4;
						fftube_out=2.2;
						translate_rotate([[0,-carriage_dim.y/2,0],[-90,0,0]])
						hull()
						{
							cylinder (d=fdtube,h=carriage_dim.y+fftube_out,$fn=40);
							translate ([0,fftube_out,0])
								cylinder (d=fdtube,h=carriage_dim.y,$fn=40);
						}
						
						hh=pc4_01_H()+9;
						dd=pc4_01_D()+7.5;
											
						union()
						fillet (r=1.6,steps=16)
						{
							//carriage_flag_width=(carriage_dim.x+carriage_tr[0].x)*2-4;
							carriage_flag_width=(carriage_dim.x+carriage_tr[0].x)*2;
							carriage_flag_thickness=1.2;
							carriage_flag_height=4;
							translate ([0,0,-carriage_flag_height])
							translate(vector_replace(carriage_tr[0],0,-carriage_flag_width/2)) 
							translate ([0,(carriage_dim.y-carriage_flag_thickness)/2,0])
								cube ([carriage_flag_width,carriage_flag_thickness,carriage_dim.z]);
							
							translate_rotate(carriage_tr) 
							difference()
							{
								translate ([0,0,carriage_dim.z])
								rotate ([0,90,0])
								linear_extrude(carriage_dim.x)
									polygon(polyRound([
										 [0,0,9]
										,[carriage_dim.z,0,1]
										,[carriage_dim.z,carriage_dim.y,1]
										,[0,carriage_dim.y,1]
									],1));
								
								length=20;
								dim=[carriage_dim.x+2,length,carriage_bottom_cut];
								translate ([-1,(carriage_dim.y-dim.y)/2,-2])
								{
									translate ([0,0,dim.z])
									rotate ([0,90,0])
									linear_extrude(dim.x)
										polygon(polyRound([
											 [0,0,8]
											,[dim.z,0,0]
											,[dim.z,dim.y,0]
											,[0,dim.y,8]
										],1));
								}
							}
						}
						translate_rotate([[0,-carriage_dim.y/2-pc4_out,0],[-90,0,0]])
						{
							hull()
							{
								cylinder (d=dd,h=hh,$fn=60);
								cut=6;
								translate ([0,8.6+cut/2,0])
									cylinder (d=dd-cut,h=hh,$fn=60);
							}
						}
					}
					
					translate_rotate([[0,-carriage_dim.y/2-1-pc4_out+1,0],[90,0,0]])
					{
						pc4_cut(offs=0.2,fix_cyl_angles=carriage_ang);
						pc4_fix(fix_cyl_angles=carriage_ang);
					}
					
					fd=filament_carriage_diameter+0.2;
					translate_rotate([[0,-carriage_dim.y/2-20,0],[-90,0,0]])
						cylinder (d=fd,h=carriage_dim.y+100,$fn=20);
					
					if (is_top)
					translate_rotate (carriage_bearing_tr)
					hull()
					{
						bearing_body(index=carriage_bearing_index,offs=1);
						translate ([40,0,0])
							bearing_body(index=carriage_bearing_index,offs=1);		
					}
				}
				translate_rotate (carriage_bearing_tr)
					bearing_stand(index=carriage_bearing_index,offs=1);
			}
			
			mk8_body_bottom(offs=offs,part=1);
			hull()
			for (j=[-offs_jitter[2],offs_jitter[2]])
				translate ([0,j,0])
					mk8_body_bottom(offs=offs,part=2);
			hull()
			for (j=[-offs_jitter[1],offs_jitter[1]])
				translate ([0,j,0])
				translate_rotate(mk8_transmission_small_tr)
					mk8_small_gear(op=3);
			hull()
			for (j=[-offs_jitter[0],offs_jitter[0]])
				translate ([0,j,0])
				translate_rotate(mk8_gear_tr) 
					mk8_cut(offs=1);
			
			translate_rotate (carriage_bearing_tr)
			translate ([0,0,-2])
			{
				rotate ([0,180,0])
				{
					m3_square_nut_planar();
					translate ([0,0,1])
					rotate ([0,180,0])
					{
						cylinder (d=m3_screw_diameter(),h=bearing_screw+0.1,$fn=20);
						translate ([0,0,bearing_screw])
						hull()
						{
							cylinder (d=m3_cap_diameter(),h=20,$fn=20);
							translate ([-10,0,0])
								cylinder (d=m3_cap_diameter(),h=20,$fn=20);
						}
					}
				}
			}
			
			for (y=[-1,1])
				translate([-1,luu8[0]/2*y,0])
				translate_rotate(luu8_tr)
				{
					hh=carriage_dim.x+2;
					difference()
					{
						cylinder (d=luu8[1]+0.25*2,h=hh,$fn=80);
						
						difference()
						{
							dim=[0.6,0.3];
							translate ([0,0,(24/2-lm8uu_groove())])
							translate ([0,0,hh/2-dim[0]/2])
								cylinder (d=luu8[1]+10,h=dim[0],$fn=80);
							cylinder (d=luu8[1]-dim[1]*2,h=hh,$fn=80);
						}
					}
				}
			
			translate ([-0.01,0,0])
			translate_rotate(luu8_tr)
			rotate ([0,0,180])
				belt (length=carriage_dim.y+1);
	
			translate_rotate(carriage_tr) 
			{
				for (x=[-1,1])
				for (y=[-1,1])
					translate ([x*(carriage_dim.x/2-screw_offs.x),y*(carriage_dim.y/2-screw_offs.y),0])
					translate ([carriage_dim.x/2,carriage_dim.y/2,carriage_dim.z-screw_in])
					rotate ([0,180,90])
					{
						translate ([0,0,-0.1])
							cylinder (d=m3_screw_diameter(),h=screw+100+0.1,$fn=20);
						translate ([0,0,-20])
						hull()
						{
							cylinder (d=m3_cap_diameter(),h=20,$fn=30);
							translate ([0,-10*x,0])
								cylinder (d=m3_cap_diameter(),h=20,$fn=30);
							if ((x!=1) || (y!=-1))
								translate ([-10*y,0,0])
									cylinder (d=m3_cap_diameter(),h=20,$fn=30);
						}
						translate ([0,0,screw-nut_offs])
						rotate ([0,0,90+90*x])
						    m3_square_nut(short_fix=true);
					}
			}
		}
	}
}

module carriage_part(offs=0)
{
	xadd=100;
	translate ([0,-xadd,0])
	translate([carriage_tr[0].x-1,carriage_tr[0].y+xadd/2,luu8_tr[0].z-offs])
	rotate(carriage_tr[1])
		cube (vector_sum(carriage_dim,[2,xadd,0]));
}

module carriage_top()
{
	intersection()
 	{
		carriage();
		carriage_part();
 	}
}

module carriage_bottom()
{
	difference()
 	{
		carriage(is_top=false);
		carriage_part(offs=0.2);
 	}
}

module mk8_stand_bottom(stand_latch_fix_nuts=false)
{
	intersection()
	{
		mk8_stand(stand_latch_fix_nuts=stand_latch_fix_nuts);
		translate_rotate (mk8_stand_tr)
		translate ([-10,-10,-10])
			cube ([200,200,mk8_stand_slot[3][0].x+mk8_stand_dim.z+10]);
	}
}

module mk8_stand_channel_cut(offs=0)
{
	ww=15.6;
	left=[14,19];
	translate ([-ww/2,mk8_stand_tr[0].y-0.01,-9.01])
	{
		dim=[ww,mk8_stand_slot[3][0].y+0.02,20];
		//cube (dim);
		linear_extrude(dim.z)
		polygon ([
			  [-offs-left[0],0]
			, [-offs-left[0],left[1]+offs]
			, [-offs,left[1]+offs]
			, [-offs,dim.y]
			, [dim.x+offs,dim.y]
			, [dim.x+offs,0]
			]);
	}
}

module mk8_stand_channel()
{
	difference()
	{
		union()
		{
			intersection()
			{
				mk8_stand_bottom(stand_latch_fix_nuts=true);
				mk8_stand_channel_cut();
			}
			ss443a_fd(op="add");
		}
		ss443a_fd(op="cut");
		ss443a_fd(op="ss443_box_fix");
	}
}
module mk8_stand_bottom_channel()
{
	difference()
	{
		mk8_stand_bottom();
		mk8_stand_channel_cut(offs=0.2);
	}
}

module mk8_stand_top()
{
	difference()
	{
		mk8_stand();
		translate_rotate (mk8_stand_tr)
		translate ([-10,-10,-10])
			cube ([200,200,mk8_stand_slot[3][0].x+mk8_stand_slot[3][1].x+mk8_stand_dim.z+10]);
	}
}

module mk8_stand_middle()
{
	difference()
	{
		mk8_stand();
		translate_rotate (mk8_stand_tr)
		
		translate ([-10,-10,-10])
			cube ([200,200,mk8_stand_slot[3][0].x+mk8_stand_dim.z+10+0.1]);
		
		translate_rotate (mk8_stand_tr)
		translate ([-10,-30,mk8_stand_slot[3][0].x+mk8_stand_slot[3][1].x+mk8_stand_dim.z-0.1])
			cube ([200,200,100]);
	}
}

module mk8_stand_middle_left()
{
	intersection()
	{
		mk8_stand_middle();
		translate_rotate (mk8_stand_tr)
		translate ([mk8_stand_dim.x/2,-10,0])
			cube ([mk8_stand_dim.x,200,200]);
	}
}

module mk8_stand_middle_right()
{
	difference()
	{
		mk8_stand_middle();
		translate_rotate (mk8_stand_tr)
		translate ([mk8_stand_dim.x/2,-10,0])
			cube ([mk8_stand_dim.x,200,200]);
	}
}

module mk8_stand(cutter_switch=true,stand_latch_fix_nuts=true,add_height=0)
{
	wire_cut=8;
	wire_cut_offs=[9,9];
	wire_cut_jitter=8;
	dd=12;
	xx=rods[0]+mk8_stand_slot[2]*2;
	parts_screw=12;
	parts_screw_offs=[0,8,-4,-4];
	th1=mk8_stand_slot[3][1].y;
	union()
	{
		difference()
		{
			union()
			{
				translate_rotate (mk8_stand_tr)
				linear_extrude(mk8_stand_dim.z)
					polygon(polyRound([
						  [0,0,4]
						, [0,mk8_stand_dim.y,4]
						, [mk8_stand_dim.x,mk8_stand_dim.y,4]
						, [mk8_stand_dim.x,0,4]
					],1));
				
				difference()
				{		
					union()
					{						
						th2=mk8_stand_slot[3][2].y;
						union()
						{
							translate ([-rods[0]/2-mk8_stand_slot[2],0,0])
							translate (vector_replace(rods_tr[0],1,mk8_stand_tr[0].y))
							translate ([-dd/2,0,0])
								cube ([xx+dd,mk8_stand_slot[3][0].y,mk8_stand_slot[3][0].x+add_height]);
							
							th1=mk8_stand_slot[3][1].y;
							
							difference()
							{
								translate ([-rods[0]/2-mk8_stand_slot[2],0,0])
								translate (vector_replace(rods_tr[0],1,mk8_stand_tr[0].y))
								translate ([xx-th1,0,0])
								{
									dim=[th1
										,mk8_stand_slot[3][0].y
										,mk8_stand_slot[3][0].x+mk8_stand_slot[3][1].x+0.1];
									difference()
									{
										cube (dim);
										for (z=[mk8_stand_slot[3][0].x+wire_cut/2+wire_cut_offs[0]
											//,mk8_stand_slot[3][0].x+mk8_stand_slot[3][1].x/2
											,mk8_stand_slot[3][0].x+mk8_stand_slot[3][1].x-wire_cut/2-wire_cut_offs[1]
											])
											hull()
												for (j=[-wire_cut_jitter,+wire_cut_jitter])
													translate ([-1,dim.y/2+j,z])
													rotate ([0,90,0])
														cylinder (d=wire_cut,h=dim.x+2,$fn=60);
									}
								}
								
								translate_rotate (cutter_tr)
								centered_rotate([[-gear_big_d/2,0,0],[0,0,90]])
								translate ([small_gear_r,-gear_small_h/2-2,0])
								rotate ([-90,0,0])
								{
									hh=73.515;
									cylinder (d=bearing685[2]+1,h=hh+0.1,$fn=70);
									cylinder (d=bearing685[0]+0.3,h=hh-dim.x+bearing685[1]+0.4,$fn=70);
								}
							}

							dim=[th1
								,mk8_stand_slot[3][0].y								
								,mk8_stand_slot[3][0].x+mk8_stand_slot[3][1].x+0.1];
							difference()
							{
								union()
								fillet(r=4,steps=8)
								{
									translate ([-rods[0]/2-mk8_stand_slot[2],0,0])
									translate (vector_replace(rods_tr[0],1,mk8_stand_tr[0].y))
										cube (dim);
									
									translate_rotate (cutter_nema_tr)
									translate ([-nema17_dim()/2,-nema17_dim()/2,0])
									{
										linear_extrude(mk8_stand_slot[3][1].y)
											polygon(polyRound([
												 [0,0,6]
												,[nema17_dim(),0,6]
												,[nema17_dim(),nema17_dim(),6]
												,[0,nema17_dim(),6]
											],20));
									}
								}
								translate ([-rods[0]/2-mk8_stand_slot[2],0,0])
								translate (vector_replace(rods_tr[0],1,mk8_stand_tr[0].y))
								for (z=[mk8_stand_slot[3][0].x+wire_cut/2+wire_cut_offs[0]])
									hull()
										for (j=[-wire_cut_jitter,+wire_cut_jitter])
											translate ([-1,dim.y/2+j,z])
											rotate ([0,90,0])
												cylinder (d=wire_cut,h=dim.x+2,$fn=60);
							}
						}
	
						difference()
						{					
							union()
							fillet(r=4,steps=8)
							{
								translate ([-rods[0]/2-mk8_stand_slot[2],0,0])
								translate (vector_replace(rods_tr[0],1,mk8_stand_tr[0].y))
								translate ([0,40-th2,mk8_stand_slot[3][0].x+mk8_stand_slot[3][1].x])
								{
									dim=[xx,th2,mk8_stand_slot[3][2].x];
									translate ([0,dim.y,0])
									rotate ([90,0,0])
									linear_extrude(dim.y)
										polygon(polyRound([
											 [0,0,0]
											,[dim.x,0,0]
											,[dim.x,dim.z,6]
											,[0,dim.z,6]
										],20));
								}
								
								translate ([-nema17_dim()/2,-nema17_dim()/2,-mk8_stand_slot[3][2].x-t8_nema_add_z])
								translate (t8_nema_tr[0])
								{
									linear_extrude(mk8_stand_slot[3][2].x+t8_nema_add_z)
										polygon(polyRound([
											 [0,0,6]
											,[nema17_dim(),0,6]
											,[nema17_dim(),nema17_dim(),6]
											,[0,nema17_dim(),6]
										],20));
								}
							}
							translate_rotate(t8_nema_tr)
								nema17_cut(main_cyl=true,washers=true);
						}
					}
					
					out=150;
					translate ([-rods[0]/2-mk8_stand_slot[2],0,0])
					translate (vector_replace(rods_tr[0],1,mk8_stand_tr[0].y))
					for(x=[-dd/2,xx+dd/2])
						translate ([x,40-out+1,dd/2])
						rotate ([-90,0,0])
						hull()
						{
							cylinder (d=dd,h=out,$fn=60);
							translate ([0,-200,-1])
								cylinder (d=dd,h=out,$fn=60);
						}
					
						
				}
				
				translate ([-rods[0]/2-mk8_stand_slot[2],0,0])
				translate (vector_replace(rods_tr[0],1,mk8_stand_tr[0].y))
				translate ([xx-th1,0,0])
				{
					dim=[th1
						,mk8_stand_slot[3][0].y
						,mk8_stand_slot[3][0].x+mk8_stand_slot[3][1].x+0.1];
				
					for (y=[-1,1])
					translate ([th1/2,dim.y/2-(dim.y/2-parts_screw_offs.y)*y,mk8_stand_slot[3][0].x])
					translate ([parts_screw_offs.x,0,parts_screw_offs.z])
					{
						out=14;
						translate ([0,0,-out+m3_washer_thickness()])
						{
							dd=m3_washer_diameter()+2;
							cylinder (d=dd,h=out,$fn=30);
							translate ([0,0,out])
								sphere (d=dd,$fn=30);
						}
					}
				}
				
				
				dim=[th1
					,mk8_stand_slot[3][0].y								
					,mk8_stand_slot[3][0].x+mk8_stand_slot[3][1].x+0.1];
				translate ([-rods[0]/2-mk8_stand_slot[2],0,0])
				translate (vector_replace(rods_tr[0],1,mk8_stand_tr[0].y))
				{
					for (y=[-1,1])
					translate ([th1/2,dim.y/2-(dim.y/2-parts_screw_offs.y)*y,mk8_stand_slot[3][0].x])
					translate ([-parts_screw_offs.x,0,parts_screw_offs.z])
					{
						out=14;
						dd=m3_washer_diameter()+2;
						translate ([0,0,-out])
						{
							cylinder (d=dd,h=out,$fn=30);
							translate ([0,0,out])
								sphere (d=dd,$fn=30);
						}
					}
				}
			}
				
			translate ([-rods[0]/2-mk8_stand_slot[2],0,0])
			translate (vector_replace(rods_tr[0],1,mk8_stand_tr[0].y))
			translate ([xx-th1,0,0])
			{
				dim=[th1
					,mk8_stand_slot[3][0].y
					,mk8_stand_slot[3][0].x+mk8_stand_slot[3][1].x+0.1];
			
				for (y=[-1,1])
				translate ([th1/2,dim.y/2-(dim.y/2-parts_screw_offs.y)*y,mk8_stand_slot[3][0].x])
				translate ([parts_screw_offs.x,0,parts_screw_offs.z])
				{
					m3_screw(h=parts_screw+1);
					m3_washer(out=60);
					translate ([0,0,-parts_screw_offs.z*2])
					rotate ([0,0,90])
						m3_square_nut();
				}
				for (y=[-1,1])
				translate ([th1/2,dim.y/2-(dim.y/2-parts_screw_offs.y)*y
					,mk8_stand_slot[3][0].x+mk8_stand_slot[3][1].x+mk8_stand_slot[3][2].x])
				translate ([parts_screw_offs.x,0,parts_screw_offs[3]])
				rotate ([180,0,0])
				{
					m3_screw(h=parts_screw+1,cap_out=20);
					hull()
					{
						m3_washer(out=60);
						translate([10,0,0])
							m3_washer(out=60);
					}
					translate ([0,0,-parts_screw_offs.z*2])
					rotate ([0,0,90])
						m3_square_nut();
				}
			}

			dim=[th1
				,mk8_stand_slot[3][0].y								
				,mk8_stand_slot[3][0].x+mk8_stand_slot[3][1].x+0.1];
			translate ([-rods[0]/2-mk8_stand_slot[2],0,0])
			translate (vector_replace(rods_tr[0],1,mk8_stand_tr[0].y))
			{
				for (y=[-1,1])
				translate ([th1/2,dim.y/2-(dim.y/2-parts_screw_offs.y)*y,mk8_stand_slot[3][0].x])
				translate ([-parts_screw_offs.x,0,parts_screw_offs.z])
				{
					m3_screw(h=parts_screw+1);
					m3_washer(out=60);
					translate ([0,0,-parts_screw_offs.z*2])
					rotate ([0,0,-90])
						m3_square_nut();
				}
				for (y=[-1,1])
				translate ([th1/2,dim.y/2-(dim.y/2-parts_screw_offs.y)*y
					,mk8_stand_slot[3][0].x+mk8_stand_slot[3][1].x+mk8_stand_slot[3][2].x])
				translate ([-parts_screw_offs.x,0,parts_screw_offs.z])
				rotate ([180,0,0])
				{
					m3_screw(h=parts_screw+1,cap_out=20);
					hull()
					{
						m3_washer(out=60);
						translate([-10,0,0])
							m3_washer(out=60);
					}
					translate ([0,0,-parts_screw_offs.z*2])
					rotate ([0,0,-90])
						m3_square_nut();
				}
			}
					
			translate_rotate (cutter_nema_tr)
				nema17_cut(screw_length=10,main_cyl=true,washers=true);
			
			translate([0,0,-t8_nema_add_z])
			for (x=[-1,1])
			{
				translate ([x*rods[0]/2,0,rods_up])
				translate_rotate (rods_tr)
					cylinder (d=rods[1]+0.4,h=200,$fn=40);
				
				translate ([0,0,-mk8_stand_slot[3][2].x/2])
				translate ([x*rods[0]/2,0,0])
				translate(vector_replace(rods_tr[0],2,t8_nema_tr[0].z))
				{					
					rotate ([90,0,0])
					translate ([0,0,rods[1]/2])
					{
						cylinder (d=m3_screw_diameter(),h=rod_screws[0]+0.1,$fn=40);
						translate ([0,0,rod_screws[0]])
							cylinder (d=m3_washer_diameter(),h=40,$fn=40);
						translate ([0,0,2])
							m3_square_nut();
					}
				}
			}
			
			translate ([0,0,mk8_stand_slot[3][0].x-4])
			translate_rotate (rods_tr)
				cylinder (d=9,h=200,$fn=40);
			
			tr=[[0,mk8_stand_tr[0].y-0.1,0],[-90,0,0]];
			if (true)
			{
				filament_catcher(tr=tr
					,filament_diameter=filament_melt_diameter
					,filament_max_diameter=filament_diameter+4
					,height=100
					,max_height=6
				);
			}
			else
			{
				translate_rotate(tr)
				fillet (r=2,steps=4)
				{
					cylinder (d=filament_melt_diameter,h=10,$fn=40);
					cylinder (d1=filament_diameter+4,d2=filament_diameter,h=6,$fn=40);
				}
			}	

			for (x=[mk8_stand_slot[1],mk8_stand_dim.x-mk8_stand_slot[1]])
			for (y=[0,1])
			{
				translate ([x,10+20*y,4])
				translate_rotate (mk8_stand_tr)
				rotate ([0,180,10])
					m5n_screw_washer(thickness=4,diff=2,washer_out=20);
			}
			
			for (a=[cutter_work_angles[0]+cutter_work_angles_add:4:cutter_work_angles[1]])
				translate_rotate (cutter_tr)
					cutter_big_gear_body(angle=a,offs=0.3);
			
			astep=2;
			translate_rotate (cutter_tr)
			translate ([-gear_big_d/2,0,-gear_big_h/2])
			for (a=[cutter_work_angles[0]:astep:cutter_work_angles[1]])
			{
				hull()
				{
					for (aa=[a,a+astep])
						rotate ([0,0,aa])
						translate_rotate (blade_tr)
							blade(offs=1,addz=0.3);//8888888888888 prev 0.1
				}
			}
			
			big_gear_screw=30;
			translate_rotate (cutter_tr)
			translate ([-gear_big_d/2,0,-(big_gear_screw-gear_big_h+2.4)])
			translate ([0,0,0])
			{
				rotate ([0,180,0])
					cylinder (d=m3_washer_diameter(),h=60,$fn=40);
				translate ([0,0,-1])
					cylinder (d=m3_screw_diameter(),h=big_gear_screw-3,$fn=40);
				translate ([0,0,big_gear_screw-3-0.01])
					cylinder (d=3,h=10,$fn=40);
				translate ([0,0,big_gear_screw-16]) 
				rotate ([0,0,180])
					m3_square_nut(out=16);
			}
			
			if (cutter_switch)
				cutter_switch_box(op=1);
			
			mk8_endstop(op=2);		
		}
		for (x=[mk8_stand_slot[1],mk8_stand_dim.x-mk8_stand_slot[1]])
		for (y=[0,1])
		{
			translate ([x,10+20*y,4])
			translate_rotate (mk8_stand_tr)
			rotate ([0,180,10])
				m5n_screw_washer_add();
		}
		
		translate_rotate(t8_nema_tr)
			nema17_cut(add=true,washers=true);
		translate_rotate (cutter_nema_tr)
			nema17_cut(screw_length=10,main_cyl=true,washers=true,add=true);
	}
}

module proto_cutter_motor()
{
	translate_rotate (cutter_nema_tr)
		proto_nema17();
}

module proto_cutter(angle=cutter_angle)
{
	cutter_switch_box(op=4);
	
	color ("#0000FF")
	translate_rotate (cutter_tr)
	translate ([-gear_big_d/2,0,-gear_big_h/2])
	rotate ([0,0,angle])
	translate_rotate (blade_tr)
		blade(addz=0.01);
}

module blade(offs=0,offsh=0,addz=0)
{
	bh=blade_count*10;
	bd=10+2.5;
	bx=17.31+4;
	
	translate ([0,0,-addz])
	linear_extrude(blade_thickness+addz*2)
		offset (delta=offs)
			polygon ([
				  [0,0]
				, [bx,-bd]
				, [bx,-bd-bh]
				, [0,-bh]
			]
	);
}

module blade_holder()
{
	bh=blade_count*10;
	bd=10+2.5;
	bx=17.31+4;
	
	difference()
	{
		linear_extrude(gear_big_h)
		offset(delta=6.4+7)
			polygon ([
				  [0,0]
				, [bx,-bd]
				, [bx,-bd-bh]
				, [0,-bh]
			]
		);
		
		translate([-60,-18,-0.1])
		rotate([0,0,-30])
		{
			cube ([60,60,gear_big_h+0.2]);
			translate ([40,-20,0])
				cube ([60,60,gear_big_h+0.2]);
		}
	}
}

module cutter_small_gear()
{
	screw_in=7;
	screw=6;
	color ("lime")	
	difference()
	{
		translate_rotate (cutter_tr)
		centered_rotate([[-gear_big_d/2,0,0],[0,0,90]])
		{
			hh=[22,64,65.2,73.7];
			difference()
			{
				union()
				{
					difference()
					{
						schneckenradsatz_small(
							  modul=gear_big_modul
							, zahnzahl=gear_big_d
							, gangzahl=gear_small_d
							, breite=gear_big_h
							, laenge=gear_small_h
							, bohrung_schnecke=0
							, bohrung_rad=0
							, eingriffswinkel=eingriffswinkel
							, steigungswinkel=gear_big_steigungswinkel
							, optimiert=false
							, zusammen_gebaut=true
						);
						translate ([0,-0.01,0])
						translate ([small_gear_r,-gear_small_h/2-2,0])
						rotate ([90,0,0])
							cylinder (d=30,h=hh[0],$fn=70);
					}
					translate ([small_gear_r,-gear_small_h/2-2,0])
					rotate ([90,0,0])
						cylinder (d=17,h=hh[0],$fn=70);
					
					translate ([small_gear_r,-gear_small_h/2-2,0])
					rotate ([-90,0,0])
						cylinder (d=14,h=hh[1],$fn=70);
					
					translate ([small_gear_r,-gear_small_h/2-2,0])
					rotate ([-90,0,0])
						cylinder (d=bearing685[2]+1,h=hh[2],$fn=70);
					
					translate ([small_gear_r,-gear_small_h/2-2,0])
					rotate ([-90,0,0])
						cylinder (d=bearing685[2]-0.4,h=hh[3],$fn=70);
				}
				translate ([small_gear_r,-gear_small_h/2-2,0])
				rotate ([-90,0,0])
				translate([0,0,0])
					cylinder (d=6,h=gear_small_h+10,$fn=40);
				
				translate ([small_gear_r,-gear_small_h/2-2,0])
				translate ([0,-8-screw_in,2])
				rotate ([0,0,-90])
				{
					cylinder (d=3.2,h=screw+0.1,$fn=40);
					translate ([0,0,1.5])
					rotate ([0,0,-90])
						m3_square_nut();
					translate ([0,0,screw-0.4])
						cylinder (d=m3_cap_diameter(),h=20,$fn=40);
				}
				
			}
		}
		translate_rotate (cutter_nema_tr)
		{
			translate ([0,0,-screw_in])
				nema17_cut(main_cyl=false,bighole=true,shaft_offset=0.1, shaft_length=60);		
		}
	}
}

module cutter_big_gear_body(angle=cutter_angle,offs=0)
{
	offs_angle=offs==0?0:2;
	translate ([-gear_big_d/2,0,-gear_big_h/2])
	rotate ([0,0,angle])
	{
		rotate([0,0,cutter_angles[0]-offs_angle])
		rotate_extrude(angle=cutter_angles[1]-cutter_angles[0]+offs_angle*2,$fn=80)
		polygon([
			 [0,-offs]
			,[gear_big_d/2-2,-offs]
			,[gear_big_d/2-2,gear_big_h+offs]
			,[0,gear_big_h+offs]
		]);
	}
	hull()
	{
		translate ([-gear_big_d/2,0,-gear_big_h/2])
		rotate ([0,0,angle])
		{
			rotate([0,0,cutter_angles[0]-offs_angle])
			rotate_extrude(angle=1,$fn=80)
			polygon([
				 [0,-offs]
				,[gear_big_d/2-2,-offs]
				,[gear_big_d/2-2,gear_big_h+offs]
				,[0,gear_big_h+offs]
			]);
		}

		translate ([-gear_big_d/2,0,-gear_big_h/2-offs])
			cylinder (d=18+offs*2,h=gear_big_h+offs*2,$fn=60);
	}
}

module cutter_big_gear(angle=cutter_angle)
{
	cutter_screws=[
		  [[22.6,-14,0],[0,0,-20]]
		 ,[[22.6,-21,0],[0,0,-20]]
		 ,[[13+0.1,-19.3+0.1,0],[0,0,-20]]
		 ,[[20-2.3,-10+1.2,0],[0,0,60]]
	];
	screw_length=6;

	translate_rotate (cutter_tr)
	{			
		color ("lime")
		union()
		{
			difference()
			{
				union()
				{
					intersection()
					{
						schneckenradsatz_big(
							modul=gear_big_modul
							, zahnzahl=gear_big_d
							, gangzahl=gear_small_d
							, breite=gear_big_h
							, laenge=gear_small_h
							, bohrung_schnecke=0
							, bohrung_rad=0
							, eingriffswinkel=eingriffswinkel
							, steigungswinkel=gear_big_steigungswinkel
							, optimiert=false
							, zusammen_gebaut=true
						);
						
						translate ([-gear_big_d/2,0,-gear_big_h/2])
						rotate ([0,0,angle])
						{
							rotate([0,0,cutter_angles[0]])
							rotate_extrude(angle=cutter_angles[1]-cutter_angles[0],$fn=80)
							polygon([
								 [0,-0.1]
								,[gear_big_d/2+4,-0.1]
								,[gear_big_d/2+4,gear_big_h+0.1]
								,[0,gear_big_h+0.1]
							]);
								
						}
					}
					
					cutter_big_gear_body(angle=angle);
					
					translate ([-gear_big_d/2,0,-gear_big_h/2])
					rotate ([0,0,angle])
					translate_rotate (blade_tr)
						blade_holder();
				}
				
				translate ([-gear_big_d/2,0,-gear_big_h/2])
				rotate ([0,0,angle])
				translate_rotate (blade_tr)
					blade(offs=0.3,addz=0.01);
				
				translate ([-gear_big_d/2,0,-gear_big_h/2])
				rotate ([0,0,angle])
				translate_rotate (blade_tr)
					for (s=cutter_screws)
						translate_rotate (s)
						{
							translate ([0,0,-0.01])
								cylinder (d=m3_cap_diameter(),h=0.3,$fn=40);
							translate ([0,0,-1])
								cylinder (d=m3_screw_diameter(),h=screw_length+1,$fn=40);
							translate ([0,0,screw_length-2]) 
								m3_square_nut_planar(out=10);
						}
				
				hh=5.1;
				translate ([-gear_big_d/2,0,-gear_big_h/2])
				rotate ([0,180,0])
				translate ([0,0,-hh])
				{
					cylinder (d=bearings[cutter_bearing_index].x+0.3,h=60,$fn=60);
					translate ([0,0,-10])
						cylinder (d=bearings[cutter_bearing_index].x-2,h=60,$fn=60);
				}
			}
			if (cutter_big_gear_add)
			translate ([-gear_big_d/2,0,-gear_big_h/2])
			rotate ([0,0,angle])
			translate_rotate (blade_tr)
				for (s=cutter_screws)
					translate_rotate (s)
					{
						translate ([0,0,screw_length-2-0.4]) 
							cylinder(d=7,h=0.4);
					}
		}
	}
}

module mechanical_half_switch(op)
{
	switchPaddingXY = [0,2.5+2.5,2.5-1];
	filamentDiameter = 2.3;
	switchWidth = 7.5;
	switchLength = 13;
	switchHeight = 5.8;
	walls = 2.6;
	bottomHeight = 4;
	screwDiameter = 3.5;
	switchOffsetX = 3;
	switchOffsetY = 0.8;
	switchDiameter = 2.1;
	switchDiameterTube = 1.6-0.4;
	
	switch_cut_sub_corr=0.5;
	switch_cut_sub=switch_cut_sub_corr;
	switchfix=0.4+0.8;
	switchfix_cut=0.4;
	
	switchRadius = switchDiameter / 2;
	width = walls * 2 + filamentDiameter + switchWidth + switchPaddingXY.z;
	height = switchHeight / 2 + bottomHeight;
	
	difference()
	{
		translate ([0,0,-4])
		{
			if (op==1)
			{
				union() 
				{
					translate([walls * 2 + screwDiameter + switchPaddingXY.x, -switchWidth, bottomHeight])
						cube([switchLength, switchWidth + 1, height-4+0.01]);

					translate([walls * 2 + screwDiameter + switchPaddingXY.x, -switchWidth+3, bottomHeight])
						cube([switchLength, switchWidth + 1, height-4+0.01]);
						
					//translate([walls * 2 + screwDiameter, -width + walls + switch_cut_sub, bottomHeight])
					//	cube([switchLength + switchPaddingXY.x + switchPaddingXY.y, width - walls * 2 - switch_cut_sub, height-4+0.01]);
				}
			}
			if (op==2)
			{
				
				union() 
				{
					translate([walls * 2 + screwDiameter + switchPaddingXY.x + switchOffsetX, -switchRadius - switchOffsetY,0])
					{
						translate ([0,0,2])
							cylinder(r=switchDiameterTube/2, h=bottomHeight+switchfix-2,$fn = 30);
						translate ([0,0,bottomHeight+switchfix-0.01])
							cylinder(r1=switchDiameterTube/2,r2=switchDiameterTube/2-switchfix_cut, h=switchfix_cut,$fn = 30);
					}
			
					translate([walls*2+screwDiameter+switchPaddingXY.x+switchLength-switchOffsetX,-switchRadius-switchOffsetY,0])
					{
						translate ([0,0,2])
							cylinder(r=switchDiameterTube/2, h=bottomHeight+switchfix-2,$fn = 30);
						translate ([0,0,bottomHeight+switchfix-0.01])
							cylinder(r1=switchDiameterTube/2,r2=switchDiameterTube/2-switchfix_cut, h=switchfix_cut,$fn = 30);
					}
				}
				
			}
		}
	}
}

module cutter_switch_box(op=1)
{
	screw=16;
	if (op==3)
	{
		translate_rotate(cutter_endstopblock_tr)
		rotate ([-90,0,0])
			for (x=[-1,1])
			translate ([cutter_endstopblock_dim.x/2+(cutter_endstopblock_dim.x/2-4.5)*x,-4.5,10.5-screw])
			{
				m3_screw (h=screw);
				m3_washer(out=100);
				translate ([0,0,screw-2])
				rotate ([0,0,180])
					m3_square_nut_planar();
			}
	}
	else
	if (op==5)
	{
		translate_rotate(cutter_endstopblock_tr)
		rotate ([-90,0,0])
			for (x=[-1,1])
			translate ([cutter_endstopblock_dim.x/2+(cutter_endstopblock_dim.x/2-4.5)*x,-4.5,10.5-screw])
			{
				translate ([0,0,screw-2])
				rotate ([0,0,180])
				translate ([0,0,-0.4])
					cylinder (d=m3_screw_diameter()+2,h=0.4);
			}
	}
	else
	if (op==4)
	{
		color ("orange")
		translate_rotate(cutter_endstop_tr)
		mirror([1,0,0])
		rotate ([-90,0,0])
		{
			translate ([8.5,0.75,7])
			rotate ([-90,0,90])
				import ("proto/switch2.stl");
		}
	}
	union()
	{
		difference()
		{
			if ((op==1)||(op==2))
			{
				offs=op==1?0.2:0;
				translate ([-offs,-offs,-offs])
				translate_rotate(cutter_endstopblock_tr)
					cube(vector_sum(cutter_endstopblock_dim,[offs*2,offs*2,offs*2]));
			}
			if (op==2)
			{
				translate_rotate(cutter_endstop_tr)
				mirror([1,0,0])
				rotate ([-90,0,0])
					mechanical_half_switch(op=1);
				
				translate_rotate(cutter_endstop_tr)
				translate ([0,2.9*2,0])
				mirror([1,0,0])
				mirror([0,1,0])
				rotate ([-90,0,0])
					mechanical_half_switch(op=1);
				
				cutter_switch_box(op=3);
			}		
		}
		if (op==1)
		{
			cutter_switch_box(op=3);
		}
		if (op==2)
		{
			translate_rotate(cutter_endstop_tr)
			mirror([1,0,0])
			rotate ([-90,0,0])
				mechanical_half_switch(op=2);
			translate_rotate(cutter_endstop_tr)
			translate ([0,2.9*2,0])
			mirror([1,0,0])
			mirror([0,1,0])
			rotate ([-90,0,0])
				mechanical_half_switch(op=2);
		}
	}
}

module cutter_switch_box_half_divider(op=1)
{
	offs=op==2?0.1:0;
	translate ([-40,2.9+offs,-20])
	translate(cutter_endstop_tr[0])
	difference()
	{
		if (op<3)
			cube ([50,30,50]);
		if (op==3)
		{
			w=10;
			translate ([24.5-w/2,-8,0])
			{
				cube ([w,4,50]);
				cube ([w,20,11+3]);
				translate ([0,6,0])
					cube ([w,4,50]);
			}
		}
	}
}

module cutter_switch_box_half1()
{
	difference()
	{
		intersection()
		{
			cutter_switch_box(op=2);
			mk8_stand(cutter_switch=false,stand_latch_fix_nuts=false,add_height=cutter_switch_add_height);
		}
		cutter_switch_box_half_divider(op=1);
		cutter_switch_box_half_divider(op=3);
	}
}
module cutter_switch_box_half2()
{
	union()
	{
		intersection()
		{
			cutter_switch_box(op=2);
			mk8_stand(cutter_switch=false,stand_latch_fix_nuts=false,add_height=cutter_switch_add_height);
			cutter_switch_box_half_divider(op=2);
		}
		cutter_switch_box(op=5);
	}
}

module mk8_endstop(op=1)
{
	screw=16;
	if (op==1)
	{
		union()
		{
			difference()
			{
				translate_rotate (mk8_endstop_body_tr)
				translate ([-mk8_endstop_body_dim.x/2,0,-mk8_endstop_body_dim.z])
				{
					dim=vector_sum((mk8_endstop_body_dim),[0,0,0]);
					//cube (dim);
					translate ([0,0,dim.z])
					rotate ([-90,0,0])
					linear_extrude(dim.y)
						polygon(polyRound([
							 [0,0,3]
							,[0,dim.z,3]
							,[dim.x,dim.z,3]
							,[dim.x,0,3]
						],20));
				}
				mk8_endstop(op=2);
				
				translate_rotate (mk8_endstop)
				for (z=[0,4])
					translate ([0,0,-z])
					rotate ([-90,0,0])
						mechanical_half_switch(op=1);
				
				translate ([0,-2.9*2,0])
				translate_rotate (mk8_endstop)
				for (z=[0,4])
					translate ([0,0,-z])
					mirror([0,1,0])
					rotate ([-90,0,0])
						mechanical_half_switch(op=1);
			}
			translate_rotate (mk8_endstop)
			rotate ([-90,0,0])
				mechanical_half_switch(op=2);
			
			translate ([0,-2.9*2,0])
			translate_rotate (mk8_endstop)
			mirror([0,1,0])
			rotate ([-90,0,0])
				mechanical_half_switch(op=2);
		}
	}
	if (op==2)
	{
		translate_rotate (mk8_endstop_body_tr)
		translate ([-mk8_endstop_body_dim.x/2,0,-mk8_endstop_body_dim.z])
		rotate ([90,0,0])
		for (x=[-1,1])
			translate ([(mk8_endstop_body_dim.x/2-5)*x,0,0])
			translate ([mk8_endstop_body_dim.x/2,mk8_endstop_body_dim.y/2,-mk8_endstop_body_dim.y])
			{
				m3_screw(h=screw+1);
				m3_washer();
				translate ([0,0,screw-3])
				rotate ([0,0,180])
					m3_square_nut();
			}
	}
	if (op==3)
	{
		translate_rotate (mk8_endstop_body_tr)
		translate ([-mk8_endstop_body_dim.x/2,0,-mk8_endstop_body_dim.z])
		rotate ([90,0,0])
		for (x=[-1,1])
			translate ([(mk8_endstop_body_dim.x/2-5)*x,0,0])
			translate ([mk8_endstop_body_dim.x/2,mk8_endstop_body_dim.y/2,-mk8_endstop_body_dim.y])
			translate ([0,0,0.4+0.1])
				cylinder (d=m3_screw_diameter()+3,h=0.4);
	}
}

module mk8_endstop_half1()
{
	intersection()
	{
		mk8_endstop();
		translate_rotate (mk8_endstop_body_tr)
		translate ([-mk8_endstop_body_dim.x/2-1,0,-mk8_endstop_body_dim.z-1])
			cube ([mk8_endstop_body_dim.x+2,mk8_endstop_body_dim.y/2,mk8_endstop_body_dim.z+2]);
	}
}


module mk8_endstop_half2()
{
	union()
	{
		difference()
		{
			mk8_endstop();
			translate_rotate (mk8_endstop_body_tr)
			translate ([-mk8_endstop_body_dim.x/2-1,-0.01,-mk8_endstop_body_dim.z-1])
				cube ([mk8_endstop_body_dim.x+2,mk8_endstop_body_dim.y/2,mk8_endstop_body_dim.z+2]);
		}
		mk8_endstop(op=3);
	}
}

module mk8_spacer_gear()
{
	difference()
	{
		s=5.4;
		cylinder (d=s+2,h=1,$fn=60);
		translate ([0,0,-1])
			cylinder (d=s,h=10,$fn=60);
	}
}

module oscube(dim,x=0,y=0,z=0)
{
	translate ([-dim.x/2-x,-dim.y/2,-dim.z])
		cube([dim.x+x,dim.y+y,dim.z+z]);
}
module optical_switch_cut(op=1,tr=[0,0,0],rot=[0,0,0],sensor_nuts=true)
{
	offs=0.4;
	ww=26.1;
	ll=10.5;
	hh=30;
	screw=10;
	
	translate(tr)
	rotate (rot)
	{
		if (op==1 || op==14)
		{
			shift=op==1 ? 0 : 15;
			//translate ([0,0,-10+shift])
			//	oscube([2.5+offs*2,10.5+offs*2,12.1],z=30-shift);//flag
			translate ([0,0,0])
			{
				oscube([12+offs*2,6+offs*2,12.1]);
				translate ([0,0,-7.5])
					oscube([24.5+offs*2,6+offs*2,4.6]);
				y=9;
				translate ([-19.4,-y/2,-11])
					cube ([5.8,y,2]);
				if (op==1)
				{
					cut=28;
					translate ([0,0,-10.5])
						oscube([ww+offs*2,ll+offs*2,hh-cut],x=6.9);
				}
				else
				{
					cut1=12;
					add1=10;
					translate ([0,0,-10.5+add1])
						oscube([ww+offs*2,ll+offs*2,6+8-cut1+add1],x=6.9);
					m=27;
					translate ([-m/2,0,-10.5])
						oscube([ww+offs*2-m,ll+offs*2,60],x=6.9);
				}
			}
		}
		if ((op==2)||op==22)
		{
			hh=op==2?10:0.4;
			for (x=[-1:2:1])
				translate ([9.55*x,0,-7])
				rotate ([180,0,0])
				{
					if (op==2)
						cylinder (d=m3_screw_diameter(),h=screw,$fn=20);
					translate ([0,0,screw-m3_nut_h()])
					rotate ([0,0,90])
						m3_nut(h=hh);
				}
		}
	}
}

module carriage_optosensor()
{
	carriage_optosensor_thickness=4;
	yadd=16;
	width=24;
	carriage_optosensor_dim=[width,slot_tr[0].y-carriage_optical_switch_tr[0].y+yadd,carriage_optosensor_thickness];
	carriage_optosensor_tr=
	[[
		 carriage_optical_switch_tr[0].x-carriage_optosensor_dim.x/2
		,slot_tr[0].y-carriage_optosensor_dim.y
		,slot_tr[0].z-20-carriage_optosensor_thickness
	],[0,0,0]];
	
	union()
	{
		intersection()
		{
			translate_rotate(carriage_optosensor_tr)
			{
				diff=(carriage_optosensor_dim.x-width)/2;
				points=
				[
					 [diff,0,2]
					,[0,carriage_optosensor_dim.y-1,2]
					,[carriage_optosensor_dim.x,carriage_optosensor_dim.y-1,2]
					,[carriage_optosensor_dim.x-diff,0,2]
				];
				
				translate([0,0,-20])
				linear_extrude(carriage_optosensor_dim.z+40)
					polygon(polyRound(points,1));
			}
		
			difference()
			{
				translate_rotate(carriage_optosensor_tr)
				union()
				{
					downl=[[0,38],[10.5,11]];
					downh=5;			
					difference()
					{
						union()
						{
							fillet (r=8,steps=1)
							{
								cube (carriage_optosensor_dim);
								translate ([0,downl[0][0],-downh])
									cube ([carriage_optosensor_dim.x,downl[0][1],downh]);
							}
							translate ([0,carriage_optosensor_dim.y-10,carriage_optosensor_thickness])
							rotate ([0,90,0])
								lgroove(carriage_optosensor_dim.x);
						}
						translate ([-1,downl[1][0],-downh-1])
							cube ([carriage_optosensor_dim.x+2,downl[1][1],downh+1]);
					}
				}
				translate_rotate (carriage_optical_switch_tr)
					optical_switch_cut(op=14);
				translate_rotate (carriage_optical_switch_tr)
					optical_switch_cut(op=2);
				
				for (x=[-1,1])
					translate ([carriage_optosensor_dim.x/2+(width/2-6)*x,carriage_optosensor_dim.y-10,0])
					translate_rotate(carriage_optosensor_tr)
						m5n_screw_washer(thickness=6, diff=0.1, washer_out=20);
			}
		}
		/*
		translate_rotate (carriage_optical_switch_tr)
			optical_switch_cut(op=22);
		for (x=[-1,1])
			translate ([carriage_optosensor_dim.x/2+(width/2-6)*x,carriage_optosensor_dim.y-10,0])
			translate_rotate(carriage_optosensor_tr)
				m5n_screw_washer_add();
		*/
	}
}

module proto_frontier()
{
	//frontier_filament_sensor(op=2);
	
	color ("#E655FF")
	translate_rotate (slot_tr)
	translate ([0,0,-10])
		import ("proto/40x20x100VSlotExtrusion.stl");
	
	for (y=[-1,1])
		translate([-frontier_dim.x/2,frontier_bearing_diff/2*y,0])
		translate_rotate(frontier_axis_tr)
			proto_lm8luu();
	
	color ("#ff4040")
	translate_rotate (frontier_t8nut_tr)
	rotate ([0,0,45])
		import ("proto/t8nut.stl");
	
	for (y=[-1,1])
		translate_rotate (frontier_nema_tr)
		translate([0,frontier_bearing_diff/2*y,0])
	 		rod8mm(length=carriage_dim.x+10);
}

module proto_frontier_rod()
{
	color ("#EEF000")
	translate_rotate (frontier_switch_tr)
		proto_optical_switch();
	
	color ("#E655FF")
	translate_rotate (slot_tr)
	translate ([0,-32,-10])
		import ("proto/40x20x100VSlotExtrusion.stl");
	
	translate_rotate (frontier_nema_tr)
		proto_nema17();
	
	for (i=[0,1])
	{
		y=i*2-1;
		translate_rotate (frontier_nema_tr)
		translate([0,frontier_bearing_diff/2*y,0])
	 		rodNmm(d=frontier_rods_diameter[i][0],length=carriage_dim.x+10);
	}
}

module frontier_cube()
{
	translate_rotate(frontier_tr)
	intersection()
	{
		//cube(frontier_dim);
		dim2=vector_replace(frontier_dim,2,frontier_dim.z-global_dim.z-frontier_z_diff);
		zsub=6;
		dim1=vector_sum(vector_replace(frontier_dim,1,global_dim.y),[0,0,-dim2.z+zsub]);
		union()
		{
			//translate ([0,0,dim2.z-zsub-0.01])
			//	cube(dim1);
			//cube(dim2);
			translate ([0,0,dim2.z-zsub-0.01])
			intersection()
			{
				//cut=[17,6,37];
				translate ([0,dim1.y+20,0])
				rotate ([90,0,0])
				linear_extrude(dim1.y+20)
					polygon(polyRound([
						 [0,0,0]
						,[0,dim1.z,1]
						,[dim1.x,dim1.z,4]
				
						//,[dim1.x,dim1.z-cut[0],0]
						//,[dim1.x-cut[1],dim1.z-cut[0]-cut[1],0]
						//,[dim1.x-cut[1],dim1.z-cut[2]+cut[1],0]
						//,[dim1.x,dim1.z-cut[2],0]
				
						,[dim1.x,0,0]
					],1));
				cutout=9-9;
				
				union()
				{
					translate ([dim1.x,0,dim1.z])
					rotate ([-90,0,90])
					{
						linear_extrude(global_dim.x)
							polygon(polyRound([
								 [0,0,4]
								,[0,dim1.z,0]
								,[dim1.y+cutout,dim1.z,0]
								,[dim1.y,dim1.z-cutout,0]
								,[dim1.y,0,1]
							],1));	
					}
					
					cutl=4;//12
					translate ([dim1.x-global_dim.x,0,dim1.z])
					rotate ([-90,0,90])
					{
						linear_extrude(dim1.x)
							polygon(polyRound([
								 [0,0,cutl]
								,[0,dim1.z,0]
								,[dim1.y+cutout,dim1.z,0]
								,[dim1.y,dim1.z-cutout,0]
								,[dim1.y,0,1]
							],1));	
					}
					
				}
			}
			
			intersection()
			{
				translate ([0,dim2.y,0])
				rotate ([90,0,0])
				linear_extrude(dim2.y)
					polygon(polyRound([
						 [0,0,1]
						,[0,dim2.z,1]
						,[dim2.x,dim2.z,1]
						,[dim2.x,0,1]
					],1));
				translate ([dim2.x,0,dim2.z])
				rotate ([-90,0,90])
				linear_extrude(dim2.x)
					polygon(polyRound([
						 [0,0,0]
						,[0,dim2.z,5]
						,[dim2.y,dim2.z,5]
						,[dim2.y,0,5]
					],1));	
			}
		}
	}
}

module frontier_t8_screws(detail=true)
{
	t8nut_offset=10;
	for (a=[0:3])
		translate_rotate (frontier_t8nut_tr)
		rotate ([0,0,a*90+45])
		translate_rotate ([[16/2,0,0],[0,180,90]])		
		{
			m3_screw(h=11);
			if (detail)
				translate ([0,0,t8nut_offset])
				{
					m3_nut_inner();
					translate ([0,0,m3_nut_h()-0.01])
						m3_nut(h=50);
				}
		}
}

module frontier_t8_cut(detail=true)
{
	translate_rotate(frontier_axis_tr)
		cylinder (d=frontier_t8_screw_diameter,h=100,$fn=70);
}

module frontier_t8_fix(detail=true)
{
	offs=detail?[0.1,0.2+0.1]:[0,0];
	union()
	{
		intersection()
		{
			difference()
			{
				translate_rotate (frontier_t8nut_tr)
				{
					hh=frontier_t8cut_width-offs[1]*2;
					fn=60;
					dd=frontier_t8nut_dd-offs[1]*2;
			
					translate ([0,0,-frontier_t8cut_offset-offs[1]])
					rotate ([180,0,0])
					hull()
					{
						translate ([-dd/2,-dd/2,0])
						{
							dim=[dd,dd,hh];
							//cube (dim);
							
							cut=5;
							linear_extrude(dim.z)
							polygon(polyRound([
								 [0,0,cut]
								,[0,dim.y,cut]
								,[dim.x,dim.y,0]
								,[dim.x,0,0]
							],1));
						}
						
						translate ([20,0,0])
							cylinder (d=dd,h=hh,$fn=fn);
					}
				}
				if (detail)
				{
					frontier_t8_cut(detail=detail);
					frontier_t8_screws(detail=detail);
				}
			}
			translate ([0,0,-0.1+offs[0]])
			translate_rotate(frontier_tr)
				cube(frontier_dim);
		}
		if (detail)
		{
			translate_rotate(frontiercarriage_flag_tr)
				cube ([frontiercarriage_flag_width,frontiercarriage_flag_thickness,frontiercarriage_flag_height]);
		}
	}
}

module frontier_sensor()
{
	frontier_sensor_thickness=4;
	frontier_sensor_thicknessv=4.8;
	yadd=16;
	width=24;
	bigwidth=width;//54;
	
	adds=5;
	frontier_sensor_dim=
	[width,frontier_switch_tr[0].y-slot_tr[0].y+yadd-20,frontier_sensor_thickness+adds];
	frontier_sensor_tr=
	[[
		 frontier_switch_tr[0].x-frontier_sensor_dim.x/2
		,slot_tr[0].y+20
		,frontier_switch_tr[0].z-12-adds
	],[0,0,0]];
	
	difference()
	{
		slf_tr=tr_sum(tr_replace(frontier_sensor_tr,2,slot_tr[0].z-20-frontier_sensor_thickness),[0,-20,0]);
		union()
		{
			diff=-(bigwidth-width)/2;
			points=
			[
				 [0+diff,1,2]
				,[0+diff,20,0]
				,[bigwidth+diff,20,0]
				,[bigwidth+diff,1,2]
			];
			vertical_h=slot_tr[0].z-frontier_sensor_tr[0].z-20-frontier_sensor_thickness;
			
			union()
			{
				fillet (r=6,steps=16)
				{
					translate_rotate(slf_tr)
					linear_extrude(frontier_sensor_thickness)
						polygon(polyRound(points,1));
					
					translate ([0,20-frontier_sensor_thicknessv,-vertical_h])	
					translate_rotate(slf_tr)
						cube ([width,frontier_sensor_thicknessv,vertical_h]);
				}
				translate_rotate(slf_tr)
				translate ([0,10,frontier_sensor_thickness])
				rotate ([0,90,0])
					lgroove(bigwidth);
			}
		
			translate_rotate(frontier_sensor_tr)
				cube (frontier_sensor_dim);
		}
		translate_rotate (frontier_switch_tr)
			optical_switch_cut(op=14);
		translate_rotate (frontier_switch_tr)
			optical_switch_cut(op=2);
		for (x=[-1,1])
			translate ([frontier_sensor_dim.x/2+(bigwidth/2-6)*x,10,0])
			translate_rotate(slf_tr)
				m5n_screw_washer(thickness=6, diff=0.1, washer_out=40);
	}
}

module filament_catcher(tr,filament_diameter,filament_max_diameter,height,max_height)
{
	translate_rotate(tr)
	rotate_extrude($fn=80)
	polygon(polyRound([
		 [0,0,0]
		,[0,height,0]
		,[filament_diameter/2,height,0]
		,[filament_diameter/2,max_height+(height-max_height)/2,0]
		,[filament_diameter/2,max_height,20]
		,[filament_max_diameter/2,max_height/2,20]
		,[filament_max_diameter/2,0,0]
	],20));
}

module frontier_filament_path(op="sub",filament_diameter)
{
//	angle=10;
//	fix_cyl_angles=[[angle,-90+angle]];
//	fix_cyl_diff=11;
	angle=0;
	fix_cyl_angles=[[-90,-90],[90,-90]];
	fix_cyl_diff=9;
	if (op=="add")
	{
		translate_rotate(frontier_pc4_tr)
			pc4_pad(fix_cyl_angles=fix_cyl_angles,fix_cyl_diff=fix_cyl_diff);
	}
	if (op=="sub")
	{
		filament_catcher(
			 tr=frontier_path_tr
			,filament_diameter=filament_diameter
			,filament_max_diameter=frontier_filament_max_d
			,height=frontier_filament_height
			,max_height=frontier_filament_max_height
		);
		
		translate_rotate(frontier_pc4_tr)
		{
			pc4_cut(offs=0.2,fix_cyl_angles=fix_cyl_angles,fix_cyl_diff=fix_cyl_diff);
			pc4_fix(fix_cyl_angles=fix_cyl_angles,fix_cyl_diff=fix_cyl_diff);
		}
	}
	if (op=="out")
	{
		translate_rotate(frontier_pc4_tr)
		{
			difference()
			{
				up=5;
				pc4_add(fix_cyl_angles=fix_cyl_angles,fix_cyl_diff=fix_cyl_diff,up=up);
				pc4_sub(fix_cyl_angles=fix_cyl_angles,fix_cyl_diff=fix_cyl_diff,up=up);
			}
		}
	}
}

module frontier_filament_fix()
{
	frontier_filament_path(op="out",filament_diameter=0);
}

module frontier(main=true)
{
	lm8screw=16;
	thrash_top_cut = frontier_path_tr[0].z-filament_diameter;	
	
	difference()
	{
		union()
		{

			union()
			{
				difference()
				{
					union()
					fillet (r=1,steps=16)
					{
						frontier_cube();
						frontier_filament_path(op="add",filament_diameter=filament_melt_diameter);
					}
					translate_rotate(frontier_thrash_tr)
						cube (frontier_thrash_dim);
					translate(vector_sum(vector_replace(frontier_thrash_tr[0],2,thrash_top_cut)
						,[0,-frontier_thrash_thickness-0.01,0]))
						cube (frontier_thrash_dim);
					translate(vector_sum(vector_replace(frontier_thrash_tr[0],2,thrash_top_cut)
						,[0,+frontier_thrash_thickness+0.01,-10]))
						cube (frontier_thrash_dim);
				}
				nozzle=1;
				down=2;
				translate(vector_sum(vector_replace(frontier_thrash_tr[0],2,thrash_top_cut)
					,[0,-frontier_thrash_thickness-0.01,0]))
				translate ([-frontier_thrash_thickness,0,-0.1])
				{
					translate ([0,0,-down])
					hull()
					{
						cube ([frontier_thrash_dim.x+frontier_thrash_thickness*2,frontier_thrash_thickness,0.1]);
						translate ([0,-nozzle,nozzle])
							cube ([frontier_thrash_dim.x+frontier_thrash_thickness*2,frontier_thrash_thickness,0.1]);
					}
					translate ([0,-nozzle,-down+nozzle])
						cube ([frontier_thrash_dim.x+frontier_thrash_thickness*2,frontier_thrash_thickness,down]);
					hull()
					translate ([frontier_thrash_dim.x+frontier_thrash_thickness,-nozzle,nozzle])
					{
						cube ([frontier_thrash_thickness,frontier_thrash_thickness,0.1]);
						translate ([0,nozzle,nozzle])
							cube ([frontier_thrash_thickness,frontier_thrash_thickness,0.1]);
					}
				}
			}
			
			translate_rotate(frontier_axis_tr)
				cylinder (d=frontier_t8_screw_diameter+2,h=frontier_dim.x,$fn=60);
			for (y=[-1,1])
				translate([0,frontier_bearing_diff/2*y,0])
				translate_rotate(frontier_axis_tr)
					cylinder (d=luu8[1]+2,h=frontier_dim.x,$fn=80);
			
			
			for (x=[-1,1])
			for (y=[-1,1])
			{
				translate([0,frontier_bearing_diff/2*y,0])
				translate_rotate(frontier_axis_tr)
				{
					translate ([0,0,frontier_dim.x/2+(45/2-lm8luu_groove()-0.5)*x])
					translate_rotate ([[-lm8screw_xoffset,(lm8screw/2-2)*y,0],[90*y,0,0]])
					{
						cylinder (d=m3_cap_diameter(),h=10,$fn=60);
					}
				}
			}
		}
		
		translate_rotate(frontier_thrash_tr)
		translate ([frontier_thrash_dim.x/2,frontier_thrash_dim.y/2,0])
		rotate ([0,180,0])
		translate ([0,0,0.3])
		{
			screw=6;
			m3_washer();
			m3_screw(h=screw);
			translate ([0,0,screw-3])
			{
				m3_nut_inner();
				translate ([0,0,m3_nut_h()-0.01])
					m3_nut(h=10);
			}
		}
		
		if (main)
		{
			/*
			frontier_filament_sensor(op=1);
			frontier_filament_sensor(op=33);
			frontier_filament_sensor(op=5);
			*/
		}
	
		for (y=[-1,1])
		translate([frontier_dim.x-10,frontier_dim.y/2+(frontier_dim.y/2-10)*y,frontier_dim.z])
		translate_rotate(frontier_tr)
		translate([0,0,-4])
		rotate ([180,0,0])
		{
			screw=25;
			m3_screw(h=screw);
			m3_washer();
			translate ([0,0,screw-3])
			rotate ([0,0,-90])
				m3_square_nut();
		}
		
		frontier_filament_path(op="sub",filament_diameter=filament_melt_diameter)
		
		frontier_t8_cut(detail=false);
		frontier_t8_screws(detail=false);
		
		translate_rotate(frontier_axis_tr)
		{
			translate ([0,0,frontier_t8cut_offset+frontier_t8cut_width])
			hull()
			{
				cylinder (d=11,h=100,$fn=70);
				translate ([-20,0,0])
					cylinder (d=frontier_t8_screw_diameter,h=100,$fn=70);
			}
		}
		
		translate_rotate (frontier_t8nut_tr)
		{
			hull()
			{
				hh=130;
				cylinder (d=frontier_t8nut_dd,h=hh,$fn=60);
				translate ([20,0,0])
					cylinder (d=frontier_t8nut_dd,h=hh,$fn=60);
			}
		}
		
		frontier_t8_fix(detail=false);
				
		for (y=[-1,1])
			translate([1,frontier_bearing_diff/2*y,0])
			translate_rotate(frontier_axis_tr)
				cylinder (d=luu8[1],h=frontier_dim.x+2,$fn=80);

		for (y=[-1,1])
		{
			translate([1,frontier_bearing_diff/2*y,0])
			translate_rotate(frontier_axis_tr)
			{
				cylinder (d=15+0.2,h=100,$fn=60);
				th=1;
				rotate ([0,0,180])
				translate([0,-th/2,0])
					cube ([60,th,100]);
			}
		}
		
		
		for (x=[-1,1])
		for (y=[-1,1])
		{
			translate([0,frontier_bearing_diff/2*y,0])
			translate_rotate(frontier_axis_tr)
			{
				translate ([0,0,frontier_dim.x/2+(45/2-lm8luu_groove()-0.5)*x])
				translate_rotate ([[-lm8screw_xoffset,(lm8screw/2-2)*y,0],[90*y,0,0]])
				{
					m3_screw(h=lm8screw,cap_out=20);
					translate ([0,0,lm8screw-3])
					{
						if (x==-1)
						{
							rotate ([0,0,90])
							{
								m3_square_nut();
								translate ([0,0,0.4])
								m3_square_nut();
							}
						}
						else
						{
							rotate ([0,0,90])
								m3_square_nut();
						}
					}
				}
			}
		}
		
	}
}

module frontier_thrash_cut(offs)
{
	yout=20;
	translate ([-frontier_thrash_thickness-offs,-frontier_thrash_thickness-offs-yout,-frontier_thrash_thickness-offs])
	translate_rotate(frontier_thrash_tr)
		cube (vector_sum(frontier_thrash_dim
			,[frontier_thrash_thickness*2+offs*2,frontier_thrash_thickness*2+offs*2+yout,frontier_thrash_thickness+offs*2]));
}

module frontier_top_cut(offs=0)
{
	frontier_top_cut_dist=23.1;
	translate ([-10,-10,frontier_dim.z-frontier_top_cut_dist+offs])
	translate_rotate(frontier_tr)
		cube ([100,100,100]);
}

module frontier_top()
{
	intersection()
	{
		difference()
		{
			frontier();
			frontier_thrash_cut(offs=0.1);
		}
		frontier_top_cut(offs=0.1);
	}
}

module frontier_main()
{
	difference()
	{
		frontier();
		frontier_thrash_cut(offs=0.1);
		frontier_top_cut();
	}
}

module frontier_thrash()
{
	intersection()
	{
		frontier(main=false);
		frontier_thrash_cut(offs=0);
	}
}

module frontier_rods_cube(dim,is_motor)
{
	//cube(dim);
	up=is_motor?0:12;
	
	intersection()
	{
		translate ([0,dim.y,0])
		rotate ([90,0,0])
		linear_extrude(dim.y)
		polygon(polyRound([
			 [0,dim.z,0]
			,[dim.x,dim.z,4]
			,[dim.x,up,4]
			,[50,up,0]
			,[40-4,dim.z-20-frontier_rod_top_thickness*2,0]
			,[0,dim.z-20-frontier_rod_top_thickness*2,0]
		],1));
	
		linear_extrude(dim.z)
		polygon(polyRound([
			 [0,dim.y,4]
			,[dim.x,dim.y,0]
			,[dim.x,0,0]
			,[0,0,4]
		],1));
	}
}

module frontier_rods(is_motor=true)
{
	soffs=0.1;
	fix_screw=10;
	union()
	{
		difference()
		{	
			translate_rotate (frontier_rod_tr)
				frontier_rods_cube(frontier_rod_dim,is_motor);
			
			angles=is_motor?[90+55,0]:[-90,-90];
			for (i=[0,1])
			{
				y=i*2-1;
				translate_rotate (frontier_nema_tr)
				translate([0,frontier_bearing_diff/2*y,-1])
				{
					dd=is_motor?frontier_rods_diameter[i][0]:frontier_rods_diameter[i][1];
					rodNmm(d=dd+0.3,length=carriage_dim.x+10);
					
					rotate ([90,0,angles[i]])
					translate ([0,frontier_rod_thickness/2,-fix_screw-dd/2+1])
					{
						m3_screw(h=fix_screw);
						m3_washer(out=60);
						translate ([0,0,fix_screw-5])
							m3_square_nut();
					}
				}
			}
			
			if (is_motor)
			translate_rotate (frontier_nema_tr)
				nema17_cut(shaft=false,main_cyl=true,washers=true,main_cyl_length=100,nema17_cut=false);
			
			translate_rotate (tr_replace(slot_tr,0,frontier_nema_tr[0].x))
			translate ([-20-1,-1,-20-soffs])
				cube ([40+soffs+1,frontier_rod_thickness+2,20+soffs*2]);

			for (y=[-1,1])
				translate_rotate (tr_replace(slot_tr,0,frontier_nema_tr[0].x))
				translate ([10*y,frontier_rod_thickness/2,0])
				{
					translate ([0,0,4])
					rotate ([180,0,0])
						m5n_screw_washer(thickness=4,washer_out=40);
					translate ([0,0,-20-4])
						m5n_screw_washer(thickness=4,washer_out=40);
				}
		}
		translate_rotate (tr_replace(slot_tr,0,frontier_nema_tr[0].x))
		translate ([20+soffs,0,-10])
		rotate ([-90,0,0])
			lgroove (frontier_rod_thickness);
	}
}

module frontier_rod_left()
{
	frontier_rods();
}

module frontier_rod_right()
{
	translate ([-30,0,0])
	mirror([1,0,0])
		frontier_rods(is_motor=false);
}

if (part=="")
{
	if (0)
	{
		//filament_proto();
		//proto_frontier();
		//proto_frontier_rod();
		
		//frontier_main();
		//frontier_top();
		
		//frontier_filament_fix();
		
		
		//frontier_thrash();

		//frontier_rod_left();
		//frontier_rod_right();
		
		//frontier_t8_fix();
	}

	if (0)
	translate ([0,0,mk8_position])
	{
		//mk8_proto();
		//translate_rotate(mk8_transmission_small_tr)	mk8_small_gear();
		//translate_rotate(mk8_transmission_big_tr) mk8_big_gear();
		mk8_body();
		//mk8_cap();
		
		//mk8_spacer_gear();
	}
	
	if (0)
	{
		//filament_proto();
		//carriage_proto();
		//carriage_opto_proto();
		
		//carriage_top();
		//carriage_bottom();
		
		//carriage_optosensor();
	}

	if (1)
	{
		//filament_proto();
		//mk8_stand_proto();
		//proto_cutter_motor();
		//proto_cutter();
		
		//mk8_stand_top();
		//mk8_stand_middle_left();
		//mk8_stand_middle_right();
		
		//mk8_stand_bottom_channel();
		mk8_stand_channel();
		//ss443a_fd(op="inner");
		//ss443a_fd(op="spring");
		
		//ss443a_fd(op="ss443_box_top");
		//ss443a_fd(op="ss443_box_bottom");
		
		//cutter_small_gear();
		//cutter_big_gear(angle=cutter_angle);
		
		//mk8_endstop_half1();
		//mk8_endstop_half2();
		
		//cutter_switch_box_half1();
		//cutter_switch_box_half2();
		
		//stand_sensor_latch_spacer();
	}
	
	if (0)
	{
		//left_rod_fix_proto();
		//left_rod_fix();
		//right_rod_fix();
		/*
		translate ([-12,0,0]) 
		{
			carriage_top();
			carriage_bottom();
		}
		*/
		//motor_pulley();
	}
}
else
{
	if (part=="motor_pulley")
		motor_pulley();
	if (part=="lm8luu")
		lm8luu();
	if (part=="lm8uu")
		lm8uu();
	if (part=="lm8luu_to_7rod")
		lm8luu_to_7rod();
	if (part=="lm8uu_to_7rod")
		lm8uu_to_7rod();
	if (part=="lm8uu_to_5rod")
		lm8uu_to_5rod();
	if (part=="lm8luu_to_5rod")
		lm8luu_to_5rod();
	
	if (part=="mk8_small_gear")
		rotate ([0,0,0])
		mk8_small_gear();
	if (part=="mk8_big_gear")
		rotate ([0,0,0])
		mk8_big_gear();
	if (part=="mk8_body")
		rotate ([180,0,0])
		mk8_body();
	if (part=="mk8_cap")
		rotate ([180,0,0])
		mk8_cap();
	if (part=="carriage_top")
		rotate ([0,0,0])
		carriage_top();
	if (part=="carriage_bottom")
		rotate ([0,90,0])
		carriage_bottom();
	if (part=="stand_top")
		rotate ([0,0,0])
		mk8_stand_top();
	if (part=="stand_left")
		rotate ([0,90,0])
		mk8_stand_middle_left();
	if (part=="stand_right")
		rotate ([0,90,0])
		mk8_stand_middle_right();
	if (part=="stand_channel")
		rotate ([0,0,0])
		mk8_stand_channel();
	if (part=="stand_channel_magnet")
		rotate ([0,0,0])
		ss443a_fd(op="inner");
	if (part=="stand_channel_magnet_spring")
		rotate ([180,0,0])
		ss443a_fd(op="spring");
	if (part=="stand_bottom_channel")
		rotate ([0,0,0])
		mk8_stand_bottom_channel();
	if (part=="stand_ss443_top")
		rotate ([0,0,0])
		ss443a_fd(op="ss443_box_top");
	if (part=="stand_ss443_bottom")
		rotate ([0,0,0])
		ss443a_fd(op="ss443_box_bottom");
	if (part=="cutter_small_gear")
		rotate ([0,-90,0])
		cutter_small_gear();
	if (part=="cutter_big_gear")
		rotate ([-90,0,0])
		cutter_big_gear();
	if (part=="cutterswitch1")
		rotate ([90,0,0])
		cutter_switch_box_half1();
	if (part=="cutterswitch2")
		rotate ([-90,0,0])
		cutter_switch_box_half2();
	if (part=="mk8_endstop_half1")
		rotate ([-90,0,0])
		mk8_endstop_half1();
	if (part=="mk8_endstop_half2")
		rotate ([90,0,0])
		mk8_endstop_half2();
	if (part=="mk8_spacer_gear")
		mk8_spacer_gear();
	if (part=="left_rod_fix")
		left_rod_fix();
	if (part=="right_rod_fix")
		rotate ([0,90,0])
		right_rod_fix();
	if (part=="carriage_optosensor")
		rotate ([0,90,0])
		carriage_optosensor();
	if (part=="frontier_main")
		rotate ([0,0,0])
		frontier_main();
	if (part=="frontier_thrash")
		rotate ([0,0,0])
		frontier_thrash();
	if (part=="frontier_top")
		rotate ([0,0,0])
		frontier_top();
	if (part=="frontier_filament_fix")
		rotate ([90,0,0])
		frontier_filament_fix();
	if (part=="carriage_filament_fix")
		rotate ([0,0,0])
		carriage_filament_fix();
	if (part=="filament_fix_nut")
		pc4_nut();
	if (part=="frontier_t8_fix")
		rotate ([0,90,0])
		frontier_t8_fix();
	if (part=="frontier_rod_left")
		rotate ([0,90,0])
		frontier_rod_left();
	if (part=="frontier_rod_right")
		rotate ([0,-90,0])
		frontier_rod_right();
	if (part=="frontier_sensor")
		rotate ([0,90,0])
		frontier_sensor();
}
