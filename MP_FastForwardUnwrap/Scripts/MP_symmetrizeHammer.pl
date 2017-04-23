#perl
# <!-- code name : Kikurihime -->
# author : "mayatsuka" from OT-tatsunoko.
# and I'm Japanese CG Guild Master. Named "RORIKONSU".
# e-mail  `mayatsuka@gmail.com`  twitter `twitter.com/mayatsuka`



my $symDir = $ARGV[0];
my $symAxis = $ARGV[1];
# my $arg2 = $ARGV[1];

# lx("select.viewport set viewport:0 frame:1");

# $viewnum = lxq("query view3dservice view.N ?");
# 	for (my $i = 0; $i < $viewnum; $i++){
# 		if (lxq("query view3dservice view.type ? $viewnum") eq "UV2D"){
# 			@frame = lxq("query view3dservice view.frame ? $viewcount");
# 			lx("select.viewport set viewport:{$frame[1]} frame:{$frame[0]}");
# 			lxout("$frame[1]");
# 			lxout("$frame[0]");
# 			lxout("test");
# 			last;
# 		}
# 	}
# 	lxout("test2");

$axisnum = 0 if($symAxis eq "x");
$axisnum = 1 if($symAxis eq "y");
$axisnum = 2 if($symAxis eq "z");

$seltest1 = 0;
$seltest2 = 0;

$symstate = lxq("select.symmetryState ?");
$uvsymstate = lxq("select.symmetryUVState ?");
lx("select.symmetryState none");
lx("select.symmetryUVState none");

$curversion = lxq("query platformservice appversion ?");

$viewcheck = lxq("query view3dservice view.type ? selected");

