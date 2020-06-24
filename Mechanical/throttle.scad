handleBarDiameter = 28;
handleBarOuterDiameter = 45;
throttleMaxWidth = 25;
throttleMaxLengthFromHandleBar = 50;
throttleMaxHeightAboveHandleBar = 18;
roundedCornerRadius = 3;
joystickWidth = 20;
joystickLength = 16.5;
joystickHeight = 15.5;
meat = 5.0;
vmeat = 2.0;

module RoundedRect( dist )
{
	hull()
	{
		translate([dist,throttleMaxWidth/2-roundedCornerRadius,roundedCornerRadius]) sphere(roundedCornerRadius,$fn=60);
		translate([dist,-(throttleMaxWidth/2-roundedCornerRadius),roundedCornerRadius]) sphere(roundedCornerRadius,$fn=60);
		translate([dist,throttleMaxWidth/2-roundedCornerRadius,throttleMaxHeightAboveHandleBar-roundedCornerRadius]) sphere(roundedCornerRadius,$fn=60);
		translate([dist,-(throttleMaxWidth/2-roundedCornerRadius),throttleMaxHeightAboveHandleBar-roundedCornerRadius]) sphere(roundedCornerRadius,$fn=60);
	}
}

difference()
{
union()
{

		hull()
		{
			RoundedRect( handleBarOuterDiameter/2 );
			rotate([90,0,0])
			rotate_extrude(angle=360,convexity=10,$fn=100)
			{
				radius = (handleBarOuterDiameter-handleBarDiameter)/2;
				yoffset = (throttleMaxWidth/2) - radius;

				translate([((handleBarOuterDiameter/2)-radius),yoffset,0])
				circle(radius, $fn=60);

				translate([((handleBarOuterDiameter/2)-radius),-yoffset,0])
				circle(radius, $fn=60);

				translate([((handleBarOuterDiameter/2)-radius),0,0])
				square([radius*2,yoffset*2], true);
			}
		}


	hull()
	{
		RoundedRect( handleBarOuterDiameter/2 );
		RoundedRect( throttleMaxLengthFromHandleBar-roundedCornerRadius );
	}
}

	// subtract handle bar
	translate([0,1000,0])
	rotate([90,0,0])
	cylinder(d=handleBarDiameter,h=2000, $fn=100);

	// Joystick
	translate([throttleMaxLengthFromHandleBar - joystickLength/2 - meat,0,joystickHeight/2+vmeat])
	union()
	{
		cube([joystickLength, joystickWidth, joystickHeight], center=true);
		translate([0,0,-5])
		cube([joystickLength, 3, joystickHeight], center=true);
	}

	// Access Hatch
	translate([-500, -500, 17.1])
	cube([1000, 1000, 1000]);
}

