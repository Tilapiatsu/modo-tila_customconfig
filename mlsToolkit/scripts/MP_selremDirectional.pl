# perl
# <!-- code name : fuguruma -->
# author : "mayatsuka" from PAIPAN MANCO Games Inc.
# and I'm Japanese CG Guild Master. Named "RORIKONSU".
# e-mail  `mayatsuka@gmail.com`  twitter `twitter.com/mayatsuka`


$viewcheck = lxq("query view3dservice view.type ? selected");

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



# maxLoopcount.if you need more or less selectCount. Edit mCount
my $mCount = 1000;

if(lxq("select.typeFrom edge;vertex;polygon;item;pivot;center;ptag ?")) {
	&lazyon if($lazycheck == 0);

	my $makoto1 = lxq("select.count edge ?");
	lx("!!select.3DElementUnderMouse remove");
	my $makoto2 = lxq("select.count edge ?");
	lx("!!select.3DElementUnderMouse add");
	my $makoto3 = lxq("select.count edge ?");
	
	if ($makoto1 == $makoto2){
		# $viewcheck = lxq("query view3dservice view.type ? selected");
			lx("!!select.editSet miki1 add");
				$edgecount = lxq("select.count edge ?");
				$icount = 0;
		
				while ($edgecount != $icount){
					$edgecount2 = lxq("select.count edge ?");
					lx("!!select.more")if ($viewcheck ne "UV2D");
					lx("!!select.more uv")if ($viewcheck eq "UV2D");
					
					# $checkcount += 1;
					# if ($checkcount % 30 == 0){
						$icount = lxq("select.count edge ?");
						if ($edgecount2 == $icount){
							last;
						}
					# }
					$killcount += 1;
					if ($killcount == $mCount){
						last;
					}
				}		
			lx("!!select.editSet miki2 add");
			lx("!!select.drop edge");
			lx("!!select.boundary")if ($viewcheck ne "UV2D");
			lx("!!uv.selectBorder")if ($viewcheck eq "UV2D");
				my $makoto4 = lxq("select.count edge ?");
					lx("!!select.editSet miki3 add")if($makoto4 != 0);
			# lx("!!select.useSet miki2 select")if($makoto3 != $makoto5);
			lx("!!select.useSet miki2 select");
			lx("!!select.useSet miki3 deselect");
			lx("!!select.deleteSet miki2 false");
			lx("!!select.deleteSet miki3 false");
			lx("!!select.useSet miki1 select");
			lx("!!select.deleteSet miki1 false");
		# }
	}
	elsif ($makoto1 == $makoto3){

		my $harukasan = lxq("query layerservice vmap.N ? all" );
		@vmaps;
		for (my $i = 0; $i < $harukasan; $i++){
			$vmaps[$i] = lxq("query layerservice vmap.name ? $i" );
		}

		&paitouch (@vmaps);

		if ($yayoiori eq "101" or $yayoiori eq "100"){
			&nijiiromiracle ("chihaya71");
		}
		elsif ($yayoiori eq "110"){
			&nijiiromiracle ("chihaya72");
		}
		elsif ($yayoiori eq "011"){
			&nijiiromiracle ("chihaya73");
		}
	}
	&lazyoff if($lazycheck == 0);

}
elsif(lxq("select.typeFrom polygon;edge;vertex;item;pivot;center;ptag ?")) {

	my $yukiho1 = lxq("select.count polygon ?");
	lx("!!select.3DElementUnderMouse remove");
	my $yukiho2 = lxq("select.count polygon ?");
	lx("!!select.3DElementUnderMouse add");
	my $yukiho3 = lxq("select.count polygon ?");
	
	if ($yukiho1 == $yukiho2){
		$viewcheck = lxq("query view3dservice view.type ? selected");
		$polycount = lxq("select.count polygon ?");
		$icount = 0;

		while ($polycount != $icount){
			$polycount2 = lxq("select.count polygon ?");
			lx("!!select.more")if ($viewcheck ne "UV2D");
			lx("!!select.more uv")if ($viewcheck eq "UV2D");
			
			# $checkcount += 1;
			# if ($checkcount % 30 == 0){
				$icount = lxq("select.count polygon ?");
				if ($polycount2 == $icount){
					last;
				}
			# }

			$killcount += 1;
			if ($killcount == $mCount){
				last;
			}
		}
	}
	elsif ($yukiho1 == $yukiho3){

		my $harukasan = lxq("query layerservice polset.N ?" );
		@polys;
		for (my $i = 0; $i < $harukasan; $i++){
			$polys[$i] = lxq("query layerservice polset.name ? $i" );
		}
	
		&paitouch (@polys);
	
		if ($yayoiori eq "101" or $yayoiori eq "100"){
			&ramuneiroseishun ("chihaya71");
		}
		elsif ($yayoiori eq "110"){
			&ramuneiroseishun ("chihaya72");
		}
		elsif ($yayoiori eq "011"){
			&ramuneiroseishun ("chihaya73");
		}
	}
}
elsif(lxq("select.typeFrom vertex;edge;polygon;item;pivot;center;ptag ?")) {
	&lazyon if($lazycheck == 0);

	my $makoto1 = lxq("select.count vertex ?");
	lx("!!select.3DElementUnderMouse remove");
	my $makoto2 = lxq("select.count vertex ?");
	lx("!!select.3DElementUnderMouse add");
	my $makoto3 = lxq("select.count vertex ?");
	
	if ($makoto1 == $makoto2){
		# $viewcheck = lxq("query view3dservice view.type ? selected");
			lx("!!select.editSet miki1 add");
				$vertexcount = lxq("select.count vertex ?");
				$icount = 0;
		
				while ($vertexcount != $icount){
					$vertexcount2 = lxq("select.count vertex ?");
					lx("!!select.more")if ($viewcheck ne "UV2D");
					lx("!!select.more uv")if ($viewcheck eq "UV2D");
					
					# $checkcount += 1;
					# if ($checkcount % 30 == 0){
						$icount = lxq("select.count vertex ?");
						if ($vertexcount2 == $icount){
							last;
						}
					# }
					$killcount += 1;
					if ($killcount == $mCount){
						last;
					}
				}		
			lx("!!select.editSet miki2 add");
			lx("!!select.drop vertex");
			# lx("!!select.boundary")if ($viewcheck ne "UV2D");
			# lx("!!uv.selectBorder")if ($viewcheck eq "UV2D");
			# 	my $makoto4 = lxq("select.count vertex ?");
			# 		lx("!!select.editSet miki3 add")if($makoto4 != 0);
			# lx("!!select.useSet miki2 select")if($makoto3 != $makoto5);
			lx("!!select.useSet miki2 select");
			# lx("!!select.useSet miki3 deselect");
			lx("!!select.deleteSet miki2 false");
			# lx("!!select.deleteSet miki3 false");
			lx("!!select.useSet miki1 select");
			lx("!!select.deleteSet miki1 false");
		# }
	}

	&lazyoff if($lazycheck == 0);

}