if($viewcheck eq "UV2D"){

	if(lxq("select.typeFrom vertex;edge;polygon;item;pivot;center;ptag ?")) {
		$curtype = "vertex";
	}
	elsif(lxq("select.typeFrom edge;vertex;polygon;item;pivot;center;ptag ?")) {
		$curtype = "edge";
	}
	elsif(lxq("select.typeFrom polygon;edge;vertex;item;pivot;center;ptag ?")) {
		$curtype = "polygon";
	}
	elsif(lxq("select.typeFrom ptag;item;pivot;center;edge;polygon;vertex ?")) {
		$curtype = "ptag";

	}

	$uvsetName = lxq("vertMap.list txuv ?");


	lx("select.type item");

	my @fgLayers = lxq( "query layerservice layer.name ? fg" );

	foreach my $layer (@fgLayers) {
		lx("select.item {$layer} add so");
	}

	my @geoname = lxq("query sceneservice selection ? mesh" );
	lx("select.drop item");

	foreach my $selgeo (@geoname) {
		lx("select.item {$selgeo} add so");
	}

	lx("select.editSet itemtemp add");

		$itemcount = lxq("select.count item ?");
	
	lx("select.type vertex");
	$vertcheck = lxq("select.count vertex ?");
	lx("select.editSet verttemp add")if($vertcheck != 0);
	lx("select.type edge");
	$edgecheck = lxq("select.count edge ?");
	lx("select.editSet edgetemp add")if($edgecheck != 0);
	lx("select.type polygon");
	$polygoncheck = lxq("select.count polygon ?");
	lx("select.editSet polygontemp add")if($polygoncheck != 0);

	if($vertcheck != 0 or $polygoncheck != 0){

		if($curtype eq "vertex"){
			lx("select.vertexConnect uv");
			lx("select.convert polygon");
		}

		lx("select.polygonConnect uv")if($curtype eq "polygon");

		lx("select.editSet curpolygon2 add");
		if($itemcount != 1){
			lx("select.copy");
			lx("select.type item");
			lx("select.drop item");
			lx("select.type polygon");
			lx("layer.new");
			lx("item.name symtemp");
			$itemname = lxq("item.name ?");
			lx("select.paste");		
		}
		elsif($itemcount == 1){
			lx("item.duplicate false all:true");
			$itemname = lxq("item.name ?");
			lx("select.type polygon");
			lx("select.useSet curpolygon2 select");
			lx("select.invert");
			lx("select.delete")if(lxq("select.count polygon ?") != 0);
		}



		if($curtype eq "vertex"){

			lx("select.type edge");
			lx("select.drop edge");
			lx("uv.selectBorder");
				# lx("convert.vertex");
				# lx("select.editSet boundvert add");
				# lx("select.type edge");
			lx("edge.split false 0.0")if($curversion > 802 or $curversion < 210);
			lx("edge.split")if($curversion < 802 and $curversion > 210);
			
			lx("select.type vertex");
			lx("select.drop vertex");
			lx("select.useSet verttemp select");
			lx("select.useSet boundvert deselect");
			# lx("vertMap.deleteByName pick boundvert");

			$mainLayer = lxq("query layerservice layer.id ? main");

			$pncheckup = 0;
			$pncheckdo = 0;
			$vertloop = $vertcheck;
			while ($vertloop > 0){
				$lastcount = lxq("select.count vertex ?");
				if($lastcount != 1){
					lx("select.editSet vert1 add");
					lx("select.less");
					lx("select.editSet vert2 add");

					lx("select.useSet vert1 select");
					lx("select.useSet vert2 deselect");					
				}


				$selvert = lxq("query layerservice verts ? selected");
				@vertpos = lxq("query layerservice vert.pos ? $selvert");
				# lxout("@vertpos[0]");

				if(@vertpos[$axisnum] > 0){
					lx("select.editSet verthi add");
					$seltest1 = 1;
				}
				if(@vertpos[$axisnum] < 0){
					lx("select.editSet vertlow add");
					$seltest2 = 1;
				}

				lx("select.drop vertex");
				lx("select.useSet vert2 select");
				lx("!!vertMap.deleteByName pick vert1");
				lx("!!vertMap.deleteByName pick vert2");


				$vertloop -= 1;

				lxout("$vertloop");

			}

			if($seltest1 != 0 and $seltest2 != 0){
				lx("select.type vertex");
				lx("select.drop vertex");
				lx("select.useSet verthi select");
				lx("select.connect");

				lx("tool.set TransformMove on");
				lx("tool.set actr.auto on");
				lx("tool.viewType xyz");
				lx("tool.setAttr xfrm.transform TX 0.1")if($symAxis eq "x");
				lx("tool.setAttr xfrm.transform TY 0.1")if($symAxis eq "y");
				lx("tool.setAttr xfrm.transform TZ 0.1")if($symAxis eq "z");
				lx("tool.doApply");

				lx("select.drop vertex");
				lx("select.useSet vertlow select");
				lx("select.connect");

				lx("tool.set TransformMove on");
				lx("tool.set actr.auto on");
				lx("tool.viewType xyz");
				lx("tool.setAttr xfrm.transform TX -0.1")if($symAxis eq "x");
				lx("tool.setAttr xfrm.transform TY -0.1")if($symAxis eq "y");
				lx("tool.setAttr xfrm.transform TZ -0.1")if($symAxis eq "z");
				lx("tool.doApply");
				lx("tool.drop");				
			}



			lx("!!vertMap.deleteByName pick verthi");
			lx("!!vertMap.deleteByName pick vertlow");

		}

			# &symfix;
			# &symfixrev;
			
		if($curtype eq "vertex"){
			lx("select.type polygon");
			lx("select.all");
		}


		lx("uv.symmetrize {$symAxis} p2n align:true")if($symDir eq "p");
		lx("uv.symmetrize {$symAxis} n2p align:true")if($symDir eq "n");

		lx("select.type polygon");
		lx("select.all");
		lx("uv.copy");
		lx("select.type item");
		lx("select.item {$itemname}");
		lx("item.delete");

		lx("select.useSet itemtemp select");
		lx("select.deleteSet itemtemp delete");
		lx("vertMap.list txuv {$uvsetName}");
		if($curtype eq "vertex"){
			lx("select.type polygon");
			lx("select.useSet curpolygon2 select");
		}
		lx("uv.paste selection")if($curversion > 802 or $curversion < 210);
		lx("uv.paste")if($curversion < 802 and $curversion > 210);
		# lxout("$curversion");

		lx("select.type polygon");
		lx("select.useSet curpolygon2 select");
		lx("select.deleteSet curpolygon2 delete");

		# lx("select.type vertex");
		# lx("select.useSet verttemp select")if($vertcheck != 0);
		# lx("select.deleteSet verttemp delete")if($vertcheck != 0);
		# lx("select.type edge");
		# lx("select.useSet edgetemp select")if($edgecheck != 0);
		# lx("vertMap.deleteByName epck edgetemp")if($edgecheck != 0);
		# lx("select.type polygon");
		# lx("select.useSet polygontemp select")if($polygoncheck != 0);
		# lx("select.deleteSet polygontemp delete")if($polygoncheck != 0);

		lx("select.polygonConnect uv");

		lx("tool.viewType uv");
		lx("tool.set TransformScale on");
		lx("tool.set actr.auto on");

		lx("tool.reset");

		lx("tool.attr center.auto cenU 0.5");
		lx("tool.attr center.auto cenV 0.5");

		lx("tool.attr xfrm.transform SX 0.5");
		lx("tool.attr xfrm.transform SY 0.5");

		lx("tool.doApply");

		lx("tool.drop");

		# lx("tool.set TransformMove on");
		lx("tool.set actr.auto off");

		lx("select.type vertex");
		lx("select.useSet verttemp select")if($vertcheck != 0);
		lx("select.deleteSet verttemp delete")if($vertcheck != 0);
		lx("select.type edge");
		lx("select.useSet edgetemp select")if($edgecheck != 0);
		lx("vertMap.deleteByName epck edgetemp")if($edgecheck != 0);
		lx("select.type polygon");
		# lx("select.useSet polygontemp select")if($polygoncheck != 0);
		# lx("select.deleteSet polygontemp delete")if($polygoncheck != 0);		

	}
}
lx("select.symmetryState {$symstate}");
lx("select.symmetryUVState {$uvsymstate}");


