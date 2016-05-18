#perl
#AUTHOR: Seneca Menard
#version 2.36
#-POLY SELECTION MODE : it'll run poly.mirror (axis) command, which will mirror the selected geometry across that chosen axis.  You need to append the axis to the script, so if you want to mirror the geometry across the X axis, type  "@quickMirror.pl x"
#-EDGE OR VERT SELECTION MODE : It'll mirror the geometry along the angle the selected element(s) have defined.  You have to append the viewport axis you want to mirror from, so if you want to do a mirror from the top down viewport, type "@quickMirror.pl y"
#symmetry isn't supported yet..  I'll get around to adding that later....

#(11-29-06 feature) : The script now works even if you're in symmetry mode.
#(11-29-06 feature) : "dontMerge" : if you add that variable to the script, it'll NOT merge the verts when it does the mirror.  eg "quickMirror.pl noMerge"
#(11-29-06 feature) : "selectNew" : if you add that variable to the script, it'll select all the new polys you just created for you.  eg "quickMirror.pl selectNew"
#(8-1-08 bugfix) : I swapped the [] for {} so that the numbers would always be read as meters and then was able to remove my temp preference change that was previously there to fix that.
#(1-22-10 feature) : I've recently created the centeringTools.pl script, which allows you to store a position in space and then you can center or flatten geometry to that position.  What I also wanted was the ability to mirror across that arbitrary position as well, and that required a mod of this script.  So as of right now, if you run @centeringTools.pl setPos and define the fake origin position, your polys will now be mirrored across that position.  To reset it back to (0,0,0), run '@centeringTools.pl resetPos'
#(2-16-10 bugfix) : I found the poly.mirror command doesn't like arguments with no descriptors.
#(6-29-10 bugfix) : odd, the poly mirror's commands were renamed in 401, but they're renamed again in 401b3 or something and so i updated them
#(7-14-10 bugfix) : the poly mirror commands still weren't working for some reason, so i changed the syntax yet again.
#(12-28-10 bugfix) : modo5 changed the mirror tool syntax again and so script is changed AGAIN to accept that change.
#(1-24-11 bugfix) : modo5 sp1 changed the mirror tool syntax AGAIN.  this is getting really fucking annoying...
#(3-29-11 bugfix) : the help text up above listed the wrong cvar name.

my $mainlayer = lxq("query layerservice layers ? main");
my $modoVer = lxq("query platformservice appversion ?");
my $modoBuild = lxq("query platformservice appbuild ?");

