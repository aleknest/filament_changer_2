/// Designed by 1sPiRe ///
///   https://www.thingiverse.com/1sPiRe   ///

use <../../../_utils_v2/sequental_hull.scad>
use <../../../_utils_v2/fillet.scad>
use <../../../_utils_v2/m3-m8.scad>
use <../../../_utils_v2/_round/polyround.scad>

$fn=80;

cut=[22,0,30];
height_add=20;

bottom_screws=[[58,-20,0],[58,33+10,0],[58-20,33+10,0]];

module boitier(a,b,outer=false) 
{
	w=98;
	h=50;
	sk=6;
	ww=w+2*b-cut.y;
	hh=h+height_add+2*b;
   	translate([-53.5,-38-b,5-10-b]) 
	{
    	hull() 
		{
			translate([0,0,sk]) 
				cube([a,ww,hh-sk*2]);
			translate([0,sk,0]) 
				cube([a,ww-sk*2,hh]);
		}
		if (outer)
		{
			//reb=[5.9,3];
			reb=[6.74,3];
			last=22;
			for (x=[ww,-reb.y])
			for (sh=[0:last])
				if (sh%2==0)
				{
					dim=sh==last?[reb.x-1,reb.y,hh-sk*2]:(sh==0?[reb.x-1,reb.y,hh-sk*2]:[reb.x,reb.y,hh-sk*2]);
					tr=sh==last?[a-dim.x,x,sk]:[sh*reb.x,x,sk];
					translate(tr) 
					{
						//cube(dim);
						rotate ([90,0,90])
						linear_extrude(dim.x)
							polygon(polyRound([
								 [0,0,x>0?0:reb.y]
								,[dim.y,0,x<0?0:reb.y]
								,[dim.y,dim.z,x<0?0:reb.y]
								,[0,dim.z,x>0?0:reb.y]
							],1));
					}
				}
		}
    }
}

module Bouton_reset() {
    translate([-16,-33.5,19.5]) 
	rotate([90,0,0])
	{
		difference()
		{
			union()
			{
        		cylinder(d=8,h=1);
        		cylinder(d=5.4,h=9);
			}
			//translate ([0,0,-1])
       		//	cylinder(d=5.4-0.8*2,h=7);
		}
        translate([0,0,9]) 
			sphere(d=5.4);
    }
}
//

//Rigoles
module rigole() 
{
    difference() {
        translate([-1.5,0,0]) boitier(4.5,0);
        hull() {
            translate([-0.1,0,0])boitier(0.2,-5);
            translate([-1.5-1,0,0]) boitier(1,0);
        }
        hull() {
            translate([1.5-0.1,0,0])boitier(0.2,-5);
            translate([3,0,0]) boitier(1,0);
        }
        translate([-0.35,0,0]) boitier(1.5+0.7,-0.7);
        translate([-1.5,0,0]) boitier(4.5,-2.5);
    }
}

//
module Box() 
{
    difference() 
	{
        union() 
		{
            difference() 
			{
                translate([-1.5-cut.z,0,0]) 
					boitier(125+21+cut.z-cut.x,1.5+0.5,outer=true);
                translate([-2.5-cut.z,0,0]) 
					boitier(125+23+cut.z-cut.x,0);
            }
            translate([62.5-53.5+5,45-38,5+height_add]) 
				for(i=[68-cut.x,-60-cut.z],j=[43.95+8-cut.y,-43.95]) 
					translate([i,j,25]) 
					rotate([90,0,0]) 
						cylinder(d=6+1.6,h=1.5+0.8,center=true);
            translate([-16,-33.5-3.75,19.5]) 
			rotate([90,0,0])  
				cylinder(d1=7,d2=12,h=0.75);

	        translate([-16,-33.5-5,19.5]) 
			rotate([90,0,0]) 
				cylinder(d=12,h=12);
        }
        
        translate([-16,-33.5,19.5]) 
		rotate([90,0,0]) 
			cylinder(d=6,h=12);
        
        translate([62.5-53.5+5,45-38,5+height_add]) 
		for(i=[68-cut.x,-60-cut.z],j=[45.25+8-cut.y,-45.25]) 
			translate([i,j,25]) rotate([90,0,0]) 
			{
				cylinder(d=6,h=3.5,center=true);
				cylinder(d=3.4,h=5,center=true);
			}
    }
    
