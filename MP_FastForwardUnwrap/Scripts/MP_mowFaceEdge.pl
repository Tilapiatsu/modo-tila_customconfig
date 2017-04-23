#perl

if(lxq("select.typeFrom polygon;edge;vertex;item;pivot;center;ptag ?")) {
	$polycount = lxq("select.count polygon ?");
	if($polycount != 0){
		lx("select.type edge");
		$edgecount = lxq("select.count edge ?");
		if($edgecount != 0){
			lx("select.editSet curedge add");
			lx("select.drop edge");
			lx("select.type polygon");
			lx("select.convert edge");
			lx("select.editSet convedge add");
			lx("select.drop edge");

			lx("select.useSet curedge select");
			lx("select.useSet convedge deselect");

			lx("vertMap.deleteByName epck curedge");
			lx("vertMap.deleteByName epck convedge");

			lx("pref.value remapping.selectionSize 27")
		}
	}
}
