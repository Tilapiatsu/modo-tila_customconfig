#perl

my $addor = $ARGV[0];


if(lxq( "select.typeFrom {edge;vertex;polygon;item} ?" )){

	if($addor eq "add"){
		$edgechek = lxq("select.count edge ?");
		if($edgechek != 0){
			lx("select.editSet curedge add");
			lx("select.loop");
			lx("select.invert");
			lx("select.editSet invedge add");
			lx("select.drop edge");
			lx("select.useSet curedge select");
			lx("select.expand");
			lx("select.useSet invedge deselect");

			lx("vertMap.deleteByName epck curedge");
			lx("vertMap.deleteByName epck invedge");			
		}

	}
	# if($addor eq "less"){
	# 	$edgenumcheck = lxq("select.count edge ?");
	# 	if($edgenumcheck >1){
	# 		lx("select.editSet curedge add");

	# 		lx("select.type polygon");
	# 		$polycheck = lxq("select.count polygon ?");
	# 		lx("select.editSet polytemp add")if($polycheck != 0);


	# 		lx("select.type edge");
	# 		lx("select.ring");
	# 		lx("select.convert polygon");
	# 		lx("select.contract");
	# 		lx("select.convert edge");
	# 		lx("select.invert");
	# 		lx("select.editSet invedge add");
	# 		lx("select.drop edge");
	# 		lx("select.useSet curedge select");
	# 		# lx("select.expand");
	# 		lx("select.useSet invedge deselect");

	# 		if($polycheck != 0){
	# 			lx("select.type polygon");
	# 			lx("select.drop polygon");
	# 			lx("select.useSet polytemp select");
	# 			lx("select.deleteSet polytemp delete");

	# 			lx("select.type edge");
	# 		}
	# 		lx("vertMap.deleteByName epck curedge");
	# 		lx("vertMap.deleteByName epck invedge");
	# 	}

	# }
	if($addor eq "less"){
		$edgenumcheck = lxq("select.count edge ?");
		if($edgenumcheck >1){
			lx("select.editSet curedge add");

			lx("select.type polygon");
			$polycheck = lxq("select.count polygon ?");
			lx("select.editSet polytemp add")if($polycheck != 0);


			lx("select.type edge");
			lx("select.convert vertex");
			lx("select.convert polygon");
			$polycon = lxq("select.count polygon ?");

			if($polycon != 0){
				lx("select.contract");
				$polycon2 = lxq("select.count polygon ?");

				if($polycon2 != 0){

					lx("select.convert edge");
					$edgesafe = lxq("select.count edge ?");
					if($edgesafe != 0){
						lx("select.ring");
						lx("select.invert");
						lx("select.editSet invedge add");
						lx("select.drop edge");
						lx("select.useSet curedge select");
						# lx("select.expand");
						lx("select.useSet invedge deselect");

						lx("vertMap.deleteByName epck curedge");
						lx("vertMap.deleteByName epck invedge")if($edgesafe != 0);
					}
				}			
			}

			if($polycheck != 0){
				lx("select.type polygon");
				lx("select.drop polygon");
				lx("select.useSet polytemp select");
				lx("select.deleteSet polytemp delete");

				lx("select.type edge");
			}
		}
		$secondcheck = lxq("select.count edge ?");
		if($edgenumcheck == $secondcheck and $secondcheck != 0 or $polycon == 0 or $polycon2 == 0){
			if($secondcheck != 0){
				lx("select.type edge");
				# lx("select.editSet curedge add");
				lx("select.loop");
				lx("select.invert");
				lx("select.editSet invedge add");
				lx("select.drop edge");
				lx("select.useSet curedge select");
				lx("select.expand");
				lx("select.useSet invedge deselect");
				lx("select.useSet curedge deselect");
				$selcount = lxq("select.count edge ?");
				if($selcount == 0){
					lx("select.useSet curedge select");
				}
				else{
					lx("select.expand");
					lx("select.editSet expedge add");
					lx("select.useSet curedge select");
					lx("select.useSet expedge deselect");
					lx("vertMap.deleteByName epck expedge");					
				}
				lx("vertMap.deleteByName epck curedge");
				lx("vertMap.deleteByName epck invedge");
			}

		}
		$thirdcheck = lxq("select.count edge ?");
		if($edgenumcheck == $thirdcheck and $thirdcheck != 0){
			if($edgenumcheck >1){

				lx("select.type edge");
				# lx("select.editSet curedge add");

				lx("select.type polygon");
				$polycheck = lxq("select.count polygon ?");
				lx("select.editSet polytemp add")if($polycheck != 0);


				lx("select.type edge");
				lx("select.ring");
				lx("select.convert vertex");
				lx("select.convert polygon");
				lx("select.contract");
				lx("select.convert edge");
				lx("select.invert");
				lx("select.editSet invedge add");
				lx("select.drop edge");
				lx("select.useSet curedge select");
				# lx("select.expand");
				lx("select.useSet invedge deselect");

				if($polycheck != 0){
					lx("select.type polygon");
					lx("select.drop polygon");
					lx("select.useSet polytemp select");
					lx("select.deleteSet polytemp delete");

					lx("select.type edge");
				}
				lx("vertMap.deleteByName epck curedge");
				lx("vertMap.deleteByName epck invedge");
			}
		}
	}

}
elsif(lxq( "select.typeFrom {polygon;vertex;edge;item} ?" )){
	if($addor eq "add"){
		lx("select.type edge");
		$edgesel = lxq("select.count edge ?");
		lx("select.editSet curedge add")if($edgesel != 0);

		lx("select.type polygon");
		$selcheck = lxq("select.count polygon ?");
		if($selcheck != 0){
			lx("select.editSet currentsel add");

			# lx("select.drop polygon")if($selcheck != 1);
			lx("select.convert edge");
			lx("select.expand");
			# lx("select.convert vertex");
			lx("select.convert polygon");

			lx("select.useSet currentsel deselect");
			lx("select.deleteSet currentsel");

			if($edgesel != 0){
				lx("select.type edge");
				lx("select.drop edge");
				lx("select.useSet curedge select");
				lx("vertMap.deleteByName epck curedge");
				lx("select.type polygon");			
			}

		}		
	}


}