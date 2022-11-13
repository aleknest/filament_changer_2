use <../../../_utils_v2/m3-m8.scad>
use <../../../_utils_v2/fillet.scad>
use <../changer/pc4fitting.scad>

fitting_up=3;

bearings = [
 [10,4,5] //mr105zz
,[11,5,5] //685zz
,[10,4,3] //623zz
,[9,3,5] //mr95
,[13,4,5] //619/5
];

bearing=bearings[0];
angles=[[180,-90]];

module translate_rotate(tr) 
{
	for (i=[0:$children-1]) 
		translate (tr[0])
		rotate(tr[1])
			children(i);
}

module fitting()
{
	difference()
	{
		pc4_add_other(fix_cyl_angles=angles,up=fitting_up,base_length_add=fitting_up);
		pc4_sub_other(fix_cyl_angles=angles,screw_add=screw-6);
	}
}


tr_fitting=[[1.11,-18.24,7.45],[0,90,90]];
tr_axis=[[-15,0.68,11.95],[0,90,0]];
bearingz_z=[
	 [0,5,0,0]
	,[22,8,3,22+4.1]
];

screw=12;
capout=12;

dim_main=[30,26.1,7.3];
tr_main=[-dim_main.x/2,-dim_main.y/2+0.15+0.7,20];
tr_fix=[-2.68,dim_main.y/2-0.85,-1.2];

rotate ([0,180,0])
difference()
{
	union()
	{
		color ("red")
			import ("src/body_-_body_2v2.stl");
			
		{
			difference()
			{
				union()
				{
					translate_rotate(tr_fitting)
					{
						fitting();
					}
					
					translate_rotate (tr_axis)
					for (bz=bearingz_z)
					{
						translate ([0,0,bz[0]])
							cylinder (d=15,h=bz[1],$fn=20);
					}
					
					add1=[1,3.05,15.8618];
					add2=[0.3,7+1,5.8+0.0618+10];
					translate (tr_main)
						cube (dim_main);
					translate (tr_main)
					translate (tr_fix)
					{
						cylinder(d=8.8,h=8.5,$fn=80);
					}
					
					translate (tr_main)
					translate ([0,-add1.y,-add1.z])
						cube ([dim_main.x,2+add1.y+add1.x,dim_main.z+add1.z]);
					translate (tr_main)
					translate ([0,dim_main.y-add2.y+add2.x,-add2.z])
						cube ([dim_main.x,add2.y,dim_main.z+add2.z]);

					translate ([4.75,12.1,14.14-10])
						cylinder (d=5.2,h=13.16+10,$fn=40);
				}
		
				translate ([4.75,12.1,14.14])
				translate ([0,0,-m3_nut_h()])
				rotate ([0,0,90])
				hull()
				{
					m3_nut();
					translate ([10,0,0])
						m3_nut();
				}
				translate_rotate (tr_axis)
				for (bz=bearingz_z)
				{
					translate ([0,0,bz[3]-0.01])
						cylinder (d=bearing[0]+0.2+0.1,h=bearing[1]+bz[2]+0.01,$fn=80);
				}
				translate_rotate (tr_axis)
					cylinder (d=bearing[0]-1.5,h=100,$fn=80);
				
				translate_rotate(tr_fitting)
				translate ([0,0,-10])
					cylinder (d=3,h=80,$fn=40);
				
				translate_rotate (tr_axis)
				translate ([0,0,5])
				hull()
				{
					hh=4.25;
					cylinder(d=30,h=hh,$fn=80);
					translate ([10,0,0])
						cylinder(d=30,h=hh,$fn=80);
					translate ([10,-8,0])
						cylinder(d=30,h=hh,$fn=80);
				}
				
				dim2=[14,10,7.3];
				translate ([4.1,-dim2.y/2,25.5])
					cube (dim2);
				
				translate ([1.1,0,-31])
					cylinder (d=19.05,h=50,$fn=80);			
			}			
		}
	}
	
	if (!$preview)
	{
		translate (tr_main)
		translate (tr_fix)
		translate ([0,0,-0.01])
		{
			cylinder(d=m3_screw_diameter(),h=9,$fn=80);
			translate ([0,0,8.5-2])
			rotate ([180,0,90])
			{
				m3_nut_inner();
				translate ([0,0,m3_nut_h()-0.01])
					m3_nut(h=3.91);
			}
		}
		translate_rotate(tr_fitting)
			pc4_sub_other(fix_cyl_angles=angles,screw_add=screw-6,capout=capout,screw_out=100);
		translate ([-14.25-0.1,-3.5,18.8])
			cube([12+0.2,7,10]);
		translate ([1.4,0,14])
		{
			cylinder (d=3.5,h=20,$fn=40);
			m3_nut(h=13.3-4);
		}
		translate ([4.75,12.1,-20])
			cylinder (d=m3_screw_diameter(),h=100,$fn=40);
	}
}	