    translate([-cut.z,0,0]) 
    	rigole();
    translate([125-1.5+18-cut.x,0,0]) 
		rigole();
}

//

//Top Box
module Top_Box() 
{
    difference() 
	{
        Box();
        translate([14,11,1.25]) 
			cube([300,200,50+height_add*2],center=true);
    }
}

//Bottom_Box
    //Arduino screws
module ard_mount(add=0) 
{
	last_out=0;
	mount_coords=[
		 [-35.55-last_out,24.25,0]
		,[-36.85-last_out,-24.25,0]
		,[39.35,24.25,0]
	    ,[44.65,-24.25,0]
	];
	for (c=mount_coords)
        translate(c) 
		{
			if (add==0)
            	translate([0,0,-5])
					cylinder(d1=12,d2=5,h=5);
			if (add==1)
			{
				screw=10;
            	translate([0,0,-screw+7])
					m3_screw(h=screw,cap_out=6);
			}
			if (add==2)
			{
				screw=10;
            	translate([0,0,-screw+7])
					cylinder(d=8,h=0.4);
			}
        }
}
    //
module Bottom_Box() 
{
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
						intersection() 
						{
							Box();
							translate([10+4,7+4,1.25]) 
								cube([300,100+8,50+height_add*2],center=true);
						}
						for(i=bottom_screws) 
							translate(i) 
							translate([0,0,-6.5]) 
								cylinder(d=10,h=4-1,center=false);
					}
					
					for(i=bottom_screws) 
						translate(i) 
						translate([0,0,-5]) 
							cylinder(d=5.4,h=10,center=true);
				}
				
				translate([62.5-53.5+5,45-38,5+height_add]) 
				for(i=[68-cut.x,-60-cut.z]) 
				{
					translate([i,48.75-cut.y,25]) rotate([90,0,0]) 
					difference() 
					{
						union() 
						{
							rotate([0,0,30]) cylinder(d=9+0.65,h=7.5,$fn=6,center=true);
							translate([0,-6,-0.5]) cube([8.3571,12,8.5],center=true);
						}
						
						translate([0,0,1.15]) 
						hull()
						{
							rotate([0,0,30]) cylinder(d=6.8,h=3.6,$fn=6,center=true);
							translate([0,5,0]) rotate([0,0,30]) cylinder(d=6.8,h=3.6,$fn=6,center=true);
						}
						cylinder(d=2.9,h=10,center=true);
						translate([0,1.25,-3.9]) cube([10,10,4],center=true);
						translate([0,-12,3]) rotate([45,0,0]) cube([9,15,11],center=true);
						
					}
					translate([i,-40.75,25]) rotate([90,0,180]) 
					difference() {
						union() {
							rotate([0,0,30]) cylinder(d=9+0.65,h=7.5,$fn=6,center=true);
							translate([0,-6,-0.5]) cube([8.3571,12,8.5],center=true);
						}
						
						translate([0,0,1.15]) hull(){ //M3 nuts??
							rotate([0,0,30]) cylinder(d=6.8,h=3.6,$fn=6,center=true);
							translate([0,5,0]) rotate([0,0,30]) cylinder(d=6.8,h=3.6,$fn=6,center=true);
						}
						cylinder(d=2.9,h=10,center=true);
						translate([0,1.25,-3.9]) cube([10,10,4],center=true);
						translate([0,-12,3]) rotate([45,0,0]) cube([9,15,11],center=true);
					}
				}
			
				for (x=[0:2:4])
					translate ([10-x*20,41,-5-0.01])
					difference()
					{
						cube ([18,4,4]);	
						translate ([2,-1,0])
							cube ([14,6,2]);	
					}
				
				plate_out=0;
				translate([plate_out,0,0])
				{
					ard_mount();
					difference()
					{
						hull() 
						{
							translate([46+5.5,0,2.25]) rotate([90,0,0]) cylinder(d=2.5,h=20,center=true);
							translate([46+5,0,-5.5]) cube([8,20,1],center=true);
							translate([46+4,0,-1]) cube([1,20,8],center=true);
						}
						translate([46,0,0.75]) cube([10,22,2],center=true);
					}
					translate([46+3.35,0,0.75]) cube([0.8,20,2-0.3],center=true);
				}
			}
			ard_mount(add=1);
		}
		ard_mount(add=2);
	}
}