sub symfix{
	lx("select.symmetryState z");
	lx("tool.set symmetry.tool on");
	lx("tool.reset");
	lx("tool.attr symmetry.tool reverse false");
	lx("tool.setAttr symmetry.tool threshold 0.0005");
	lx("tool.doApply");
	# lx("tool.drop");

	lx("select.symmetryState y");
	# lx("tool.set symmetry.tool on");
	# lx("tool.reset");
	# lx("tool.setAttr symmetry.tool threshold 0.0015");
	lx("tool.doApply");
	# lx("tool.drop");

	lx("select.symmetryState x");
	# lx("tool.set symmetry.tool on");
	# lx("tool.reset");
	# lx("tool.setAttr symmetry.tool threshold 0.0015");
	lx("tool.doApply");
	lx("tool.drop");
}

sub symfixrev{
	lx("select.symmetryState z");
	lx("tool.set symmetry.tool on");
	lx("tool.reset");
	lx("tool.attr symmetry.tool reverse true");
	lx("tool.setAttr symmetry.tool threshold 0.0005");
	lx("tool.doApply");
	# lx("tool.drop");

	lx("select.symmetryState y");
	# lx("tool.set symmetry.tool on");
	# lx("tool.reset");
	# lx("tool.attr symmetry.tool reverse true");
	# lx("tool.setAttr symmetry.tool threshold 0.0015");
	lx("tool.doApply");
	# lx("tool.drop");

	lx("select.symmetryState x");
	# lx("tool.set symmetry.tool on");
	# lx("tool.reset");
	# lx("tool.attr symmetry.tool reverse true");
	# lx("tool.setAttr symmetry.tool threshold 0.0015");
	lx("tool.doApply");
	lx("tool.drop");
}