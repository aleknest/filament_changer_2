function pc4_01_D()=9.7;
function pc4_01_H()=6.7;

module pc4(long_ptfe=false)
{
	cm=1;
	translate ([0,0,-cm]) cylinder (d1=pc4_01_D(),d2=pc4_01_D()+cm*2,h=cm,$fn=60);
	translate ([0,0,-pc4_01_H()])
	{
		difference()
		{
			cylinder (d=pc4_01_D(),h=pc4_01_H()+0.1,$fn=60);
			
			rays=12*4;
			angle=360/rays;
			for (a=[0:angle:360])
				rotate ([0,0,a])
				translate ([pc4_01_D()/2,0,-1])
					cylinder (d=0.4+0.1,h=pc4_01_H()-1+0.8,$fn=16);
		}
		
		hull()
		{
			dd=6;
			translate ([0,2.9,0])
				cylinder (d=dd,h=pc4_01_H()+10,$fn=30);
			cylinder (d=dd,h=pc4_01_H()+10,$fn=30);
		}
		
		ptfe_d=4.2;
		ptfe_h=long_ptfe?6:3;
		cc=1;
		translate ([0,0,-cc])
			cylinder (d2=ptfe_d+cc*2,d1=ptfe_d,h=cc+0.01,$fn=50);
		translate ([0,0,-ptfe_h])
			cylinder (d=ptfe_d,h=ptfe_h+0.1,$fn=30);
	}
}

pc4(long_ptfe=true);