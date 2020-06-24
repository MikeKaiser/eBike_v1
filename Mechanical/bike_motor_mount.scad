radialFudge = 0.4; // Compensate fo plastic squidge around holes with critical radii
motorRadius = 30;
motorLen = 66;
motorPlateRadius = 70 / 2; // minimum plate radius
motorPlateExtra = 15;
motorCornerRoundingRadius = 15;
armLenAdjust = 50;
armLen = armLenAdjust + motorRadius;
armThick = 11;
extraPivotMeat = 40;
bracketThickness 	= 60;
bracketLen 			= 80;// See file://Measurements.pdn
seatPostMinHeight	= -80;
seatPostMaxHeight	= 72;
bracketTubeOffset 	= (seatPostMaxHeight + seatPostMinHeight) / 2;	// given the top and bottom of the seatpost mounts are asymetric, this shifts it up or down by the right amount
seatPostRadius 		= (27.1+radialFudge) / 2;
seatPostMeat 		= 20;
seatPostClearance	= 30;		// the mount to offset the seatpost cutout so it clears the seat-height adjustment knob
downTubeRadius 		= (32+radialFudge) / 2;
motorToBracketClearance = 50.0 * 2 - 10;
boltHoleRadius = 3.1;
boltHeadRadius = 8;
seatPostSquareOffRadius = 10;
seatPostSquareOffChamfer = 3; // purely cosmetic little detail
limitPinDiameter = 10;
pivotBoltMaxDiameter = 20;


module bearing( hei, rIn, rOut, withHole )
{
	difference()
	{
		cylinder(r=rOut,h=hei, $fn=120);
		if( withHole )
			translate([0,0,-1])	cylinder(r=rIn,h=hei+2, $fn=60);
	}
}

module bearing10mm( withHole )
{
	bearing( 5, 10.2/2, 19.2/2, withHole );
}

module shaft10mm( len )
{
	cylinder(r=5.1,h=len, $fn=120);
}

module shaft10mmOversize( len ) // this creates the lip that the two bearings rest on
{
	cylinder(r=(19-2)/2,h=len, $fn=120);
}

module shaft25mm( len )
{
	cylinder(r=12.5,h=len, $fn=120);
}

module LimitPin()
{
	translate([-32, -15, -500])
	cylinder(d=limitPinDiameter+(radialFudge*2),h=1000,$fn=60);
}

module LimitPinSweep()
{
	// Simulate the motor swing back
	for( angle=[0:0.5:20] )
	{
		rotate([0,0,angle]) LimitPin();
	}
}

module LimitLockingBlock( direction )
{
	pivotRadius = (19 + extraPivotMeat) / 2;
	difference()
	{
		hull()
		{
			blockOuterRadius = pivotRadius + (limitPinDiameter) + (radialFudge*2);
			cylinder( r=pivotRadius, h=armThick*2, $fn=240 );
			//for( angle=[10:-10:-30] ) <- this locks up OpenSCAD
			{
				rotate([0,0,10]) translate([-blockOuterRadius,0,0]) cylinder( r=2, h=armThick*2, $fn=240 );
				rotate([0,0,0]) translate([-blockOuterRadius,0,0]) cylinder( r=2, h=armThick*2, $fn=240 );
				rotate([0,0,-10]) translate([-blockOuterRadius,0,0]) cylinder( r=2, h=armThick*2, $fn=240 );
				rotate([0,0,-20]) translate([-blockOuterRadius,0,0]) cylinder( r=2, h=armThick*2, $fn=240 );
				rotate([0,0,-30]) translate([-blockOuterRadius,0,0]) cylinder( r=2, h=armThick*2, $fn=240 );
			}
		}
		LimitPinSweep();
		translate([0,0,-10*direction]) cylinder( r=pivotRadius + 2, h=armThick+10, $fn=240 );
		translate([0,0,-10]) cylinder( d=pivotBoltMaxDiameter, h=armThick*5, $fn=240 );
	}
}

