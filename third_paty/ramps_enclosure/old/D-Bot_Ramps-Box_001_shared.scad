/// Designed by 1sPiRe ///
///   https://www.thingiverse.com/1sPiRe   ///

use <../../../_utils_v2/sequental_hull.scad>
use <../../../_utils_v2/m3-m8.scad>

$fn=80;

cut=[22,0,30];
height_add=20;

module boitier(a,b) 
{
    hull() 
	{
    	translate([-53.5,-38-b,5-b]) 
			cube([a,98+2*b-cut.y,30+height_add+2*b]);
    	translate([-53.5,-38+10-b,-5-b]) 
			cube([a,98-20+2*b-cut.y,30+20+height_add+2*b]);
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
					boitier(125+21+cut.z-cut.x,1.5+0.5);
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
        }
        
        translate([-16,-33.5,19.5]) 
		rotate([90,0,0]) 
			cylinder(d=6,h=7);
        
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
			cube([300,108,50+height_add*2],center=true);
    }
}

//Bottom_Box
    //Arduino screws
    module ard_mount() 
	{
		last_out=0;
        translate([-35.55-last_out,24.25,0]) 
		{
            union() {
                translate([0,0,-5]) cylinder(d1=7,d2=5,h=5);
                cylinder(d=2.8,h=6,center=true);
            }
        }
        translate([-36.85-last_out,-24.25,0]) 
		{
            cylinder(d=2.8,h=6,center=true);
            translate([0,0,-5]) cylinder(d1=7,d2=5,h=5);
        }
        translate([39.35,24.25,0]) 
		{
            cylinder(d=2.8,h=6,center=true);
            translate([0,0,-5]) cylinder(d1=7,d2=5,h=5);
        }
        translate([44.65,-24.25,0]) 
		{
            union() {
                translate([0,0,-5]) cylinder(d1=7,d2=5,h=5);
                cylinder(d=2.8,h=6,center=true);
            }
        }

    }
    //
module Bottom_Box() 
{
	screws=[[58,-20,0],[58,33+10,0],[58-20,33+10,0]];
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
			for(i=screws) 
				translate(i) 
				translate([0,0,-6.5]) 
					cylinder(d=10,h=4-1,center=false);
			
			/*
			translate ([0,-45.6-2,11.6])
			{
				th=6;
				cut=9;
				dim=[20,th,30];
				//cube (dim);
				rotate ([90,0,90])
				linear_extrude(dim.x)
				polygon([
					 [0,0]
					,[cut,-cut]
					,[cut+th,-cut]
					,[dim.y,0]
					,[dim.y,dim.z]
					,[0,dim.z]
				]);
			}
			*/
        }
        
        for(i=screws) 
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

	for (x=[0:4])
	translate ([10-x*20,41,-5-0.01])
	difference()
	{
		cube ([18,4,4]);	
		translate ([2,-1,0])
			cube ([14,6,2]);	
	}
    
    plate_out=0;
    //Arduino fix
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

module fFace_screen_screw(add=false)
{
	yy=31.5-1;
	zz=29.7-1;
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
	screen_tr=[-60,13+15,34];
	screen_dim=[18,30,15];
	offs=[2,14];
	screenborder_dim=[2,screen_dim.y+offs.x*2,screen_dim.z+offs.y*2];
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
			cube(screen_dim,true);
			translate([-2.5,0,0])
				cube([screen_dim.x,screen_dim.y+20,screen_dim.z+9.4],true);
			
			cut=3;
			cutx=5.8;
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



//

/*
intersection()
{
	fFace();
	translate ([-60,14,34])
		cube ([30,40,38],true);
}
*/

fFace();
//fFace_lock();
//fBack();
//Top_Box();
//Bottom_Box();

//rotate([-90,0,0]); Bouton_reset();

