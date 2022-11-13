use <../../../_utils/mfunctions.scad>
use <../../../_utils/atomic.scad>
use <../../../_utils/_round/polyround.scad>
use <../../../_utils/fillet.scad>
	
m5_screw_diameter_diff = 1;
m5_screw_diameter = 5 + m5_screw_diameter_diff;
m5_cap_S=8+0.2;
m5_cap_H=3.55;

diff=0.2;
cap_h=2;
thickness=0.4;
handle_dia=3.0;
base_height=11.95;
from=0;
to=0;
dd=m5_cap_S+thickness*2;
newheight=false;

module thumb2 (from,to,offs=0,newheight=false)
{
	rays=6;
	
	sd=from-to;
	cheight=sd>8?base_height+sd-8:base_height;
	height=newheight?sd+4:cheight;
	
	screw_diff=from-to;
	
	difference()
	{
		union()
		{
			for (a=[0:360/rays:360])
			fillet(r=0.7,steps=8)
			{
				rotate ([0,0,a])
				translate ([dd/2,0,0])
					cylinder (d=handle_dia+offs*2,h=height,$fn=60);
				cylinder (d=dd+offs*2,h=height,$fn=60);
			}
		}
		
		translate ([0,0,screw_diff])
			nut (S=m5_cap_S-0.1,H=20);
		translate ([0,0,-0.1])
			cylinder (d=5,h=30,$fn=40);
	}
}

if (from==0 || to==0)
{
	translate ([20,0,0]) thumb2 (from=16,to=10,newheight=true);
//	thumb2 (from=16,to=8);
//	translate ([-20,0,0]) thumb2 (from=20,to=10);
}
else
{
	thumb2 (from=from,to=to,newheight=newheight);
}