module SmallArm()
{
	difference()
	{
		rotate([0,0,-90])
		{
			difference()
			{
				union()
				{
					// Pivot End
					pivotRadius = (19 + extraPivotMeat) / 2;
					cylinder( r=pivotRadius, h=armThick, $fn=240 );
					
					// Arm
					translate([0,armLen,0]) cylinder( r=pivotRadius, h=armThick, $fn=240 );
					
					// Motor End
					translate([-pivotRadius,0,0]) cube([pivotRadius*2,armLen,armThick]);
				}
				
				//Pivot attachment point
				translate([0,0,-0.1]) shaft10mmOversize( 20 ); // this creates the lip that the two bearings rest on
				translate([0,0,-0.1]) bearing10mm( false );
				translate([0,0,6+0.1]) bearing10mm( false );

				// Motor attachment point
				translate([0,armLen,-0.1]) shaft10mmOversize( 20 );
				translate([0,armLen,-0.1]) bearing10mm( false );
				translate([0,armLen,6+0.1]) bearing10mm( false );
			}
		}
		LimitPinSweep();
	}
}

module BigArm()
{
	difference()
	{
		rotate([0,0,-90])
		difference()
		{
			hull()
			{
				// Pivot End
				pivotRadius = (19 + extraPivotMeat) / 2;
				cylinder( r=pivotRadius, h=armThick, $fn=240 );
				translate([0,armLen,0]) cylinder( r=pivotRadius, h=armThick, $fn=240 );


				// Motor End
				motorMountRadius = motorPlateRadius + motorPlateExtra - motorCornerRoundingRadius;
				for(angle=[45:90:360])
				{
					translate([0,armLen,0])
						rotate([0,0,angle])
							translate([motorMountRadius,0,0])
								cylinder(r=motorCornerRoundingRadius,h=armThick,$fn=60);
				}
			
			}
			
			//Pivot attachment point
			translate([0,0,-0.1]) shaft10mmOversize( 20 );
			translate([0,0,-0.1]) bearing10mm( false );
			translate([0,0,6+0.1]) bearing10mm( false );

			// Motor attachment point
			translate([0,armLen,-0.1]) shaft25mm( 20 );
			for(angle=[45:90:360])
			{
				translate([0,armLen,0])
					rotate([0,0,angle])
						translate([motorPlateRadius,0,-0.1])
							cylinder(r=1.5,h=20,$fn=60);
			}
		}
		LimitPinSweep();
	}
}


module Motor( radiusAdd )
{
	cylinder( r=motorRadius + radiusAdd, h=66, $fn=120 );
}


module BoltPin( boltRadius, headRadius, fixingLength )
{
	translate([0,0,-fixingLength/2])
	union()
	{
		translate([0,0,-60])
			cylinder(r=boltRadius,h=240,$fn=60);
		
		difference()
		{
			translate([0,0,-60]) cylinder(r=headRadius,h=240,$fn=60);
			translate([0,0,fixingLength/2]) cube([headRadius*2, headRadius*2, fixingLength], center=true);
		}
	}
}


