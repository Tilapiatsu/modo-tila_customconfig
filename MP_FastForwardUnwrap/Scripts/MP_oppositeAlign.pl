#perl
# <!-- code name : Kikurihime -->
# author : "mayatsuka" from OT-tatsunoko.
# and I'm Japanese CG Guild Master. Named "RORIKONSU".
# e-mail  `mayatsuka@gmail.com`  twitter `twitter.com/mayatsuka`


my $uvstate = $ARGV[0];


$symstate = lxq("select.symmetryState ?");
lx("select.symmetryState none");

$curversion = lxq("query platformservice appversion ?");

if(lxq("select.typeFrom vertex;edge;polygon;item;pivot;center;ptag ?")) {
	$curtype = "vertex";

	$layerswitch = 1;

	&multifix;
}
# elsif(lxq("select.typeFrom edge;vertex;polygon;item;pivot;center;ptag ?")) {
# 	$curtype = "edge";

# 	$layerswitch = 2;

# 	$edgecount = lxq("select.count edge ?");
# 	# lx("select.editSet curedge add")if($edgecount != 0);

# 	if($edgecount != 0){
# 		lx("select.editSet curedge add");
# 		lx("select.drop edge");
# 		lx("select.useSet curedge select");	
# 	}
# 	# lx("select.convert vertex")if(lxq("select.count edge ?") == 1);

# 	if($edgecount != 0 and $edgecount < 20){
# 		for ($i = 0; $i < $edgecount; $i++){
# 			my $currentcount2 = lxq("query layerservice edge.n ? selected");

# 			if ($currentcount2 == 1){

# 				$layerswitch = 1 if($edgecount == 1);
# 				$layerswitch = 4 if($edgecount != 1);

# 				lx("select.convert vertex");
# 				&multifix;

# 				lx("select.type $curtype");
# 				lx("select.useSet curedge select");
# 				lx("vertMap.deleteByName epck curedge");

# 				last;
# 			}
# 			elsif ($currentcount2 != 1){

# 				lx("select.editSet edgetemp1 add");
# 				lx("select.less");
# 				lx("select.editSet edgetemp2 add");

# 				lx("select.useSet edgetemp1 select");
# 				lx("select.useSet edgetemp2 deselect");

# 				lx("select.convert vertex");
# 				&multifix;

# 				$layerswitch = 3;

# 				lx("select.drop edge");
# 				lx("select.useSet edgetemp2 select");

# 				lx("vertMap.deleteByName epck edgetemp1");
# 				lx("vertMap.deleteByName epck edgetemp2");			
# 			}
# 		}			
# 	}
# }
elsif(lxq("select.typeFrom polygon;edge;vertex;item;pivot;center;ptag ?")) {

	$transcheck = lxq("tool.set TransformMove ?");
	
	$curtype = "vertex";

	$layerswitch = 1;

	lx("select.type vertex");

	&multifix;

	lx("select.type polygon");

	lx("tool.set TransformMove on")if($transcheck eq "on");

}

