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
		$edgecount = lxq("select.count edge ?");
		lx("!!select.editSet majisaikou add")if($edgecount != 0);
		lx("!!select.drop edge");
		lx("!!select.3DElementUnderMouse add");
			&lazyadd if($lazycheck == 0);
		lx("!!select.loop")if ($viewcheck ne "UV2D");
		if ($viewcheck eq "UV2D"){
			lx("!!select.loop space:uv");
			lx("!!select.editSet majisaikou2 add");
			lx("!!select.drop edge")if($edgecount != 0);
			lx("!!select.useSet majisaikou2 select")if($edgecount != 0);
		}

		lx("!!select.useSet majisaikou select");
		lx("!!select.deleteSet majisaikou false")if($edgecount != 0);
		lx("!!select.deleteSet majisaikou2 false")if ($viewcheck eq "UV2D");

	&lazyoff if($lazycheck == 0);

}
elsif(lxq( "!!select.typeFrom {vertex;edge;polygon;item} ?" ) || lxq( "!!select.typeFrom {polygon;vertex;edge;item} ?" )){
		lx("!!select.3DElementUnderMouse remove");
		lx("!!select.editSet majisaikou add");
		lx("!!select.3DElementUnderMouse add");
		lx("!!select.more")if ($viewcheck ne "UV2D");
		lx("!!select.more uv")if ($viewcheck eq "UV2D");
		lx("!!select.useSet majisaikou deselect");
		lx("!!select.loop")if ($viewcheck ne "UV2D");
		lx("!!select.loop space:uv")if ($viewcheck eq "UV2D");
		lx("!!select.useSet majisaikou select");
		lx("!!select.deleteSet majisaikou false");
}
