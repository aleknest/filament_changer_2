use <../../../_utils/mfunctions.scad>
use <../../../_utils/fillet.scad>
use <../../../_utils/sequental_hull.scad>
use <../../../_utils/_round/polyround.scad>
use <../../../_utils_v2/m3-m8.scad>

block_width=16;
add=3.667;
sub=0.9;
block_length=16+add-sub*2;
block_length_offset=2+add+sub;
block_height=24;

rpi352_width = 6.4+0.2;
rpi352_length = 4.2;
rpi352_height = 5.4;
rpi352_width_cut = 3;
rpi352_height_cut=3.9-0.3;//-0.3 25.12.2020
rpi352_legs_width=5;
rpi352_legs_length=2.5;
rpi352_cut=1;

rpi352_latch_width=rpi352_width+4;
rpi352_latch_height=rpi352_length+18+8;
rpi352_latch_thickness=3.0;

filament_diameter_=1.75+1*2;

//rpi352_filament_offset=-3.5+0.5;//-1.5,+1,+0.5(best),+0.1(bad) after print
//rpi352_sensor_offset=0.0;

rpi352_filament_offset=-3.5+0.5-0.5;//-1.5,+1,+0.5(best),+0.1(bad) after print
//rpi352_sensor_offset=-0.8+0.1-0.3;
rpi352_sensor_offset=-0.8+0.1-0.3-0.1-0.1;

m3_cap_diameter = 6.0; 
m3_cap_h = 3;
m3_nut_G = 6.6;
m3_nut_G_inner_diff=0.2;
m3_nut_H = 2.4 + 0.2;
m3_screw_diameter = 3.4; //M3 screw + diff (prev 0.4)
m3_washer_diameter_diff = 1;
m3_washer_diameter = 7 + m3_washer_diameter_diff; // M3 washer diameter 7mm + diff
m3_washer_thickness = 0.5;
m3_square_nut_S_real=5.5;
m3_square_nut_S=m3_square_nut_S_real+0.2;
m3_square_nut_H=1.8+0.2;

/*
module m3_square_nut(out=20,offs=0.2)
{
	square=m3_square_nut_S+offs;
	translate ([-square/2,-square/2,0])
	{
		cube ([square,square+out,m3_square_nut_H],false);
		diff=0.2;
		translate ([-diff,square-0.2,-diff])
			cube ([square+diff*2,0.2+out,m3_square_nut_H+diff*2],false);
	}
}
*/

module filament_path(hin=0,filament_diameter)
{
	hh=100;
	translate ([0,0,0])
		cylinder (d=filament_diameter,h=hh/2,$fn=60);
}

//filament_path2_tr=[0,-0.5,0];
//filament_path2_dadd=0.5;
filament_path2_tr=[0,0,0];
filament_path2_dadd=0;
module filament_path2(hin=0,filament_diameter)
{
	hh=100;
	translate (filament_path2_tr)
	translate ([0,0,-hh/2])
		cylinder (d=filament_diameter+filament_path2_dadd,h=hh/2,$fn=60);
}
module filament_path0(hin=0,filament_diameter)
{
	hh=50;
	translate ([0,0,-hh/2])
		cylinder (d=filament_diameter,h=hh/2,$fn=60);
}

function rpi352_cut_shape(offsx,offsy)=
	polyRound([
			  [-rpi352_width_cut/2-offsx,0,0]
			, [rpi352_width_cut/2+offsx,0,0]
			, [rpi352_width_cut/2+offsx,-rpi352_height_cut,1]
			, [-rpi352_width_cut/2-offsx,-rpi352_height_cut,1]
		],20);

module rpi352_filament_path_cut1()
{
	translate([0,rpi352_filament_offset,0])
	translate ([-5,-10+2.5,-10])
		cube([10,10,20]);
}

module rpi352_filament_path_cut2(filament_diameter)
{
	hh=40;
	translate ([-5,filament_diameter/2,-hh/2])
		cube ([10,10,hh]);
}

module rpi352_filament_path(op=0,filament_diameter)
{
	offsx_base=0.001;
	offsx_cut=4;
	offsx=op==1?offsx_cut:offsx_base;
	
