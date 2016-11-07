# perl


if (lxq( "!!select.typeFrom {polygon;vertex;edge;item} ?" )){
	lx("!!select.type edge");
	lx("!!select.drop edge");
	lx("!!select.type polygon");
	lx("!!select.boundary");
	lx("!!select.editSet ietemp add");
	lx("!!select.type polygon");
	lx("!!select.convert edge");
	lx("!!select.editSet ietemp2 add");
	lx("!!select.drop edge");
	lx("!!select.useSet ietemp2 select");
	lx("!!select.useSet ietemp deselect");
	lx("!!vertMap.deleteByName epck ietemp");
	lx("!!vertMap.deleteByName epck ietemp2");
	lx("!!select.lazyState true");
}