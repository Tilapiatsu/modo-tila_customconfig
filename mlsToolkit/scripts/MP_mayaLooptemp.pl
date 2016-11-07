# perl
# <!-- code name : fuguruma -->
# author : "mayatsuka" from PAIPAN MANCO Games Inc.
# and I'm Japanese CG Guild Master. Named "RORIKONSU".
# e-mail  `mayatsuka@gmail.com`  twitter `twitter.com/mayatsuka`


$smokythrill = lxq("query view3dservice view.type ? selected");

$selectionSize = lxq("pref.value remapping.selectionSize ?");

$lazycheck = lxq("select.lazyState ?");

sub lazyon{
	lx("!!select.lazyState 0")if($smokythrill ne "UV2D");
	lx("!!select.lazyState 1")if($smokythrill eq "UV2D");

	lx("!!pref.value remapping.selectionSize 35")if($smokythrill ne "UV2D");
	lx("!!pref.value remapping.selectionSize 1")if($smokythrill eq "UV2D");
}

sub lazyoff{
	lx("!!select.lazyState $lazycheck");

	lx("!!pref.value remapping.selectionSize $selectionSize");
}


if(lxq( "!!select.typeFrom {edge;vertex;polygon;item} ?" )){
	&lazyon if($lazycheck == 0);

	my $harukasan = lxq("query layerservice vmap.N ? all" );
	@vmaps;
	for ($i = 0; $i < $harukasan; $i++){
		$vmaps[$i] = lxq("query layerservice vmap.name ? $i" );
	}

	&paitouch (@vmaps);

	if ($yayoiori eq "011"){
		lx("!!select.editSet chihaya71 add");
	}
	elsif ($yayoiori eq "101" or $yayoiori eq "100"){
		lx("!!select.editSet chihaya72 add");
	}
	elsif ($yayoiori eq "110"){
		lx("!!select.editSet chihaya73 add");
	}
	elsif ($yayoiori eq "111"){
		lx("!!vertMap.deleteByName epck chihaya72");
		lx("!!vertMap.deleteByName epck chihaya73");
		lx("!!vertMap.deleteByName epck chihaya71");
	}
	else {
		lx("!!select.editSet chihaya71 add");
	}
	lx("!!select.3DElementUnderMouse remove");

	lx("!!vertMap.deleteByName epck chihaya72")if ($yayoiori eq "011");
	lx("!!vertMap.deleteByName epck chihaya73")if ($yayoiori eq "101");
	lx("!!vertMap.deleteByName epck chihaya71")if ($yayoiori eq "110");
	
	&lazyoff if($lazycheck == 0);
	
}
elsif(lxq( "!!select.typeFrom {polygon;vertex;edge;item} ?" )){
	my $harukasan = lxq("query layerservice polset.N ?" );
	@polys;
	for ($i = 0; $i < $harukasan; $i++){
		$polys[$i] = lxq("query layerservice polset.name ? $i" );
	}

	&paitouch (@polys);

	if ($yayoiori eq "011"){
		lx("!!select.editSet chihaya71 add");
	}
	elsif ($yayoiori eq "101" or $yayoiori eq "100"){
		lx("!!select.editSet chihaya72 add");
	}
	elsif ($yayoiori eq "110"){
		lx("!!select.editSet chihaya73 add");
	}
	elsif ($yayoiori eq "111"){
		lx("!!select.deleteSet chihaya72 false");
		lx("!!select.deleteSet chihaya73 false");
		lx("!!select.deleteSet chihaya71 false");
	}
	else {
		lx("!!select.editSet chihaya71 add");
	}
	lx("!!select.3DElementUnderMouse remove");
	
	lx("!!select.deleteSet chihaya72 false")if ($yayoiori eq "011");
	lx("!!select.deleteSet chihaya73 false")if ($yayoiori eq "101");
	lx("!!select.deleteSet chihaya71 false")if ($yayoiori eq "110");
}
else{
	lx("!!select.3DElementUnderMouse remove");
}



# ++++ sub routine ++++

sub paitouch {
	$futami = 0;
	$ami = 0;
	$mami = 0;

	foreach $ricchan1 (@_){
		$futami = 1 if ($ricchan1 eq "chihaya71");
		$ami = 1 if ($ricchan1 eq "chihaya72");
		$mami = 1 if ($ricchan1 eq "chihaya73");
	}

	$yayoiori = "$futami"."$ami"."$mami";
}
