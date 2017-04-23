#perl
# <!-- code name : Kikurihime -->
# author : "mayatsuka" from OT-tatsunoko.
# and I'm Japanese CG Guild Master. Named "RORIKONSU".
# e-mail  `mayatsuka@gmail.com`  twitter `twitter.com/mayatsuka`



sub uvsearch{

	$uvsetName = lxq("vertMap.list txuv ?");
	if($uvsetName eq "_____n_o_n_e_____"){
		lx("vertMap.list txuv Texture");
		$uvsetName = lxq("vertMap.list txuv ?");
		if($uvsetName ne "Texture"){
			lx("vertMap.new Texture txuv");
			$uvsetName = lxq("vertMap.list txuv ?");			
		}

	}

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
	
}

sub cursel{
	lx("select.type polygon");
	$polycount = lxq("select.count polygon ?");
	lx("select.editSet curpolygon add")if($polycount != 0);

		lx("select.all");
		lx("select.editSet unselpolygon add");
		lx("select.drop polygon");

	lx("select.type edge");
	$edgecount = lxq("select.count edge ?");
	lx("select.editSet curedge add")if($edgecount != 0);
}


if(lxq("select.typeFrom edge;vertex;polygon;item;pivot;center;ptag ?")) {

	$firstcheck = lxq("select.count edge ?");

	if($firstcheck > 0){

		&uvsearch;

		&cursel;

		lx("select.type edge");

		lx("select.connect");
		lx("select.convert polygon");
		lx("select.editSet curpolygon2 add");

		lx("hide.unsel");

		lx("select.type edge");
		lx("select.drop edge");
		lx("select.useSet curedge select");

		&unwrap;

		lx("select.type edge");
		lx("select.drop edge");

		&relax2;

		# lx("uv.orient auto");
		lx("uv.pack true orient:false udim:1001 regionX:0.0 regionY:-1.0 regionW:1.0 regionH:1.0");
		

		lx("select.type polygon");
		lx("unhide");

		lx("select.type polygon");
		lx("select.useSet curpolygon2 select");
		lx("select.deleteSet curpolygon2 delete");
		lx("select.convert vertex");

		lx("select.type polygon");
			lx("select.useSet unselpolygon select");
			lx("select.deleteSet unselpolygon delete");
			lx("hide.unsel");
		lx("select.drop polygon");
		lx("select.useSet curpolygon select")if($polycount != 0);
		lx("select.deleteSet curpolygon delete")if($polycount != 0);
		lx("select.type edge");
		lx("select.useSet curedge select")if($edgecount != 0);
		lx("vertMap.deleteByName epck curedge")if($edgecount != 0);
	}
	lx("select.type vertex");

}
elsif(lxq("select.typeFrom polygon;edge;vertex;item;pivot;center;ptag ?")) {

	$firstcheck = lxq("select.count polygon ?");

	if($firstcheck != 0){
		&uvsearch;

		&cursel;


		lx("select.type polygon");
		lx("select.useSet curpolygon select")if($polycount != 0);
		lx("hide.unsel");

		if($edgecount != 0){
			lx("select.type edge");
			# $secondcheck = lxq("select.count edge ?");
			# lx("uv.selectBorder")if($secondcheck == 0);
		}
		# elsif($edgecount == 0){
		# 	lx("select.type polygon");
		# 	lx("select.boundary");
		# 	# lx("uv.selectBorder");
		# }

		&unwrap;

		lx("select.type edge");
		lx("select.drop edge");

		&relax2;

		# lx("uv.orient auto");
		lx("uv.pack true orient:false udim:1001 regionX:0.0 regionY:-1.0 regionW:1.0 regionH:1.0");


		lx("select.type polygon");
		lx("unhide");

		lx("select.type edge");
		lx("select.useSet curedge select")if($edgecount != 0);
		lx("vertMap.deleteByName epck curedge")if($edgecount != 0);
		lx("select.type polygon");
			lx("select.useSet unselpolygon select");
			lx("select.deleteSet unselpolygon delete");
			lx("hide.unsel");
		lx("select.drop polygon");
		lx("select.useSet curpolygon select")if($polycount != 0);
		lx("select.deleteSet curpolygon delete")if($polycount != 0);


		# &relax;		
	}


}
elsif(lxq("select.typeFrom vertex;edge;polygon;item;pivot;center;ptag ?")) {
	$firstcheck = lxq("select.count vertex ?");
	if($firstcheck != 0){
		lx("tool.set uv.relax on");
		lx("tool.reset");
		# &relax;		
	}

}
elsif(lxq("select.typeFrom item;pivot;center;edge;polygon;vertex;ptag ?")) {
	lx("select.type polygon");
	$itempoly = lxq("select.count polygon ?");
	&relax if($itempoly != 0);
	if($itempoly == 0){
		lx("!!select.polygon add 0 face");
		$itempoly2 = lxq("select.count polygon ?");
		&relax if($itempoly2 != 0);
	}
	# lx("select.type item")if($itempoly == 0);
	lx("select.type item");
}

