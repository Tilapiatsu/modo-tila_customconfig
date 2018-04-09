#perl
#ver 0.5
#author : Seneca Menard
#TEMP :
#does not support rotated viewports. (so it doesn't truly know what up or down is...)
#also. doesn't support symmetry.
#also, doesn't move uv sets yet.
#also, probably needs a cvar to do everythign as a group or individually.  especially for uv view, once that feature's put in.
#also, because i have to deselect and reselect layers, it's losing elem selection when i have multiple layers selected.  need to query if vert.move has a layer specifier or not..
#also, needs to support edge loops and poly groups..  doh.

#setup
my $mainlayer = lxq("query layerservice layers ? main");
my @foregroundLayers = lxq("query layerservice layers ? foreground");
my $moveDir = "up";
my $moveDirTableVal = 0;
my $lesserOrGreater = "lesser";
my $horizontalVertical = 0;
my $eachGroup = 0;
my $eachElement = 0;
my %elems;
my $skipReselectionSub = 0;

#script args:
foreach my $arg (@ARGV){
	if		($arg eq "up")			{$moveDir = "up";		$moveDirTableVal = 0;	}
	elsif	($arg eq "right")		{$moveDir = "right";	$moveDirTableVal = 1;	}
	elsif	($arg eq "down")		{$moveDir = "down";		$moveDirTableVal = 2;	}
	elsif	($arg eq "left")		{$moveDir = "left";		$moveDirTableVal = 3;	}
	elsif	($arg eq "horizontal")	{$horizontalVertical = 1;						}
	elsif	($arg eq "vertical")	{$horizontalVertical = 1;						}
	elsif	($arg eq "eachGroup")	{$eachGroup = 1;								}
	elsif	($arg eq "eachElement")	{$eachElement = 1;								}
}

#find the viewport axis
my $viewport = lxq("query view3dservice mouse.view ?");
my $viewportType = lxq("query view3dservice view.type ? $viewport");
lxout("viewportType = $viewportType");
my @axis = lxq("query view3dservice view.axis ? $viewport");
my @angles = lxq("query view3dservice view.angles ? $viewport");
my $axis;
my $toolAxis;
my $viewportAxis;
my @xAxis = (1,0,0);
my @yAxis = (0,1,0);
my @zAxis = (0,0,1);
my $dp0 = dotProduct(\@axis,\@xAxis);
my $dp1 = dotProduct(\@axis,\@yAxis);
my $dp2 = dotProduct(\@axis,\@zAxis);
if 		((abs($dp0) >= abs($dp1)) && (abs($dp0) >= abs($dp2)))	{	$viewportAxis = 0;	lxout("[->] : Using world X axis");	}
elsif	((abs($dp1) >= abs($dp0)) && (abs($dp1) >= abs($dp2)))	{	$viewportAxis = 1;	lxout("[->] : Using world Y axis");	}
else															{	$viewportAxis = 2;	lxout("[->] : Using world Z axis");	}
if (($moveDir eq "up") || ($moveDir eq "right"))				{	$lesserOrGreater = "greater";							}

#selection modes
if    	( lxq( "select.typeFrom {vertex;edge;polygon;item} ?" ) )	{	our $selMode = "vert";	}
elsif	( lxq( "select.typeFrom {edge;polygon;item;vertex} ?" ) )	{	our $selMode = "edge";	}
elsif	( lxq( "select.typeFrom {polygon;item;vertex;edge} ?" ) )	{	our $selMode = "poly";	}
else																{	die("\\\\n.\\\\n[---------------------------------------------You're not in vert, edge, or polygon mode.--------------------------------------------]\\\\n[--PLEASE TURN OFF THIS WARNING WINDOW by clicking on the (In the future) button and choose (Hide Message)--] \\\\n[-----------------------------------This window is not supposed to come up, but I can't control that.---------------------------]\\\\n.\\\\n");}

#build element tables
if ($viewportType eq "MO3D"){
	our @firstLastElems = createPerLayerElemList($selMode,\%elems,edgeSort);
}elsif (($selMode eq "poly") && (($eachGroup == 1) || ($eachElement == 1))){
	&selectVmap;
	our @firstLastElems = createPerLayerElemList($selMode,\%elems,edgeSort);
}elsif (($selMode eq "edge") && (($eachGroup == 1) || ($eachElement == 1))){
	&selectVmap;
	our %edges;
	our @firstLastEdges = createPerLayerElemList(edge,\%edges,edgeSort);
	our @firstLastUvVerts = createPerLayerUVSelList(uvEdge,\%elems,\@foregroundLayers);
}elsif  (($eachGroup == 1) || ($eachElement == 1)){
	&selectVmap;
	our @firstLastUvVerts = createPerLayerUVSelList(uvVert,\%elems,\@foregroundLayers);
}

#viewport axis hack flip
if ($viewportAxis == 0){
	if (($moveDir eq "up") || ($moveDir eq "down"))	{$axis = 1; $toolAxis = "posY";}
	else											{$axis = 2; $toolAxis = "posZ"; if ($lesserOrGreater eq "greater"){$lesserOrGreater = "lesser";}else{$lesserOrGreater = "greater";}} #flipping Z axis (TEMP)
}elsif ($viewportAxis == 1){
	if (($moveDir eq "up") || ($moveDir eq "down"))	{$axis = 2; $toolAxis = "posZ";	if ($lesserOrGreater eq "greater"){$lesserOrGreater = "lesser";}else{$lesserOrGreater = "greater";}} #flipping Z axis (TEMP)
	else											{$axis = 0; $toolAxis = "posX"; }
}else{
	if (($moveDir eq "up") || ($moveDir eq "down"))	{$axis = 1; $toolAxis = "posY";}
	else											{$axis = 0; $toolAxis = "posX";}
}

