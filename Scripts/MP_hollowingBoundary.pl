# perl
# <!-- code name : Kikurihime -->
# author : "mayatsuka" from OT-tatsunoko.
# and I'm Japanese CG Guild Master. Named "RORIKONSU".
# e-mail  `mayatsuka@gmail.com`  twitter `twitter.com/mayatsuka`


$viewcheck = lxq("query view3dservice view.type ? selected");

if($viewcheck ne "UV2D"){
	if (lxq( "select.typeFrom {polygon;vertex;edge;item} ?" )){
		lx("select.type edge");

		$edgenum = lxq("select.count edge ?");
		lx("select.editSet curedge add")if ($edgenum != 0);

		lx("select.drop edge");

		lx("select.type polygon");
		lx("select.boundary");
		lx("select.editSet ietemp add");
		lx("select.type polygon");
		lx("select.convert edge");
		lx("select.editSet ietemp2 add");
		lx("select.drop edge");

		lx("select.useSet curedge select")if ($edgenum != 0);

		lx("select.useSet ietemp2 deselect");
		lx("select.useSet ietemp select");
		
		lx("vertMap.deleteByName epck curedge")if ($edgenum != 0);
		lx("vertMap.deleteByName epck ietemp");
		lx("vertMap.deleteByName epck ietemp2");
		# lx("select.lazyState true");
		lx("pref.value remapping.selectionSize 27");
	}
}
if($viewcheck eq "UV2D"){
	lx("uv.selectBorder");
	lx("select.type edge");
	$edgecount = lxq("select.count edge ?");
	lx("uv.selectBorder") if($edgecount eq "0");
}

