#perl
#AUTHOR: Seneca Menard
#version 1.21
#(3-17-07 fix) : the warning window wasn't working properly.
#(12-21-10 feature) : put in a "forceYes" option, so that you can skip the warning window that pops up when you have no polys selected.

#This script will look at all the polygons you have selected and delete whichever are below zero in whatever axis you picked
#You have to append "x","y",or "z" to the script, and "-" if you want to delete the negative half of the axis
#Another argument is "forceYes", which will ignore the warning dialog window that pops up when you have no polys selected.
#ex: @deletehalf.pl z -
#ex: @deletehalf.pl x - forceYes

my $mainlayer = lxq("query layerservice layers ? main");
my @arrVertex;
my @posA;
my $num;
my $half=1;
my $fromElem = 0;

#---------------------------------------------------------------------------------------------------
#Look thru the variables to choose the proper axis
#---------------------------------------------------------------------------------------------------
foreach my $arg (@ARGV){
	if    ($arg eq "x")			{	$num = 0;				}
	elsif ($arg eq "y")			{	$num = 1;				}
	elsif ($arg eq "z")			{	$num = 2;				}
	elsif ($arg eq "-")			{	$half = 2;				}
	elsif ($arg eq "fromElem")	{	$fromElem = 1;			}
	elsif ($arg eq "forceYes")	{	$forceYes = 1;			}
}

#---------------------------------------------------------------------------------------------------
#Determine which delete half subroutine to run
#---------------------------------------------------------------------------------------------------
if ($fromElem == 1)				{	&deleteHalfFromElem;	}
else							{	&deleteHalf;			}



sub deleteHalfFromElem{
	my @pos;
	my $selType;

	popup("This has not been coded yet");

	if		(lxq( "select.typeFrom {vertex;edge;polygon;item} ?" ))	{	$selType = "vert";	}
	elsif	(lxq( "select.typeFrom {edge;polygon;item;vertex} ?" ))	{	$selType = "edge";	}
	elsif	(lxq( "select.typeFrom {polygon;item;vertex;edge} ?" ))	{	$selType = "poly";	}
	else															{	die("you're not in vert, edge, or poly mode, so i'm cancelling the script");}

	my @firstLastElems = createPerLayerElemList($selType,\%elems);
	if (@firstLastElems == 0){die("You don't have any verts, edges, or polys selected, so I'm canceling the script");}
	@pos = lxq("query layerservice $selType.pos ? @firstLastElems[-1]");
	#if ($selType eq "vert"){
	#	@pos = lxq("query layerservice $selType.pos ? @firstLastElems[-1]");
	#}elsif ($selType eq "edge"){
	#	@pos = lxq("query layerservice $selType.pos ? @firstLastElems[-1]");
	#}elsif ($selType eq "poly"){
	#
	#}
	#popup("pos = @pos");

	if (lxq("select.count polygon ?") > 0){


	}else{

	}

	#my lx("select.count ? polygon");

}




sub deleteHalf{
	#---------------------------------------------------------------------------------------------------
	#check if you have polygons selected and warn you if you don't
	#---------------------------------------------------------------------------------------------------
	if(lxq( "select.typeFrom {polygon;item;vertex;edge} ?" ) && lxq( "select.count polygon ?" )){
		#If there's a polygon selection, the script will run on that selection
		lx("select.connect"); #select rest of model
		lx("select.convert vertex");
		@arrVertex = lxq("query layerservice verts ? selected");
	}elsif(lxq( "select.typeFrom {vertex;edge;polygon;item} ?" ) && lxq( "select.count vertex ?" )){
		lxout("[->] VERT SELECTION MODE");
		#lx("select.connect");
		@arrVertex = lxq("query layerservice verts ? selected");
	}else{
		#This will bring up the warning window
		if ($forceYes != 1){
			lx("dialog.setup yesNo");
			lx("dialog.msg {You have no polygons selected.  Are you sure you want to delete one half of all that's visible?}");
			lx("dialog.open");
			$confirm = lxq("dialog.result ?");
			if ($confirm eq "no"){
				die("Script Aborted.");
			}
		}
		#Runs the script because you said "yes"
		lx("select.drop vertex");
		lx("select.invert");
		@arrVertex = lxq("query layerservice verts ? selected");
	}


	#---------------------------------------------------------------------------------------------------
	#select all verts on one side of the chosen axis
	#---------------------------------------------------------------------------------------------------
	#start selection from scratch and reselect one half
	lx("select.drop vertex");

	foreach my $arrVert(@arrVertex){
		@posA = lxq("query layerservice vert.pos ? $arrVert");
		if($num == 2){ #fixes Z bug
			if($half == 1){ #delete lesser half
				if($posA[$num] <= 0.00000001){
					lx("select.element [$mainlayer] vertex add index:$arrVert");
				}
			}
			else{ #delete greater half
				if($posA[$num] >= -0.00000001){
					lx("select.element [$mainlayer] vertex add index:$arrVert");
				}
			}
		}
		else{ #fixes Z bug
			if($half == 2){ #delete lesser half
				if($posA[$num] <= 0.00000001){
					lx("select.element [$mainlayer] vertex add index:$arrVert");
				}
			}else{ #delete greater half
				if($posA[$num] >= -0.00000001){
					lx("select.element [$mainlayer] vertex add index:$arrVert");
				}
			}
		}
	}


	#---------------------------------------------------------------------------------------------------
	#convert selected verts to polygons and delete 'em
	#---------------------------------------------------------------------------------------------------
	lx("select.convert polygon");
	if (lxq("select.count polygon ?")){
		lx("delete");
	}
}





#=====================================================================================================================================
#=====================================================================================================================================
#=====================================================================================================================================
#=====================================================================================================================================
#===									   					SUBROUTINES															  ====
#=====================================================================================================================================
#=====================================================================================================================================
#=====================================================================================================================================
#=====================================================================================================================================

#-----------------------------------------------------------------------------------------------------------
#POPUP SUBROUTINE
#-----------------------------------------------------------------------------------------------------------
sub popup #(MODO2 FIX)
{
	lx("dialog.setup yesNo");
	lx("dialog.msg {@_}");
	lx("dialog.open");
	my $confirm = lxq("dialog.result ?");
	if($confirm eq "no"){die;}
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#CREATE A PER LAYER ELEMENT SELECTION LIST (retuns first and last elems, and ordered list for all layers)
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#usage : my @firstLastPolys = createPerLayerElemList(poly,\%polys);
sub createPerLayerElemList{
	my $hash = @_[1];
	my @totalElements = lxq("query layerservice selection ? @_[0]");
	if (@totalElements == 0){die("\\\\n.\\\\n[---------------------------------------------You don't have any @_[0]s selected and so I'm cancelling the script.--------------------------------------------]\\\\n[--PLEASE TURN OFF THIS WARNING WINDOW by clicking on the (In the future) button and choose (Hide Message)--] \\\\n[-----------------------------------This window is not supposed to come up, but I can't control that.---------------------------]\\\\n.\\\\n");}

	#build the full list
	foreach my $elem (@totalElements){
		$elem =~ s/[\(\)]//g;
		my @split = split/,/,$elem;
		push(@{$$hash{@split[0]}},@split[1]);
	}

	#return the first and last elements
	return(@totalElements[0],@totalElements[-1]);
}