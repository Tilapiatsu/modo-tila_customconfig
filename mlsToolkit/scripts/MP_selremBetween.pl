# perl
# <!-- code name : fuguruma -->
# author : "mayatsuka" from PAIPAN MANCO Games Inc.
# and I'm Japanese CG Guild Master. Named "RORIKONSU".
# e-mail  `mayatsuka@gmail.com`  twitter `twitter.com/mayatsuka`


$smokythrill = lxq("query view3dservice view.type ? selected");

$selectionSize = lxq("pref.value remapping.selectionSize ?");

$lazycheck = lxq("select.lazyState ?");

my $fgLayers = lxq( "query layerservice layer.N ? fg" );

sub lazyon{
	lx("!!select.lazyState 0")if($viewcheck ne "UV2D");
	lx("!!select.lazyState 1")if($viewcheck eq "UV2D");

	lx("!!pref.value remapping.selectionSize 45")if($viewcheck ne "UV2D");
	lx("!!pref.value remapping.selectionSize 1")if($viewcheck eq "UV2D");
}

sub lazyoff{
	lx("s!!elect.lazyState $lazycheck");

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


if(lxq("!!select.typeFrom vertex;edge;polygon;item;pivot;center;ptag ?")) {
	$curtype = "vertex";
}
elsif(lxq("!!select.typeFrom edge;vertex;polygon;item;pivot;center;ptag ?")) {
	$curtype = "edge";
}
elsif(lxq("!!select.typeFrom polygon;edge;vertex;item;pivot;center;ptag ?")) {
	$curtype = "polygon";
}
elsif(lxq("!!select.typeFrom item;pivot;center;edge;polygon;vertex;ptag ?")) {
	$curtype = "item";
}

if ($curtype ne "item" or $smokythrill ne "UV2D"){
	$topocheck = lxq("tool.set mesh.topology ?");
	$topobgcheck = lxq("tool.set TopologyPenBGCons ?");
	if($topocheck eq "on" or $topobgcheck eq "on"){
		lx("select.type edge");
		$edgecount = lxq("select.count edge ?");
		lx("select.editSet curedge add")if($edgecount != 0);
		lx("select.drop edge");
		&lazyon if($lazycheck == 0);
		lx("select.3DElementUnderMouse");
			&lazyadd if($lazycheck == 0);
		lx("select.loop");
		lx("select.delete");
		lx("select.drop edge");
		lx("select.useSet curedge select")if($edgecount != 0);
		lx("vertMap.deleteByName epck curedge")if($edgecount != 0);
		&lazyoff if($lazycheck == 0);
		lx("select.type {$curtype}");
	}
	else{
	if(lxq( "!!select.typeFrom {edge;vertex;polygon;item} ?" )){
		&lazyon if($lazycheck == 0);

		my $makoto1 = lxq("select.count edge ?");
		lx("!!select.3DElementUnderMouse remove");
		my $makoto2 = lxq("select.count edge ?");
		lx("!!select.3DElementUnderMouse add");
		my $makoto3 = lxq("select.count edge ?");
		
		if ($makoto1 == $makoto2){
			# $smokythrill = lxq("query view3dservice view.type ? selected");
				lx("!!select.between uv")if ($smokythrill eq "UV2D");
				lx("!!select.between")if ($smokythrill ne "UV2D");
				lx("!!vertMap.deleteByName epck chihaya71");
				lx("!!vertMap.deleteByName epck chihaya72");
				lx("!!vertMap.deleteByName epck chihaya73");
		}
		elsif ($makoto1 == $makoto3){
			my $harukasan = lxq("query layerservice vmap.N ? all" );
			@vmaps;
			for (my $i = 0; $i < $harukasan; $i++){
				$vmaps[$i] = lxq("query layerservice vmap.name ? $i" );
			}
		
			&paitouch (@vmaps);
		
			if ($yayoiori eq "101" or $yayoiori eq "100"){
				&nijiiromiracle ("chihaya71");
			}
			elsif ($yayoiori eq "110"){
				&nijiiromiracle ("chihaya72");
			}
			elsif ($yayoiori eq "011"){
				&nijiiromiracle ("chihaya73");
			}
		}
		&lazyoff if($lazycheck == 0);
		# else{
		
		# }
	}



	elsif(lxq( "!!select.typeFrom {polygon;vertex;edge;item} ?" )){

		my $yukiho1 = lxq("select.count polygon ?");
		lx("!!select.3DElementUnderMouse remove");
		my $yukiho2 = lxq("select.count polygon ?");
		lx("!!select.3DElementUnderMouse add");
		my $yukiho3 = lxq("select.count polygon ?");
		
		if ($yukiho1 == $yukiho2){

			if($fgLayers != 1){
				$seltest = lxq("select.count polygon ?");
				$symshold = 2;
				$selsym = lxq("select.symmetryState ?");
				$symshold = 4 if($selsym ne none);
				if($seltest > $symshold){
				lx("select.less");
				lx("select.editSet bettemp add");
				lx("select.less");
				lx("select.editSet bettemp2 add");
				lx("select.useSet bettemp select");
				lx("select.useSet bettemp2 deselect");
				lx("!!select.3DElementUnderMouse add");			
				}				
			}


				lx("!!select.between uv")if ($smokythrill eq "UV2D");
				lx("!!select.between")if ($smokythrill ne "UV2D");
			lx("select.useSet bettemp select")if($seltest > $symshold);

			lx("!!select.3DElementUnderMouse remove");
			lx("!!select.3DElementUnderMouse add");

				lx("!!select.clearSet chihaya71 false");
				lx("!!select.clearSet chihaya72 false");
				lx("!!select.clearSet chihaya73 false");
				if($fgLayers != 1){
					lx("!!select.clearSet bettemp false")if($seltest > $symshold);
					lx("!!select.clearSet bettemp2 false")if($seltest > $symshold);					
				}



		}
		elsif ($yukiho1 == $yukiho3){
			$smokythrill = lxq("query view3dservice view.type ? selected");
			my $harukasan = lxq("query layerservice polset.N ?" );
			@polys;
			for (my $i = 0; $i < $harukasan; $i++){
				$polys[$i] = lxq("query layerservice polset.name ? $i" );
			}
			
			&paitouch (@polys);
			
			if ($yayoiori eq "101" or $yayoiori eq "100"){
				&ramuneiroseishun ("chihaya71");
			}
			elsif ($yayoiori eq "110"){
				&ramuneiroseishun ("chihaya72");
			}
			elsif ($yayoiori eq "011"){
				&ramuneiroseishun ("chihaya73");
			}
		}		
		# else{
		
		# }					
	}
	elsif(lxq("!!select.typeFrom vertex;edge;polygon;item;pivot;center;ptag ?")) {
		lx("!!select.3DElementUnderMouse add");
		lx("!!select.between uv")if ($smokythrill eq "UV2D");
		lx("!!select.between")if ($smokythrill ne "UV2D");
	}
	}

}
elsif($curtype eq "item" and $smokythrill eq "UV2D"){

	my $shinysmile = lxq("select.lazyState ?");
	lx("!!select.lazyState 0");

	lx("select.type polygon");
	$polycount = lxq("select.count polygon ?");
	lx("select.editSet curpolygon add")if($polycount != 0);
	lx("select.drop polygon");
	lx("select.3DElementUnderMouse add");
	$switchcount = lxq("select.count polygon ?");
	if($switchcount != 0){
		lx("select.polygonConnect uv");

		lx("tool.viewType uv");
		lx("tool.set TransformRotate on");
		lx("tool.set actr.auto on");

		@vtest = lxq("query view3dservice mouse.pos ?");


		lx("tool.attr center.auto cenU @vtest[0]");
		lx("tool.attr center.auto cenV @vtest[1]");


		lx("tool.setAttr xfrm.transform RZ -90");
		lx("tool.doApply");
		lx("tool.drop");

		lx("tool.set actr.auto off");

		lx("select.type polygon");
		lx("select.drop polygon");
		lx("select.useSet curpolygon select")if($polycount != 0);
		lx("select.deleteSet curpolygon delete")if($polycount != 0);
		lx("select.type $curtype");		
	}
	lx("!!select.lazyState $shinysmile");

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

sub nijiiromiracle{

	my $piyochan;
	($piyochan) = @_;
		lx("!!select.3DElementUnderMouse remove");
		lx("!!select.editSet hoshii add");
		lx("!!select.useSet $piyochan select");
		lx("!!select.useSet hoshii deselect");
		lx("!!select.3DElementUnderMouse add");
		lx("!!select.between uv")if ($smokythrill eq "UV2D");
		lx("!!select.between")if ($smokythrill ne "UV2D");
		lx("!!select.editSet hoshii2 add");
		lx("!!select.drop edge");
		lx("!!select.useSet hoshii select");
		lx("!!select.useSet hoshii2 deselect");
		lx("!!select.deleteSet hoshii false");
		lx("!!select.deleteSet hoshii2 false");	
		lx("!!vertMap.deleteByName epck chihaya71") if($futami);
		lx("!!vertMap.deleteByName epck chihaya72") if($ami);
		lx("!!vertMap.deleteByName epck chihaya73") if($mami);
		lx("!!select.3DElementUnderMouse add");
		lx("!!select.editSet chihaya71 add");
		lx("!!select.3DElementUnderMouse remove");
}

# ++++ sub routine ++++

sub ramuneiroseishun{

	my $piyochan;
	($piyochan) = @_;
		lx("!!select.3DElementUnderMouse remove");
		lx("!!select.editSet hoshii add");
		lx("!!select.useSet $piyochan select");
		lx("!!select.useSet hoshii deselect");
		lx("!!select.3DElementUnderMouse add");
		lx("!!select.between uv")if ($smokythrill eq "UV2D");
		lx("!!select.between")if ($smokythrill ne "UV2D");
		lx("!!select.editSet hoshii2 add");
		lx("!!select.drop polygon");
		lx("!!select.useSet hoshii select");
		lx("!!select.useSet hoshii2 deselect");
		lx("!!select.clearSet hoshii false");
		lx("!!select.clearSet hoshii2 false");	
		lx("!!select.clearSet chihaya71 false") if($futami);
		lx("!!select.clearSet chihaya72 false") if($ami);
		lx("!!select.clearSet chihaya73 false") if($mami);
		lx("!!select.3DElementUnderMouse add");
		lx("!!select.editSet chihaya71 add");
		lx("!!select.3DElementUnderMouse remove");
}