#perl
# <!-- code name : Kikurihime -->
# author : "mayatsuka" from OT-tatsunoko.
# and I'm Japanese CG Guild Master. Named "RORIKONSU".
# e-mail  `mayatsuka@gmail.com`  twitter `twitter.com/mayatsuka`


# my $mirDir = $ARGV[0];

# lx("select.3DElementUnderMouse set");
# lx("select.polygonConnect uv");

# # lx("tool.set actr.auto off");
# lx("tool.set actr.auto on");

# lx("tool.set TransformMove on");


# $gettransu = lxq("tool.attr center.auto cenU ?");
# $gettransv = lxq("tool.attr center.auto cenV ?");

# lxout($gettransu);
# lxout($gettransv);

# lx("tool.drop");

# lx("uv.mirror u {$gettransu}")if($mirDir eq "u");
# lx("uv.mirror v {$gettransv}")if($mirDir eq "v");

# lx("select.drop polygon");

# lx("tool.set actr.auto off");




my $mirDir = $ARGV[0];

$viewcheck = lxq("query view3dservice view.type ? selected");



if($viewcheck eq "UV2D"){

	$symstate = lxq("select.symmetryState ?");
	$uvsymstate = lxq("select.symmetryUVState ?");
	lx("select.symmetryState none");
	lx("select.symmetryUVState none");
	

	$lazycheck = lxq("select.lazyState ?");
	lx("!!select.lazyState 1");

	# lx("tool.set center.auto on");
	# lx("select.type vertex");
	# lx("select.drop vertex");
	# lx("select.3DElementUnderMouse set");
	lx("select.type polygon");
	lx("select.drop polygon");

	lx("select.3DElementUnderMouse set");
	if(lxq("select.count polygon ?") != 0){
		lx("select.connect uv");

		@vtest = lxq("query view3dservice mouse.pos ?");


		# tool.set center.auto on

		# lx("tool.set actr.auto off");
		# lx("tool.set TransformMove on");
		# lx("tool.reset");
		# lx("tool.set actr.auto on");
		# $negcheck = lxq("tool.attr xfrm.transform negScale ?");
		# lx("tool.attr xfrm.transform negScale true");

		# $gettransu = lxq("tool.attr center.auto cenU ?");
		# $gettransv = lxq("tool.attr center.auto cenV ?");

		# lx("tool.attr xfrm.transform SX -1.0");
		# lx("tool.doApply");
		# $gettransu = lxq("tool.attr center.auto cenU ?")if($mirDir eq "u");
		# $gettransv = lxq("tool.attr center.auto cenV ?")if($mirDir eq "v");

		# lx("tool.doApply");

		# lx("tool.attr xfrm.transform negScale false")if($negcheck eq "false");

		# lx("tool.drop");

		lx("uv.mirror u {@vtest[0]}")if($mirDir eq "u");
		lx("uv.mirror v {@vtest[1]}")if($mirDir eq "v");

		lx("select.drop polygon");


	}
		# lx("tool.set center.auto off");

	lx("!!select.lazyState $lazycheck");

	lx("select.symmetryState {$symstate}");
	lx("select.symmetryUVState {$uvsymstate}");
	
}


