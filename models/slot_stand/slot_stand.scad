use <../../../_utils_v2/_round/polyround.scad>
use <../../../_utils_v2/fillet.scad>
use <../../../_utils_v2/deb.scad>
use <../../../_utils_v2/Getriebe.scad>
use <../../../_utils_v2/m3-m8.scad>
use <../../../_utils_v2/slot.scad>
use <../../../_utils_v2/rods.scad>

part="";

z=[20,20,20];
//x=[60,20];
x=[70,20];
yout=60;

middlez=40;
middleb=[4,8];

module fix()
{
	difference()
	{
		union()
		{
			//fillet (r=10,steps=16)
			{
				//fillet (r=10,steps=16)
				{
					dim1=[20,20,z[0]+z[1]];
					translate ([0,dim1.y,0])
					rotate ([90,0,0])
					linear_extrude(dim1.y)
					polygon(polyRound([
						 [0,0,0]
						,[dim1.x,0,0]
						,[dim1.x,dim1.z,0]
						,[0,dim1.z,12]
					],20));
					
					dim2=[x[0]-20,20,z[1]];
					translate ([20,0,z[0]])
					{
						translate ([0,dim2.y,0])
						rotate ([90,0,0])
						linear_extrude(dim2.y)
						polygon(polyRound([
							 [0,0,0]
							,[dim2.x,0,12]
							,[dim2.x,dim2.z,0]
							,[0,dim2.z,0]
						],20));
					}
				}
				dim3=[x[1],40,z[2]];
				#translate ([x[0]-x[1],yout,z[0]+z[1]])	
				{
					rotate ([90,0,90])
					linear_extrude(dim3.x)
					polygon(polyRound([
						 [0,0,0]
						,[dim3.y,0,12]
						,[dim3.y,dim3.z,0]
						,[0,dim3.z,0]
					],20));
				}
			}
			
			translate ([0,yout,z[0]])
			translate ([x[0]-x[1],0,z[1]])
			{
				for (y=[10,30])
				translate ([0,y,z[2]])
				rotate([0,90,0])
					groove(x[1]);
			}
			translate ([10,20,0])
			rotate ([0,-90,90])
				groove(20);
		}
		translate ([10,10,4])
		rotate ([180,0,0])
			m5n_screw_washer(thickness=4, diff=2, washer_out=100);
		for (y=[10,30])
			translate ([x[0]-x[1]/2,y+yout,z[0]+z[1]+z[2]-4])
				m5n_screw_washer(thickness=4, diff=2, washer_out=100);
	}
}

module middle()
{
	//fix();
	translate ([x[0]-x[1],0,z[0]+z[1]+z[2]])
	{
		difference()
		{
			union()
			{
				cube ([x[1],40,middlez]);
				
				for (y=[10,30])
					translate ([0,y,middlez-0.01])
					rotate ([0,90,0])
						groove(x[1]);
			}
		
			translate ([-1,middleb.x,middleb.y])
			{
				dim=[x[1]+2,40-middleb.x*2,middlez-middleb.y*2];
				//cube (dim);
				rotate ([90,0,90])
				linear_extrude(dim.x)
					polygon(polyRound([
						 [0,0,4]
						,[dim.y,0,4]
						,[dim.y,dim.z,4]
						,[0,dim.z,4]
					],20));
			}
			
			for (y=[10,30])
				translate ([-1,y,-0.01])
				rotate ([0,90,0])
					groove(x[1]+2);
			
			for (y=[10,30])
				translate ([x[1]/2,y,middlez-4])
					m5n_screw_washer(thickness=4, diff=2, washer_out=10);
			
			for (y=[10,30])
				translate ([x[1]/2,y,-4])
				{
					cylinder(d=m5_screw_diameter(), h=10, $fn=60);
					translate ([0,0,7])
					{
						nut(G=m5_nut_G(),H=m5_nut_H()+0.1);
						translate ([0,0,m5_nut_H()])
							nut(G=m5_nut_G()+0.4,H=4);
					}
				}
		}	
	}
}

if (part=="")
{
	fix();
}
if (part=="left")
	rotate ([90,0,0])
	fix();
if (part=="right")
	rotate ([90,0,0])
	mirror([1,0,0])
	fix();
if (part=="middle")
	rotate ([0,90,0])
	middle();