#------------------------------------------------------------------------------------------------------------
#ARGS
#------------------------------------------------------------------------------------------------------------
foreach my $arg (@ARGV){
	if		($arg =~ /x/i)				{	our $mirrorAxis = 2;	our $axis = 0;	}
	elsif	($arg =~ /y/i)				{	our $mirrorAxis = 0;	our $axis = 1;	}
	elsif	($arg =~ /z/i)				{	our $mirrorAxis = 1;	our $axis = 2;	}
	elsif	($arg =~ /dontmerge/i)		{	our $noMerge = 1;						}
	elsif	($arg =~ /selectnew/i)		{	our $selectNew = 1;						}
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#--------------------------------------SAFETY CHECKS------------------------------------------
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------

#extra setup
userValueTools(sen_centeringToolsPos,string,temporary,"The fake origin position","","","",xxx,xxx,"","");

#WORKPLANE : Remember what the workplane was and turn it off
my @WPmem;
@WPmem[0] = lxq ("workPlane.edit cenX:? ");
@WPmem[1] = lxq ("workPlane.edit cenY:? ");
@WPmem[2] = lxq ("workPlane.edit cenZ:? ");
@WPmem[3] = lxq ("workPlane.edit rotX:? ");
@WPmem[4] = lxq ("workPlane.edit rotY:? ");
@WPmem[5] = lxq ("workPlane.edit rotZ:? ");
lx("!!workPlane.reset ");

#REFERENCE : set the main layer to be "reference" to get the true vert positions.
my $mainlayerID = lxq("query layerservice layer.id ? $mainlayer");
my $layerReference = lxq("layer.setReference ?");
lx("!!layer.setReference $mainlayerID");

#SYMMAXIS : convert the symm axis to my oldschool number
our $symmAxis = lxq("select.symmetryState ?");
if 		($symmAxis eq "none")	{	$symmAxis = 3;						}
elsif	($symmAxis eq "x")		{	$symmAxis = 0;						}
elsif	($symmAxis eq "y")		{	$symmAxis = 1;						}
elsif	($symmAxis eq "z")		{	$symmAxis = 2;						}
if		($symmAxis != 3)		{	lx("select.symmetryState none");	}








#------------------------------------------------------------------------------------------------------------
#VERT MODE
#------------------------------------------------------------------------------------------------------------
if(lxq("select.typeFrom {vertex;edge;polygon;item} ?") && lxq( "query layerservice vert.n ? selected")>0){
	my @verts = lxq("query layerservice verts ? selected");

	#[--------------------------------------------------------------------------------]
	#[--SYMM OFF---------------------------------------------------------------]
	#[--------------------------------------------------------------------------------]
	if ($symmAxis == 3){
		my @importantVerts = (@verts[0],@verts[-1]);
		&mirror(@importantVerts);
	}

	#[--------------------------------------------------------------------------------]
	#[--SYMM ON-----------------------------------------------------------------]
	#[--------------------------------------------------------------------------------]
	else{
		my @polys = lxq("query layerservice polys ? selected");
		my @polysPos;
		my @polysNeg;
		my @vertsPos;
		my @vertsNeg;
		our $symmRunCount=0;

		if (@polys == ""){
			lx("select.type polygon");
			lx("select.invert");
			@polys = lxq("query layerservice polys ? visible");
		}

		#split up the verts into two arrays.
		foreach my $vert (@verts){
			my @pos = lxq("query layerservice vert.pos ? $vert");
			if (@pos[$symmAxis] > 0){
				push(@vertsPos,$vert);
			}elsif (@pos[$symmAxis] < 0){
				push(@vertsNeg,$vert);
			}else{
				push(@vertsPos,$vert);
				push(@vertsNeg,$vert);
			}
		}

		#split up the polys into two arrays.
		foreach my $poly (@polys){
			my @pos = lxq("query layerservice poly.pos ? $poly");
			if (@pos[$symmAxis] >= 0){
				push(@polysPos,$poly);
			}else{
				push(@polysNeg,$poly);
			}
		}

		#run the script on each symm half
		if (@polysPos != ""){
			lxout("[->] Running script on POSITIVE symmetry polys");
			$symmRunCount++;

			lx("select.drop polygon");
			foreach my $poly (@polysPos){	lx("select.element $mainlayer polygon add $poly");	}
			my @importantVerts = (@vertsPos[0],@vertsPos[-1]);
			&mirror(@importantVerts);
		}
		if (@polysNeg != ""){
			lxout("[->] Running script on NEGATIVE symmetry polys");
			$symmRunCount++;

			lx("select.drop polygon");
			foreach my $poly (@polysNeg){	lx("select.element $mainlayer polygon add $poly");	}
			my @importantVerts = (@vertsNeg[0],@vertsNeg[-1]);
			&mirror(@importantVerts);
		}

		#reselect the other half of the original polys
		if ($symmRunCount == 2){
			foreach my $poly (@polysPos){
				lx("select.element $mainlayer polygon add $poly");
			}
		}
	}
}
#------------------------------------------------------------------------------------------------------------
#EDGE MODE
#------------------------------------------------------------------------------------------------------------
elsif(lxq("select.typeFrom {edge;polygon;item;vertex} ?") && lxq( "query layerservice edge.n ? selected")>0){
	my @tempEdgeList = lxq("query layerservice selection ? edge");
	my @edges;
	foreach my $edge (@tempEdgeList){	if ($edge =~ /\($mainlayer/){push(@edges,$edge);}	}


	#[--------------------------------------------------------------------------------]
	#[--SYMM off------------------------------------------------------------------]
	#[--------------------------------------------------------------------------------]
	if ($symmAxis == 3){
		s/\(\d{0,},/\(/  for @edges[-1];
		tr/()//d for @edges[-1];
		my @verts = split(/,/, @edges[-1]);
		&mirror(@verts);
	}
	#[--------------------------------------------------------------------------------]
	#[--SYMM ON-----------------------------------------------------------------]
	#[--------------------------------------------------------------------------------]
	else{
		our @polys = lxq("query layerservice polys ? selected");
		my @polysPos;
		my @polysNeg;
		my @edgesPos;
		my @edgesNeg;
		our $symmRunCount=0;

		#split up the edges into two arrays
		foreach my $edge (@edges){
			tr/()//d for $edge;
			my @verts = my @verts = split(/,/, $edge);
			my @pos = lxq("query layerservice edge.pos ? (@verts[1],@verts[2]");
			$edge = @verts[1].",".@verts[2];

			if (@pos[$symmAxis] >= 0){
				push(@edgesPos,$edge);
			}else{
				push(@edgesNeg,$edge);
			}
		}

		#split up the polys into two arrays.
		foreach my $poly (@polys){
			my @pos = lxq("query layerservice poly.pos ? $poly");
			if (@pos[$symmAxis] >= 0){
				push(@polysPos,$poly);
			}else{
				push(@polysNeg,$poly);
			}
		}

		#run script on both symmetry axes.
		if ( (@polysPos != "") && (@edgesPos != "") ){
			lxout("[->] Running script on POSITIVE symmetry half");
			$symmRunCount++;

			lx("select.drop polygon");
			foreach my $poly (@polysPos){	lx("select.element $mainlayer polygon add $poly");	}
			my @verts = split(/,/, @edgesPos[-1]);
			&mirror(@verts);
		}
		if ( (@polysNeg != "") && (@edgesNeg != "") ){
			lxout("[->] Running script on NEGATIVE symmetry half");
			$symmRunCount++;

			lx("select.drop polygon");
			foreach my $poly (@polysNeg){	lx("select.element $mainlayer polygon add $poly");	}
			my @verts = split(/,/, @edgesNeg[-1]);
			&mirror(@verts);
		}

		#reselect the other half of the original polys
		if ($symmRunCount == 2){
			foreach my $poly (@polysPos){
				lx("select.element $mainlayer polygon add $poly");
			}
		}
	}
}
#------------------------------------------------------------------------------------------------------------
#ITEM + MATERIAL MODE
#------------------------------------------------------------------------------------------------------------
elsif(lxq("select.typeFrom ptag;vertex;edge;polygon;item ?") || lxq("select.typeFrom item;ptag;vertex;edge;polygon ?")){
	die("\n.\n[---------------------------------------------You're not in vert, edge, or polygon mode.--------------------------------------------]\n[--PLEASE TURN OFF THIS WARNING WINDOW by clicking on the (In the future) button and choose (Hide Message)--] \n[-----------------------------------This window is not supposed to come up, but I can't control that.---------------------------]\n.\n");
}
#------------------------------------------------------------------------------------------------------------
#POLY MODE (or vert or edge w/ no selection)
#------------------------------------------------------------------------------------------------------------
else{
	lxout("[->] Performing axis mirror");
	my $centeringToolsScriptPos = lxq("user.value sen_centeringToolsPos ?");

	if ($centeringToolsScriptPos ne ""){
		my @pos = split (/[,]/, $centeringToolsScriptPos);
		if		(@ARGV[0] =~ /x/i)	{lx("poly.mirror axis:[x] cenX:{$pos[0]} cenY:{0} cenZ:{0}");}
		elsif	(@ARGV[0] =~ /y/i)	{lx("poly.mirror axis:[y] cenX:{0} cenY:{$pos[1]} cenZ:{0}");}
		else						{lx("poly.mirror axis:[z] cenX:{0} cenY:{0} cenZ:{$pos[2]}");}
		lxout("Mirroring using the fake origin position stored from the 'centeringTools.pl' script instead of the world origin.  If you wish to mirror from the world origin, reset the other script's cvar by running this command : '@centeringTools.pl resetPos'");
	}else{
		lx("poly.mirror {@ARGV[0]};");
	}
}
#------------------------------------------------------------------------------------------------------------
#SELECT THE NEW POLYGONS
#------------------------------------------------------------------------------------------------------------
if ($selectNew == 1){
	#[--------------------------------------------------------------------------------]
	#[--SELECT AT LEAST HALF THE POLYS--------------------------]
	#[--------------------------------------------------------------------------------]
	my $polys = lxq("query layerservice poly.n ? selected");
	my $polyCount = lxq("query layerservice poly.n ? all");

	#select all if none were selected.  and select only the new ones if some were selected.
	if ($polys == 0){
		lx("select.type polygon");
		lx("select.invert");
	}else{
		for (my $i=$polyCount-$polys; $i<$polyCount; $i++){
			lx("select.element $mainlayer polygon add $i");
		}
	}
	#[--------------------------------------------------------------------------------]
	#[--SYMM ON-----------------------------------------------------------------]
	#[--------------------------------------------------------------------------------]
	if ($symmRunCount == 2){
		#select the second set of new polys
		for (my $i=$polyCount-($polys*2); $i<$polyCount-$polys; $i++){
			lx("select.element $mainlayer polygon add $i");
		}
	}
}


#------------------------------------------------------------------------------------------------------------
#CLEANUP
#------------------------------------------------------------------------------------------------------------
#REFERENCE : Set the layer reference back
lx("!!layer.setReference {$layerReference}");

#WORKPLANE : put the workplane back to what you were in before.
lx("workPlane.edit {@WPmem[0]} {@WPmem[1]} {@WPmem[2]} {@WPmem[3]} {@WPmem[4]} {@WPmem[5]}");

#SYMMETRY : set symmetry back
if ($symmAxis != 3)
{
	#CONVERT MY OLDSCHOOL SYMM AXIS TO MODO's NEWSCHOOL NAME
	if 		($symmAxis == "3")	{	$symmAxis = "none";	}
	elsif	($symmAxis == "0")	{	$symmAxis = "x";		}
	elsif	($symmAxis == "1")	{	$symmAxis = "y";		}
	elsif	($symmAxis == "2")	{	$symmAxis = "z";		}
	lxout("turning symm back on ($symmAxis)"); lx("!!select.symmetryState $symmAxis");
}



















#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------SUBROUTINES--------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------
#MIRROR SUBROUTINE
#------------------------------------------------------------------------------------------------------------
sub mirror{
	my @verts = @_;
	my @pos = lxq("query layerservice vert.pos ? @verts[0]");
	my $angle = angleCheck(@verts[0],@verts[1],$axis);
	lxout("@verts[0],@verts[1] <> angle = $angle <> mirrorAxis = $mirrorAxis");

	lx("select.type polygon");

	if		( ($modoVer < 302) )								{	our $alg = 301;	}	#modo3 and earlier
	elsif	( ($modoVer > 300) && ($modoBuild < 33819) )		{	our $alg = 401;	}	#modo4, but before sp3
	elsif	( ($modoBuild >= 33819) && ($modoBuild < 40017) )	{	our $alg = 403;	}	#modo4 sp3 and greater
	elsif	( ($modoBuild >= 40017) && ($modoBuild < 40425) ) 	{	our $alg = 501;	}	#modo5
	elsif	( ($modoBuild >= 40425) )							{	our $alg = 403;	}	#modo5 sp1

	if ($alg == 301){
		lxout("301 mirror alg");
		lx("tool.set poly.mirror on");
		lx("tool.reset");
		if ($noMerge == 1){	lx("tool.attr poly.mirror merge 0");	}
		lx("tool.attr poly.mirror axis  {$mirrorAxis}");
		lx("tool.attr poly.mirror cenX  {@pos[0]}");
		lx("tool.attr poly.mirror cenY  {@pos[1]}");
		lx("tool.attr poly.mirror cenZ  {@pos[2]}");
		lx("tool.attr poly.mirror angle {$angle}");
		lx("tool.doApply");
		lx("tool.set poly.mirror off");
	}elsif ($alg == 401){
		lxout("401 mirror alg");
		lx("tool.set *.mirror on");
		lx("tool.reset");
		lx("tool.attr effector.clone flip 1");
		if 		($noMerge == 1)		{	lx("tool.attr effector.clone merge 0");	}
		else						{	lx("tool.attr effector.clone merge 1");	}
		if 		($mirrorAxis == 0)	{	our @axis = (1,0,0,0,1,0);				}
		elsif	($mirrorAxis == 1)	{	our @axis = (0,1,0,0,0,1);				}
		else						{	our @axis = (0,0,1,1,0,0);				}

		lx("tool.attr gen.mirror axis 	{$mirrorAxis}");
		lx("tool.attr gen.mirror cenX 	{@pos[0]}");
		lx("tool.attr gen.mirror cenY 	{@pos[1]}");
		lx("tool.attr gen.mirror cenZ 	{@pos[2]}");
		lx("tool.attr gen.mirror leftX 	{@axis[0]}");
		lx("tool.attr gen.mirror leftY 	{@axis[1]}");
		lx("tool.attr gen.mirror leftZ 	{@axis[2]}");
		lx("tool.attr gen.mirror upX 	{@axis[3]}");
		lx("tool.attr gen.mirror upY 	{@axis[4]}");
		lx("tool.attr gen.mirror upZ 	{@axis[5]}");
		lx("tool.attr gen.mirror angle 	{$angle}");
		lx("tool.doApply");
		lx("tool.set poly.mirror off 0");
	}elsif($alg == 403){
		lxout("403 mirror alg");
		lx("tool.set *.mirror on");
		lx("tool.reset");
		if 		($noMerge == 1)		{	lx("tool.attr effector.clone merge false");	}
		else						{	lx("tool.attr effector.clone merge true");	}
		if 		($mirrorAxis == 0)	{	our @axis = (1,0,0,0,1,0);					}
		elsif	($mirrorAxis == 1)	{	our @axis = (0,1,0,0,0,1);					}
		else						{	our @axis = (0,0,1,1,0,0);					}
		lx("tool.setAttr effector.clone flip true");
		lx("tool.setAttr gen.mirror cenX  {$pos[0]}");
		lx("tool.setAttr gen.mirror cenY  {$pos[1]}");
		lx("tool.setAttr gen.mirror cenZ  {$pos[2]}");
		lx("tool.setAttr gen.mirror axis  {$mirrorAxis}");
		lx("tool.setAttr gen.mirror leftX {$axis[0]}");
		lx("tool.setAttr gen.mirror leftY {$axis[1]}");
		lx("tool.setAttr gen.mirror leftZ {$axis[2]}");
		lx("tool.setAttr gen.mirror upX   {$axis[3]}");
		lx("tool.setAttr gen.mirror upY   {$axis[4]}");
		lx("tool.setAttr gen.mirror upZ   {$axis[5]}");
		lx("tool.setAttr gen.mirror angle {$angle}");
		lx("tool.doApply");
		lx("tool.set poly.mirror off 0");
	}elsif($alg == 501){
		lxout("501 mirror alg");
		lx("tool.set *.mirror on");
		lx("tool.reset");
		if 		($noMerge == 1)		{	lx("tool.attr poly.mirror merge false");		}
		else						{	lx("tool.attr poly.mirror merge true");			}
		if 		($mirrorAxis == 0)	{	our @axis = (1,0,0,0,1,0);						}
		elsif	($mirrorAxis == 1)	{	our @axis = (0,1,0,0,0,1);						}
		else						{	our @axis = (0,0,1,1,0,0);						}
		#lx("tool.setAttr effector.clone flip true");
		lx("tool.setAttr poly.mirror cenX  {$pos[0]}");
		lx("tool.setAttr poly.mirror cenY  {$pos[1]}");
		lx("tool.setAttr poly.mirror cenZ  {$pos[2]}");
		lx("tool.setAttr poly.mirror axis  {$mirrorAxis}");
		lx("tool.setAttr poly.mirror leftX {$axis[0]}");
		lx("tool.setAttr poly.mirror leftY {$axis[1]}");
		lx("tool.setAttr poly.mirror leftZ {$axis[2]}");
		lx("tool.setAttr poly.mirror upX   {$axis[3]}");
		lx("tool.setAttr poly.mirror upY   {$axis[4]}");
		lx("tool.setAttr poly.mirror upZ   {$axis[5]}");
		lx("tool.setAttr poly.mirror angle {$angle}");
		lx("tool.doApply");
		lx("tool.set poly.mirror off 0");
	}
}

#------------------------------------------------------------------------------------------------------------
#GET ANGLE FROM 2 VERTS SUBROUTINE
#------------------------------------------------------------------------------------------------------------
sub angleCheck{
	my ($vert1,$vert2,$axis) = @_;
	my $pi=3.1415926535897932384626433832795;
	my $disp1;
	my $disp2;
	my @vertPos1 = lxq("query layerservice vert.pos ? $vert1");
	my @vertPos2 = lxq("query layerservice vert.pos ? $vert2");

	my @displacement = (@vertPos2[0]-@vertPos1[0],@vertPos2[1]-@vertPos1[1],@vertPos2[2]-@vertPos1[2]);
	if ($axis == 0)
	{
		$disp1= @displacement[1];
		$disp2= @displacement[2];
	}
	elsif ($axis == 1)
	{
		$disp1 = @displacement[2];
		$disp2 = @displacement[0];
	}
 	elsif ($axis == 2)
	{
		$disp1 = @displacement[0];
		$disp2 = @displacement[1];
	}
	my $radian = atan2($disp2,$disp1);
	my $angle = ($radian*180)/$pi;
	return $angle;
}

#------------------------------------------------------------------------------------------------------------
#POPUP SUBROUTINE
#------------------------------------------------------------------------------------------------------------
sub popup #(MODO2 FIX)
{
	lx("dialog.setup yesNo");
	lx("dialog.msg {@_}");
	lx("dialog.open");
	my $confirm = lxq("dialog.result ?");
	if($confirm eq "no"){die;}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SET UP THE USER VALUE OR VALIDATE IT   (no popups)
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#userValueTools(name,type,life,username,list,listnames,argtype,min,max,action,value);
sub userValueTools{
	if (lxq("query scriptsysservice userValue.isdefined ? @_[0]") == 0){
		lxout("Setting up @_[0]--------------------------");
		lxout("Setting up @_[0]--------------------------");
		lxout("0=@_[0],1=@_[1],2=@_[2],3=@_[3],4=@_[4],5=@_[6],6=@_[6],7=@_[7],8=@_[8],9=@_[9],10=@_[10]");
		lxout("@_[0] didn't exist yet so I'm creating it.");
		lx( "user.defNew name:[@_[0]] type:[@_[1]] life:[@_[2]]");
		if (@_[3] ne "")	{	lxout("running user value setup 3");	lx("user.def [@_[0]] username [@_[3]]");	}
		if (@_[4] ne "")	{	lxout("running user value setup 4");	lx("user.def [@_[0]] list [@_[4]]");		}
		if (@_[5] ne "")	{	lxout("running user value setup 5");	lx("user.def [@_[0]] listnames [@_[5]]");	}
		if (@_[6] ne "")	{	lxout("running user value setup 6");	lx("user.def [@_[0]] argtype [@_[6]]");		}
		if (@_[7] ne "xxx")	{	lxout("running user value setup 7");	lx("user.def [@_[0]] min @_[7]");			}
		if (@_[8] ne "xxx")	{	lxout("running user value setup 8");	lx("user.def [@_[0]] max @_[8]");			}
		if (@_[9] ne "")	{	lxout("running user value setup 9");	lx("user.def [@_[0]] action [@_[9]]");		}
		if (@_[1] eq "string"){
			if (@_[10] eq ""){lxout("woah.  there's no value in the userVal sub!");							}		}
		elsif (@_[10] == ""){lxout("woah.  there's no value in the userVal sub!");									}
								lx("user.value [@_[0]] [@_[10]]");		lxout("running user value setup 10");
	}else{
		#STRING-------------
		if (@_[1] eq "string"){
			if (lxq("user.value @_[0] ?") eq ""){
				lxout("user value @_[0] was a blank string");
				lx("user.value [@_[0]] [@_[10]]");
			}
		}
		#BOOLEAN------------
		elsif (@_[1] eq "boolean"){

		}
		#LIST---------------
		elsif (@_[4] ne ""){
			if (lxq("user.value @_[0] ?") == -1){
				lxout("user value @_[0] was a blank list");
				lx("user.value [@_[0]] [@_[10]]");
			}
		}
		#ALL OTHER TYPES----
		elsif (lxq("user.value @_[0] ?") == ""){
			lxout("user value @_[0] was a blank number");
			lx("user.value [@_[0]] [@_[10]]");
		}
	}
}