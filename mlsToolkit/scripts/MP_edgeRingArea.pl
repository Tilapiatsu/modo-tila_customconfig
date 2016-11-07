#perl


if(lxq( "!!select.typeFrom {edge;vertex;polygon;item} ?" )){

	lx("!!select.editSet edgetemp1 add");

	lx("select.type polygon");
	$polycount1 = lxq("select.count polygon ?");
	lx("!!select.editSet polytemp1 add")if ($polycount1 != 0);

	lx("select.type edge");

		$uvsetName = lxq("vertMap.list txuv ?");
		lx("vertMap.new ringuv txuv");

		lx("select.ring");
		lx("select.convert polygon");

		lx("tool.set uv.unwrap on");
		$itertemp = lxq("tool.attr uv.unwrap iter ?");
		lx("tool.reset");
		lx("tool.attr uv.unwrap iter 1");
		lx("tool.doApply");
		lx("tool.attr uv.unwrap iter $itertemp");
		lx("tool.drop");

	lx("!!select.drop polygon");
	lx("!!select.useset polytemp1 select")if ($polycount1 != 0);
	lx("!!select.deleteSet polytemp1 false")if ($polycount1 != 0);

	lx("select.type edge");
	lx("select.drop edge");
	lx("select.useset edgetemp1 select");
	lx("select.loop space:uv");

	lx("vertMap.deleteByName epck edgetemp1");


	lx("vertMap.list txuv $uvsetName");

	lx("vertMap.deleteByName txuv ringuv");


}