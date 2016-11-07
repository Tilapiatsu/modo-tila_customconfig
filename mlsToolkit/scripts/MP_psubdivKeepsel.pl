# perl
# <!-- code name : fuguruma -->
# author : "mayatsuka" from PAIPAN MANCO Games Inc.
# and I'm Japanese CG Guild Master. Named "RORIKONSU".
# e-mail  `mayatsuka@gmail.com`  twitter `twitter.com/mayatsuka`


# lx("!!App.undoSuspend");

my $hibiki;
my $keephide = 1;

if(lxq("!!select.typeFrom vertex;edge;polygon;item;pivot;center;ptag ?")) {
	$hibiki = "vertex";
}
elsif(lxq("!!select.typeFrom edge;vertex;polygon;item;pivot;center;ptag ?")) {
	$hibiki = "edge";
}
elsif(lxq("!!select.typeFrom polygon;edge;vertex;item;pivot;center;ptag ?")) {
	$hibiki = "polygon";
}
elsif(lxq("!!select.typeFrom ptag;item;pivot;center;edge;polygon;vertex ?")) {
	$hibiki = "ptag";
}
elsif(lxq("!!select.typeFrom item;pivot;center;edge;polygon;vertex;ptag ?")) {
	$hibiki = "item";
		my $trans1 = lxq("!!tool.set TransformMoveItem ?");
		my $trans2 = lxq("!!tool.set TransformRotateItem ?");
		my $trans3 = lxq("!!tool.set TransformScaleItem ?");
		my $trans4 = lxq("!!tool.set TransformItem ?");
	lx("!!tool.drop");
	lx("!!select.nextMode item");
		lx("!!tool.set TransformMoveItem on")if ($trans1 eq on);
		lx("!!tool.set TransformRotateItem on")if ($trans2 eq on);
		lx("!!tool.set TransformScaleItem on")if ($trans3 eq on);
		lx("!!tool.set TransformItem on")if ($trans4 eq on);
		if(lxq("!!select.typeFrom vertex;edge;polygon;item;pivot;center;ptag ?")) {
			$nextmode = "vertex";
		}
		elsif(lxq("!!select.typeFrom edge;vertex;polygon;item;pivot;center;ptag ?")) {
			$nextmode = "edge";
		}
		elsif(lxq("!!select.typeFrom polygon;edge;vertex;item;pivot;center;ptag ?")) {
			$nextmode = "polygon";
		}
		elsif(lxq("!!select.typeFrom ptag;item;pivot;center;edge;polygon;vertex ?")) {
			$hibiki = "ptag";
		}
	$curstate = item;
}

lx("!!select.type polygon")if ($hibiki ne polygon);
my $takane = lxq("!!select.count polygon ?");
	if($takane != 0) {
		lx("!!select.editSet kawaiidesuyo add");
	}
if($keephide eq 1){
	lx("!!select.polygon add 0 face");
	lx("!!select.editSet unhidepoly add");
	lx("!!select.drop polygon");
}

lx("!!unhide"); # if you don't need unhide. comment out this line.
lx("!!select.drop polygon");
lx("!!select.invert");
lx("!!select.polygon remove type psubdiv 2");
lx("!!select.polygon remove type curve 3");
lx("!!select.polygon remove type bezier 4");
lx("!!select.polygon remove type spatch 5");
lx("!!select.polygon remove type line 7");
my $takane2 = lxq("!!select.count polygon ?");
	if($takane2 != 0){
		lx("!!select.drop polygon");
		lx("!!poly.convert face psubdiv false");
		lx("!!poly.convert face psubdiv true");
		my $takane3 = lxq("!!select.count polygon ?");
			if ($takane3 == 0){
				if($keephide eq 1){
					lx("!!select.useSet unhidepoly select");
					lx("!!select.deleteSet unhidepoly false");
					lx("!!hide.unsel");
					lx("!!select.drop polygon");
				}

				lx("!!select.useSet kawaiidesuyo select")if($takane != 0);
				lx("!!select.deleteSet kawaiidesuyo false")if($takane != 0);
				lx("!!select.type $nextmode")if ($curstate eq "item");
				lx("!!select.type $hibiki")if ($hibiki ne "polygon");
			}
			else {
				if($keephide eq 1){
					lx("!!select.useSet unhidepoly select");
					lx("!!select.deleteSet unhidepoly false");
					lx("!!hide.unsel");
					lx("!!select.drop polygon");
				}

				lx("!!select.deleteSet kawaiidesuyo false")if($takane != 0);
				lx("!!select.type $nextmode")if ($curstate eq "item");
				lx("!!select.type $hibiki")if ($hibiki ne "polygon");
			}

	}
	else{
		lx("!!select.drop polygon");
		lx("!!poly.convert face psubdiv false");

		if($keephide eq 1){		
			lx("!!select.useSet unhidepoly select");
			lx("!!select.deleteSet unhidepoly false");
			lx("!!hide.unsel");
			lx("!!select.drop polygon");
		}

		lx("!!select.useSet kawaiidesuyo select")if($takane != 0);
		lx("!!select.deleteSet kawaiidesuyo false")if($takane != 0);
		lx("!!select.type $nextmode")if ($curstate eq "item");
		lx("!!select.type $hibiki")if ($hibiki ne "polygon");
	}
