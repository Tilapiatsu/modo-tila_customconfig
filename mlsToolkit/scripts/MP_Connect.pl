# perl


$viewcheck = lxq("query view3dservice view.type ? selected");

lx("!!select.Connect m3d")if ($viewcheck ne "UV2D");
lx("!!select.Connect uv")if ($viewcheck eq "UV2D");