module MountingBracket()
{
	difference()
	{
		hull()
		{
			// motor mount
			cylinder(r=motorToBracketClearance/4,h=motorLen,$fn=240);
			translate([0,0,motorLen*1/10]) cylinder(r=motorToBracketClearance/2,h=motorLen*4/5,$fn=240);

			// top meat
			translate([-80+5, 0, motorLen/4]) cylinder(r=5,h=motorLen/2,$fn=240);
			
			// Seat post Mount
			translate([seatPostMinHeight,-bracketLen,motorLen/2]) rotate([0,90,0]) cylinder(r=seatPostRadius + seatPostMeat,h=1,$fn=160);
			translate([seatPostMaxHeight,-bracketLen,motorLen/2]) rotate([0,90,0]) cylinder(r=seatPostRadius + seatPostMeat,h=1,$fn=160);
			
			// Square off the leading edge of the seat post mount so the bolt heads don't stick out
			yOffset = -bracketLen-seatPostMeat-seatPostRadius+seatPostSquareOffRadius+seatPostSquareOffChamfer;
			translate([seatPostMinHeight,yOffset,0+seatPostSquareOffRadius]) rotate([0,90,0]) cylinder(r=seatPostSquareOffRadius,h=1,$fn=160);
			translate([seatPostMaxHeight,yOffset,0+seatPostSquareOffRadius]) rotate([0,90,0]) cylinder(r=seatPostSquareOffRadius,h=1,$fn=160);
			translate([seatPostMinHeight,yOffset,motorLen-seatPostSquareOffRadius]) rotate([0,90,0]) cylinder(r=seatPostSquareOffRadius,h=1,$fn=160);
			translate([seatPostMaxHeight,yOffset,motorLen-seatPostSquareOffRadius]) rotate([0,90,0]) cylinder(r=seatPostSquareOffRadius,h=1,$fn=160);
		}

		// Motor Pivot Shaft
		translate([0,0,-60]) cylinder(r=10.1/2,h=240,$fn=60);


		// Seat Post
		translate([+0.1,-bracketLen,motorLen/2]) rotate([0,-90,0]) cylinder(r=seatPostRadius,h=1000,$fn=60);

		// Down Tube (the bit the seat post fits into)
		translate([-0.1,-bracketLen,motorLen/2]) rotate([0,90,0]) cylinder(r=downTubeRadius,h=1000,$fn=60);

		
		// Seat post quick release cut out
		hull()
		{
			radius = 5;
			translate([  0-radius,  -45, -10]) cylinder(r=5,h=120,$fn=30);
			translate([  0-radius, -200, -10]) cylinder(r=5,h=120,$fn=30);
			translate([-50+radius,  -45, -10]) cylinder(r=5,h=120,$fn=30);
			translate([-50+radius, -200, -10]) cylinder(r=5,h=120,$fn=30);
		}

		// Seat post cross brace cut out
		hull()
		{
			radius = 5;
			translate([  0-radius,  -80, -10]) cylinder(r=5,h=120,$fn=30);
			translate([  0-radius, -200, -10]) cylinder(r=5,h=120,$fn=30);
			translate([ 37-radius,  -80, -10]) cylinder(r=5,h=120,$fn=30);
			translate([ 37-radius, -200, -10]) cylinder(r=5,h=120,$fn=30);
		}


		// Simulate the motor swing back
		for( angle=[-60:-0.5:-95] )
		{
			rotate([0,0,angle]) translate([0,armLen,0]) Motor(5);
		}


		// Bolt Holes
		translate([seatPostMaxHeight-15,-bracketLen-downTubeRadius-boltHoleRadius,motorLen/2]) BoltPin( boltHoleRadius, boltHeadRadius, motorLen-10 );
		translate([seatPostMaxHeight-15,-bracketLen+downTubeRadius+boltHoleRadius,motorLen/2]) BoltPin( boltHoleRadius, boltHeadRadius, motorLen-10 );
		translate([seatPostMinHeight+15,-bracketLen-downTubeRadius-boltHoleRadius,motorLen/2]) BoltPin( boltHoleRadius, boltHeadRadius, motorLen-10 );
		translate([seatPostMinHeight+15,-bracketLen+downTubeRadius+boltHoleRadius,motorLen/2]) BoltPin( boltHoleRadius, boltHeadRadius, motorLen-10 );
		translate([seatPostMaxHeight-55,-bracketLen+downTubeRadius+boltHoleRadius,motorLen/2]) BoltPin( boltHoleRadius, boltHeadRadius, motorLen-10 );
		translate([seatPostMinHeight+15,-6,motorLen/2]) BoltPin( boltHoleRadius, boltHeadRadius, motorLen-30 );
		
		LimitPin();
	}
}





if(1)
{
	translate([0,0,motorLen]) SmallArm();
	translate([0,0,-armThick]) BigArm();
	translate([armLen,0,0]) Motor( 0 );
}

if(1)
{
	MountingBracket();
}

if(0)
{
// Half Mounting Bracket
	difference()
	{
		MountingBracket();
		cube([1000, 1000, motorLen], center=true);
	}
}

translate([0,0,motorLen + armThick]) LimitLockingBlock(1);

translate([0,0,-armThick*3]) LimitLockingBlock(-1);