#3D : sort the elems and then send them to moveToFarthest sub
if ($viewportType eq "MO3D"){
	if ($selMode eq "vert"){
		#[->] : VERT : GROUPS
		if ($eachGroup == 1){
			my %touchingVerts; returnTouchingElems("vert",\%elems,\%touchingVerts);
			foreach my $layer (keys %touchingVerts){
				my $layerID = lxq("query layerservice layer.id ? $layer");
				if (@foregroundLayers > 1){lx("select.subItem {$layerID} set mesh;triSurf;meshInst;camera;light;backdrop;groupLocator;replicator;locator;deform;locdeform;chanModify;chanEffect 0 0");}
				foreach my $group (keys %{$touchingVerts{$layer}}){
					moveToFarthest(@{$touchingVerts{$layer}{$group}});
				}
			}
		}
		#[->] : VERT : ALL
		else{
			foreach my $layer (sort keys %elems){
				my $layerID = lxq("query layerservice layer.id ? $layer");
				if (@foregroundLayers > 1){lx("select.subItem {$layerID} set mesh;triSurf;meshInst;camera;light;backdrop;groupLocator;replicator;locator;deform;locdeform;chanModify;chanEffect 0 0");}
				moveToFarthest(@{$elems{$layer}});
			}
		}
	}elsif ($selMode eq "edge"){
		#[->] : EDGE : GROUP
		if ($eachGroup == 1){
			my %touchingEdges; returnTouchingElems("edge",\%elems,\%touchingEdges);

			foreach my $layer (keys %touchingEdges){
				my $layerID = lxq("query layerservice layer.id ? $layer");
				if (@foregroundLayers > 1){lx("select.subItem {$layerID} set mesh;triSurf;meshInst;camera;light;backdrop;groupLocator;replicator;locator;deform;locdeform;chanModify;chanEffect 0 0");}

				foreach my $group (keys %{$touchingEdges{$layer}}){
					my %vertList = ();
					foreach my $edge (@{$touchingEdges{$layer}{$group}}){
						my @verts = split (/[^0-9]/, $edge);
						$vertList{@verts[0]} = 1;
						$vertList{@verts[1]} = 1;
					}
					moveToFarthest(keys %vertList);
				}
			}
		}
		#[->] : EDGE : INDIVIDUAL
		elsif ($eachElement == 1){
			foreach my $layer (sort keys %elems){
				my $layerID = lxq("query layerservice layer.id ? $layer");
				if (@foregroundLayers > 1){lx("select.subItem {$layerID} set mesh;triSurf;meshInst;camera;light;backdrop;groupLocator;replicator;locator;deform;locdeform;chanModify;chanEffect 0 0");}
				my %elemList;

				foreach my $edge (@{$elems{$layer}}){
					my @verts = split (/[^0-9]/, $edge);
					moveToFarthest(@verts[0],@verts[1]);
				}
			}
		}
		#[->] : EDGE : ALL
		else{
			foreach my $layer (sort keys %elems){
				my $layerID = lxq("query layerservice layer.id ? $layer");
				if (@foregroundLayers > 1){lx("select.subItem {$layerID} set mesh;triSurf;meshInst;camera;light;backdrop;groupLocator;replicator;locator;deform;locdeform;chanModify;chanEffect 0 0");}
				my %vertList;

				foreach my $edge (@{$elems{$layer}}){
					my @verts = split (/[^0-9]/, $edge);
					$vertList{@verts[0]} = 1;
					$vertList{@verts[1]} = 1;
				}
				moveToFarthest(keys %vertList);
			}
		}
	}elsif ($selMode eq "poly"){
		#[->] : POLY : GROUPS
		if ($eachGroup == 1){
			my %touchingPolys; returnTouchingElems("poly",\%elems,\%touchingPolys);

			foreach my $layer (keys %touchingPolys){
				my $layerID = lxq("query layerservice layer.id ? $layer");
				if (@foregroundLayers > 1){lx("select.subItem {$layerID} set mesh;triSurf;meshInst;camera;light;backdrop;groupLocator;replicator;locator;deform;locdeform;chanModify;chanEffect 0 0");}

				foreach my $group (keys %{$touchingPolys{$layer}}){
					my %vertList;
					foreach my $poly (@{$touchingPolys{$layer}{$group}}){
						my @verts = lxq("query layerservice $selMode.vertList ? $poly");
						$vertList{$_} = 1 for @verts;
					}
					moveToFarthest(keys %vertList);
				}
			}
		}
		#[->] : POLY : INDIVIDUAL
		elsif ($eachElement == 1){
			foreach my $layer (sort keys %elems){
				my $layerID = lxq("query layerservice layer.id ? $layer");
				if (@foregroundLayers > 1){lx("select.subItem {$layerID} set mesh;triSurf;meshInst;camera;light;backdrop;groupLocator;replicator;locator;deform;locdeform;chanModify;chanEffect 0 0");}

				foreach my $poly (@{$elems{$layer}}){
					my @verts = lxq("query layerservice $selMode.vertList ? $poly");
					moveToFarthest(@verts);
				}
			}
		}
		#[->] : POLY : ALL
		else{
			foreach my $layer (sort keys %elems){
				my $layerID = lxq("query layerservice layer.id ? $layer");
				if (@foregroundLayers > 1){lx("select.subItem {$layerID} set mesh;triSurf;meshInst;camera;light;backdrop;groupLocator;replicator;locator;deform;locdeform;chanModify;chanEffect 0 0");}
				my %vertList;

				foreach my $poly (@{$elems{$layer}}){
					my @verts = lxq("query layerservice $selMode.vertList ? $poly");
					$vertList{$_} = 1 for @verts;
				}
				moveToFarthest(keys %vertList);
			}
		}
	}
}
#UV : use the uv align commands.
else{
	lxout("[->] : Using UV window, so firing uv align command");

	if ($selMode eq "vert"){
		#[->] : UV VERT : GROUP
		if ($eachGroup == 1){
			my %touchingUvVerts; my %touchingUvVertBBOXes; returnTouchingElems("uvVert",\%elems,\%touchingUvVerts,\%touchingUvVertBBOXes);

			foreach my $layer (keys %touchingUvVerts){
				foreach my $group (keys %{$touchingUvVerts{$layer}}){
					lx("select.drop vertex");
					foreach my $uv (@{$touchingUvVerts{$layer}{$group}}){
						my @uvInfo = split(/,/, $uv);
						lx("select.element layer:$layer type:vert mode:add index:$uvInfo[1] index3:$uvInfo[0]");
					}
					moveUVsToFarthest("stretch",\@{$touchingUvVertBBOXes{$layer}{$group}});
				}
			}
		}
		#[->] : UV VERT : ALL
		else{
			lxout("moving all");
			$skipReselectionSub = 1;
			moveUVsToFarthest("uv.align");
		}
	}elsif ($selMode eq "edge"){
		#[->] : UV EDGE : GROUP
		if ($eachGroup == 1){
			$skipReselectionSub = 1;
			my %touchingUvVerts; my %touchingUvVertBBOXes; returnTouchingElems("uvEdge",\%elems,\%touchingUvVerts,\%touchingUvVertBBOXes,\%edges);

			foreach my $layer (keys %touchingUvVerts){
				foreach my $group (keys %{$touchingUvVerts{$layer}}){
					lx("select.drop vertex");
					foreach my $uv (@{$touchingUvVerts{$layer}{$group}}){
						my @uvInfo = split(/,/, $uv);
						lx("select.element layer:$layer type:vert mode:add index:$uvInfo[1] index3:$uvInfo[0]");
					}
					moveUVsToFarthest("stretch",\@{$touchingUvVertBBOXes{$layer}{$group}});
				}
			}
			lx("select.type edge");
		}
		#[->] : UV EDGE : INDIVIDUAL
		elsif ($eachElement == 1){
			$skipReselectionSub = 1;
			moveUVsToFarthest("uv.align");
		}
		#[->] : UV EDGE : ALL
		else{
			$skipReselectionSub = 1;
			moveUVsToFarthest("uv.align");
		}
	}elsif ($selMode eq "poly"){
		#[->] : UV POLY : GROUP
		if ($eachGroup == 1){
			$skipReselectionSub = 1;
			moveUVsToFarthest("uv.align");
		}
		#[->] : UV POLY : INDIVIDUAL
		elsif ($eachElement == 1){
			$skipReselectionSub = 1;
			moveUVsToFarthest("uv.align");
		}
		#[->] : UV POLY : ALL
		else{
			$skipReselectionSub = 1;
			moveUVsToFarthest("uv.align");
		}
	}
}