sub multifix{

	$vertnum = lxq("select.count vertex ?");
	if($vertnum == 1){

		$uvsetName = lxq("vertMap.list txuv ?");

		lx("select.editSet curvert add");

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

		if($curtype ne "polygon"){
			lx("select.type polygon");
			$polycount = lxq("select.count polygon ?");
			lx("select.editSet curpolygon add")if($polycount != 0);		
		}

		lx("select.type vertex");

		lx("select.vertexConnect uv");
		lx("select.convert polygon");

		lx("select.copy");
			lx("select.type item");
			lx("select.drop item");
			lx("select.type polygon");
			lx("layer.new");
			lx("item.name alignlayer");	
		lx("select.paste");

		lx("select.type item");
		lx("select.drop item");
		lx("select.item alignlayer");

		$mainLayer = lxq("query layerservice layer.id ? main");
		# lxout("$mainLayer");

		lx("tool.viewType uv");
		lx("vertMap.list txuv {$uvsetName}");

		lx("select.type vertex");
		lx("select.drop vertex");
		lx("select.useSet curvert select");


		$seluv1 = lxq("query layerservice uvs ? selected");
		@vertpos1 = lxq("query layerservice uv.pos ? $seluv1");

		lx("select.type item");
		lx("select.item alignlayer");
			lx("item.delete");
		lx("select.useSet itemtemp select");
		lx("vertMap.list txuv {$uvsetName}");
		lx("select.deleteSet itemtemp delete");

		if($polycount != 0){
			lx("select.type polygon");
			lx("select.useSet curpolygon select");
			lx("select.deleteSet curpolygon delete");
		}


		lx("select.type vertex");
		lx("select.useSet curvert select");

		$loopplusx1 = @vertpos1[0];
		$loopminusx1 = @vertpos1[0];
		$loopcheckx1 = 0;
		while($loopplusx1 > 1){
			$loopplusx1 -= 1;
			$loopcheckx1 += 1;
		}
		while($loopminusx1 < 0){
			$loopminusx1 += 1;
			$loopcheckx1 -= 1;
		}

			$loopplusy1 = @vertpos1[1];
			$loopminusy1 = @vertpos1[1];
			$loopchecky1 = 0;
			while($loopplusy1 > 1){
				$loopplusy1 -= 1;
				$loopchecky1 += 1;
			}
			while($loopminusy1 < 0){
				$loopminusy1 += 1;
				$loopchecky1 -= 1;
			}


		if($uvstate eq "u"){
			$secondmovex = 0.5 - (@vertpos1[0] - $loopcheckx1);

			$secondmovey = 0;
		}

		if($uvstate eq "v"){
			$secondmovey = 0.5 - (@vertpos1[1] - $loopchecky1);

			$secondmovex = 0;	
		}


			lx("select.connect uv");
			
			lx("tool.viewType uv");
			lx("tool.set TransformMove on");
			lx("tool.set actr.auto on");


			lx("tool.setAttr center.auto cenU @vertpos1[0]");
			lx("tool.setAttr center.auto cenV @vertpos1[1]");
			
			lx("tool.setAttr xfrm.transform U $secondmovex");
			lx("tool.setAttr xfrm.transform V $secondmovey");
			lx("tool.doApply");
			lx("tool.set actr.auto off");
			lx("tool.drop");

			lx("select.drop vertex");
			lx("select.useSet curvert select");
			lx("vertMap.deleteByName PICK curvert");

			lx("select.type $curtype");

	}
	
	if($vertnum == 2 or $vertnum == 4){

		$uvsetName = lxq("vertMap.list txuv ?");

		lx("select.editSet curvert add");
		lx("select.less");
		lx("select.less")if($vertnum == 4);
		lx("select.editSet firstvert add");
		lx("select.useSet curvert select");
		lx("select.useSet firstvert deselect");
		lx("select.editSet secondvert add");
		lx("select.useSet curvert select");


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

		if($curtype ne "polygon"){
			lx("select.type polygon");
			$polycount = lxq("select.count polygon ?");
			lx("select.editSet curpolygon add")if($polycount != 0);		
		}

		lx("select.type vertex");
		lx("select.drop vertex");
		lx("select.useSet firstvert select");

		lx("select.vertexConnect uv");
		lx("select.convert polygon");

		lx("select.copy");
		if($layerswitch == 1 or $layerswitch == 2){
			lx("select.type item");
			lx("select.drop item");
			lx("select.type polygon");
			lx("layer.new");
			lx("item.name alignlayer");	
		}
		if($layerswitch == 3 or $layerswitch == 4){
			lx("select.item alignlayer");
		}

		lx("select.paste");

		lx("select.type polygon");
		lx("select.all");
		lx("uv.cut");
		lx("uv.paste selection")if($curversion > 802);		
		lx("uv.paste")if($curversion < 802);
		lx("select.drop polygon");

		lx("select.type item");
		lx("select.drop item");
		lx("select.item alignlayer");

		$mainLayer = lxq("query layerservice layer.id ? main");
		# lxout("$mainLayer");

		lx("tool.viewType uv");
		lx("vertMap.list txuv {$uvsetName}");

		lx("select.type vertex");
		lx("select.drop vertex");

		lx("select.useSet firstvert select");
		$seluv1 = lxq("query layerservice uvs ? selected");
		@vertpos1 = lxq("query layerservice uv.pos ? $seluv1");
		lx("select.type polygon");
		lx("select.all");
		lx("uv.cut");

		lx("select.type item");
		lx("select.useSet itemtemp select");
		lx("select.type vertex");
		lx("select.drop vertex");
		lx("select.useSet secondvert select");
		lx("select.vertexConnect uv");
		lx("select.convert polygon");

		lx("select.copy");
		lx("select.type item");
		lx("select.item alignlayer");

		lx("select.paste");

		lx("select.type polygon");
		lx("select.all");
		lx("uv.cut");
		lx("uv.paste selection")if($curversion > 802);		
		lx("uv.paste")if($curversion < 802);
		lx("select.drop polygon");

		lx("select.type vertex");
		lx("select.useSet secondvert select");
		$seluv2 = lxq("query layerservice uvs ? selected");
		@vertpos2 = lxq("query layerservice uv.pos ? $seluv2");


		lx("select.type item");
		lx("select.item alignlayer");

		if($layerswitch == 1 or $layerswitch == 4){
			lx("item.delete");
		}
		if($layerswitch == 2 or $layerswitch == 3){
			lx("select.drop item");
		}

		lx("select.useSet itemtemp select");
		lx("vertMap.list txuv {$uvsetName}");
		lx("select.deleteSet itemtemp delete");

		if($polycount != 0){
			lx("select.type polygon");
			lx("select.useSet curpolygon select");
			lx("select.deleteSet curpolygon delete");
		}

		lx("select.type vertex");
		lx("select.useSet curvert select");

		lx("vertMap.deleteByName PICK firstvert");
		# lx("vertMap.deleteByName PICK secondvert");

		# lx("select.deleteSet firstvert delete");
		# lx("select.deleteSet secondvert delete");
		$loopplusx1 = @vertpos1[0];
		$loopminusx1 = @vertpos1[0];
		$loopcheckx1 = 0;
		while($loopplusx1 > 1){
			$loopplusx1 -= 1;
			$loopcheckx1 += 1;
		}
		while($loopminusx1 < 0){
			$loopminusx1 += 1;
			$loopcheckx1 -= 1;
		}

			$loopplusy1 = @vertpos1[1];
			$loopminusy1 = @vertpos1[1];
			$loopchecky1 = 0;
			while($loopplusy1 > 1){
				$loopplusy1 -= 1;
				$loopchecky1 += 1;
			}
			while($loopminusy1 < 0){
				$loopminusy1 += 1;
				$loopchecky1 -= 1;
			}


		$loopplusx2 = @vertpos2[0];
		$loopminusx2 = @vertpos2[0];
		$loopcheckx2 = 0;
		while($loopplusx2 > 1){
			$loopplusx2 -= 1;
			$loopcheckx2 += 1;
		}
		while($loopminusx2 < 0){
			$loopminusx2 += 1;
			$loopcheckx2 -= 1;
		}

			$loopplusy2 = @vertpos2[1];
			$loopminusy2 = @vertpos2[1];
			$loopchecky2 = 0;
			while($loopplusy2 > 1){
				$loopplusy2 -= 1;
				$loopchecky2 += 1;
			}
			while($loopminusy2 < 0){
				$loopminusy2 += 1;
				$loopchecky2 -= 1;
			}


		if($uvstate eq "u"){
			$secondposx = 1 - (@vertpos1[0] - $loopcheckx1);
			$secondmovex = $secondposx - (@vertpos2[0] - $loopcheckx2) + ($loopcheckx1 - $loopcheckx2);

			$secondposy = 1 - (@vertpos1[1] - $loopchecky1);
			$secondmovey = (@vertpos1[1] - $loopchecky1) - (@vertpos2[1] - $loopchecky2) + ($loopchecky1 - $loopchecky2);			
		}

		if($uvstate eq "v"){
			$secondposy = 1 - (@vertpos1[1] - $loopchecky1);
			$secondmovey = $secondposy - (@vertpos2[1] - $loopchecky2) + ($loopchecky1 - $loopchecky2);

			$secondposx = 1 - (@vertpos1[0] - $loopcheckx1);
			$secondmovex = (@vertpos1[0] - $loopcheckx1) - (@vertpos2[0] - $loopcheckx2) + ($loopcheckx1 - $loopcheckx2);			
		}




		# $secondposx = 1 - (@vertpos1[0] - $loopcheckx1);
		# $secondmovex = $secondposx - (@vertpos2[0] - $loopcheckx2) + $loopcheckx1;

		# $secondposy = 1 - (@vertpos1[1] - $loopchecky1);
		# $secondmovey = $secondposy - (@vertpos2[1] - $loopchecky2) + $loopchecky1;





			if($curtype eq "vertex" or $curtype eq "edge"){
				lx("select.drop vertex");
				lx("select.useSet secondvert select");
				lx("vertMap.deleteByName PICK secondvert");
				lx("select.connect uv");	
			}
			if($curtype eq "polygon"){
				if($polyedgenum == 1){
					lx("select.type edge");
					lx("select.useSet polyedge select");
					lx("vertMap.deleteByName epck polyedge");
				}
				lx("select.type polygon");
				# lx("select.useSet curpolygon select")if($polycount != 0);
				# lx("select.deleteSet curpolygon delete")if($polycount != 0);
			}
			
			lx("tool.viewType uv");
			lx("tool.set TransformMove on");
			lx("tool.set actr.auto on");

			if($curtype eq "edge"){
				lx("tool.setAttr center.auto cenU $midx");
				lx("tool.setAttr center.auto cenV $midy");
			}
			else{
				lx("tool.setAttr center.auto cenU @vertpos2[0]");
				lx("tool.setAttr center.auto cenV @vertpos2[1]");			
			}
			
			lx("tool.setAttr xfrm.transform U $secondmovex");
			lx("tool.setAttr xfrm.transform V $secondmovey");
			lx("tool.doApply");
			lx("tool.set actr.auto off");
			lx("tool.drop");

			lx("select.drop vertex");
			lx("select.useSet curvert select");
			lx("vertMap.deleteByName PICK curvert");

				# lx("select.type polygon");
				# lx("select.useSet curpolygon select")if($polycount != 0);
				# lx("select.deleteSet curpolygon delete")if($polycount != 0);

			lx("select.type $curtype");

			# if($curtype eq "edge" and $edgecount ne 0){
			# 	lx("select.useSet curedge select");
			# 	lx("vertMap.deleteByName epck curedge");
			# }

	}

}

lx("select.symmetryState {$symstate}");