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

	lx("pref.value remapping.selectionSize 45")if($viewcheck ne "UV2D");
	lx("pref.value remapping.selectionSize 1")if($viewcheck eq "UV2D");
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

if(lxq( "select.typeFrom {vertex;edge;polygon;item} ?" )){
	&lazyon if($lazycheck == 0);

	lx("!!select.3DElementUnderMouse add");

	&lazyadd if($lazycheck == 0);
	lx("!!select.vertexConnect m3d")if ($viewcheck ne "UV2D");
	lx("!!select.vertexConnect uv")if ($viewcheck eq "UV2D");

	&lazyoff if($lazycheck == 0);
}

# elsif(lxq( "select.typeFrom {edge;vertex;polygon;item} ?" )){
# 	lx("select.3DElementUnderMouse remove");
# 	if (lxq("select.count edge ?") != 0){

# 		lx("select.editSet curedge add");

# 		$uvsetName = lxq("vertMap.list txuv ?");

# 		lx("vertMap.new islanduv txuv");

# 		lx("tool.set uv.unwrap on");
# 		$itertemp = lxq("tool.attr uv.unwrap iter ?");
# 		lx("tool.reset");
# 		lx("tool.attr uv.unwrap iter 1");
# 		lx("tool.doApply");
# 		lx("tool.attr uv.unwrap iter $itertemp");
# 		lx("tool.drop");
# 		# lx("tool.doApply");

# 		# lx("vertMap.deleteByName epck curedge");

# 		lx("select.drop edge");
# 		lx("select.3DElementUnderMouse add");
# 		lx("select.loop space:uv");

# 		lx("select.useSet curedge select");
# 		lx("vertMap.deleteByName epck curedge");

# 		lx("vertMap.list txuv $uvsetName");

# 		lx("vertMap.deleteByName txuv islanduv");
# 	}
# 	elsif (lxq("select.count edge ?") == 0){
# 		lx("select.3DElementUnderMouse add");
# 		lx("select.loop");
# 	}



# }
elsif(lxq( "select.typeFrom {edge;vertex;polygon;item} ?" )){
	if (lxq("select.count edge ?") != 0){

		&lazyon if($lazycheck == 0);

		$edgeremcheck1 = lxq("select.count edge ?");
		lx("select.3DElementUnderMouse remove");
		$edgeremcheck2 = lxq("select.count edge ?");
		if($edgeremcheck1 == $edgeremcheck2){
			lx("!!select.lazyState 1");
			lx("!!select.3DElementUnderMouse remove");
			lx("!!select.lazyState 0");				
		}


		$uvsetName = lxq("vertMap.list txuv ?");

		lx("vertMap.new islanduv txuv");

		if($layernum != 1){
			if($curversion > 900 or $curversion < 210 ){
				lx("select.type item");		
				# &unwrapmod;
				lx("tool.set uv.create on");
				lx("tool.reset");
				lx("tool.doApply");
				lx("tool.drop");
				lx("select.type edge");				
			}			
		}

		&unwrapmod;

		lx("vertMap.deleteByName epck curedge");

		lx("select.type polygon");
		lx("select.drop polygon");

		lx("select.3DElementUnderMouse add");

		lx("select.polygonConnect uv");

		lx("vertMap.list txuv $uvsetName");

		lx("vertMap.deleteByName txuv islanduv");

		&lazyoff if($lazycheck == 0);
	}
	elsif (lxq("select.count edge ?") == 0){
		lx("select.type polygon");
		lx("select.3DElementUnderMouse add");
		lx("select.polygonConnect m3d")if(lxq("select.count polygon ?") != 0);
		lx("select.type edge")if(lxa("select.count polygon ?") == 0);
	}



}
elsif(lxq( "select.typeFrom {polygon;vertex;edge;item} ?" )){

	lx("select.3DElementUnderMouse add");
	if(lxq("select.count polygon ?") != 0){
		lx("select.editSet hidakaai add");
		lx("select.drop polygon");
		lx("select.3DElementUnderMouse add");
			$lazyedgecheck = lxq("select.count polygon ?");
			if($lazyedgecheck == 0){
				lx("!!select.lazyState 1");
				lx("!!select.3DElementUnderMouse add");
				lx("!!select.lazyState 0");				
			}
		lx("select.polygonConnect m3d")if ($viewcheck ne "UV2D");
		lx("select.polygonConnect uv")if ($viewcheck eq "UV2D");
		$polycount = lxq("select.count polygon ?");
		lx("select.editSet conepoly add")if($polycount != 0);
		my $masterpiece1 = lxq("select.count polygon ?");
		lx("select.useSet hidakaai deselect");
		my $masterpiece2 = lxq("select.count polygon ?");
	
		if ($masterpiece2 >= ($masterpiece1 / 2)){
			lx("select.drop polygon");
			lx("select.useSet hidakaai select");
			lx("select.useSet conepoly select")if($polycount != 0);
		}
		else{
			lx("select.useSet hidakaai select");
			lx("select.useSet conepoly deselect")if($polycount != 0);
		}
		lx("select.clearSet hidakaai false");
		lx("select.clearSet conepoly false")if($polycount != 0);
	}


}


sub unwrapmod{

	lx("tool.set uv.unwrap on");
	$itertemp = lxq("tool.attr uv.unwrap iter ?");
	$methtemp = lxq("tool.attr uv.unwrap mode ?");
	$sealtemp = lxq("tool.attr uv.unwrap seal ?");
	$layoutemp = lxq("tool.attr uv.unwrap layout ?");
	$symmtemp = lxq("tool.attr uv.unwrap symmetrize ?");
	# $projtemp = lxq("tool.attr uv.unwrap project ?");
	lx("tool.reset");
	lx("tool.attr uv.unwrap iter {$itelatefluc}");
	# lx("tool.attr uv.unwrap project normal");
	lx("tool.attr uv.unwrap seal false");
	lx("tool.attr uv.unwrap layout false");
	lx("tool.doApply");
	lx("tool.reset");
	lx("tool.attr uv.unwrap iter $itertemp");
	lx("tool.attr uv.unwrap mode {$methtemp}");
	lx("tool.attr uv.unwrap seal {$sealtemp}");
	lx("tool.attr uv.unwrap layout {$layoutemp}");
	lx("tool.attr uv.unwrap symmetrize {$symmtemp}");
	# lx("tool.attr uv.unwrap project {$projtemp}");
	lx("tool.drop");

}