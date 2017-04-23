#perl
# <!-- code name : Kikurihime -->
# author : "mayatsuka" from OT-tatsunoko.
# and I'm Japanese CG Guild Master. Named "RORIKONSU".
# e-mail  `mayatsuka@gmail.com`  twitter `twitter.com/mayatsuka`


# if(lxq( "select.typeFrom {vertex;edge;polygon;item} ?" )){

# if(lxq( "select.typeFrom {edge;vertex;polygon;item} ?" )){

$viewcheck = lxq("query view3dservice view.type ? selected");

$curversion = lxq("query platformservice appversion ?");

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
	$lazyedgecheck = lxq("select.count edge ?");
	if($lazyedgecheck == 0){
		lx("!!select.lazyState 1");
		lx("!!select.3DElementUnderMouse add");
		lx("!!select.lazyState 0");				
	}
}

# $layernum = lxq("query layerservice layer.N ? fg");

$itelatefluc = 1;

# if ($viewcheck ne "UV2D"){


# if ($viewcheck eq "UV2D"){

	# vertMap.copy txuv

	# vertMap.paste txuv
$addloopcheck = lxq("tool.set edge.addLoop ?");
$addloopbg = lxq("tool.set AddLoopBGCons ?");
$topocheck = lxq("tool.set mesh.topology ?");
$topobgcheck = lxq("tool.set TopologyPenBGCons ?");
if($addloopcheck eq "on" or $addloopbg eq "on" or $topocheck eq "on" or $topobgcheck eq "on"){
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
if(lxq( "select.typeFrom {edge;vertex;polygon;item} ?" ) and ($viewcheck ne "UV2D")){


	$transcheck = lxq("tool.set TransformMove ?");
	$rotatecheck = lxq("tool.set TransformRotate ?");
	$scalecheck = lxq("tool.set TransformScale ?");
	$slidecheck = lxq("tool.set EdgeSlide ?");
	$slidebg = lxq("tool.set EdgeSlideBGCons ?");
	$smoothcheck = lxq("tool.set xfrm.smooth ?");
	$smoothbg = lxq("tool.set SmoothBGCons ?");
	$pushcheck = lxq("tool.set xfrm.push ?");

	if($transcheck eq "on" or $rotatecheck eq "on" or $scalecheck eq "on" or $slidecheck eq "on" or $slidebg eq "on" or $smoothcheck eq "on" or $smoothbg eq "on" or $pushcheck eq "on"){

		$loopcount = lxq("select.count edge ?");
		if($loopcount eq "0"){
			&lazyon if($lazycheck == 0);
			lx("select.3DElementUnderMouse add");
				&lazyadd;
			lx("select.loop");
			&lazyoff if($lazycheck == 0);
		}
		else{
			lx("select.editSet motoedge add")if($loopcount != 0);

			&lazyon if($lazycheck == 0);
			lx("select.drop edge");
			lx("select.3DElementUnderMouse set");
				&lazyadd if($lazycheck == 0);
			lx("select.loop");
			lx("select.invert");
			lx("select.editSet invertedge add");
			lx("select.drop edge");
			lx("select.useSet motoedge select");
			lx("select.expand");
			lx("select.expand");
			lx("select.contract");
			lx("select.useSet invertedge deselect");

			lx("vertMap.deleteByName epck invertedge");
			lx("vertMap.deleteByName epck motoedge");

			$loopcount3 = lxq("select.count edge ?");

			if($loopcount3 == 0){
				lx("select.3DElementUnderMouse set");
				lx("select.loop");
			}
			lx("vertMap.deleteByName epck motoedge")if($loopcount != 0);
			&lazyoff if($lazycheck == 0);
		}

	}
	else{

	&lazyon if($lazycheck == 0);

	$firstcheck = lxq("select.count edge ?");
	if($firstcheck != 0){
		lx("select.editSet tempedge add");
		lx("select.drop edge");
		lx("select.useSet tempedge select");
		lx("vertMap.deleteByName epck tempedge");		
	}


	my $checkEdge1 = lxq("select.count edge ?");
	lx("select.3DElementUnderMouse remove");
	my $checkEdge2 = lxq("select.count edge ?");
	# lx("select.3DElementUnderMouse add");
	# my $checkEdge3 = lxq("select.count edge ?");

	# lx("select.3DElementUnderMouse remove");

	if ($checkEdge1 == $checkEdge2){

		if (lxq("select.count edge ?") != 0){

			lx("select.editSet curedge add");

			lx("select.drop edge");
			lx("select.3DElementUnderMouse add");
				&lazyadd if($lazycheck == 0);
			lx("select.editSet firstedge add");

			lx("select.drop edge");

			lx("select.useSet curedge select");
			lx("select.edge add bond equal");

			$uvsetName = lxq("vertMap.list txuv ?");

			lx("vertMap.new islanduv txuv");

			&checknine;

			&unwrapmod;
			# lx("tool.doApply");

			# lx("vertMap.deleteByName epck curedge");


			lx("select.drop edge");
			lx("select.useSet firstedge select");

			# $isledgecheck = lxq("select.count edge ?");

			# if($isledgecheck != 0){
				# lxout("test3");
				lx("select.loop");
				lx("select.invert");
				lx("select.editSet invedge add");
				lx("select.drop edge");

				# lx("uv.selectBorder");
				# lx("select.editSet invedge add")if (lxq("select.count edge ?") != 0);
				# lx("select.drop edge");

				lx("select.useSet firstedge select");
				lx("select.loop space:uv");

				lx("select.useSet invedge deselect");
				# lx("select.edge remove bond less");
			# }


			lx("select.useSet curedge select");
			lx("vertMap.deleteByName epck curedge");
			lx("vertMap.deleteByName epck firstedge");
			lx("vertMap.deleteByName epck invedge");

			lx("vertMap.list txuv {$uvsetName}");

			lx("vertMap.deleteByName txuv islanduv");
		}
		elsif (lxq("select.count edge ?") == 0){
			lx("select.3DElementUnderMouse add");
				&lazyadd if($lazycheck == 0);
			lx("select.loop");
		}
	}
	elsif ($checkEdge1 != $checkEdge2){

		$deselcheck = lxq("select.count edge ?");
		lx("select.editSet curedge add")if($deselcheck != 0);

		lx("select.drop edge");
		lx("select.3DElementUnderMouse add");

		&lazyadd if($lazycheck == 0);

		$isledgecheck = lxq("select.count edge ?");

		if($isledgecheck != 0){

			lx("select.editSet firstedge add");

			lx("select.loop");
			lx("select.editSet loopedge add");

			lx("select.useSet curedge select");

			lx("select.useSet loopedge deselect");

			lx("select.edge add bond equal");

			$uvsetName = lxq("vertMap.list txuv ?");

			lx("vertMap.new islanduv txuv");

			$itelatefluc = 4;

			&checknine;

			&unwrapmod;
			# lx("tool.doApply");

			# lx("vertMap.deleteByName epck curedge");

			lx("select.drop edge");
			lx("select.useSet firstedge select");
			lx("select.loop space:uv");

			# lx("select.edge remove bond less (none)");

			lx("select.editSet uvedge add");
		}


		if($deselcheck != 0){
			lx("select.useSet curedge select");	
			lx("vertMap.deleteByName epck curedge");
		}

		if($isledgecheck != 0){
			lx("select.useSet uvedge deselect");

			lx("vertMap.deleteByName epck loopedge");
			lx("vertMap.deleteByName epck uvedge");
			lx("vertMap.deleteByName epck firstedge");

			lx("vertMap.list txuv {$uvsetName}");

			lx("vertMap.deleteByName txuv islanduv");			
		}

	}

	&lazyoff if($lazycheck == 0);
	}


}
elsif(lxq( "select.typeFrom {edge;vertex;polygon;item} ?" ) and ($viewcheck eq "UV2D")){

	&lazyon if($lazycheck == 0);

	my $checkEdge1 = lxq("select.count edge ?");
	lx("select.3DElementUnderMouse add");
	&lazyadd if($lazycheck == 0);
	lx("select.editSet selproof add");
	lx("select.drop edge");
	lx("select.useSet selproof select");
	lx("vertMap.deleteByName epck selproof");
	my $checkEdge2 = lxq("select.count edge ?");


	$edgecount = lxq("select.count edge ?");
	lx("select.editSet curedgetemp add")if ($edgecount != 0);

	lx("select.drop edge");

	# lx("uv.selectBorder");
	# lx("select.editSet borderedge add");
	# lx("select.drop edge");

	lx("select.3DElementUnderMouse add");

	lx("select.loop");
	lx("select.invert");
	lx("select.editSet invertEdge add");

	lx("select.drop edge");

	lx("select.3DElementUnderMouse add");

	lx("select.loop space:uv");
	lx("select.editSet uvrepeat add");
	lx("select.drop edge");
	lx("select.useSet uvrepeat select");
	# lx("select.useSet borderedge deselect");
	# lx("select.edge remove bond less");
	lx("select.useSet invertEdge deselect");

	lx("select.editSet deseltemp add")if($checkEdge1 == $checkEdge2);

	lx("select.useSet curedgetemp select")if ($edgecount != 0);

	lx("select.useSet deseltemp deselect")if($checkEdge1 == $checkEdge2);
	lx("vertMap.deleteByName epck deseltemp")if($checkEdge1 == $checkEdge2);

	lx("vertMap.deleteByName epck uvrepeat");
	# lx("vertMap.deleteByName epck borderedge");
	lx("vertMap.deleteByName epck invertEdge");
	lx("vertMap.deleteByName epck curedgetemp")if ($edgecount != 0);


	&lazyoff if($lazycheck == 0);

}

elsif(lxq( "select.typeFrom {polygon;vertex;edge;item} ?" ) and ($viewcheck ne "UV2D")){

	$transcheck = lxq("tool.set TransformMove ?");
	$rotatecheck = lxq("tool.set TransformRotate ?");
	$scalecheck = lxq("tool.set TransformScale ?");
	# lx("tool.drop")if($transcheck eq "on" or $rotatecheck eq "on" or  $scalecheck eq "on");


	if (lxq("select.count polygon ?") != 0){
		lx("select.editSet islandtemp1 add");

		my $islandsel1 = lxq("select.count polygon ?");
		lx("select.3DElementUnderMouse remove");
		my $islandsel2 = lxq("select.count polygon ?");
		# lx("select.3DElementUnderMouse add");
		# my $islandsel3 = lxq("select.count polygon ?");

		# lx("select.drop polygon")if($islandsel1 == $islandsel2);
		lx("select.drop polygon");
		lx("select.3DElementUnderMouse add");
		$firstpolycount = lxq("select.count polygon ?");
		lx("select.editSet firstpoly add")if($firstpolycount != 0);

		lx("select.drop polygon");

		# lx("select.3DElementUnderMouse add")if($viewcheck eq "UV2D");
		# lx("select.editSet selmarkface add")if($viewcheck eq "UV2D");
		# lx("select.drop polygon")if($viewcheck eq "UV2D");

		# lx("select.useSet islandtemp1 select")if($islandsel1 == $islandsel2);
		lx("select.useSet islandtemp1 select");

		if($firstpolycount != 0){
			
			$uvsetName = lxq("vertMap.list txuv ?");

			lx("vertMap.new islanduv txuv");
			lx("select.type edge");

			$edgetemp = lxq("select.count edge ?");
			lx("select.editSet curedge add")if ($edgetemp != 0);

			lx("select.drop edge");
			lx("select.type polygon");
			lx("select.boundary");

			lx("select.edge add bond equal (none)");

			&checknine;

			&unwrapmod;
			# lx("tool.doApply");

			lx("select.drop edge");
			lx("select.useSet curedge select")if ($edgetemp != 0);
			lx("vertMap.deleteByName epck curedge");


			lx("select.type polygon");
			lx("select.drop polygon");

			# lx("select.3DElementUnderMouse add");
			lx("select.useSet firstpoly select");
			# lx("select.useSet selmarkface select")if($viewcheck eq "UV2D");
			# lx("select.deleteSet selmarkface delete")if($viewcheck eq "UV2D");

			lx("select.polygonConnect uv");
			$polycount2 = lxq("select.count polygon ?");
			lx("select.editSet islandtemp2 add");


			if ($islandsel1 == $islandsel2){
				lx("select.drop polygon");
				lx("select.useSet islandtemp1 select");
				lx("select.useSet islandtemp2 select")if ($polycount2 != 0);
			}
			elsif ($islandsel1 != $islandsel2){
				lx("select.drop polygon");
				lx("select.useSet islandtemp1 select");
				lx("select.useSet islandtemp2 deselect")if ($polycount2 != 0);
			}

			lx("select.deleteSet islandtemp1 false");
			lx("select.deleteSet islandtemp2 false");
			lx("select.deleteSet firstpoly false");

			lx("vertMap.list txuv {$uvsetName}");

			lx("vertMap.deleteByName txuv islanduv");			
		}
		else{
			lx("select.deleteSet islandtemp1 false");
		}
	}
	elsif (lxq("select.count polygon ?") == 0){
		lx("select.3DElementUnderMouse add");
		lx("select.polygonConnect m3d")if(lxq("select.count polygon ?") != 0);
	}

	lx("tool.set TransformMove on")if($transcheck eq "on");
	lx("tool.set TransformRotate on")if($rotatecheck eq "on");
	lx("tool.set TransformScale on")if($scalecheck eq "on");



}
elsif(lxq( "select.typeFrom {polygon;vertex;edge;item} ?" ) and ($viewcheck eq "UV2D")){

	# $toolcheck = lxq("tool.snapState ?");
	# if($toolcheck == 1){
	# 	lx("select.drop polygon");
	# 	lx("select.3DElementUnderMouse add");
	# 	lx("select.connect uv")if(lxq("select.count polygon ?") != 0);
	# }
	# else{
		if (lxq("select.count polygon ?") != 0){
			lx("select.editSet islandtemp1 add");

			my $islandsel1 = lxq("select.count polygon ?");
			lx("select.3DElementUnderMouse remove");
			my $islandsel2 = lxq("select.count polygon ?");
			lx("select.3DElementUnderMouse add");
			my $islandsel3 = lxq("select.count polygon ?");

			# lx("select.drop polygon")if($islandsel1 == $islandsel2);
			lx("select.drop polygon");

			lx("select.3DElementUnderMouse add");
			lx("select.editSet selmarkface add");
			lx("select.drop polygon");

			lx("select.type vertex");
			$verttemp = lxq("select.count vertex ?");
			lx("select.editSet curvert add")if ($verttemp != 0);

			lx("select.type edge");
			$edgetemp = lxq("select.count edge ?");
			lx("select.editSet curedge add")if ($edgetemp != 0);
			lx("select.drop edge");
			lx("uv.selectBorder");
			lx("select.editSet borderback add");
			lx("select.drop edge");

			lx("select.type polygon");


			# lx("select.useSet islandtemp1 select")if($islandsel1 == $islandsel2);
			lx("select.useSet islandtemp1 select");

			$uvsetName = lxq("vertMap.list txuv ?");

			lx("vertMap.new islanduv txuv");
			# lx("select.type edge");

			# $edgetemp = lxq("select.count edge ?");
			# lx("select.editSet curedge add")if ($edgetemp != 0);

			# lx("select.drop edge");
			# lx("uv.selectBorder");
			# lx("select.editSet borderback add");

			# lx("select.drop edge");
			# lx("select.type polygon");
			lx("select.boundary");

			lx("select.type edge");

			lx("select.useSet borderback select");
			lx("vertMap.deleteByName epck borderback");

			&unwrapmod;
			# lx("tool.doApply");

			lx("select.drop edge");
			lx("select.useSet curedge select")if ($edgetemp != 0);
			lx("vertMap.deleteByName epck curedge")if ($edgetemp != 0);

			lx("select.type vertex");
			lx("select.drop vertex");
			lx("select.useSet curvert select")if ($verttemp != 0);
			lx("select.deleteSet curvert delete")if ($verttemp != 0);


			lx("select.type polygon");
			lx("select.drop polygon");

			# lx("select.3DElementUnderMouse add")if($viewcheck ne "UV2D");
			lx("select.useSet selmarkface select");
			lx("select.deleteSet selmarkface delete");

			lx("select.polygonConnect uv")if ($islandsel2 != $islandsel3);
			$polycount2 = lxq("select.count polygon ?");
			lx("select.editSet islandtemp2 add");


			if ($islandsel1 == $islandsel2){
				lx("select.drop polygon");
				lx("select.useSet islandtemp1 select");
				lx("select.useSet islandtemp2 select")if ($polycount2 != 0);
			}
			elsif ($islandsel1 == $islandsel3){
				lx("select.drop polygon");
				lx("select.useSet islandtemp1 select");
				lx("select.useSet islandtemp2 deselect")if ($polycount2 != 0);
			}

			lx("select.deleteSet islandtemp1 false");
			lx("select.deleteSet islandtemp2 false");

			lx("vertMap.list txuv {$uvsetName}");

			lx("vertMap.deleteByName txuv islanduv");
		}
		elsif (lxq("select.count polygon ?") == 0){
			lx("select.3DElementUnderMouse add");
			lx("select.polygonConnect uv")if(lxq("select.count polygon ?") != 0);
		}		
	# }

}
elsif ($viewcheck eq "UV2D"){

	if(lxq("select.typeFrom item;pivot;center;edge;polygon;vertex;ptag ?")) {

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


			lx("tool.setAttr xfrm.transform RZ 90");
			lx("tool.doApply");
			lx("tool.drop");

			lx("tool.set actr.auto off");

			lx("select.type polygon");
			lx("select.drop polygon");
			lx("select.useSet curpolygon select")if($polycount != 0);
			lx("select.deleteSet curpolygon delete")if($polycount != 0);
			lx("select.type item");		
		}
		&lazyoff if($lazycheck == 0);
	}



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
# }