#perl
# <!-- code name : Kikurihime -->
# author : "mayatsuka" from OT-tatsunoko.
# and I'm Japanese CG Guild Master. Named "RORIKONSU".
# e-mail  `mayatsuka@gmail.com`  twitter `twitter.com/mayatsuka`


$viewcheck = lxq("query view3dservice view.type ? selected");

$curversion = lxq("query platformservice appversion ?");

$layernum = lxq("query layerservice layer.N ? fg");

if(lxq( "!!select.typeFrom {edge;vertex;polygon;item} ?" )){

	# $viewcheck = lxq("query view3dservice view.type ? selected");

	# if ($viewcheck ne "UV2D");
	if ($viewcheck eq "UV2D"){
		lx("select.type polygon");
		lx("select.drop polygon");
		lx("select.3DElementUnderMouse add");
		lx("select.editSet uvpolytemp add");

		lx("select.type edge");
		lx("select.editSet uvedgetemp add");
		lx("select.drop edge");
		lx("uv.selectBorder");
		lx("select.useSet uvedgetemp select");

		$uvsetName = lxq("vertMap.list txuv ?");

		lx("vertMap.new islanduv txuv");

		# if($curversion > 900 and $layernum != 1){
		# 	lx("select.type item");		
		# 	&unwrapmod;
		# 	lx("select.type edge");				
		# }
		&unwrapmod;

		# lx("tool.set uv.unwrap on");
		# $itertemp = lxq("tool.attr uv.unwrap iter ?");
		# lx("tool.reset");
		# lx("tool.attr uv.unwrap iter 1");
		# lx("tool.doApply");
		# lx("tool.attr uv.unwrap iter $itertemp");
		# lx("tool.drop");

		lx("select.drop edge");
		lx("select.useSet uvedgetemp select");
		lx("vertMap.deleteByName epck uvedgetemp");

		lx("select.type polygon");
		lx("select.useSet uvpolytemp select");
		lx("select.polygonConnect uv");

		lx("select.deleteSet uvpolytemp delete");


		lx("vertMap.list txuv {$uvsetName}");

		lx("vertMap.deleteByName txuv islanduv");

	}
	else{
		if (lxq("select.count edge ?") != 0){

			# lx("select.editSet curedge add");

			$uvsetName = lxq("vertMap.list txuv ?");

			lx("vertMap.new islanduv txuv");

			&unwrapmod;

			# lx("tool.set uv.unwrap on");
			# $itertemp = lxq("tool.attr uv.unwrap iter ?");
			# lx("tool.reset");
			# lx("tool.attr uv.unwrap iter 1");
			# lx("tool.doApply");
			# lx("tool.attr uv.unwrap iter $itertemp");
			# lx("tool.drop");
			# lx("tool.doApply");

			# lx("vertMap.deleteByName epck curedge");

			lx("select.type polygon");
				$curpolycheck = lxq("select.count polygon ?");
				lx("select.editSet polyaddtemp add")if($curpolycheck != 0);

				my $islandsel1 = lxq("select.count polygon ?");
				# lx("!!select.3DElementUnderMouse remove");
				# my $islandsel2 = lxq("select.count polygon ?");
				lx("!!select.3DElementUnderMouse add");
				my $islandsel3 = lxq("select.count polygon ?");

			lx("select.drop polygon");

			lx("!!select.3DElementUnderMouse add");

			lx("select.polygonConnect uv");

			lx("select.editSet adremface add")if($curpolycheck != 0 and $islandsel1 == $islandsel3);

			# lx("select.convert edge");
			# 	lx("select.type polygon");
				lx("select.useSet polyaddtemp select")if($curpolycheck != 0);
				lx("select.useSet adremface deselect")if($curpolycheck != 0 and $islandsel1 == $islandsel3);
				lx("select.deleteSet polyaddtemp delete")if($curpolycheck != 0);
				lx("select.deleteSet adremface delete")if($curpolycheck != 0 and $islandsel1 == $islandsel3);
			lx("select.type edge");
				# lx("!!select.3DElementUnderMouse add");
			# lx("select.useSet curedge select");
			# lx("vertMap.deleteByName epck curedge");

			lx("vertMap.list txuv {$uvsetName}");

			lx("vertMap.deleteByName txuv islanduv");
		}
		elsif (lxq("select.count polygon ?") == 0){
			lx("!!select.3DElementUnderMouse add");
			lx("!!select.polygonConnect m3d");
		}		
	}


}