	offsy_base=0.6;
	offsy_cut=4;
	offsy=op==1?offsy_cut:offsy_base;
	points=rpi352_cut_shape(offsx,offsy);
	union()
	{
		difference()
		{
			translate([0,rpi352_filament_offset,0])
			{
				rotate ([-90,0,0])
				translate ([0,rpi352_length/2+offsy,rpi352_height])
				rotate ([90,0,0])
				linear_extrude (rpi352_length+offsy*2)
					polygon (points);
			}
			if (op==0)
			{
				rpi352_filament_path_cut1();
				rpi352_filament_path_cut2(filament_diameter=filament_diameter);
			}
		}
		if (op==0)
		{
			hull()
			{
				translate ([0,0,-rpi352_length/2-offsy_cut-0.1])
				{
					cylinder (d=filament_diameter,h=0.1,$fn=60);
					translate (filament_path2_tr)
						cylinder (d=filament_diameter+filament_path2_dadd,h=0.1,$fn=60);
				}
				
				difference()
				{
					translate([0,rpi352_filament_offset,0])
					rotate ([-90,0,0])
						translate ([0,rpi352_length/2+offsy_base,rpi352_height])
						rotate ([90,0,0])
						linear_extrude (0.01)
							polygon (rpi352_cut_shape(offsx_base,offsy_base));
					rpi352_filament_path_cut1();
					rpi352_filament_path_cut2(filament_diameter=filament_diameter);
				}
			}
			hull()
			{
				translate ([0,0,rpi352_length/2+offsy_cut])
					cylinder (d=filament_diameter,h=0.1,$fn=60);
			
				difference()
				{
					translate([0,rpi352_filament_offset,0])
					rotate ([-90,0,0])
						translate ([0,-rpi352_length/2-offsy_base+0.01,rpi352_height])
						rotate ([90,0,0])
						linear_extrude (0.01)
							polygon (rpi352_cut_shape(offsx_base,offsy_base));
					rpi352_filament_path_cut1();
					rpi352_filament_path_cut2(filament_diameter=filament_diameter);
				}
			}
		}
			
	}
}

module rpi352(op=0)
{
	out=(op==1 || op==3)?100:0;
	out2=op==1?20:0;
	xy=op==1?0.1:0;
	out_offs=op==1?0.6:0;
	
	translate([0,rpi352_filament_offset+rpi352_sensor_offset,0])
	rotate ([-90,0,0])
	union()
	{
		difference()
		{
			union()
			fillet(r=1.4,steps=16)
			{
				translate ([-rpi352_width/2-xy,-rpi352_length/2-xy,0])
				{
					fix_offs=op==1?0.8:0;
					//fix_offs=op==1?-0.3:0;
					fix_offs_up=op==1?0.6:0;
					fix_offs_out=op==1?1:0;
					insert_add=op==1?[0.1+0.2,0.1+0.2]:[0,0];
					dim=[rpi352_width+xy*2,rpi352_length+xy*2,rpi352_height+out2];
					translate ([0,dim.y+insert_add.y,0])
					rotate ([90,0,0])
					linear_extrude (dim.y+insert_add.y*2)
						polygon (polyRound([
							 [-insert_add.x,-0.1,0]
							,[-insert_add.x,rpi352_height+0.1,0]
							,[fix_offs,rpi352_height+0.1,0]
							,[fix_offs,rpi352_height+fix_offs_up,0]//
							,[-fix_offs_out,rpi352_height+fix_offs_up,0]
							,[-fix_offs_out,dim.z,0]
							,[dim.x+fix_offs_out,dim.z,0]
							,[dim.x+fix_offs_out,rpi352_height+0.1+fix_offs_up,0]
							,[dim.x-fix_offs,rpi352_height+0.1+fix_offs_up,0]
							,[dim.x-fix_offs,rpi352_height+0.1,0]
							,[dim.x+insert_add.x,rpi352_height+0.1,0]
							,[dim.x+insert_add.x,-0.1,0]
						],20));
					
				}
			
				translate ([-rpi352_width/2-xy-out_offs,-rpi352_length/2-xy-out_offs,-out])
					cube ([rpi352_width+xy*2+out_offs*2,rpi352_length+xy*2+out_offs*2,out]);
			}
					
			translate ([0,rpi352_length/2+1,rpi352_height])
			rotate ([90,0,0])
				linear_extrude (rpi352_length+2)
				offset(-0.01)
					polygon (polyRound([
						  [-rpi352_width_cut/2,0.1+out2,0]
						, [rpi352_width_cut/2,0.1+out2,0]
						, [rpi352_width_cut/2,-rpi352_height_cut,1]
						, [-rpi352_width_cut/2,-rpi352_height_cut,1]
					],20));
		}
		if (op==0)
		{
			for (x=[-1:2:1])
			for (y=[-1:2:1])
				translate ([rpi352_legs_width/2*x,rpi352_legs_length/2*y,0])
				rotate ([180,0,0])
					cylinder (d=0.25,h=10,$fn=16);
		}
		if (op==2)
		{
			hull()
			for (x=[-1:2:1])
			for (y=[-1:2:1])
			{
				offs=x==1?10:0;
				translate ([rpi352_legs_width/2*x+offs,rpi352_legs_length/2*y,0])
				rotate ([180,0,0])
				{
					dia=0.7;
					translate ([-dia/2,-dia/2,0])
						cube ([dia,dia,20]);
				}
			}
		}
	}
}

module rpi352_proto()
{
	color ("lime")
		rpi352(op=0);
}