#CLEANUP :
#restore the layer list because I had to hijack the selected layers in order to
if ((@foregroundLayers > 1) && ($skipReselectionSub != 1)){
	my $layerID = lxq("query layerservice layer.id ? @foregroundLayers[0]");
	lx("select.subItem {$layerID} set mesh;triSurf;meshInst;camera;light;backdrop;groupLocator;replicator;locator;deform;locdeform;chanModify;chanEffect 0 0");
	for (my $i=1; $i<@foregroundLayers; $i++){
		my $layerID = lxq("query layerservice layer.id ? @foregroundLayers[$i]");
		lx("select.subItem {$layerID} add mesh;triSurf;meshInst;camera;light;backdrop;groupLocator;replicator;locator;deform;locdeform;chanModify;chanEffect 0 0");
	}
	restoreSelection();
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#RESTORE SELECTION SUB
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#usage : restoreSelection();
#NOTE : uses the hardcoded %elems hash table
#NOTE : uses the viewport type answer
sub restoreSelection{
	if ($viewportType eq "MO3D"){
		foreach my $layer (keys %elems){
			if ($selMode eq "edge"){
				foreach my $elem (@{$elems{$layer}}){
					my @verts = split (/[^0-9]/, $elem);
					lx("select.element $layer $selMode add $verts[0] $verts[1]");
				}
			}else{
				foreach my $elem (@{$elems{$layer}}){
					lx("select.element $layer $selMode add $elem");
				}
			}
		}
	}else{
		foreach my $layer (keys %elems){
			if ($selMode eq "vert"){
				foreach my $uv (@{$elems{$layer}}){
					my @uvInfo = split(/,/, $uv);
					lxout("uvInfo = @uvInfo[0]<>@uvInfo[1]<>@uvInfo[2]");
					lx("select.element layer:$layer type:$selMode mode:add index:$uvInfo[1] index3:$uvInfo[0]");
				}
			}elsif ($selMode eq "edge"){
				foreach my $uv (@{$elems{$layer}}){
					my @uvInfo = split(/,/, $uv);
					lxout("uvInfo = @uvInfo[0]<>@uvInfo[1]<>@uvInfo[2]");
					lx("select.element layer:$layer type:$selMode mode:add index:$uvInfo[1] index2:[2] index3:$uvInfo[0]");
				}
			}else{
				foreach my $elem (@{$elems{$layer}}){
					lx("select.element $layer $selMode add $elem");
				}
			}
		}
	}
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#MOVE UVS TO FARTHEST SUB :
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#usage : moveUVsToFarthest(<stretch|uv.align>,\@bbox); 2
sub moveUVsToFarthest{
	if ($_[0] eq "uv.align"){
		if		($moveDir eq "up")		{lx("uv.align Up High");	}
		elsif	($moveDir eq "right")	{lx("uv.align Right High");	}
		elsif	($moveDir eq "down")	{lx("uv.align Down Low");	}
		elsif	($moveDir eq "left")	{lx("uv.align Left Low");	}
		else	{die("You didn't type in up, right, down, or left as a cvar and so I'm cancelling the script");}
	}elsif($_[0] eq "stretch"){
		my @stretchAmount = (1,1);
		my @toolCenter;

		if		($moveDir eq "up"){
			if ($horizontalVertical == 1)	{	$stretchAmount[1] = 0;	@toolCenter = ( @{$_[1]}[0] , (@{$_[1]}[3]+@{$_[1]}[1])*.5 );	}
			else							{	$stretchAmount[1] = 0;	@toolCenter = ( @{$_[1]}[0] , @{$_[1]}[3] );					}
		}elsif	($moveDir eq "right"){
			if ($horizontalVertical == 1)	{	$stretchAmount[0] = 0;	@toolCenter = ( (@{$_[1]}[2]+@{$_[1]}[0])*.5 , @{$_[1]}[3] );	}
			else							{	$stretchAmount[0] = 0;	@toolCenter = ( @{$_[1]}[2] , @{$_[1]}[3] );					}
		}elsif	($moveDir eq "down"){
			if ($horizontalVertical == 1)	{	$stretchAmount[1] = 0;	@toolCenter = ( @{$_[1]}[0] , (@{$_[1]}[3]+@{$_[1]}[1])*.5 );	}
			else							{	$stretchAmount[1] = 0;	@toolCenter = ( @{$_[1]}[0] , @{$_[1]}[1] );					}
		}elsif	($moveDir eq "left"){
			if ($horizontalVertical == 1)	{	$stretchAmount[0] = 0;	@toolCenter = ( (@{$_[1]}[2]+@{$_[1]}[0])*.5 , @{$_[1]}[3] );	}
			else							{	$stretchAmount[0] = 0;	@toolCenter = ( @{$_[1]}[0] , @{$_[1]}[3] );					}
		}

		lx("tool.viewType uv");
		lx("!!tool.set actr.auto on");
		lx("!!tool.set xfrm.stretch on");
		if ($selMode eq "poly"){lx("!!tool.xfrmDisco false");}
		lx("!!tool.setAttr center.auto cenU {$toolCenter[0]}");
		lx("!!tool.setAttr center.auto cenV {$toolCenter[1]}");
		lx("!!tool.setAttr xfrm.stretch factX {$stretchAmount[0]}");
		lx("!!tool.setAttr xfrm.stretch factY {$stretchAmount[1]}");
		lx("!!tool.setAttr xfrm.stretch factZ 1");
		lx("!!tool.doApply");
		lx("!!tool.set xfrm.stretch off");
	}
}


#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
##MOVETOFARTHEST SUB :
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
sub moveToFarthest{
	my @furthestVertPos = lxq("query layerservice vert.pos ? @_[0]");
	my $furthestDist = @furthestVertPos[$axis];
	my @bbox = (@furthestVertPos,@furthestVertPos);

	#align the group to the horizontal or vertical midpoint
	if ($horizontalVertical == 1){
		foreach my $vert (@_){
			my @pos = lxq("query layerservice vert.pos ? $vert");
			if (@pos[$axis] < @bbox[$axis])		{@bbox[$axis] = @pos[$axis];	}
			if (@pos[$axis] > @bbox[$axis+3])	{@bbox[$axis+3] = @pos[$axis];	}
		}
		$furthestDist = .5 * (@bbox[$axis]+@bbox[$axis+3]);
	}

	#align the group the farthest element
	else{
		foreach my $vert (@_){
			my @pos = lxq("query layerservice vert.pos ? $vert");
			if		(($lesserOrGreater eq "greater") && (@pos[$axis] > $furthestDist))	{$furthestDist = @pos[$axis];}
			elsif	(($lesserOrGreater eq "lesser") && (@pos[$axis] < $furthestDist))	{$furthestDist = @pos[$axis];}
		}
	}

	foreach my $vert (@_){lx("vert.move vertIndex:$vert $toolAxis:$furthestDist");}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SELECT THE PROPER VMAP  #MODO301
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub selectVmap{
	my $vmaps = lxq("query layerservice vmap.n ?");
	my %uvMaps;
	my @selectedUVmaps;
	our $finalVmap;

	lxout("-Checking which uv maps to select or deselect");

	for (my $i=0; $i<$vmaps; $i++){
		if (lxq("query layerservice vmap.type ? $i") eq "texture"){
			if (lxq("query layerservice vmap.selected ? $i") == 1){push(@selectedUVmaps,$i);}
			my $name = lxq("query layerservice vmap.name ? $i");
			$uvMaps{$i} = $name;
		}
	}

	#ONE SELECTED UV MAP
	if (@selectedUVmaps == 1){
		lxout("     -There's only one uv map selected <> $uvMaps{@selectedUVmaps[0]}");
		$finalVmap = @selectedUVmaps[0];
	}

	#MULTIPLE SELECTED UV MAPS  (try to select "Texture")
	elsif (@selectedUVmaps > 1){
		my $foundVmap;
		foreach my $vmap (@selectedUVmaps){
			if ($uvMaps{$vmap} eq "Texture"){
				$foundVmap = $vmap;
				last;
			}
		}
		if ($foundVmap != "")	{
			lx("!!select.vertexMap $uvMaps{$foundVmap} txuv replace");
			lxout("     -There's more than one uv map selected, so I'm deselecting all but this one <><> $uvMaps{$foundVmap}");
			$finalVmap = $foundVmap;
		}
		else{
			lx("!!select.vertexMap $uvMaps{@selectedUVmaps[0]} txuv replace");
			lxout("     -There's more than one uv map selected, so I'm deselecting all but this one <><> $uvMaps{@selectedUVmaps[0]}");
			$finalVmap = @selectedUVmaps[0];
		}
	}

	#NO SELECTED UV MAPS (try to select "Texture" or create it)
	elsif (@selectedUVmaps == 0){
		lx("!!select.vertexMap Texture txuv replace") or $fail = 1;
		if ($fail == 1){
			lx("!!vertMap.new Texture txuv [0] [0.78 0.78 0.78] [1.0]");
			lxout("     -There were no uv maps selected and 'Texture' didn't exist so I created this one. <><> Texture");
		}else{
			lxout("     -There were no uv maps selected, but 'Texture' existed and so I selected this one. <><> Texture");
		}

		my $vmaps = lxq("query layerservice vmap.n ? all");
		for (my $i=0; $i<$vmaps; $i++){
			if (lxq("query layerservice vmap.name ? $i") eq "Texture"){
				$finalVmap = $i;
			}
		}
	}

	#ask the name of the vmap just so modo knows which to query.
	my $name = lxq("query layerservice vmap.name ? $finalVmap");
}


#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#DOT PRODUCT subroutine
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#USAGE : my $dp = dotProduct(\@vector1,\@vector2);
sub dotProduct{
	my @array1 = @{$_[0]};
	my @array2 = @{$_[1]};
	my $dp = (	(@array1[0]*@array2[0])+(@array1[1]*@array2[1])+(@array1[2]*@array2[2])	);
	return $dp;
}


#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#POPUP SUB
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#USAGE : popup("What I wanna print");
sub popup #(MODO2 FIX)
{
	lx("dialog.setup yesNo");
	lx("dialog.msg {@_}");
	lx("dialog.open");
	my $confirm = lxq("dialog.result ?");
	if($confirm eq "no"){die;}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------RETURN TOUCHING ELEMENTS SUBROUTINES---------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#RETURN TOUCHING ELEMS SUB
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#usage : my %touchingVerts; returnTouchingElems("vert",\%verts,\%touchingVerts);
#REQUIRES the vmap to be already queried if working with uvs
#REQUIRES buildVmapTable sub
#REQUIRES createPerLayerElemList sub : ie a layer based selection table
#REQUIRES createPerLayerUVSelList sub : ie a layer based uv selection table
#REQUIRES findPolysNeighboringPolyVerts sub
#REQUIRES removeListFromArray sub
#REQUIRES splitUVGroups sub
#REQUIRES update2dBoundingBox sub
#NOTE : makes the referenced empty hash table be a 3 tiered hash table. (layerIndice, group#, elementList)
#NOTE : if finding uv edge groups, it'll have to do a select.convert vertex because of the "uvs ? selected" query.  :(
sub returnTouchingElems{
	#VERTEX===========
	if ($_[0] eq "vert"){
		lxout("[->] : Finding touching vert groups");
		my %vertTable;
		foreach my $layer (keys %{$_[1]}){
			my $layerName = lxq("query layerservice layer.name ? $layer");
			my %selectedVertTable;	$selectedVertTable{$_} = 1 for @{${$_[1]}{$layer}};
			my %toDoListTable = %selectedVertTable;
			my %checkedVertTable = ();
			my $roundCount = 0;
			my @vertsToCheck;

			while (keys %toDoListTable > 0){
				$roundCount++;
				@vertsToCheck = (keys %toDoListTable)[0];
				delete $toDoListTable{$vertsToCheck[0]};
				$checkedVertTable{$vertsToCheck[0]} = 1;
				push(@{$_[2]{$layer}{$roundCount}},$vertsToCheck[0]);

				while (@vertsToCheck > 0){
					my @connectedVerts = lxq("query layerservice vert.vertList ? $vertsToCheck[0]");
					foreach my $vert (@connectedVerts){
						if ($checkedVertTable{$vert} != 1){
							$checkedVertTable{$vert} = 1;
							if ($selectedVertTable{$vert} == 1){
								push(@vertsToCheck,$vert);
								delete $toDoListTable{$vert};
								push(@{$_[2]{$layer}{$roundCount}},$vert);
							}
						}
					}
					shift(@vertsToCheck);
				}
			}
		}
	}
	#EDGE=============
	elsif ($_[0] eq "edge"){
		lxout("[->] : Finding touching edge groups");
		my %edgeTable;
		foreach my $layer (keys %{$_[1]}){
			my $layerName = lxq("query layerservice layer.name ? $layer");
			my %selectedEdgeTable;	$selectedEdgeTable{$_} = 1 for @{${$_[1]}{$layer}};
			my %toDoListTable = %selectedEdgeTable;
			my %checkedEdgeTable = ();
			my $roundCount = 0;
			my @edgesToCheck = ();

			while (keys %toDoListTable > 0){
				$roundCount++;
				@edgesToCheck = (keys %toDoListTable)[0];
				delete $toDoListTable{$edgesToCheck[0]};
				$checkedEdgeTable{$edgesToCheck[0]} = 1;
				push(@{$_[2]{$layer}{$roundCount}},$edgesToCheck[0]);

				while (@edgesToCheck > 0){
					my @verts = split (/[^0-9]/, $edgesToCheck[0]);
					my @connectedVerts1 = lxq("query layerservice vert.vertList ? $verts[0]");
					my @connectedVerts2 = lxq("query layerservice vert.vertList ? $verts[1]");
					my @connectedEdges;

					foreach my $vert (@connectedVerts1){
						if ($verts[0] < $vert)	{	push(@connectedEdges,$verts[0].",".$vert);	}
						else					{	push(@connectedEdges,$vert.",".$verts[0]);	}
					}
					foreach my $vert (@connectedVerts2){
						if ($verts[1] < $vert)	{	push(@connectedEdges,$verts[1].",".$vert);	}
						else					{	push(@connectedEdges,$vert.",".$verts[1]);	}
					}

					foreach my $edge (@connectedEdges){
						if ($checkedEdgeTable{$edge} != 1){
							$checkedEdgeTable{$edge} = 1;
							if ($selectedEdgeTable{$edge} == 1){
								push(@edgesToCheck,$edge);
								delete $toDoListTable{$edge};
								push(@{$_[2]{$layer}{$roundCount}},$edge);
							}
						}
					}
					shift(@edgesToCheck);
				}
			}
		}

	}
	#POLY=============
	elsif ($_[0] eq "poly"){
		lxout("[->] : Finding touching poly groups");
		my %polyTable;
		foreach my $layer (keys %{$_[1]}){
			my $layerName = lxq("query layerservice layer.name ? $layer");
			my %selectedPolyTable;	$selectedPolyTable{$_} = 1 for @{${$_[1]}{$layer}};
			my %toDoListTable = %selectedPolyTable;
			my %checkedPolyTable = ();
			my $roundCount = 0;
			my @polysToCheck;

			while (keys %toDoListTable > 0){
				$roundCount++;
				@polysToCheck = (keys %toDoListTable)[0];
				delete $toDoListTable{$polysToCheck[0]};
				$checkedPolyTable{$polysToCheck[0]} = 1;
				push(@{$_[2]{$layer}{$roundCount}},$polysToCheck[0]);

				while (@polysToCheck > 0){
					my @polyVerts = lxq("query layerservice poly.vertList ? $polysToCheck[0]");
					my %tempPolyTable=();
					foreach my $vert (@polyVerts){
						my @vertPolyList = lxq("query layerservice vert.polyList ? $vert");
						$tempPolyTable{$_} = 1 for @vertPolyList;
					}
					my @connectedPolys = (keys %tempPolyTable);

					foreach my $poly (@connectedPolys){
						if ($checkedPolyTable{$poly} != 1){
							$checkedPolyTable{$poly} = 1;
							if ($selectedPolyTable{$poly} == 1){
								push(@polysToCheck,$poly);
								delete $toDoListTable{$poly};
								push(@{$_[2]{$layer}{$roundCount}},$poly);
							}
						}
					}
					shift(@polysToCheck);
				}
			}
		}
	}
	#UV VERT OR EDGE==========
	elsif (($_[0] eq "uvVert") || ($_[0] eq "uvEdge")){
		lxout("[->] : Finding touching uvVert groups");
		my %uvVertTable;
		foreach my $layer (keys %{$_[1]}){
			my $layerName = lxq("query layerservice layer.name ? $layer");
			my %selectedUvVertTable;	$selectedUvVertTable{$_} = 1 for @{${$_[1]}{$layer}};
			my %toDoListTable = %selectedUvVertTable;
			my %checkedUvVertTable = ();
			my $roundCount = 0;
			my @uvVertsToCheck = ();
			my %uvPosTable = ();
			my $vmapName = lxq("query layerservice vmap.name ? $finalVmap");
			buildVmapTable(@_[1],\%uvPosTable,$layer);
			if ($_[0] eq "uvEdge"){
				our %selectedEdgeTable;
				foreach my $edge (@{$_[4]{$layer}}){$selectedEdgeTable{$edge} = 1;}
			}

			while (keys %toDoListTable > 0){
				my @bleh = (keys %toDoListTable);
				$roundCount++;
				@uvVertsToCheck = (keys %toDoListTable)[0];
				delete $toDoListTable{$uvVertsToCheck[0]};
				$checkedUvVertTable{$uvVertsToCheck[0]} = 1;
				push(@{$_[2]{$layer}{$roundCount}},$uvVertsToCheck[0]);

				while (@uvVertsToCheck > 0){
					my @uvInfo = split(/,/, $uvVertsToCheck[0]);
					my @polyList = lxq("query layerservice vert.polyList ? $uvInfo[1]");

					update2dBoundingBox(	$_[3]	,	$layer	,	$roundCount	,	@{$uvPosTable{$uvInfo[0]}{$uvInfo[1]}}[0]	,	@{$uvPosTable{$uvInfo[0]}{$uvInfo[1]}}[1]);

					#for each poly, I find the neighboring poly-disco-verts that are selected and add 'em to the array.
					foreach my $poly (@polyList){
						#check neighbor disco verts
						if ((@{$uvPosTable{$uvInfo[0]}{$uvInfo[1]}}[0] == @{$uvPosTable{$poly}{$uvInfo[1]}}[0]) &&
							(@{$uvPosTable{$uvInfo[0]}{$uvInfo[1]}}[1] == @{$uvPosTable{$poly}{$uvInfo[1]}}[1])){

							my @neighborVerts = findPolysNeighboringPolyVerts($poly,$uvInfo[1]);
							foreach my $vert (@neighborVerts){
								#if in edge mode, skip unselected edges <total hack, i need to be able to query disco uv edges>
								if ($_[0] eq "uvEdge"){
									if ($uvInfo[1] < $vert){
										if ($selectedEdgeTable{$uvInfo[1].",".$vert} != 1)	{next;}
									}else{
										if ($selectedEdgeTable{$vert.",".$uvInfo[1]} != 1)	{next;}
									}
								}
								if (($selectedUvVertTable{$poly.",".$vert} == 1) && ($checkedUvVertTable{$poly.",".$vert} != 1)){
									push(@uvVertsToCheck,$poly.",".$vert);
									push(@{$_[2]{$layer}{$roundCount}},$poly.",".$vert);
									delete $toDoListTable{$poly.",".$vert};
									$checkedUvVertTable{$poly.",".$vert} = 1;
									update2dBoundingBox(	$_[3]	,	$layer	,	$roundCount	,	@{$uvPosTable{$poly}{$vert}}[0]	,	@{$uvPosTable{$poly}{$vert}}[1]);
								}
							}
						}

						#check touching disco verts
						if ((@{$uvPosTable{$uvInfo[0]}{$uvInfo[1]}}[0] == @{$uvPosTable{$poly}{$uvInfo[1]}}[0]) &&
							(@{$uvPosTable{$uvInfo[0]}{$uvInfo[1]}}[1] == @{$uvPosTable{$poly}{$uvInfo[1]}}[1])){

							if ($poly != $uvInfo[0]){
								if ($checkedUvVertTable{$poly.",".$uvInfo[1]} != 1){
									push(@uvVertsToCheck,$poly.",".$uvInfo[1]);
									push(@{$_[2]{$layer}{$roundCount}},$poly.",".$uvInfo[1]);
									delete $toDoListTable{$poly.",".$uvInfo[1]};
									$checkedUvVertTable{$poly.",".$uvInfo[1]} = 1;
									update2dBoundingBox(	$_[3]	,	$layer	,	$roundCount	,	@{$uvPosTable{$poly}{$uvInfo[1]}}[0]	,	@{$uvPosTable{$poly}{$uvInfo[1]}}[1]);
								}
							}
						}
					}
					shift(@uvVertsToCheck);
				}
			}
		}
	}
	#UV POLY==========
	elsif ($_[0] eq "uvPoly"){
		lxout("[->] : Finding touching uvPoly groups");
		foreach my $layer (keys %{$_[1]}){
			my $layerName = lxq("query layerservice layer.name ? $layer");
			our @polys = @{$_[1]{$layer}};
			&splitUVGroups;
			my $roundCount = 0;
			foreach my $key (keys %touchingUVList){
				$roundCount++;
				push(@{$_[2]{$layer}{$roundCount}},@{$touchingUVList{$key}});
				push(@{$_[3]{$layer}{$roundCount}},@{$uvBBOXList{$key}});
			}
		}
	}
	#ERROR============
	else{
		die("This subroutine was called without any arguments so I'm cancelling the script.");
	}
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#BUILD VMAP TABLE SUB :
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#usage buildVmapTable(\%uvListRef,\%uvPosListRef,$layer);
#builds it as : table->poly->vert data
sub buildVmapTable{
	foreach my $uv ( @{$_[0]{$_[2]}} ){
		my @uvInfo = split(/,/, $uv);
		my @polyList = lxq("query layerservice vert.polyList ? $uvInfo[1]");
		foreach my $poly (@polyList){
			my @vertList = lxq("query layerservice poly.vertList ? $poly");
			my @vmapList = lxq("query layerservice poly.vmapValue ? $poly");

			for (my $i=0; $i<@vertList; $i++){
				@{$_[1]{$poly}{$vertList[$i]}} = ($vmapList[$i*2] , $vmapList[($i*2)+1]);
			}
		}
	}
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#CREATE A PER LAYER ELEMENT SELECTION LIST ver 3.0! (retuns first and last elems, and ordered list for all layers)  (THIS VERSION DOES SUPPORT EDGES <and can refine the edge names>!)
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#usage : my @firstLastEdges = createPerLayerElemList(edge,\%edges,edgeSort<optional>);
#also, if you want the edges to be sorted, ie store 12,24 instead of 24,12, then put "edgeSort" as arg3
sub createPerLayerElemList{
	my $hash = @_[1];
	my @totalElements = lxq("query layerservice selection ? @_[0]");
	if (@totalElements == 0){die("\\\\n.\\\\n[---------------------------------------------You don't have any @_[0]s selected and so I'm cancelling the script.--------------------------------------------]\\\\n[--PLEASE TURN OFF THIS WARNING WINDOW by clicking on the (In the future) button and choose (Hide Message)--] \\\\n[-----------------------------------This window is not supposed to come up, but I can't control that.---------------------------]\\\\n.\\\\n");}

	#build the full list
	foreach my $elem (@totalElements){
		$elem =~ s/[\(\)]//g;
		my @split = split/,/,$elem;
		if (@_[0] eq "edge"){
			if (@_[2] eq "edgeSort"){
				if ($split[1] < $split[2]){
					push(@{$$hash{@split[0]}},@split[1].",".@split[2]);
				}else{
					push(@{$$hash{@split[0]}},@split[2].",".@split[1]);
				}
			}else{
				push(@{$$hash{@split[0]}},@split[1].",".@split[2]);
			}
		}else{
			push(@{$$hash{@split[0]}},@split[1]);
		}

	}

	#return the first and last elements
	return(@totalElements[0],@totalElements[-1]);
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#CREATE A PER LAYER UV SELECTION LIST (only for verts and edges.  for polys, use createPerLayerElemList sub)
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#usage : my @firstLastUVs = createPerLayerUVSelList(uvVert,\%uvVerts,\@layersToReportOn)
#returns two values.  ((layer,poly,vert) , (layer,poly,vert))
#NOTE : if in edge sel mode, i must convert to verts in order to run the modo query
sub createPerLayerUVSelList{
	my @firstLastUVs;
	my $type = @_[0];
	my $hashRef = @_[1];
	my $layersArrayRef = @_[2];
	my $loopCheck = 0;

	foreach my $layer (@{$_[2]}){
		my $layerName = lxq("query layerservice layer.name ? $layer");
		$loopCheck++;

		if (@_[0] eq "uvEdge"){lx("!!select.convert vertex");}
		@{@_[1]}{$layer} = [lxq("query layerservice uvs ? selected")]; #note, this puts the array ref into the hash table.  this is how you get access : @{$_[1]{$layer}}
		$_ =~ s/[\(\)]//g for @firstLastUVs,@{$_[1]{$layer}};
		if ($loopCheck == 1)			{	push(@firstLastUVs,$layer . "," . @{$_[1]{$layer}}[0]);	}
		elsif ($loopCheck == @{@_[2]})	{	push(@firstLastUVs,$layer . "," . @{$_[1]{$layer}}[-1]);}
	}
	return(@firstLastUVs);
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#FIND POLYS NEIGHBORING POLY-VERTS SUB :
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#usage findPolysNeighboringPolyVerts($poly,$vert)
#ie : if a poly's verts are (1,2,3,4,5,6) and you tell it to look for 4, it'll return (3,5)
sub findPolysNeighboringPolyVerts{
	my @vertList = lxq("query layerservice poly.vertList ? $_[0]");
	for (my $i=0; $i<$#vertList; $i++){	if ($vertList[$i] == $_[1]){	return($vertList[$i-1],$vertList[$i+1]);	}	}
																		return($vertList[-2],$vertList[0]);
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#REMOVE ARRAY2 FROM ARRAY1 SUBROUTINE
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub removeListFromArray{
	my $array1Copy = @_[0];
	my $array2Copy = @_[1];
	my @fullList = @$array1Copy;
	my @removeList = @$array2Copy;
	for (my $i=0; $i<@removeList; $i++){
		for (my $u=0; $u<@fullList; $u++){
			if (@fullList[$u] eq @removeList[$i]	){
				splice(@fullList, $u,1);
				last;
			}
		}
	}
	return @fullList;
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#SPLIT THE POLYGONS INTO TOUCHING UV GROUPS (and build the uvBBOX) modded to make sure all variables are blank and also queries vmap name.
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
sub splitUVGroups{
	lxout("[->] Running splitUVGroups subroutine");
	our %touchingUVList = ();
	our %uvBBOXList = ();
	my %originalPolys = ();
	my %vmapTable = ();
	my @scalePolys = @polys;
	my $round = 0;
	foreach my $poly (@scalePolys){$originalPolys{$poly} = 1;}
	my $vmapName = lxq("query layerservice vmap.name ? $finalVmap");

	#---------------------------------------------------------------------------------------
	#LOOP1
	#---------------------------------------------------------------------------------------
	#[1] :	(create a current uvgroup array) : (add the first poly to it) : (set 1stpoly to 1 in originalpolylist) : (build uv list for it)
	while (@scalePolys != 0){
		#setup
		my %ignorePolys = ();
		my %totalPolyList = ();
		my @uvGroup = @scalePolys[0];
		my @nextList = @scalePolys[0];
		my $loop = 1;
		my @verts = lxq("query layerservice poly.vertList ? @scalePolys[0]");
		my @vmapValues = lxq("query layerservice poly.vmapValue ? @scalePolys[0]");
		my %vmapDiscoTable = ();
		$totalPolyList{@scalePolys[0]} = 1;
		$ignorePolys{@scalePolys[0]} = 1;

		#clear the vmapTable for every round and start it from scratch
		%vmapTable = ();
		for (my $i=0; $i<@verts; $i++){
			$vmapTable{@verts[$i]}[0] = @vmapValues[$i*2];
			$vmapTable{@verts[$i]}[1] = @vmapValues[($i*2)+1];
		}

		#build the temp uvBBOX
		my @tempUVBBOX = (999999999,999999999,-999999999,-999999999); #I'm pretty sure this'll never be capped.
		$uvBBOXList{$round} = \@tempUVBBOX;

		#put the first poly's uvs into the bounding box.
		for (my $i=0; $i<@verts; $i++){
			if ( @vmapValues[$i*2] 		< 	$uvBBOXList{$round}[0] )	{	$uvBBOXList{$round}[0] = @vmapValues[$i*2];		}
			if ( @vmapValues[($i*2)+1]	< 	$uvBBOXList{$round}[1] )	{	$uvBBOXList{$round}[1] = @vmapValues[($i*2)+1];	}
			if ( @vmapValues[$i*2] 		> 	$uvBBOXList{$round}[2] )	{	$uvBBOXList{$round}[2] = @vmapValues[$i*2];		}
			if ( @vmapValues[($i*2)+1]	> 	$uvBBOXList{$round}[3] )	{	$uvBBOXList{$round}[3] = @vmapValues[($i*2)+1];	}
		}



		#---------------------------------------------------------------------------------------
		#LOOP2
		#---------------------------------------------------------------------------------------
		while ($loop == 1){
			#[1] :	(make a list of the verts on nextlist's polys) :
			my %vertList;
			my %newPolyList;
			foreach my $poly (@nextList){
				my @verts = lxq("query layerservice poly.vertList ? $poly");
				$vertList{$_} = 1 for @verts;
			}

			#clear nextlist for next round
			@nextList = ();


			#[2] :	(make a newlist of the polys connected to the verts) :
			foreach my $vert (keys %vertList){
				my @vertListPolys = lxq("query layerservice vert.polyList ? $vert");

				#(ignore the ones that are [1] in the originalpolyList or not in the list)
				foreach my $poly (@vertListPolys){
					if (($originalPolys{$poly} == 1) && ($ignorePolys{$poly} != 1)){
						$newPolyList{$poly} = 1;
						$totalPolyList{$poly} = 1;
					}
				}
			}


			#[3] :	(go thru all the polys in the new newlist and see if their uvs are touching the newlist's uv list) : (if they are, add 'em to the uvgroup and nextlist) :
			#(build the uv list for the newlist) : (add 'em to current uvgroup array)
			foreach my $poly (keys %newPolyList){
				my @verts = lxq("query layerservice poly.vertList ? $poly");
				my @vmapValues = lxq("query layerservice poly.vmapValue ? $poly");
				my $last;

				for (my $i=0; $i<@verts; $i++){
					if ($last == 1){last;}

					for (my $j=0; $j<@{$vmapTable{@verts[$i]}}; $j=$j+2){
						#if this poly's matching so add it to the poly lists.
						if ("(@vmapValues[$i*2],@vmapValues[($i*2)+1])" eq "(@{$vmapTable{@verts[$i]}}[$j],@{$vmapTable{@verts[$i]}}[$j+1])"){
							push(@uvGroup,$poly);
							push(@nextList,$poly);
							$ignorePolys{$poly} = 1;

							#this poly's matching so i'm adding it's uvs to the uv list
							for (my $u=0; $u<@verts; $u++){
								if ($vmapDiscoTable{@verts[$u].",".@vmapValues[$u*2].",".@vmapValues[($u*2)+1]} != 1){
									push(@{$vmapTable{@verts[$u]}} , @vmapValues[$u*2]);
									push(@{$vmapTable{@verts[$u]}} , @vmapValues[($u*2)+1]);
									$vmapDiscoTable{@verts[$u].",".@vmapValues[$u*2].",".@vmapValues[($u*2)+1]} = 1;
								}
							}

							#this poly's matching, so I'll create the uvBBOX right now.
							for (my $i=0; $i<@verts; $i++){
								if ( @vmapValues[$i*2] 		< 	$uvBBOXList{$round}[0] )	{	$uvBBOXList{$round}[0] = @vmapValues[$i*2];		}
								if ( @vmapValues[($i*2)+1]	< 	$uvBBOXList{$round}[1] )	{	$uvBBOXList{$round}[1] = @vmapValues[($i*2)+1];	}
								if ( @vmapValues[$i*2] 		> 	$uvBBOXList{$round}[2] )	{	$uvBBOXList{$round}[2] = @vmapValues[$i*2];		}
								if ( @vmapValues[($i*2)+1]	> 	$uvBBOXList{$round}[3] )	{	$uvBBOXList{$round}[3] = @vmapValues[($i*2)+1];	}
							}
							$last = 1;
							last;
						}
					}
				}
			}

			#This round of UV grouping is done.  Time for the next round.
			if (@nextList == 0){
				$touchingUVList{$round} = \@uvGroup;
				$round++;
				$loop = 0;
				@scalePolys = removeListFromArray(\@scalePolys, \@uvGroup);
			}
		}
	}

	my $keyCount = (keys %touchingUVList);
	lxout("     -There are ($keyCount) uv groups");
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#UPDATE 2D BOUNDING BOX SUB
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#usage : update2dBoundingBox(\$bboxLayerHashTable,$layer,$round,$posU,$posV);
#NOTE  : requires a layer based selection hash table.
sub update2dBoundingBox{
	#lxout("$_[0] <> $_[1] <> $_[2] <> $_[3] <> $_[4]");

	if (@{$_[0]{$_[1]}{$_[2]}} == 0){
		lxout("this bbox number doesn't exist");
		@{$_[0]{$_[1]}{$_[2]}}[0] = $_[3];
		@{$_[0]{$_[1]}{$_[2]}}[1] = $_[4];
		@{$_[0]{$_[1]}{$_[2]}}[2] = $_[3];
		@{$_[0]{$_[1]}{$_[2]}}[3] = $_[4];
	}else{
		if (@{$_[0]{$_[1]}{$_[2]}}[0] > $_[3])	{	@{$_[0]{$_[1]}{$_[2]}}[0] = $_[3];	}
		if (@{$_[0]{$_[1]}{$_[2]}}[1] > $_[4])	{	@{$_[0]{$_[1]}{$_[2]}}[1] = $_[4];	}
		if (@{$_[0]{$_[1]}{$_[2]}}[2] < $_[3])	{	@{$_[0]{$_[1]}{$_[2]}}[2] = $_[3];	}
		if (@{$_[0]{$_[1]}{$_[2]}}[3] < $_[4])	{	@{$_[0]{$_[1]}{$_[2]}}[3] = $_[4];	}
	}
}



































#VERTS!
#my %verts;
#my @firstLastVerts = createPerLayerElemList(vert,\%verts);
#my %touchingVerts; returnTouchingElems("vert",\%verts,\%touchingVerts);
#foreach my $layer (keys %touchingVerts){
#	lxout("layer = $layer");
#	foreach my $group (keys %{$touchingVerts{$layer}}){
#		lxout("group = $group");
#		lxout("verts = @{$touchingVerts{$layer}{$group}}");
#	}
#}

#EDGES!
#my %edges;
#my @firstLastEdges = createPerLayerElemList(edge,\%edges,edgeSort);
#my %touchingEdges; returnTouchingElems("edge",\%edges,\%touchingEdges);
#foreach my $layer (keys %touchingEdges){
#	lxout("layer = $layer");
#	foreach my $group (keys %{$touchingEdges{$layer}}){
#		lxout("group = $group");
#		lxout("edges = @{$touchingEdges{$layer}{$group}}");
#	}
#}

#POLYS!
#my %polys;
#my @firstLastPolys = createPerLayerElemList(poly,\%polys);
#my %touchingPolys; returnTouchingElems("poly",\%polys,\%touchingPolys);
#foreach my $layer (keys %touchingPolys){
#	lxout("layer = $layer");
#	foreach my $group (keys %{$touchingPolys{$layer}}){
#		lxout("group = $group");
#		lxout("polys = @{$touchingPolys{$layer}{$group}}");
#	}
#}

#UVS VERTS!
#my $mainlayer = lxq("query layerservice layers ? main");
#&selectVmap;
#my %uvVerts;
#my @fgLayers = lxq("query layerservice layers ? fg");
#my @firstLastUvVerts = createPerLayerUVSelList(uvVert,\%uvVerts,\@fgLayers);
#my %touchingUvVerts; my %touchingUvVertBBOXes; returnTouchingElems("uvVert",\%uvVerts,\%touchingUvVerts,\%touchingUvVertBBOXes);
#foreach my $layer (keys %touchingUvVerts){
#	lxout("layer = $layer");
#	foreach my $group (keys %{$touchingUvVerts{$layer}}){
#		lxout("   group = $group");
#		lxout("      uvs = @{$touchingUvVerts{$layer}{$group}}");
#		lxout("      uvBBOX = @{$touchingUvVertBBOXes{$layer}{$group}}");
#	}
#}

#UVS EDGES!
#my $mainlayer = lxq("query layerservice layers ? main");
#&selectVmap;
#my %uvVerts;
#my %edges;
#my @fgLayers = lxq("query layerservice layers ? fg");
#my @firstLastUvVerts = createPerLayerUVSelList(uvEdge,\%uvVerts,\@fgLayers);
#my @firstLastEdges = createPerLayerElemList(edge,\%edges,edgeSort);
#my %touchingUvVerts; my %touchingUvVertBBOXes; returnTouchingElems("uvEdge",\%uvVerts,\%touchingUvVerts,\%touchingUvVertBBOXes,\%edges);
#foreach my $layer (keys %touchingUvVerts){
#	lxout("layer = $layer");
#	foreach my $group (keys %{$touchingUvVerts{$layer}}){
#		lxout("   group = $group");
#		lxout("      uvs = @{$touchingUvVerts{$layer}{$group}}");
#		lxout("      uvBBOX = @{$touchingUvVertBBOXes{$layer}{$group}}");
#	}
#}

#UVS POLYS!
#my $mainlayer = lxq("query layerservice layers ? main");
#&selectVmap;
#my %uvPolys;
#my %uvBboxes;
#my @fgLayers = lxq("query layerservice layers ? fg");
#my @firstLastPolys = createPerLayerElemList(poly,\%uvPolys);
#my %touchingUvPolys; my %touchingUvBBOXes; returnTouchingElems("uvPoly",\%uvPolys,\%touchingUvPolys,\%touchingUvBBOXes);
#foreach my $layer (keys %touchingUvPolys){
#	lxout("layer = $layer");
#	foreach my $group (keys %{$touchingUvPolys{$layer}}){
#		lxout("   group = $group");
#		lxout("      uvs = @{$touchingUvPolys{$layer}{$group}}");
#		lxout("      uvBBOX = @{$touchingUvBBOXes{$layer}{$group}}");
#	}
#}