sub unwrap{
	lx("tool.set uv.unwrap on");
	$modetemp = lxq("tool.attr uv.unwrap mode ?");
	$itertemp = lxq("tool.attr uv.unwrap iter ?");
	$methtemp = lxq("tool.attr uv.unwrap mode ?");
	$sealtemp = lxq("tool.attr uv.unwrap seal ?");
	$layoutemp = lxq("tool.attr uv.unwrap layout ?");
	$symmtemp = lxq("tool.attr uv.unwrap symmetrize ?");
	$projtemp = lxq("tool.attr uv.unwrap project ?");
	lx("tool.reset");
	lx("tool.attr uv.unwrap mode abf");
	lx("tool.attr uv.unwrap iter 3460");
	lx("tool.attr uv.unwrap project normal");
	lx("tool.attr uv.unwrap seal false");
	lx("tool.attr uv.unwrap layout false");
	lx("tool.attr uv.unwrap symmetrize false");
	lx("tool.doApply");
	lx("tool.reset");
	lx("tool.attr uv.unwrap mode {$modetemp}");
	lx("tool.attr uv.unwrap iter {$itertemp}");
	lx("tool.attr uv.unwrap mode {$methtemp}");
	lx("tool.attr uv.unwrap seal {$sealtemp}");
	lx("tool.attr uv.unwrap layout {$layoutemp}");
	lx("tool.attr uv.unwrap symmetrize {$symmtemp}");
	lx("tool.attr uv.unwrap project {$projtemp}");
	lx("tool.drop");	
}


# lx("select.type edge");
# lx("select.drop edge");


sub relax{
	lx("tool.set uv.relax on");

	$relaxmode = lxq("tool.attr uv.relax mode ?");
	$relaxiter = lxq("tool.attr uv.relax iter ?");
	$relaxinte = lxq("tool.attr uv.relax live ?");

	lx("tool.reset");
	lx("tool.attr uv.relax mode abf");
	lx("tool.attr uv.relax iter 3460");
	lx("tool.attr uv.relax live false");
	lx("tool.doApply");
	lx("tool.drop");


	lx("tool.set uv.relax on");

	lx("tool.reset");
	lx("tool.attr uv.relax mode adaptive");
	lx("tool.attr uv.relax iter 172");
	lx("tool.doApply");
	lx("tool.drop");

	# lx("tool.set uv.relax on");

	# lx("tool.reset");
	# lx("tool.attr uv.relax mode abf");
	# lx("tool.attr uv.relax iter 20");
	# lx("tool.attr uv.relax live true");
	# lx("tool.doApply");
	# lx("tool.drop");


	lx("tool.set uv.relax on");

	lx("tool.reset");
	lx("tool.attr uv.relax live {$relaxinte}");
	lx("tool.attr uv.relax mode {$relaxmode}");
	lx("tool.attr uv.relax iter {$relaxiter}");
	lx("tool.drop");	
}

sub relax2{
	lx("tool.set uv.relax on");

	$relaxmode = lxq("tool.attr uv.relax mode ?");
	$relaxiter = lxq("tool.attr uv.relax iter ?");
	$relaxinte = lxq("tool.attr uv.relax live ?");

	# lx("tool.reset");
	# lx("tool.attr uv.relax mode abf");
	# lx("tool.attr uv.relax iter 3460");
	# lx("tool.attr uv.relax live true");
	# lx("tool.doApply");
	# lx("tool.drop");


	# lx("tool.set uv.relax on");

	lx("tool.reset");
	lx("tool.attr uv.relax mode adaptive");
	lx("tool.attr uv.relax iter 172");
	lx("tool.doApply");
	lx("tool.drop");

	# lx("tool.set uv.relax on");

	# lx("tool.reset");
	# lx("tool.attr uv.relax mode abf");
	# lx("tool.attr uv.relax iter 20");
	# lx("tool.attr uv.relax live true");
	# lx("tool.doApply");
	# lx("tool.drop");


	lx("tool.set uv.relax on");

	lx("tool.reset");
	lx("tool.attr uv.relax live {$relaxinte}");
	lx("tool.attr uv.relax mode {$relaxmode}");
	lx("tool.attr uv.relax iter {$relaxiter}");
	lx("tool.drop");	
}
