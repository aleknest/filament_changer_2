SS443A_width=4.1+0.16;
SS443A_thickness=1.6+0.06;
SS443A_front=2.5+0.1;
SS443A_front_angle=48;
SS443A_height=3.0+0.12;
SS443A_out=4;
function SS443A_hall()=1.7+0.07;
SS443A_front_out=4;
SS443A_offs=0.2;

sk=tan(SS443A_front_angle)*((SS443A_width-SS443A_front)/2);
function pointsm(SS443A_front_out=SS443A_front_out)=[
	 [SS443A_front/2,-SS443A_front_out]
	,[SS443A_front/2,0]
	,[SS443A_width/2,sk]
	,[SS443A_width/2,SS443A_thickness]
	,[-SS443A_width/2,SS443A_thickness]
	,[-SS443A_width/2,sk]
	,[-SS443A_front/2,0]
	,[-SS443A_front/2,-SS443A_front_out]
];

function pointsl()=[
	 [SS443A_width/2,sk]
	,[SS443A_width/2,SS443A_thickness]
	,[-SS443A_width/2,SS443A_thickness]
	,[-SS443A_width/2,sk]
];

module protoSS443A()
{
	color ("Violet")
	translate ([0.19,0,0])
	translate ([0,0,-SS443A_hall()/2])
	{
		linear_extrude(SS443A_height)
		offset (delta=SS443A_offs)
			polygon(pointsm(0));
		
		translate ([0,0,-SS443A_out+0.01])
		linear_extrude(SS443A_out)
			offset(delta=SS443A_offs) 
				polygon(pointsl());
	}
}

module SS443A(SS443A_out=SS443A_out,SS443A_yout=0,SS443A_yout_addthickness=0, wire_cut=[0,0])
{
	
	translate ([0.19,0,0])
	translate ([0,0,-SS443A_hall()/2])
	{
		linear_extrude(SS443A_height)
		offset (delta=SS443A_offs)
			polygon(pointsm());
		
		translate ([0,0,-SS443A_out+0.01])
		linear_extrude(SS443A_out)
			offset(delta=SS443A_offs) 
				polygon(pointsl());
		if (SS443A_yout>0)
		{
			w=SS443A_width+SS443A_offs*2;
			h=SS443A_thickness-sk+SS443A_offs*2+SS443A_yout_addthickness;
			out=SS443A_yout;
			translate ([-w/2
						,sk+(SS443A_thickness+SS443A_offs)/2-out
						,-SS443A_out-SS443A_yout_addthickness])
				cube([w,out,h]);
		}
		if (wire_cut!=[0,0])
		{
			w=SS443A_width+SS443A_offs*2;
			h=wire_cut[1];
			out=wire_cut[0];
			translate ([-w/2
						,sk+(SS443A_thickness+SS443A_offs)/2
						,-SS443A_out-SS443A_yout_addthickness])
				cube([w,out,h]);
		}
	}
}

//SS443A(SS443A_out=5,SS443A_yout=5,SS443A_yout_addthickness=4,wire_cut=[1,8]);

module SS443A_cut(dim,tr)
{
	translate (tr)
	translate ([0,-dim.y+SS443A_thickness+SS443A_offs,0])
		cube (dim);
}

module SS443A_cut2(dim,tr,in)
{
	translate (tr)
	translate ([0,-dim.y+SS443A_thickness+SS443A_offs,0])
	{
		cube (dim);
		translate ([0,0,-tr.z+SS443A_hall()+in.x])
			cube ([dim.x,dim.y+in.y,dim.z]);
		
		translate ([dim.x-in[2],0,0])
			cube ([in[2],dim.y+in.y,dim.z]);
	}
}

