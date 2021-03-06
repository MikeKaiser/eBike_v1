// With arms that are free to rotate, you really need a spring to push the motor against the wheel.
// This also means you need to have something that will prevent the motor from digging into the tyre
// and flipping the motor out to the other side where is can no longer produce a useful force.
// This is provided by the rotation stoppers.
// You also need to ensure that the angle between the arm holding the motor and the virtual line
// between the motor pivot and the hub of the wheel is less that 45 degrees.
// Less that 45 degrees has the effect that the motor will dig in a bite into the tyre harder automatically.
//   It tries to climb up the tyre resulting in more grip. This is why the rotation stoppers are needed.
// Greater than 45 degrees means the motor will just bounce off the surface of the tyre more.
//   It would then rely on a spring for creating the grip between the motor and the tyre.

// With locked arms, you are just relying on friction to keep the motor where it is.


lockedArms = 0; // 0 = arms that are free to rotate, 1 = arms that are bolted into place 
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
limitSplineHeight = 1;
limitSplineDepth = 1;
pivotPinDiameter = 10.1;
pivotBoltMaxDiameter = 20;
spacerThickness = 0.0; // sometimes, if the motor has to be mounted quite low on the seat post, the motor arm may interfere with the frame. This lets us push that out
escWidth = 45;
escLength = 100;
escHeight = 25;
escPowerSpacing = 14; // offset from the middle of the ESC
escMotorSpacing = 9;  // offset from the middle of the ESC






module LockingSplines( angleStepDegrees, angleOffset, innerRadius, outerRadius, height, invert )
{
	translate([0,0,invert==0?0:height+0.0])
	rotate([0,0,invert==0?0:angleStepDegrees/2])
	union()
	{
		// create a tooth that subtends half the angleStep
		circumferenceOuter = outerRadius * 2 * PI;
		circumferenceInner = innerRadius * 2 * PI;

		//echo(circumferenceOuter);

		toothWidthOuter = circumferenceOuter * (angleStepDegrees / 360) / 2; 
		toothWidthInner = circumferenceInner * (angleStepDegrees / 360) / 2; 

		//echo(toothWidthOuter);
	
		// The next two lines define the taper of the tooth
		// If the tooth with is 1 and we want to shrink it
		// by 2 (multiple by 0.5) then the corresponding negative space
		// will be wider than the positive space.
		// So we need to expand the root of each tooth but by how much?
		// Lets assume our tooth is 1 unit wide.
		// If we are shrinking the tip of the tooth by 0.5 then we're taking
		// 0.25 away from each side of the tip so we need to add 0.25 to each
		// side of the root to ensure the negative space is the same size.
		// This means the tip is 0.5 and the root is 1.5. The way the extrude
		// works, we can only scale in one direction so we have to artifically
		// increase the width of our tooth root so that the scale by 0.5 gets us
		// to the correct tip size.
		//
		// Naively we might think to set the tooth root size to 1.5 but as we can see
		// 1.5 * 0.5 = 0.75 which is not the tip size we want

		shrinkFudge = 0.5;
		expandFudge = 1 + 95/300;

		for( angle=[angleOffset:angleStepDegrees:360+angleOffset] )
		{
			rotate([0,0,angle])
			{
				// Again, because OpenSCAD is retarded, it cannot extrude in any direction other than the +ve Z axis
				// so we have to muck about here to get what we want.
				if( invert == 0 )
				{
					linear_extrude(height = height, scale=[shrinkFudge,1], slices = 100)	
					polygon( points=[[-toothWidthInner/2 * expandFudge,innerRadius],[ toothWidthInner/2 * expandFudge,innerRadius],
									[ toothWidthOuter/2 * expandFudge,outerRadius],[-toothWidthOuter/2 * expandFudge,outerRadius]] );
				}
				else
				{
					rotate([180,0,0])
					linear_extrude(height = height, scale=[shrinkFudge,1], slices = 100)	
					polygon( points=[[-toothWidthInner/2 * expandFudge,innerRadius],[ toothWidthInner/2 * expandFudge,innerRadius],
									[ toothWidthOuter/2 * expandFudge,outerRadius],[-toothWidthOuter/2 * expandFudge,outerRadius]] );
				}
			}
		}
	}
}

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

