module Spacer( innerDia, outerDia, height )
{
	difference()
	{
		cylinder(h=height, d=outerDia, $fn=200);
		translate([0,0,-1]) cylinder(h=height+2, d=innerDia, $fn=200);
	}
}

Spacer( 10.5, 30, 1 );
translate([35, 0, 0]) Spacer( 10.5, 30, 2 );
translate([70, 0, 0]) Spacer( 10.5, 30, 4 );
