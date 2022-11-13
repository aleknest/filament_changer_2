function nema17_dim() =42.3+0.2;

module proto_optical_switch()
{
	color ("#FF4400")
	{
		translate([-3.45,0,-12.1])
			import ("proto/optical_switch.stl");
	}
}

module proto_nema17()
{
	color ("#8888ff")
	rotate ([0,180,0])
	translate ([-nema17_dim()/2,-nema17_dim()/2,-24])
		import ("proto/nema17.stl");	
}

module proto_nema17_pulley_GT2T16()
{
	color ("#AAAAff")
	translate ([0,0,8])
	rotate ([0,-90,0])
		import ("proto/gt2_16t_nema.stl");	
}

module proto_mk8gear()
{
	color ("#5577FF")
	rotate ([90,0,0])
		import ("proto/mk8_gear_hole.stl");
}