pivotRadius = (19 + extraPivotMeat) / 2;

function InvertBool( x ) = x != 0 ? 0 : 1;

module LimitLockingSplines( direction, invert )
{
	translate([0,0,-(limitSplineDepth+limitSplineHeight/2)+armThick])
	{
		LockingSplines(10, 0, pivotBoltMaxDiameter/2+3, pivotRadius-3, limitSplineHeight, direction == 1?InvertBool(invert):invert);
	}
}

module BigArmLockingSplines( invert )
{
	translate([0,0,-0.5])
	LockingSplines(10, 0, pivotBoltMaxDiameter/2+3, pivotRadius-3, 1, invert);
}


module LimitLockingBlock( direction )
{
	LimitLockingSplines( direction, 0 );
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

		LimitLockingSplines( direction, 1 );
	}
}



module PivotOuter(height)
{
	cylinder( r=pivotRadius, h=height, $fn=240 );
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
					PivotOuter(armThick);
					
					// Arm
					translate([0,armLen,0]) cylinder( r=pivotRadius, h=armThick, $fn=240 );
					
					// Motor End
					translate([-pivotRadius,0,0]) cube([pivotRadius*2,armLen,armThick]);
				}
				
				//Pivot attachment point	
				if( lockedArms == 0 )
				{
					translate([0,0,-0.1]) shaft10mmOversize( 20 ); // this creates the lip that the two bearings rest on
					translate([0,0,-0.1]) bearing10mm( false );
					translate([0,0,6+0.1]) bearing10mm( false );
				}
				else
				{
					translate([0,0,-500]) shaft10mm(1000);
				}

				// Motor attachment point
				translate([0,armLen,-0.1]) shaft10mmOversize( 20 );
				translate([0,armLen,-0.1]) bearing10mm( false );
				translate([0,armLen,6+0.1]) bearing10mm( false );
			}
		}
		LimitPinSweep();
	}
}


motorMountRadius = motorPlateRadius + motorPlateExtra - motorCornerRoundingRadius;

module MotorMounts( thickness, roundingRadius )
{
	for(angle=[45:90:360])
	{
		translate([0,armLen,0])
			rotate([0,0,angle])
				translate([motorMountRadius,0,0])
					cylinder(r=roundingRadius,h=thickness,$fn=60);
	}
}

