use <../../../_utils_v2/_round/polyround.scad>
use <../../../_utils_v2/fillet.scad>
use <../../../_utils_v2/m3-m8.scad>
use <../../../_utils_v2/slot.scad>

function vec_add (v1,v2)=[v1.x+v2.x,v1.y+v2.y,v1.z+v2.z];

up=6;

thickness=[2,3];
top_out=2.0;
top_th=2;
offs=0.8;
height=25+up;
top_thi=height;
dim=[53.35,57.2,height];
tr=[0,0,0];
fix=[19,9,8+20];

corr=[-0.25,57.32,0];
corr_screw=[25.46,-11.5,1.85];
coord=[
	 [20.51,8.84,0+up]
	,[-7.43,8.84,0+up]
	,[-22.67,-41.96,0+up]
	,[25.59,-43.23,0+up]
];	

//color ("pink") translate (corr) rotate ([90,0,0]) import ("proto/exp2.stl");

inner_tr=vec_add(tr,[-offs,-offs,0]);
inner_dim=vec_add(dim,[offs*2,offs*2,0]);
outer_tr=vec_add(inner_tr,[-thickness.x,-thickness.x,-thickness.y]);
outer_dim=vec_add(inner_dim,[thickness.x*2,thickness.x*2,thickness.y-0.01]);
top_tr=[outer_tr.x-top_out,outer_tr.y-top_out,height-top_thi];
top_dim=[outer_dim.x+top_out*2,outer_dim.y+top_out*2,top_th+top_thi];

module power_cut()
{
	translate (tr)
	translate ([37.6,-10,3.3+up])
		cube ([9.3,30,11.4+20]);
}

module bottom()
{
	difference()
	{
		union()
		{
			difference()
			{
				translate (outer_tr)
					cube (outer_dim);
				
				translate (inner_tr)
					cube (inner_dim);
				power_cut();
			}
			
			translate (corr)
			translate (corr_screw)
			for (c=coord)
				translate ([c.x,c.y,0])
				{
					translate ([0,0,c.z])
					rotate ([180,0,0])
						cylinder (d=m3_screw_diameter()+2,h=thickness.y,$fn=40);
					translate ([0,0,up-thickness.y+2])
					rotate ([180,0,0])
						cylinder (d=10,h=up+thickness.y,$fn=40);
				}
				translate (outer_tr)
				translate ([-fix[0],outer_dim.y-fix[1]-10,0])
					for (xx=[fix[2],outer_dim.x+fix[0]*2-fix[2]])
						translate ([xx,fix[1]/2,0])
						{
							cylinder (d=14,h=4,$fn=40);
						}
		}
		
		translate ([0,0,0.01])
		translate (corr)
		translate (corr_screw)
		for (c=coord)
			translate (c)
			rotate ([180,0,0])
			{
				cylinder (d=m3_screw_diameter(),h=10,$fn=40);
				translate ([0,0,3])
					m3_nut(h=40);
			}
			
		translate (outer_tr)
		translate ([-fix[0],outer_dim.y-fix[1]-10,0])
			for (xx=[fix[2],outer_dim.x+fix[0]*2-fix[2]])
				translate ([xx,fix[1]/2,4])
				rotate ([180,0,0])
				{
					m5n_screw_washer(thickness=5, diff=1, washer_out=40);
				}
	}
}

module top()
{
	difference()
	{
		translate (top_tr)
			cube (top_dim);
		translate (vec_add(outer_tr,[-offs,-offs,0]))
			cube (vec_add(outer_dim,[offs*2,offs*2,0]));
		translate ([0,0,-10])
			power_cut();
	}
}

//bottom();
top();