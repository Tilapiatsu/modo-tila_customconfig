#perl

# author : "mayatsuka"
# e-mail  `mayatsuka@gmail.com`  twitter `twitter.com/mayatsuka`

$maxedgenum = 6000; #safety number edit your own 

$viewport = lxq("query view3dservice view.type ? selected");

if(lxq( "!!select.typeFrom {edge;vertex;polygon;item} ?" )){

	if ($viewport eq "UV2D") {
		lx("select.loop space:uv");
	}
	else{
		$edgecount = lxq("select.count edge ?");

		if ($edgecount == 1 or $edgecount >= $maxedgenum){
			lx("select.loop");
		}
		else{
			for ($i = 0; $i < $edgecount; $i++){
				my $edgecount2 = lxq("select.count edge ?");

				if ($edgecount2 == 1 or $edgecount2 == 0){
					lx("select.loop")if($edgecount2 != 0);
					lx("select.useSet edgefinish select");
					lx("vertMap.deleteByName epck edgefinish");
					last;
				}
				elsif ($edgecount2 > 1){
					lx("select.editSet edgetemp1 add");
					lx("select.less");
					lx("select.editSet edgetemp2 add");

					lx("select.useSet edgetemp1 select");
					lx("select.useSet edgetemp2 deselect");
					lx("select.loop");
					lx("select.editSet edgefinish add");

					lx("select.drop edge");
					lx("select.useSet edgetemp2 select");
					lx("select.useSet edgefinish deselect");

					lx("vertMap.deleteByName epck edgetemp1");
					lx("vertMap.deleteByName epck edgetemp2");			
				}
			}	
		}

	
	}
}
else{

	if ($viewport eq "UV2D") {
		lx("select.loop space:uv");
	}
	else {
		lx("select.loop");
	}

}
