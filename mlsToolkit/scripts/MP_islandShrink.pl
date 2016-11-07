#perl


$viewcheck = lxq("query view3dservice view.type ? selected");

if(lxq( "!!select.typeFrom {polygon;vertex;edge;item} ?" ) and $viewcheck ne "UV2D"){


	if (lxq("select.count polygon ?") == 0)	{return;}

	lx("!!select.editSet islandtemp1 add");

	my $islandsel1 = lxq("select.count polygon ?");
	lx("!!select.3DElementUnderMouse remove");
	my $islandsel2 = lxq("select.count polygon ?");
	lx("!!select.3DElementUnderMouse add");
	my $islandsel3 = lxq("select.count polygon ?");

	lx("select.drop polygon")if($islandsel1 == $islandsel2);
	lx("!!select.useSet islandtemp1 select")if($islandsel1 == $islandsel2);

		$uvsetName = lxq("vertMap.list txuv ?");
		lx("vertMap.new islanduv txuv");
		lx("select.type edge");
		$edgecount1 = lxq("select.count edge ?");
			lx("select.editSet edgetemp1 add")if ($edgecount1 != 0);
		lx("select.drop edge");
		lx("select.type polygon");
		lx("select.boundary");
		lx("tool.set uv.unwrap on");
		$itertemp = lxq("tool.attr uv.unwrap iter ?");
		lx("tool.reset");
		lx("tool.attr uv.unwrap iter 1");
		lx("tool.doApply");
		lx("tool.attr uv.unwrap iter $itertemp");
		lx("tool.drop");
		# lx("tool.doApply");

	lx("select.type polygon");
	lx("select.drop polygon");

	lx("!!select.3DElementUnderMouse add");

	lx("select.polygonConnect uv");
		$polycount3 = lxq("select.count polygon ?");
		lx("!!select.editSet islandtemp3 add")if ($islandsel1 == $islandsel3);
	lx("select.expand")if ($islandsel1 == $islandsel2);
	lx("select.contract")if ($islandsel1 == $islandsel3);

		$polycount2 = lxq("select.count polygon ?");
		lx("!!select.editSet islandtemp2 add");


		if ($islandsel1 == $islandsel2){
			lx("select.drop polygon");
			lx("!!select.useSet islandtemp1 select");
			lx("!!select.useSet islandtemp2 deselect")if ($polycount2 != 0);
		}
		elsif ($islandsel1 == $islandsel3){
			lx("select.drop polygon");
			lx("!!select.useSet islandtemp1 select");
			lx("!!select.useSet islandtemp3 deselect")if ($polycount3 != 0);
			lx("!!select.useSet islandtemp2 select")if ($polycount2 != 0);
		}

			lx("!!select.deleteSet islandtemp1 false");
			lx("!!select.deleteSet islandtemp2 false");
			lx("!!select.deleteSet islandtemp3 false");

		if ($edgecount1 != 0){
			lx("select.type edge");
			lx("select.drop edge");
			lx("select.useSet edgetemp1 select");
			lx("vertMap.deleteByName epck edgetemp1");
			lx("select.type polygon");
		}	
		elsif ($edgecount1 == 0){
			lx("select.type edge");
			lx("select.drop edge");
			lx("select.type polygon");
		}


		

	lx("vertMap.list txuv $uvsetName");

	lx("vertMap.deleteByName txuv islanduv");

}