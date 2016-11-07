# perl
# <!-- code name : fuguruma -->
# author : "mayatsuka" from PAIPAN MANCO Games Inc.
# and I'm Japanese CG Guild Master. Named "RORIKONSU".
# e-mail  `mayatsuka@gmail.com`  twitter `twitter.com/mayatsuka`


$smokythrill = lxq("query view3dservice view.type ? selected");

$selectionSize = lxq("pref.value remapping.selectionSize ?");

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
	$edgecount2 = lxq("select.count edge ?");
	if($edgecount2 == 0){
		lx("!!select.lazyState 1");
		lx("!!select.3DElementUnderMouse add");
		lx("!!select.lazyState 0");				
	}
}

$topocheck = lxq("tool.set mesh.topology ?");
$topobgcheck = lxq("tool.set TopologyPenBGCons ?");
if($topocheck eq "on" or $topobgcheck eq "on"){
	if($smokythrill ne "UV2D"){
		if(lxq("select.typeFrom vertex;edge;polygon;item;pivot;center;ptag ?")) {
			$curtype = "vertex";
		}
		elsif(lxq("select.typeFrom edge;vertex;polygon;item;pivot;center;ptag ?")) {
			$curtype = "edge";
		}
		elsif(lxq("select.typeFrom polygon;edge;vertex;item;pivot;center;ptag ?")) {
			$curtype = "polygon";
		}
		elsif(lxq("select.typeFrom item;pivot;center;edge;polygon;vertex;ptag ?")) {
			$curtype = "item";
		}
		lx("select.type edge");
		$edgecount = lxq("select.count edge ?");
		lx("select.editSet curedge add")if($edgecount != 0);
		lx("select.drop edge");
		&lazyon if($lazycheck == 0);
		lx("select.3DElementUnderMouse");
		$edgecount2 = lxq("select.count edge ?");
			&lazyadd if($lazycheck == 0);
		lx("select.loop");
		lx("select.delete");
		lx("select.drop edge");
		lx("select.useSet curedge select")if($edgecount != 0);
		lx("vertMap.deleteByName epck curedge")if($edgecount != 0);
		&lazyoff if($lazycheck == 0);
		lx("select.type {$curtype}");		
	}

}
elsif(lxq( "select.typeFrom {edge;vertex;polygon;item} ?" )){
	&lazyon if($lazycheck == 0);

	my $makoto1 = lxq("select.count edge ?");
	# lx("select.3DElementUnderMouse remove");
	# my $makoto2 = lxq("select.count edge ?");
	lx("select.3DElementUnderMouse add");
	my $makoto3 = lxq("select.count edge ?");

	# lx("select.edgeDeLoop uv");
	
	if ($makoto1 != $makoto3){
			lx("select.3DElementUnderMouse add");
			lx("select.editSet majisaikou add");
			lx("select.drop edge");
			lx("select.3DElementUnderMouse add");
				&lazyadd;
			lx("select.loop")if ($smokythrill ne "UV2D");
			if ($smokythrill eq "UV2D"){
				lx("select.loop space:uv");
				lx("select.editSet majisaikou2 add");
				lx("select.drop edge");
				lx("select.useSet majisaikou2 select");			
			}
			lx("select.useSet majisaikou select");
			lx("select.deleteSet majisaikou false");
			lx("select.deleteSet majisaikou2 false")if ($smokythrill eq "UV2D");
	
		&lazyoff if($lazycheck == 0);
	}

	elsif ($makoto1 != 0){
			lx("select.editSet majisaikou add");
			lx("select.drop edge");
			lx("select.3DElementUnderMouse add");
				&lazyadd if($lazycheck == 0);
			lx("select.loop")if ($smokythrill ne "UV2D");
			lx("select.loop space:uv")if ($smokythrill eq "UV2D");
			lx("select.editSet majisaikou2 add");
			lx("select.drop edge")if ($smokythrill eq "UV2D");
			lx("select.useSet majisaikou2 select")if ($smokythrill eq "UV2D");
			lx("select.editSet majisaikou2 add")if ($smokythrill eq "UV2D");
			lx("select.useSet majisaikou select");
			lx("select.useSet majisaikou2 deselect");
			lx("select.deleteSet majisaikou false");
			lx("select.deleteSet majisaikou2 false");
				
		&lazyoff if($lazycheck == 0);
	}

}


elsif(lxq( "select.typeFrom {polygon;vertex;edge;item} ?" )){

	my $yukiho1 = lxq("select.count polygon ?");
	lx("select.3DElementUnderMouse remove");
	my $yukiho2 = lxq("select.count polygon ?");
	lx("select.3DElementUnderMouse add");
	my $yukiho3 = lxq("select.count polygon ?");
	
	if ($yukiho1 == $yukiho2){
			lx("!!select.3DElementUnderMouse remove");
			lx("!!select.editSet majisaikou add");
			lx("!!select.3DElementUnderMouse add");
			lx("!!select.more")if ($smokythrill ne "UV2D");
			lx("!!select.more uv")if ($smokythrill eq "UV2D");
			lx("!!select.useSet majisaikou deselect");
			lx("!!select.loop")if ($smokythrill ne "UV2D");
			lx("!!select.loop space:uv")if ($smokythrill eq "UV2D");
			lx("!!select.useSet majisaikou select");
			lx("!!select.deleteSet majisaikou false");
	}
	elsif ($yukiho1 == $yukiho3){
		lx("select.3DElementUnderMouse remove");

			my $harukasan = lxq("query layerservice polset.N ?" );
			@polys;
			for ($i = 0; $i < $harukasan; $i++){
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


}
elsif(lxq("select.typeFrom item;pivot;center;edge;polygon;vertex;ptag ?")) {
	my $shinysmile = lxq("select.lazyState ?");
	lx("select.lazyState 0");

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
		lx("select.type item");		
	}
	lx("select.lazyState $shinysmile");	
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
		lx("select.editSet hoshii add");
		lx("select.useSet $piyochan select");
		lx("select.useSet hoshii deselect");
		lx("select.loop")if ($smokythrill ne "UV2D");
		lx("select.loop space:uv")if ($smokythrill eq "UV2D");
		lx("select.editSet hoshii2 add");
		lx("select.drop polygon");
		lx("select.useSet hoshii select");
		lx("select.useSet hoshii2 deselect");
		lx("select.clearSet hoshii false");
		lx("select.clearSet hoshii2 false");	
		lx("select.clearSet chihaya71 false") if($futami);
		lx("select.clearSet chihaya72 false") if($ami);
		lx("select.clearSet chihaya73 false") if($mami);
}