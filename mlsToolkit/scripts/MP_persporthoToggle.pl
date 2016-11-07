# perl
# author : "mayatsuka" from PAIPAN MANCO Games Inc.
# and I'm japanese CG Guild Master. Named "RORIKONSU".
# e-mail  `mayatsuka@gmail.com`  twitter `twitter.com/mayatsuka`

$viewcheck = lxq("query view3dservice view.type ? selected");
if($viewcheck eq "MO3D"){
	$view = lxq('view3d.projection ?');
	if ($view eq 'psp'){
		$pers = lxq( "pref.value opengl.perspective ?" );
		if ($pers eq 2.5){
			# maya aov
				lx("pref.value opengl.perspective 0.5443");
			# softimage fov
				# lx("pref.value opengl.perspective 0.53638");
			# 3ds max fov
				# lx("pref.value opengl.perspective 0.45");
			# modo default
				# lx("pref.value opengl.perspective 0.4");
			# lx("view3d.bgEnvironment background shaded");		
		}
		else{
			lx("pref.value opengl.perspective 2.5");
			# lx("pref.value opengl.perspective 2.0");
			# lx("view3d.bgEnvironment background solid")	;
		}

	}
	else{
		lx('view3d.projection psp');
	}
	
}
