#perl

my $symdir = $ARGV[0];

$curstate = lxq("select.symmetryUVState ?");


if($symdir eq "u"){
	lx("select.symmetryUVState none")if($curstate eq "u");
	lx("select.symmetryUVState u")if($curstate ne "u");
}


elsif($symdir eq "v"){
	lx("select.symmetryUVState none")if($curstate eq "v");
	lx("select.symmetryUVState v")if($curstate ne "v");
}