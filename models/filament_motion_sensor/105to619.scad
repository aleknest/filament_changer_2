mr105zz=[10,5,3];
b619_5zz=[13,5,4];

difference()
{
	union()
	{
		dd=b619_5zz.x-0.2;
		cylinder (d=dd,h=b619_5zz.z,$fn=80);
	}
	translate ([0,0,-0.01])
	{
		cylinder (d=mr105zz.x-2,h=b619_5zz.z+0.02,$fn=80);
	}
	
	translate ([0,0,-0.01])
	{
		cut=0.6;
		dd=mr105zz.x+0.2;
		hh=mr105zz.z+0.1+0.5;
		union()
		{
			cylinder (d=dd,h=hh,$fn=80);
			cylinder (d1=dd+cut,d2=dd,h=cut,$fn=80);
		}
	}
}