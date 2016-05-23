#perl
# Quick Align UVs
# Version 1.01
# Author: James O'Hare - http://www.hull-breach.com/Talon

# It's a script that will align the UV island(s) of 1
# selected UV edge or any 2 selected UV verts with the nearest axis*

# It's a companion for modo's default "Orient UVs" tool, which isn't
# always perfect, especially on organic shapes.

# Instructions;
# - Ensure you are in the UV viewport.
# - Select the edge or any two vertices you want to align their islands to.
# - Run the script.

#*If you only want to align only the selected verts or edge
# (i.e. not their entire island) then add the argument "notisland" to the shortcut.
# e.g. @quickAlignUVs.pl notisland

# Thanks to Seneca Menard and Kim DongJoo for their excellent script examples.

# Ensure UV viewport is the active one.

$viewport = lxq("query view3dservice view.type ? selected");
if ($viewport eq "UV2D") {

	if (lxq("select.typeFrom {edge;polygon;item;vertex} ?")) {
		if (lxq("query layerservice edge.N ? selected") == 1) {
			lx("select.convert vertex");
			lx("select.drop edge");
			lx("select.typeFrom vertex;edge;polygon;item;pivot;center;ptag 1");
			$valid = "edge";
		}
	}
	elsif (lxq("select.typeFrom {vertex;edge;polygon;item} ?"))
	{
			# There's no real easy validation of how many verts you have selected
			# as one vertex could be many vertices in the UV map. Just use your
			# common sense and, you'll be fine.
			$valid = "vertex";
	}

	if (($valid eq "vertex") || ($valid eq "edge")) {

		@UVVertList = lxq("query layerservice uvs ? selected");
		@UVPosList1 = lxq("query layerservice uv.pos ? @UVVertList[0]");
		
		foreach $UVVert (@UVVertList) {
			@UVPosListTemp = lxq("query layerservice uv.pos ? $UVVert");
			if ((@UVPosListTemp[0] != @UVPosList1[0]) || (@UVPosListTemp[1] != @UVPosList1[1])) {
				#lxout("Pair found!");
				@UVPosList2 = @UVPosListTemp;
				last;
			}
			#else
			#{
				#lxout("No pair found!");
			#}
		}

		if (@UVPosList2[0]) {

			# Get the difference between the two coords' U and V then use trig to work out the angle they're offset to.
			$diffU = @UVPosList1[0] - @UVPosList2[0];
			$diffV = @UVPosList1[1] - @UVPosList2[1];

			# Get the average position of the two verts to use as the action centre.
			$centreU = (@UVPosList1[0] + @UVPosList2[0]) / 2;
			$centreV = (@UVPosList1[1] + @UVPosList2[1]) / 2;
			
			# Trig stuff from Seneca's script example.
			$angle = atan2($diffU,$diffV);
			$pi = 4 * atan2(1, 1);
			$angle = ($angle*180)/$pi;
			
			#Fix angle needs to be the shallowest angle to the nearest axis.
			if (($angle == 0) || ($angle == 90) || ($angle == -90) || ($angle == -180)) {
				#lxout("Angle is aligned already.");
			}
			elsif (($angle > 0) && ($angle < 45)) {
				$fixangle = $angle * -1;
				#lxout("Angle is 0 & 45: ".$angle);
			}
			elsif ($angle == 45) {
				$fixangle = -45;
				#lxout("Angle is 45: ".$angle);
			}
			elsif (($angle > 45) && ($angle < 90)) {
				$fixangle = 90 - $angle;
				#lxout("Angle is 45 & 90: ".$angle);
			}
			elsif (($angle > 90) && ($angle < 135)) {
				$fixangle = ($angle - 90) * -1;
				#lxout("Angle is 90 & 135: ".$angle);
			}
			elsif ($angle == 135) {
				$fixangle = 45;
				#lxout("Angle is 135: ".$angle);
			}
			elsif (($angle > 135) && ($angle < 180)) {
				$fixangle = 180 - $angle;
				#lxout("Angle is 135 & 180: ".$angle);
			}
			elsif (($angle < 0) && ($angle > -45)) {
				$fixangle = $angle * -1;
				#lxout("Angle is 0 & -45: ".$angle);
			}
			elsif ($angle == -45) {
				$fixangle = 45;
				#lxout("Angle is -45: ".$angle);
			}
			elsif (($angle < -45) && ($angle > -90)) {
				$fixangle = -90 + ($angle * -1);
				#lxout("Angle is -45 & -90: ".$angle);
			}
			elsif (($angle < -90) && ($angle > -135)) {
				$fixangle = ($angle + 90) * -1;
				#lxout("Angle is -90 & -135: ".$angle);
			}
			elsif ($angle == -135) {
				$fixangle = -45;
				#lxout("Angle is -135: ".$angle);
			}
			elsif (($angle < -135) && ($angle > -180)) {
				$fixangle = -180 + ($angle * -1);
				#lxout("Angle is -135 & -180: ".$angle);
			}
			#else
			#{
				#lxout("Angle is : ".$angle);
				#lxout("But isn't getting caught.");
			#}
			
			if ($fixangle) {
				$fixangle = $fixangle * -1;
				#lxout("Fixangle: ".$fixangle);
				if (@ARGV[0] ne "notisland") {
					lx("select.vertexConnect uv");
				}
				lx("tool.set Transform on");
				lx("tool.set actr.auto on 0");
				lx("tool.setAttr center.auto cenU ".$centreU);
				lx("tool.setAttr center.auto cenV ".$centreV);
				lx("tool.setAttr xfrm.transform RX 0.0");
				lx("tool.setAttr xfrm.transform RY 0.0");
				lx("tool.setAttr xfrm.transform RZ ".$fixangle);
				lx("tool.doApply");
				lx("tool.set Transform off");
			}
			else
			{
				lxout("For some reason, I can't resolve an angle.");
			}

		}
		else
		{
			lxout("Couldn't get a second UV coord, looks like you've only got one UV vert selected.");
		}

    lx("select.drop vertex");
		# Can't restore the original UV selection so having to just drop selection altogether.
		lx("select.drop ".$valid);
		
	}
	else
	{
		lxout("Please select only one edge.");
	}
}