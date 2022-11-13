use <../../../_utils_v2/_round/polyround.scad>
use <../../../_utils_v2/fillet.scad>
use <../../../_utils_v2/deb.scad>
use <../../../_utils_v2/Getriebe.scad>
use <../../../_utils_v2/m3-m8.scad>
use <../../../_utils_v2/slot.scad>
use <../../../_utils_v2/rods.scad>

module proto()
{
	//translate ([-59,0,10])
	color ("green")
	translate ([100,0,0])
	rotate ([0,0,90])
	scale ([1,2,1])
		import ("proto/40x20x100VSlotExtrusion.stl");
	
	color ("orange")
	translate ([0,-122,-65+8])
	rotate ([90,0,90])
		import ("proto/OPI1_case_bottom.stl");
}

//proto();

thickness=6;
bthickness=3;
wout=26;
translate ([0,-20+0.1,10])
{
	ww=74.8;
	hh=58.4;
	border=[7,7];
	shift=[3,8];
	difference()
	{
		union()
		{
			dimp=[wout,40,thickness];
			fillet (r=4,steps=16)
			{
				translate ([-wout,0,0])
				{
					dim=dimp;
					linear_extrude(dim.z)
						polygon(polyRound([
							 [0,0,6]
							,[dim.x,0,0]
							,[dim.x,dim.y,0]
							,[0,dim.y,6]
						],20));
				}
				translate ([-bthickness,0,0])
				{
					dim=[bthickness,ww,hh];
					rotate ([90,0,90])
					linear_extrude(dim.x)
						polygon(polyRound([
							 [0,0,0]
							,[dim.y,0,1]
							,[dim.y,dim.z,1]
							,[0,dim.z,1]
						],20));
				}
			}
			for (y=[10,30])
				translate ([0,y,0])
				rotate ([0,-90,0])
					groove(dimp.x);
		}
		translate ([-bthickness,0,0])
		translate ([-1,border.x+shift.x,border.y+shift.y])
		fillet (r=2,steps=4)
		{
			dim=[bthickness+2,ww-border.x*2-shift.x,hh-border.y*2-shift.y];
			rotate ([90,0,90])
			linear_extrude(dim.x)
				polygon(polyRound([
					 [0,0,2]
					,[dim.y,0,2]
					,[dim.y,dim.z,2]
					,[0,dim.z,2]
				],20));
			translate ([0,dim.y/2,dim.z/2])
			rotate ([0,90,0])
				cylinder(d=dim.z+8,h=bthickness+2,$fn=100);
		}
		
		for (y=[0,1])
		for (z=[0,1])
			translate ([-bthickness+1,7.92+y*62.8,12.1+z*42.2])
			rotate ([0,90,0])
			{
				m3_screw(h=40,cap_out=100);
			}
			
		for (y=[0,1])
		translate ([-wout/2-4,10+y*20,4])
		rotate ([180,0,0])
			m5n_screw_washer(4, diff=2, washer_out=10);
	}
	
}

/*
module fix(w)
{
	translate ([26,-20,10])
	{
		screw=16;
		screw_offs=7;
		dim=[w,40,thickness];
		last_screw=[10.9,12.7];
		
		union()
		{
			difference()
			{
				union()
				{
					linear_extrude(dim.z)
						polygon(polyRound([
							 [0,0,2]
							,[dim.x,0,4]
							,[dim.x,dim.y,4]
							,[last_screw.x,dim.y,1]
							,[last_screw.x,dim.y+last_screw.y,2]
							,[0,dim.y+last_screw.y,2]
						],1));
					
					for (y=[0,1])
						translate ([dim.x,10+y*20,0])
						rotate ([0,-90,0])
							groove (dim.x);
				}		
				for (y=[0,1])
					translate ([dim.x-screw_offs,10+y*20,4])
					rotate ([180,0,0])
						m5n_screw_washer(thickness=4,diff=2,washer_out=10);
				
				for (y=[0,1])
					translate ([5.64,5.16+y*42.26,m3_cap_h()+1])
					{
						m3_screw(h=screw,cap_out=10);
						m3_washer(out=10);
					}
			}
	
			for (y=[0,1])
				translate ([5.64,5.16+y*42.26,m3_cap_h()+1])
					m3_washer_add();
			
			for (y=[0,1])
				translate ([dim.x-screw_offs,10+y*20,4])
				rotate ([180,0,0])
					m5n_screw_washer_add();	
			}
	}
}

module left()
{
	fix(w=28);
}

module right()
{
	mirror([1,0,0])
		fix(w=24);
}

left();
right();
*/