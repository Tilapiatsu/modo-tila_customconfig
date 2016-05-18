#perl

if(lxq( "!!select.typeFrom {edge;vertex;polygon;item} ?" )){
	$edgesel = lxq("select.count edge ?");
	lx("select.editSet edgeseltemp add");
	lx("select.ring");

	lx("select.convert polygon");
	lx("select.type edge");
	lx("select.drop edge");
	lx("select.useSet edgeseltemp select");
	lx("vertMap.deleteByName epck edgeseltemp");
	lx("select.type polygon");
}
elsif(lxq( "!!select.typeFrom {polygon;vertex;edge;item} ?" )){
	lx("select.type edge");
	$edgesel = lxq("select.count edge ?");
	$edgesel = 1 if($edgesel == 0 or $edgesel > 20);
	lx("select.type polygon");

	$selcheck = lxq("select.count polygon ?");
	lx("select.editSet currentsel add")if($selcheck != 0);

	# lx("select.drop polygon")if($selcheck != 1);
	for (my $i = 0; $i < $edgesel; $i++){
		lx("select.expand");
	}
	

	lx("select.useSet currentsel deselect");
	lx("select.deleteSet currentsel");
}