module BigArm()
{
	difference()
	{
		rotate([0,0,-90])
		difference()
		{
			union()
			{
				hull()
				{
					// Pivot End
					PivotOuter(armThick);
					
					// Arm
					translate([0,armLen,0]) cylinder( r=pivotRadius, h=armThick, $fn=240 );


					// Motor End
					MotorMounts(armThick, motorCornerRoundingRadius);
				}
				
				// Pivot Spacer
				PivotOuter(armThick + spacerThickness);
				
				// Motor Spacer
				hull()
				{
					MotorMounts(armThick + spacerThickness, motorCornerRoundingRadius/3);
				}

				BigArmLockingSplines(1);
			}
			
			//Pivot attachment point
			if( lockedArms == 0 )
			{
				translate([0,0,-0.1]) shaft10mmOversize( 20 );
				translate([0,0,-0.1]) bearing10mm( false );
				translate([0,0,6+0.1+spacerThickness]) bearing10mm( false );
			}
			else
			{
				translate([0,0,-500]) shaft10mm(1000);
			}
			
			// Motor attachment point
			translate([0,armLen,-0.1]) shaft25mm( 20 );
			for(angle=[45:90:360])
			{
				translate([0,armLen,0])
					rotate([0,0,angle])
						translate([motorPlateRadius,0,-0.1])
							cylinder(r=1.5,h=20,$fn=60);
			}

			BigArmLockingSplines(0);
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
		union()
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
		}

		
		// Motor Pivot Shaft
		translate([0,0,-60]) cylinder(d=pivotPinDiameter,h=240,$fn=60);


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

module RoundedBox( x, y, z, r )
{
		hull()
		{
			translate([-x, -y, -z])sphere(r, $fn=50);
			translate([ x, -y, -z])sphere(r, $fn=50);
			translate([-x,  y, -z])sphere(r, $fn=50);
			translate([ x,  y, -z])sphere(r, $fn=50);
			translate([-x, -y,  z])sphere(r, $fn=50);
			translate([ x, -y,  z])sphere(r, $fn=50);
			translate([-x,  y,  z])sphere(r, $fn=50);
			translate([ x,  y,  z])sphere(r, $fn=50);
		}
}

module RoundedShell( irad, orad )
{
	echo( "OR:", orad, " IR:", irad );
	difference()
	{
		RoundedBox(escWidth/2, escLength/2, escHeight/2, orad);
		RoundedBox(escWidth/2, escLength/2, escHeight/2, irad);
	}
}

module ControllerBox( slice )
{
	outerRadius = 4;
	innerRadius = 2;
	middleRadius = (outerRadius + innerRadius) / 2;
	rimDepth = 0.5;
	halfRimDepth = rimDepth / 2;
	
	translate([-110,-bracketLen,escHeight/2])
	difference()
	{
		union()
		{
			// The Box
			difference()
			{
				RoundedBox(escWidth/2, escLength/2, escHeight/2, outerRadius);
				RoundedBox(escWidth/2, escLength/2, escHeight/2, innerRadius);
				
				
				if( slice == 0 )
				{
					translate([-500,-500,-halfRimDepth]) cube([1000,1000,1000]);
				}
				else
				{
					translate([-500,-500,-1000+halfRimDepth]) cube([1000,1000,1000]);
				}
			}
			
			// Locator rim around the edge
			// openscad is retarded. If I set new values to old variables inside an IF scope, the values are lost outside the IF scope!
			// Hence the slightly weird repetition of code here.
			if( slice == 0 )
			{
				orad = outerRadius;
				irad = middleRadius;
				difference()
				{
					RoundedShell( irad, orad );
					translate([-500,-500,+halfRimDepth]) cube([1000,1000,1000]);
				}
			}
			if( slice == 1 )
			{
				orad = middleRadius;
				irad = innerRadius;
				difference()
				{
					RoundedShell( irad, orad );
					translate([-500,-500,-1000-halfRimDepth]) cube([1000,1000,1000]);
				}
			}
		}
		// Motor lines
		translate([-escMotorSpacing, -escLength/2 + 50, 0]) rotate([90,0,0]) cylinder(h=100,d=5,$fn=60);
		translate([ escMotorSpacing, -escLength/2 + 50, 0]) rotate([90,0,0]) cylinder(h=100,d=5,$fn=60);
		translate([               0, -escLength/2 + 50, 0]) rotate([90,0,0]) cylinder(h=100,d=5,$fn=60);

		// Power + Data lines
		translate([-escPowerSpacing,  escLength/2 + 50, 0]) rotate([90,0,0]) cylinder(h=100,d=5,$fn=60);
		translate([ escPowerSpacing,  escLength/2 + 50, 0]) rotate([90,0,0]) cylinder(h=100,d=5,$fn=60);
		//translate([              0,  escLength/2 + 0, 0]) cube([10,10,3], center=true);
		translate([ 0,  escLength/2 + 50, 0]) rotate([90,0,0]) cylinder(h=100,d=5,$fn=60);
	}
}


// Arms
if(1)
{
	translate([0,0,motorLen]) SmallArm();
	translate([0,0,-armThick-spacerThickness]) BigArm();
}

// Motor
if(0)
{
	translate([armLen,0,0]) Motor( 0 );
}

if(0)
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

// Rotation stoppers
if(1)
{
	translate([0,0,motorLen + armThick]) LimitLockingBlock(1);

	translate([0,0,-armThick*3-spacerThickness]) LimitLockingBlock(-1);
}

// Speed Controller Box Top
if( 0 )
{
	ControllerBox(0);
}

// Speed Controller Box Bottom
if( 0 )
{
	translate([0,0,30]) ControllerBox(1);
}