module opt_filament_path(filament_diameter)
{
	echo ("fd=",filament_diameter);
	union()
	{
		rpi352_filament_path(op=0,filament_diameter=filament_diameter);
		difference()
		{
			union()
			{
				filament_path(hin=0,filament_diameter=filament_diameter);
				hull()
				{
					filament_path2(hin=0,filament_diameter=filament_diameter);
					filament_path0(hin=0,filament_diameter=filament_diameter);
				}
			}
			scale ([10,10,1])
				rpi352_filament_path(op=1,filament_diameter=filament_diameter);
		}
	}
}

module rp352_sensor_cut(rpi352_op=1,filament_diameter)
{
	rpi352(op=rpi352_op);
	opt_filament_path(filament_diameter=filament_diameter);
}

module rp352_sensor_body(out=0)
{
	difference()
	{
		translate ([-block_width/2,-block_length/2-block_length_offset,-block_height/2-out])
			cube ([block_width,block_length,block_height+out*2]);
	}
}

module rp352_sensor_block(rpi352_op=1,filament_diameter,out=0)
{
	union()
	{
		difference()
		{
			rp352_sensor_body(out=out);
			rp352_sensor_cut(rpi352_op=rpi352_op,filament_diameter=filament_diameter);
		}
	}
}

module rp352_sensor_latch_fix(op=0)
{
	screw=8;
	nutoffs=2;
	for (y=[-1,1])
		translate ([0,-block_length/2-block_length_offset-rpi352_latch_thickness,(-rpi352_latch_height/2+4)*y])
		rotate ([90,90,0])
		translate ([0,0,-screw])
		{
			if (op==0)
			{
				cylinder (d=m3_screw_diameter,h=screw,$fn=60);
				translate ([0,0,nutoffs])
				rotate ([0,0,y*-90])
					m3_square_nut(out=100,offs=0.1);
				translate ([0,0,screw-0.01])
					cylinder (d=m3_cap_diameter,h=20,$fn=60);
			}
			if (op==1)
			{
				translate ([0,0,nutoffs-0.4])
					cylinder (d=m3_screw_diameter+1,h=0.4,$fn=60);
			}
		}
}

module rp352_sensor_latch_(filament_diameter,filament_y_correction=0)
{
	difference()
	{
		translate ([-rpi352_latch_width/2,-block_length/2-block_length_offset-rpi352_latch_thickness,-rpi352_latch_height/2])
			cube ([rpi352_latch_width
					,block_length/2+rpi352_latch_thickness+filament_y_correction
					,rpi352_latch_height]);
		translate ([0,0,20])
			rp352_sensor_block(rpi352_op=3,filament_diameter=filament_diameter,out=100);
		//rpi352(op=2);
	}
}

module rp352_sensor_latch_cut()
{
	translate([0,3.5,0])
	{
		difference()
		{
			offs=0.3;
			translate ([0,-60,0])
			translate ([-rpi352_latch_width/2-offs,-block_length/2-block_length_offset-rpi352_latch_thickness,-rpi352_latch_height/2-offs])
				cube ([rpi352_latch_width+offs*2,block_length/2+rpi352_latch_thickness+60,rpi352_latch_height+offs*2]);
			rp352_sensor_body(out=20);
		}
		wire=[17,26,3];
		wire2=[6,60,10];
		translate([0,-15.5-wire.y+3,0])
		{
			translate([0,0,-wire.z/2])
				cube ([wire.x+100,wire.y+1,wire.z]);
			//translate([wire.x-0.01,0,-wire2.z/2])
			//	cube (wire2);
		}
	}
}

module rp352_sensor_latch_cut_small()
{
	translate([0,3.5,0])
	{
		difference()
		{
			offs=0.3;
			translate ([0,-60,0])
			translate ([-rpi352_latch_width/2-offs,-block_length/2-block_length_offset-rpi352_latch_thickness,-rpi352_latch_height/2-offs])
				cube ([rpi352_latch_width+offs*2,block_length/2+rpi352_latch_thickness+60,rpi352_latch_height+offs*2]);
			rp352_sensor_body(out=20);
		}
	}
}

module rp352_sensor_latch(filament_diameter,filament_y_correction=0)
{
	translate([0,3.5,0])
	{
		rp352_sensor_latch_(filament_diameter=filament_diameter,filament_y_correction=filament_y_correction);
	}
}


//rp352_sensor_latch_cut();
//rp352_sensor_latch(1.75);

//rp352_sensor_latch_cut_small();
//opt_filament_path(filament_diameter=3);

//rpi352_proto();
//opt_filament_path(filament_diameter=1.75+0.3*2);
rpi352(op=1);





//rp352_sensor_block(filament_diameter=filament_diameter_);

//translate ([0,-20,0])
//	rp352_sensor_latch(filament_diameter=filament_diameter_,filament_y_correction=-1);

//translate ([0,0,-20])
//	rpi352(op=0);

//translate ([0,0,-26])
//	rpi352(op=1);
//translate ([0,0,-32])
//	rpi352(op=2);
//translate ([0,0,-38])
//	rpi352(op=3);
//rp352_sensor_latch_fix();


