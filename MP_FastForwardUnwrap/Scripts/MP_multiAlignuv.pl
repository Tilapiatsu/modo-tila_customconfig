#perl
# <!-- code name : Kikurihime -->
# author : "mayatsuka" from OT-tatsunoko.
# and I'm Japanese CG Guild Master. Named "RORIKONSU".
# e-mail  `mayatsuka@gmail.com`  twitter `twitter.com/mayatsuka`


$symstate = lxq("select.symmetryState ?");
$uvsymstate = lxq("select.symmetryUVState ?");
lx("select.symmetryState none");
lx("select.symmetryUVState none");

$curversion = lxq("query platformservice appversion ?");


if(lxq("select.typeFrom vertex;edge;polygon;item;pivot;center;ptag ?")) {
	$curtype = "vertex";

	$layerswitch = 1;

	lx("select.type edge");
	$edgecount = lxq("select.count edge ?");
	lx("select.editSet curedge add")if($edgecount != 0);

	lx("select.type polygon");
	$polycount = lxq("select.count polygon ?");
	lx("select.editSet curpolygon add")if($polycount != 0);
	lx("select.type vertex");

	&multifix;

	if($edgecount != 0){
		lx("select.type edge");
		lx("select.useSet curedge select");
		lx("vertMap.deleteByName epck curedge");
	}

	if($polycount != 0){
		lx("select.type polygon");
		lx("select.useSet curpolygon select");
		lx("select.deleteSet curpolygon delete");
	}
	lx("select.type vertex");
}
elsif(lxq("select.typeFrom edge;vertex;polygon;item;pivot;center;ptag ?")) {
	$curtype = "edge";

	$layerswitch = 2;

	lx("select.type vertex");
	$vertcount = lxq("select.count vertex ?");
	lx("select.editSet curvert2 add")if($vertcount != 0);

	lx("select.type polygon");
	$polycount = lxq("select.count polygon ?");
	lx("select.editSet curpolygon add")if($polycount != 0);
	lx("select.type edge");

	$edgecount = lxq("select.count edge ?");
	# lx("select.editSet curedge add")if($edgecount != 0);

	if($edgecount != 0){
		lx("select.editSet curedge add");
		if($edgecount > 1){
			lx("select.drop edge");
			lx("select.useSet curedge select");	
		}
	}
	# lx("select.convert vertex")if(lxq("select.count edge ?") == 1);

	if($edgecount != 0 and $edgecount < 20){
		for ($i = 0; $i < $edgecount; $i++){
			my $currentcount2 = lxq("query layerservice edge.n ? selected");

			if ($currentcount2 == 1){

				$layerswitch = 1 if($edgecount == 1);
				$layerswitch = 4 if($edgecount != 1);

				lx("select.convert vertex");
				&multifix;

				if($vertcount != 0){
					lx("select.type vertex");
					lx("select.drop vertex");
					lx("select.useSet curvert2 select");
					lx("vertMap.deleteByName PICK curvert2");
				}

				if($polycount != 0){
					lx("select.type polygon");
					lx("select.useSet curpolygon select");
					lx("select.deleteSet curpolygon delete");
				}

				lx("select.type $curtype");
				lx("select.useSet curedge select");
				lx("vertMap.deleteByName epck curedge");

				last;
			}
			elsif ($currentcount2 != 1){

				lx("select.editSet edgetemp1 add");
				lx("select.less");
				lx("select.editSet edgetemp2 add");

				lx("select.useSet edgetemp1 select");
				lx("select.useSet edgetemp2 deselect");

				lx("select.convert vertex");
				&multifix;

				$layerswitch = 3;

				lx("select.drop edge");
				lx("select.useSet edgetemp2 select");

				lx("vertMap.deleteByName epck edgetemp1");
				lx("vertMap.deleteByName epck edgetemp2");			
			}
		}			
	}




}
elsif(lxq("select.typeFrom polygon;edge;vertex;item;pivot;center;ptag ?")) {
	$curtype = "polygon";

	$layerswitch = 1;

	$polycount = lxq("select.count polygon ?");
	if($polycount != 0){
		lx("select.editSet curpolygon add");

		lx("select.type edge");
		$polyedgenum = lxq("select.count edge ?");
		if($polyedgenum == 1){
			lx("select.editSet polyedge add");
			lx("select.convert vertex");		
		}
		if($polyedgenum == 2){
			lx("select.less");
			lx("select.editSet polyedge add");
			lx("select.convert vertex");		
		}


		lx("select.type vertex");

		&multifix;	
	}

}

