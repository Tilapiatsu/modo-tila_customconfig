# perl
# <!-- code name : fuguruma -->
# author : "mayatsuka" from PAIPAN MANCO Games Inc.
# and I'm Japanese CG Guild Master. Named "RORIKONSU".
# e-mail  `mayatsuka@gmail.com`  twitter `twitter.com/mayatsuka`


my $hibiki;

# $viewcheck = lxq("query view3dservice view.type ? selected");

# if($viewcheck ne "UV2D"){
# 	lx("view3d.showSelectionRollover false");
# }

if(lxq("select.typeFrom vertex;edge;polygon;item;pivot;center;ptag ?")) {
	$hibiki = "vertex";
	&chihacheck;
}
elsif(lxq("select.typeFrom edge;vertex;polygon;item;pivot;center;ptag ?")) {
	$hibiki = "edge";
	&chihacheck;
}
elsif(lxq("select.typeFrom polygon;edge;vertex;item;pivot;center;ptag ?")) {
	$hibiki = "polygon";
	&chihacheck;
}
elsif(lxq("select.typeFrom item;pivot;center;edge;polygon;vertex;ptag ?")) {
	# $hibiki = "item";
	lx("select.typeFrom item;pivot;center;edge;polygon;vertex;ptag true");
	lx("select.nextMode item");
		if(lxq("select.typeFrom vertex;edge;polygon;item;pivot;center;ptag ?")) {
			$hibiki = "vertex";
		}
		elsif(lxq("select.typeFrom edge;vertex;polygon;item;pivot;center;ptag ?")) {
			$hibiki = "edge";
		}
		elsif(lxq("select.typeFrom polygon;edge;vertex;item;pivot;center;ptag ?")) {
			$hibiki = "polygon";
		}
	&chihacheck;
}
else{
	lx("select.typeFrom item;pivot;center;edge;polygon;vertex;ptag true");
}

sub chihacheck{
	lx("select.typeFrom edge;vertex;polygon;item;pivot;center;ptag true");

	my $harukasan = lxq("query layerservice vmap.N ? all" );
	@vmaps;
	for ($i = 0; $i < $harukasan; $i++){
		$vmaps[$i] = lxq("query layerservice vmap.name ? $i" );
	}
	foreach $ricchan1 (@vmaps){
		lx("vertMap.deleteByName epck chihaya71")if ($ricchan1 eq "chihaya71");
		lx("vertMap.deleteByName epck chihaya72")if ($ricchan1 eq "chihaya72");
		lx("vertMap.deleteByName epck chihaya73")if ($ricchan1 eq "chihaya73");
	}

	lx("select.typeFrom polygon;edge;vertex;item;pivot;center;ptag true");

	my $harukasan2 = lxq("query layerservice polset.N ?" );
	@polys;
	for ($i = 0; $i < $harukasan2; $i++){
		$polys[$i] = lxq("query layerservice polset.name ? $i" );
	}
	foreach $ricchan2 (@polys){
		lx("select.deleteSet chihaya71 false")if ($ricchan2 eq "chihaya71");
		lx("select.deleteSet chihaya72 false")if ($ricchan2 eq "chihaya72");
		lx("select.deleteSet chihaya73 false")if ($ricchan2 eq "chihaya73");
	}
	lx("select.type $hibiki");
	lx("select.type item");
	# lx("!!pref.value remapping.selectionSize 4.5");
	# lx("!!select.lazyState 0");
}
