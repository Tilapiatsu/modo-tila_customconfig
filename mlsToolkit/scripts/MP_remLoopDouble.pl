# perl
# <!-- code name : fuguruma -->
# author : "mayatsuka" from PAIPAN MANCO Games Inc.
# and I'm Japanese CG Guild Master. Named "RORIKONSU".
# e-mail  `mayatsuka@gmail.com`  twitter `twitter.com/mayatsuka`

$selectionSize = lxq("pref.value remapping.selectionSize ?");

$viewcheck = lxq("query view3dservice view.type ? selected");

$lazycheck = lxq("select.lazyState ?");

sub lazyon{
	lx("!!select.lazyState 0")if($viewcheck ne "UV2D");
	lx("!!select.lazyState 1")if($viewcheck eq "UV2D");

	lx("!!pref.value remapping.selectionSize 45")if($viewcheck ne "UV2D");
	lx("!!pref.value remapping.selectionSize 1")if($viewcheck eq "UV2D");
}

sub lazyoff{
	lx("!!select.lazyState $lazycheck");

	lx("!!pref.value remapping.selectionSize $selectionSize");
}

sub lazyadd{
	$lazyedgecheck = lxq("select.count edge ?");
	if($lazyedgecheck == 0){
		lx("!!select.lazyState 1");
		lx("!!select.3DElementUnderMouse add");
		lx("!!select.lazyState 0");				
	}
}


if(lxq( "!!select.typeFrom {edge;vertex;polygon;item} ?" )){
	&lazyon if($lazycheck == 0);

	 	$makoto1 = lxq("select.count edge ?");

		if ($makoto1 != 0){
			$smokythrill = lxq("query view3dservice view.type ? selected");
			$edgecount = lxq("select.count edge ?");
			lx("!!select.editSet majisaikou add")if($edgecount != 0);
			lx("!!select.drop edge");
			lx("!!select.3DElementUnderMouse add");
				&lazyadd if($lazycheck == 0);
			lx("!!select.loop")if ($smokythrill ne "UV2D");
			lx("!!select.loop space:uv")if ($smokythrill eq "UV2D");
			lx("!!select.editSet majisaikou2 add");
			lx("select.drop edge")if ($smokythrill eq "UV2D");
			lx("select.useSet majisaikou2 select")if ($smokythrill eq "UV2D");
			lx("!!select.useSet majisaikou select")if($edgecount != 0);
			lx("!!select.useSet majisaikou2 deselect");
			lx("!!select.deleteSet majisaikou false")if($edgecount != 0);
			lx("!!select.deleteSet majisaikou2 false");
		}
		lx("!!vertMap.deleteByName epck chihaya71");
		lx("!!vertMap.deleteByName epck chihaya72");
		lx("!!vertMap.deleteByName epck chihaya73");

	&lazyoff if($lazycheck == 0);
}


elsif(lxq( "!!select.typeFrom {polygon;vertex;edge;item} ?" )){
	my $harukasan = lxq("query layerservice polset.N ?" );
	@polys;
	for ($i = 0; $i < $harukasan; $i++){
		$polys[$i] = lxq("query layerservice polset.name ? $i" );
	}

	&paitouch (@polys);

	if ($yayoiori eq "110"){
		&ramuneiroseishun ("chihaya71");
	}
	elsif ($yayoiori eq "011" or $yayoiori eq "100"){
		&ramuneiroseishun ("chihaya72");
	}
	elsif ($yayoiori eq "101"){
		&ramuneiroseishun ("chihaya73");
	}
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

# ++++ sub routine ++++

sub ramuneiroseishun{

	my $piyochan;
	($piyochan) = @_;
	$smokythrill = lxq("query view3dservice view.type ? selected");
		lx("!!select.editSet hoshii add");
		lx("!!select.useSet $piyochan select");
		lx("!!select.useSet hoshii deselect");
		lx("!!select.loop")if ($smokythrill ne "UV2D");
		lx("!!select.loop space:uv")if ($smokythrill eq "UV2D");
		lx("!!select.editSet hoshii2 add");
		lx("!!select.drop polygon");
		lx("!!select.useSet hoshii select");
		lx("!!select.useSet hoshii2 deselect");
		lx("!!select.clearSet hoshii false");
		lx("!!select.clearSet hoshii2 false");	
		lx("!!select.clearSet chihaya71 false") if($futami);
		lx("!!select.clearSet chihaya72 false") if($ami);
		lx("!!select.clearSet chihaya73 false") if($mami);
}