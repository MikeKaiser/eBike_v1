seatPostRadius = 27;
boltDiameter = 5 + 0.4;
spacerDiameter = 18;

difference()
{
cylinder(h=seatPostRadius, d=spacerDiameter, $fn = 120);
translate([0,0,-10]) cylinder(h=seatPostRadius + 20, d=boltDiameter, $fn = 60);
}