sub multifix{

	$vertnum = lxq("select.count vertex ?");

	if($vertnum > 1){
		# if($vertnum ne 2 and $curtype ne "vertex"){
		# 	lx("select.expand uv");
		# 	lx("select.contract uv");
		# }

		$uvsetName = lxq("vertMap.list txuv ?");

		lx("select.editSet curvert add");
			# if($curtype eq "vertex"){
			# 	lx("select.type edge");
			# 	lx("select.drop edge");
			# 	lx("select.type vertex");
			# 	lx("select.between uv");
			# 	lx("select.convert edge");
			# 	$delborder1 = lxq("select.count edge ?");
			# 	lx("select.edge remove bond less (none)");
			# 	$delborder2 = lxq("select.count edge ?");
			# 	lx("select.type vertex");
			# 	lx("select.drop vertex");
			# 	lx("select.useSet curvert select");
			# 	if($vertnum != 2){
			# 		lx("select.expand uv");
			# 		lx("select.contract uv");
			# 	}
			# }
		# lx("select.less");
		# lx("select.less")if(lxq("select.count vertex ?") == 3 and $delborder2 == 0 and $delborder1 != 0);
		# # $lesscheck = lxq("select.count vertex ?");
		# lx("select.editSet firstvert add");
		# lx("select.useSet curvert select");
		# lx("select.useSet firstvert deselect");
		# lx("select.editSet secondvert add");
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

		# if($curtype ne "polygon"){
		# 	lx("select.type polygon");
		# 	$polycount = lxq("select.count polygon ?");
		# 	lx("select.editSet curpolygon add")if($polycount != 0);
		# }

		lx("select.type vertex");

		# lx("select.vertexConnect uv");
		lx("select.expand uv");
		lx("select.convert polygon");
		while(lxq("select.count polygon ?") == 0){
			lx("select.type vertex");
			lx("select.expand uv");
			lx("select.convert polygon");
		}

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
			lx("select.type edge");
			lx("select.drop edge");
			lx("uv.selectBorder");
			lx("edge.split false 0.0")if($curversion > 802);
			lx("edge.split")if($curversion < 802);

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
		lx("select.useSet curvert select");
		# lx("select.expand");
		lx("select.less");
		# lx("select.less")if(lxq("select.count vertex ?") == 3);
		# $lesscheck = lxq("select.count vertex ?");
		lx("select.editSet firstvert add");
		lx("select.useSet curvert select");
		lx("select.useSet firstvert deselect");
		lx("select.editSet secondvert add");



		lx("select.type vertex");
		lx("select.drop vertex");

		lx("select.useSet firstvert select");
		$seluv1 = lxq("query layerservice uvs ? selected");
		# lxout("$seluv1");
		@vertpos1 = lxq("query layerservice uv.pos ? $seluv1");

		# lxout("@vertpos1[0]");
		# lxout("@vertpos2[0]");
		# lxout("@vertpos1[1]");
		# lxout("@vertpos2[1]");

		lx("select.drop vertex");
		lx("select.useSet secondvert select");
		$seluv2 = lxq("query layerservice uvs ? selected");
		# lxout("$seluv2");
		@vertpos2 = lxq("query layerservice uv.pos ? $seluv2");

		# lxout("@vertpos1[0]");
		# lxout("@vertpos2[0]");
		# lxout("@vertpos1[1]");
		# lxout("@vertpos2[1]");

		lx("select.type item");
		lx("select.item alignlayer");

		if($layerswitch == 1 or $layerswitch == 4){
			lx("item.delete");	
		}
		if($layerswitch == 2 or $layerswitch == 3){
			lx("select.type polygon");
			lx("select.all");
			lx("uv.cut");
			lx("select.drop item");
		}

		lx("select.useSet itemtemp select");
		lx("vertMap.list txuv {$uvsetName}");
		lx("select.deleteSet itemtemp delete");

		if($polycount != 0){
			if($curtype eq "polygon"){
				lx("select.type polygon");
				lx("select.useSet curpolygon select");
				lx("select.deleteSet curpolygon delete");				
			}
		}

		lx("select.type vertex");
		lx("select.useSet curvert select");

		lx("vertMap.deleteByName PICK firstvert");
		lx("vertMap.deleteByName PICK secondvert");

		# lx("select.deleteSet firstvert delete");
		# lx("select.deleteSet secondvert delete");

		if(@vertpos1[0] > @vertpos2[0]){
			$rotswitch = 1;
			$xlength = @vertpos1[0] - @vertpos2[0];
			$sec1 = 1;
			# lxout("m");
		}
		elsif(@vertpos1[0] < @vertpos2[0]){
			$rotswitch = 1;
			$xlength = @vertpos2[0] - @vertpos1[0];
			$sec1 = 2;
			# lxout("n");
		}
		else{
			$rotswitch = 0;
			lx("vertMap.deleteByName PICK curvert");
			lx("select.type $curtype");
			# lxout("$i");
		}

		if($rotswitch == 1){

			if(@vertpos1[1] > @vertpos2[1]){
				$rotswitch = 1;
				$ylength = @vertpos1[1] - @vertpos2[1];
				$sequad = 3 if($sec1 == 1);
				$sequad = 4 if($sec1 == 2);
				# lxout("a");
			}
			elsif(@vertpos1[1] < @vertpos2[1]){
				$rotswitch = 1;
				$ylength = @vertpos2[1] - @vertpos1[1];
				$sequad = 2 if($sec1 == 1);
				$sequad = 1 if($sec1 == 2);
				# lxout("b");
			}
			else{
				$rotswitch = 0;
				lx("vertMap.deleteByName PICK curvert");
				lx("select.type $curtype");
				# lxout("$i");
			}

			# if($curtype eq "edge"){
				$midx = (@vertpos1[0] + @vertpos2[0]) / 2;
				$midy = (@vertpos1[1] + @vertpos2[1]) / 2;
			# }
		}

		# lxout("$sequad");

		if($rotswitch == 1){

			# lxout("$i");

			# $ylength = sprintf('%.6f', $ylength);
			# $xlength = sprintf('%.6f', $xlength);

			$pai = 3.1415926535;
			$ladangle = atan2($ylength, $xlength);

			$degangle = ($ladangle * 180) / $pai;

			if($sequad == 1 or $sequad == 3){
				if($degangle <= 45){
					$changeangle = $degangle * -1;
					# lxout("$changeangle");
				}
				else{
					$changeangle = 90 -$degangle;
					# lxout("$changeangle");
				}
			}
			if($sequad == 2 or $sequad == 4){
				if($degangle <= 45){
					$changeangle = $degangle;
					# lxout("$changeangle");
				}
				else{
					$changeangle = (90 - $degangle) * -1;
					# lxout("$changeangle");
				}
			}

			# lxout("$changeangle");
			$changeangle = sprintf('%.3f', $changeangle);


			if($curtype eq "vertex" or $curtype eq "edge"){
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
			lx("tool.set TransformRotate on");
			lx("tool.set actr.auto on");

			# if($curtype eq "edge"){
				lx("tool.setAttr center.auto cenU $midx");
				lx("tool.setAttr center.auto cenV $midy");
			# }
			# else{
			# 	lx("tool.setAttr center.auto cenU @vertpos1[0]");
			# 	lx("tool.setAttr center.auto cenV @vertpos1[1]");			
			# }
			
			lx("tool.setAttr xfrm.transform RZ $changeangle");
			lx("tool.doApply");
			lx("tool.set actr.auto off");
			lx("tool.drop");

			lx("select.drop vertex");
			lx("select.useSet curvert select");
			lx("vertMap.deleteByName PICK curvert");

			lx("select.type $curtype");

			# if($curtype eq "edge" and $edgecount ne 0){
			# 	lx("select.useSet curedge select");
			# 	lx("vertMap.deleteByName epck curedge");
			# }
			
		}

	}

}

lx("select.symmetryState {$symstate}");
lx("select.symmetryUVState {$uvsymstate}");