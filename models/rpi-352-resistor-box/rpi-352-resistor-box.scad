w=16;
l=28.2+1;//+1 чтобы стопудов налазило
h=7;
th=1.2;

module bottom()
{
	difference()
	{
		translate ([-th,-th,-th])
			cube ([w+th*2,l+th*2,h+th]);
		cube ([w,l,h+1]);
		translate ([w/2,l/2,-th-0.1])
			cylinder (d=3.4,h=20,$fn=40);
	}
}
bottom ();
	