# ++++ sub routine ++++

sub paitouch {
	$futami = 0;
	$ami = 0;
	$mami = 0;

	foreach $ricchan1 (@_){
		$futami = 1 if ($ricchan1 eq "chihaya71");
		$ami = 1 if ($ricchan1 eq "chihaya72");
		$mami = 1 if ($ricchan1 eq "chihaya73");
	}

	$yayoiori = "$futami"."$ami"."$mami";
}

# ++++ sub routine ++++

sub nijiiromiracle{

	my $piyochan;
	($piyochan) = @_;
	# $viewcheck = lxq("query view3dservice view.type ? selected");
		lx("!!select.editSet hoshii add");
		lx("!!select.useSet $piyochan select");
		lx("!!select.useSet hoshii deselect");
		lx("!!select.3DElementUnderMouse remove");
		lx("!!select.3DElementUnderMouse add");
				$edgecount = lxq("select.count edge ?");
				lxout("$edgecount");
				$icount = 0;
		
				while ($edgecount != $icount){
					$edgecount2 = lxq("select.count edge ?");
					lx("!!select.more")if ($viewcheck ne "UV2D");
					lx("!!select.more uv")if ($viewcheck eq "UV2D");
					
					# $checkcount += 1;
					# if ($checkcount % 30 == 0){
						$icount = lxq("select.count edge ?");
						if ($edgecount2 == $icount){
							last;
						}
					# }
		
					$killcount += 1;
					if ($killcount == $mCount){
						last;
					}
				}
		lx("!!select.editSet hoshii2 add");
		lx("!!select.drop edge");
		lx("!!select.boundary")if ($viewcheck ne "UV2D");
		lx("!!uv.selectBorder")if ($viewcheck eq "UV2D");
			my $makoto5 = lxq("select.count edge ?");
				lx("!!select.editSet miki4 add")if($makoto5 != 0);
		lx("!!select.useSet hoshii2 select");
		lx("!!select.useSet miki4 deselect");
		lx("!!select.editSet miki5 add");
		lx("!!select.useSet hoshii select");
		lx("!!select.useSet miki5 deselect");
		lx("!!select.deleteSet hoshii false");
		lx("!!select.deleteSet hoshii2 false");
		lx("!!select.deleteSet miki4 false");
		lx("!!select.deleteSet miki5 false");
		lx("!!vertMap.deleteByName epck chihaya71") if($futami);
		lx("!!vertMap.deleteByName epck chihaya72") if($ami);
		lx("!!vertMap.deleteByName epck chihaya73") if($mami);
}

# ++++ sub routine ++++

sub ramuneiroseishun{

	my $piyochan;
	($piyochan) = @_;
	$viewcheck = lxq("query view3dservice view.type ? selected");
		lx("!!select.editSet hoshii add");
		lx("!!select.useSet $piyochan select");
		lx("!!select.useSet hoshii deselect");
		lx("!!select.3DElementUnderMouse remove");
		lx("!!select.3DElementUnderMouse add");
		$polycount = lxq("select.count polygon ?");
		$icount = 0;

		while ($polycount != $icount){
			$polycount2 = lxq("select.count polygon ?");
			lx("!!select.more")if ($viewcheck ne "UV2D");
			lx("!!select.more uv")if ($viewcheck eq "UV2D");
			
			# $checkcount += 1;
			# if ($checkcount % 30 == 0){
				$icount = lxq("select.count polygon ?");
				if ($polycount2 == $icount){
					last;
				}
			# }

			$killcount += 1;
			if ($killcount == $mCount){
				last;
			}
		}
		lx("!!select.editSet hoshii2 add");
		lx("!!select.drop polygon");
		lx("!!select.useSet hoshii select");
		lx("!!select.useSet hoshii2 deselect");
		lx("!!select.deleteSet hoshii false");
		lx("!!select.deleteSet hoshii2 false");	
		lx("!!select.deleteSet chihaya71 false") if($futami);
		lx("!!select.deleteSet chihaya72 false") if($ami);
		lx("!!select.deleteSet chihaya73 false") if($mami);
}