elsif(lxq( "!!select.typeFrom {polygon;vertex;edge;item} ?" ) and $viewcheck ne "UV2D"){

	$transcheck = lxq("tool.set TransformMove ?");
	$rotatecheck = lxq("tool.set TransformRotate ?");
	$scalecheck = lxq("tool.set TransformScale ?");

	my $lazycheck = lxq("select.lazyState ?");
	lx("select.lazyState 0");
	# lx("tool.drop")if($transcheck eq "on" or $rotatecheck eq "on" or  $scalecheck eq "on");


	if (lxq("select.count polygon ?") != 0){

		$islandsel = lxq("select.count polygon ?");
		lx("select.editSet curpolygon add")if($islandsel != 0);

		$uvsetName = lxq("vertMap.list txuv ?");

		lx("vertMap.new islanduv txuv");
		lx("select.type edge");

		$edgetemp = lxq("select.count edge ?");
		lx("select.editSet curedge add")if ($edgetemp != 0);

		lx("select.drop edge");
		lx("select.type polygon");
		lx("select.boundary");

		lx("select.edge add bond equal");

		&checknine;
		
		&unwrapmod;
		
		# lx("tool.set uv.unwrap on");
		# $itertemp = lxq("tool.attr uv.unwrap iter ?");
		# lx("tool.reset");
		# lx("tool.attr uv.unwrap iter 1");
		# lx("tool.doApply");
		# lx("tool.attr uv.unwrap iter $itertemp");
		# lx("tool.drop");
		# lx("tool.doApply");
		
		lx("select.drop edge");
		lx("select.useSet curedge select")if ($edgetemp != 0);
		lx("vertMap.deleteByName epck curedge");

		lx("select.type polygon");
		lx("select.drop polygon");

		lx("select.3DElementUnderMouse add");
		$invcheck = lxq("select.count polygon ?");

		lx("select.polygonConnect uv")if($invcheck != 0);
		$polycount2 = lxq("select.count polygon ?");


		lx("vertMap.list txuv {$uvsetName}");

		lx("vertMap.deleteByName txuv islanduv");

		$islandcheck = lxq("select.count polygon ?");
		if($invcheck eq 0){
			lx("select.useSet curpolygon select")if($islandsel != 0);
			lx("select.polygonConnect m3d")if($islandsel != 0);
			lx("select.invert");
			$invcount = lxq("select.count polygon ?");
			lx("select.editSet invisl add")if($invcount != 0);
			lx("select.drop polygon");

			lx("select.useSet curpolygon select")if($islandsel != 0);
			lx("select.invert");
			lx("select.useSet invisl deselect")if($invcount != 0);
			lx("select.deleteSet invisl false")if($invcount != 0);
		}
		if($islandsel eq $islandcheck){
			lx("select.3DElementUnderMouse add");
			lx("select.polygonConnect m3d")if($islandsel != 0);
			lx("select.invert");
			$invcount = lxq("select.count polygon ?");
			lx("select.editSet invisl add")if($invcount != 0);
			lx("select.drop polygon");

			lx("select.useSet curpolygon select")if($islandsel != 0);
			lx("select.invert");
			lx("select.useSet invisl deselect")if($invcount != 0);
			lx("select.deleteSet invisl false")if($invcount != 0);
		}
		lx("select.deleteSet curpolygon false")if($islandsel != 0);
	}
	elsif (lxq("select.count polygon ?") == 0){
		lx("select.3DElementUnderMouse add");
		$polycount3 = lxq("select.count polygon ?");
		lx("select.polygonConnect m3d")if($polycount3 != 0);
		lx("select.invert")if($polycount3 == 0);
	}

	lx("tool.set TransformMove on")if($transcheck eq "on");
	lx("tool.set TransformRotate on")if($rotatecheck eq "on");
	lx("tool.set TransformScale on")if($scalecheck eq "on");

	lx("select.lazyState $lazycheck");

}
elsif(lxq( "!!select.typeFrom {polygon;vertex;edge;item} ?" ) and $viewcheck eq "UV2D"){
	lx("select.drop polygon");
	lx("select.3DElementUnderMouse add");
	lx("select.connect uv")if(lxq("select.count polygon ?") != 0);
}

elsif(lxq("select.typeFrom item;pivot;center;edge;polygon;vertex;ptag ?") and $viewcheck eq "UV2D"){

		my $lazycheck = lxq("select.lazyState ?");
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
		lx("select.lazyState $lazycheck");


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

sub checknine{
	if($curversion > 900 or $curversion < 210){
		lx("select.type item");		
		# &unwrapmod;
		lx("tool.set uv.create on");
		lx("tool.reset");
		lx("tool.doApply");
		lx("tool.drop");
		lx("select.type edge");				
	}
}