module fFace_screen_screw(add=false)
{
	yy=30.5;
	zz=28.7;
	for (z=[-1,1])
	for (y=[-1,1])
		translate ([0,y*yy/2,z*zz/2])
		rotate ([0,90,0])
		{
			if (add)
				translate ([0,0,6.5-1.5-0.4])
					cylinder(d=6,h=3);
			else
				cylinder(d=3.4,h=18);
		}
	if (!add)
		for (z=[-1,1])
		translate ([2,0,15*z])
			cube ([10,18,6],true);
}

module fFace() 
{
	screen_tr=[-60,28,34];
	screen_dim=[18,30,15];
	screen_zoffs=2;
	difference() 
	{
		union()
		{
			boitier(1.5,-1.2);
			translate(screen_tr) 
				fFace_screen_screw(add=true);
		}
		translate(screen_tr) 
		{
			translate ([0,0,screen_zoffs])
				cube(screen_dim,true);
			translate([-2.5,0,0])
				cube([screen_dim.x,screen_dim.y+20,screen_dim.z+9.4],true);
			
			cut=3;
			cutx=5.8;
			translate ([0,0,screen_zoffs])
			sequental_hull()
			{
				cube([0.1,screen_dim.y,screen_dim.z],true);
				translate ([cutx,0,0])
					cube([0.1,screen_dim.y,screen_dim.z],true);
				translate ([cutx+cut,0,0])
					cube([0.1,screen_dim.y+cut*2,screen_dim.z+cut*2],true);
			}
			fFace_screen_screw();
		}
	}
}

module fBack()
{
	intersection()
	{
		difference() 
		{
			boitier(1.5,-1.2);
			
			translate([-50,11,-24+24]) 
				cube([18,62,40],center=true);
	
			translate ([-60,-24,40])
			rotate ([0,90,0])
				cylinder (d=8,h=10,$fn=100);
		}
		translate ([-5,0,0])
        	boitier(1.5+10,-1.2);
	}
}

module slot_stand()
{
	w=90;
	th=4;
	up=30;
	x=60;
	translate ([0,0,-6-th])
	difference ()
	{
		union()
		{
			translate ([69-40,-34,0])
			{
				fillet(r=8,steps=16)
				{
					dim=[40,w,th];
					//cube (dim);
					linear_extrude(dim.z)
						polygon(polyRound([
							 [0,0,4]
							,[dim.x,0,4]
							,[dim.x,dim.y,4]
							,[0,dim.y,4]
						],1));
					translate ([0,x,-up])
						cube ([40,th,up]);
				}
				fillet(r=8,steps=16)
				{
					translate ([0,x,-up])
						cube ([40,th,up]);
					dim=[40,w-x,th];
					translate ([0,x,-up])
					linear_extrude(dim.z)
						polygon(polyRound([
							 [0,0,4]
							,[dim.x,0,4]
							,[dim.x,dim.y,4]
							,[0,dim.y,4]
						],1));
				}
			}
			for(i=bottom_screws) 
				translate(i) 
				translate([0,0,-m5_nut_H()+2]) 
				hull()
				{
					nut(G=m5_nut_G()+2,H=m5_nut_H());
					translate ([0,0,m5_nut_H()])
						nut(G=m5_nut_G()+6,H=0.1);
				}
		}
		for(i=bottom_screws) 
			translate(i) 
			translate([0,0,-m5_nut_H()+2-0.01]) 
			{
				nut(G=m5_nut_G(),H=m5_nut_H());
				translate ([0,0,-80])
					cylinder (d=m5_screw_diameter(),h=100,$fn=60);
			}
	}
}



//

/*
intersection()
{
	fFace();
	translate ([-60,14,34])
		cube ([30,40,38],true);
}
*/

//fFace();
//fBack();
//Top_Box();
//Box();

//Bottom_Box();
slot_stand();

//rotate([-90,0,0]); Bouton_reset();

