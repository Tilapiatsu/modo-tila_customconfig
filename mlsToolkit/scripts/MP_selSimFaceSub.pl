#perl

# this script uses "Legendaly modo programmer Seneca Menard's method"
# say thanx to seneca my lord.

#------------------------ mp modified
if(lxq( "!!select.typeFrom {polygon;vertex;edge;item} ?" )){

$toolcheck = lxq("tool.set sculpt.maskErase ?");

if ($toolcheck ne on){
	lx("tool.set sculpt.maskErase on rawquery:true");
}
elsif ($toolcheck eq on){
my $getbrushsize = lxq("tool.attr brush.smooth size ?");
if ($getbrushsize > 300){
	$correctionvalue = 1.3;
}
else{
	$correctionvalue = $getbrushsize / 1000 + 1;
}



	$layernum = lxq("query layerservice layer.N ? fg");

	if($layernum > 1){
		$polycount = lxq("select.count polygon ?");
		lx("select.editSet curpoly add")if($polycount != 0);

		lx("select.drop polygon");
		lx("select.3DElementUnderMouse set");
		$polycheck = lxq("select.count polygon ?");
		lx("select.editSet selpoly add")if($polycheck != 0);


		lx("select.type vertex");
		$vertexcount = lxq("select.count vertex ?");
		lx("select.editSet curvertex add")if($vertexcount != 0);

		lx("select.type edge");
		$edgecount = lxq("select.count edge ?");
		lx("select.editSet curedge add")if($edgecount != 0);
		lx("select.type item");
		
		$itemnum = lxq("select.count item ?");
		
		@fgLayers = lxq( "query layerservice layer.name ? fg" );

		if($itemnum == 0){
			foreach my $layer (@fgLayers) {
				lx("select.item {$layer} add so");
			}			
		}

		@geoname = lxq("query sceneservice selection ? mesh" );
		lx("select.drop item");

		foreach my $selgeo (@geoname) {
			lx("select.item {$selgeo} add so");
		}

		lx("lock.unsel");

		foreach my $selgeo (@geoname) {
			lx("select.item {$selgeo} add so");
		}
		lx("select.drop item");

		lx("select.3DElementUnderMouse set");

		$itemnum2 = lxq("select.count item ?");
		if($itemnum2 == 0){
			foreach my $layer (@fgLayers) {
				lx("select.item {$layer} add so");
			}
			lx("select.type vertex");
			lx("select.useSet curvertex select")if($vertexcount != 0);
			lx("select.deleteSet curvertex delete")if($vertexcount != 0);
			
			lx("select.type edge");
			lx("select.useSet curedge select")if($edgecount != 0);
			lx("vertMap.deleteByName epck curedge")if($edgecount != 0);

			lx("select.type polygon");
			lx("select.useSet curpoly select")if($polycount != 0);
			lx("select.deleteSet curpoly delete")if($polycount != 0);
			return;
		}

		lx("unlock");

		lx("select.type polygon");

	}
	elsif($layernum == 1){
		$selcount = lxq("select.count polygon ?");
		lx("!!select.editSet keepsel1 add")if($selcount != 0);

		lx("select.drop polygon");
		lx("select.3DElementUnderMouse set");
		$polycheck = lxq("select.count polygon ?");
		lx("select.editSet selpoly add")if($polycheck != 0);
	}



lx("select.useSet selpoly select")if($polycheck != 0);

if (lxq("select.count polygon ?") == 0){
	&selsum;
	return;
}

lx("!!select.drop polygon");
# lx("!!select.3DElementUnderMouse add");
lx("select.useSet selpoly select")if($polycheck != 0);
#------------------------

my $mainlayer = lxq("query layerservice layers ? main");
my @originalPolys = lxq("query layerservice polys ? selected");
my @matchingPolys;
my %normalList;
my $count;
my $pi = 3.14159265358979323;


my $facingRatio = 40.0;
$facingRatio = $facingRatio*($pi/180);
$facingRatio = cos($facingRatio) * $correctionvalue;

my $accuracy = 10.0;
$accuracy = $accuracy*($pi/180);
$accuracy = cos($accuracy);


	my @firstPolyNormal = lxq("query layerservice poly.normal ? @originalPolys[0]");
	$normalList{"@firstPolyNormal[0] @firstPolyNormal[1] @firstPolyNormal[2]"}[0] = @firstPolyNormal[0];
	$normalList{"@firstPolyNormal[0] @firstPolyNormal[1] @firstPolyNormal[2]"}[1] = @firstPolyNormal[1];
	$normalList{"@firstPolyNormal[0] @firstPolyNormal[1] @firstPolyNormal[2]"}[2] = @firstPolyNormal[2];

	foreach my $poly (@originalPolys)
	{
		my @normal = lxq("query layerservice poly.normal ? $poly");

		my $loopCount = keys %normalList;
		my $i = 1;
		foreach my $key (keys %normalList)
		{
			my $dp = ((@normal[0]*$normalList{$key}[0])+(@normal[1]*$normalList{$key}[1])+(@normal[2]*$normalList{$key}[2]));
			if ($dp > $accuracy)
			{
				last;
			}
			elsif ($i == $loopCount)
			{
				$normalList{"@normal[0] @normal[1] @normal[2]"}[0] = @normal[0];
				$normalList{"@normal[0] @normal[1] @normal[2]"}[1] = @normal[1];
				$normalList{"@normal[0] @normal[1] @normal[2]"}[2] = @normal[2];
			}
			else
			{
				$i++;
			}
		}
	}

	my $stopScript = 0;
	our %totalPolyList;
	my %currentPolys;
	my @lastPolyList;
	my $i = 0;

	if ($selectByPoly == 0)
	{
		foreach my $poly (@originalPolys)		{	$totalPolyList{$poly} = 1;		}
	}
	else
	{
		%totalPolyList =();
	}
	@lastPolyList = @originalPolys;


	while ($stopScript == 0)
	{
		my %vertList;
		foreach my $poly (@lastPolyList)
		{
			my @verts = lxq("query layerservice poly.vertList ? $poly");

			foreach my $vert (@verts)
			{
				if ($vertList{$vert} == "")
				{
					$vertList{$vert} = 1;
				}
			}
		}
		foreach my $vert (keys %vertList)
		{
			my @polys = lxq("query layerservice vert.polyList ? $vert");

			foreach my $poly (@polys)
			{
				if (lxq("query layerservice poly.hidden ? $poly") == 0)
				{
					if ($totalPolyList{$poly} == "")
					{
						if ($currentPolys{$poly} == "")
						{
							$currentPolys{$poly} = 1;
						}
					}
				}
			}
		}

		foreach my $poly (keys %currentPolys)
		{
			my @normal = lxq("query layerservice poly.normal ? $poly");
			foreach my $key(keys %normalList)
			{
				my $dp = ((@normal[0]*$normalList{$key}[0])+(@normal[1]*$normalList{$key}[1])+(@normal[2]*$normalList{$key}[2]));
				if ($dp >= $facingRatio)
				{
					push(@matchingPolys,$poly);
					last;
				}
			}
		}

		for (my $i =0; $i<@matchingPolys; $i++){ 	lx("select.element $mainlayer polygon add @matchingPolys[$i]"); 	}


		if ($#matchingPolys == -1)
		{
			$stopScript = 1;
		}

		foreach my $poly (keys %currentPolys)	{	$totalPolyList{$poly} = 1;		}

		if ($selectByPoly == 1)
		{
			delete $selByPolyTable{@originalPolys[0]};
			foreach my $poly (@matchingPolys)
			{
				delete $selByPolyTable{$poly};
			}

			my $selByPolyTableCount = scalar(keys(%selByPolyTable));
			if (($selByPolyTableCount == 0) && ($expandPolyLoop == 1))
			{
				$expandPolyLoop = 0;
			}
		}
		@lastPolyList = @matchingPolys;
		@matchingPolys = ();
		%currentPolys = ();
	}

#----------------------mp modified
# if ($selcheck1 == $selcheck2){
# 	lx("!!select.useSet keepsel1 select");
# 	lx("!!select.clearSet keepsel1 false");
# }
# elsif ($selcheck1 == $selcheck3){
	lx("select.editSet keepsel2 add");
	lx("select.drop polygon");
	&selsum;
sub selsum{
	if($layernum > 1){
		foreach my $selgeo (@geoname) {
			lx("select.item {$selgeo} add so");
		}
		lx("select.type vertex");
		lx("select.useSet curvertex select")if($vertexcount != 0);
		lx("select.deleteSet curvertex delete")if($vertexcount != 0);
		
		lx("select.type edge");
		lx("select.useSet curedge select")if($edgecount != 0);
		lx("vertMap.deleteByName epck curedge")if($edgecount != 0);

		lx("select.type polygon");
		lx("select.useSet curpoly select")if($polycount != 0);
		lx("select.deleteSet curpoly delete")if($polycount != 0);
		lx("select.deleteSet selpoly delete")if($polycheck != 0);
	}
	elsif($layernum == 1){
		lx("select.useSet keepsel1 select")if($selcount != 0);
		lx("select.deleteSet keepsel1 delete")if($selcount != 0);
		lx("select.deleteSet selpoly delete")if($polycheck != 0);
	}	
}

	lx("select.useSet keepsel2 deselect");
	lx("select.deleteSet keepsel2 delete");
# }
}
#----------------------
}