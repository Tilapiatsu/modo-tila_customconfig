#!perl

# AUTHOR : Ariel Chai (www.arielchai.com)
# VERSION : 2.2 for modo 2.01-5.01 (22.2.2011)
# DESCRIPTION : 	AlignPoints aligns points, polys, edges to the last selected element along x y z axes accroding to what was provided as argument. 
#                   Works accross layers, and supports symmetry
#                   
#
# USAGE : Use axis as arguement, e.g. @alignPoints.pl X
#         * Choosing all axis as argument (XYZ) on symmetry mode for verts, can be a primitive symmetry fixer tool.
#

my $modoVersion = lxq("query platformservice appversion ?");
$edgemode=lxq("select.typeFrom typelist:{edge;polygon;vertex;item} ? ");
$vertmode=lxq("select.typeFrom typelist:{vertex;edge;polygon;item} ? ");
$polymode=lxq("select.typeFrom typelist:{polygon;vertex;edge;item} ? ");
my $symmAxis = lxq("select.symmetryState ?");
my @layers = lxq("query layerservice layer.id ? all");
my @pos;
my $attrType;

&getPos;
&alignVerts;

sub getPos {
	if( $vertmode ) { 
		$attrType = vert;
	} elsif( $edgemode) {
		$attrType = edge;
	} elsif( $polymode ) {
		$attrType = poly;
	} else {
	  die("Vert/Edge/Poly modes only")
	}
	
#${attrType}s
	@elems=lxq("query layerservice selection ? $attrType");
	if(!@elems){die("no elements selected")}
	@buf=split(/,/, $elems[-1]);
	$buf[0]=~s/\(//i;
	$buf[$#buf]=~s/\)//i;
	$layer=$buf[0];
	$layer -= 1;
	&queryLayer ($layer);
	
	if($edgemode) { @pos=lxq("query layerservice edge.pos ? {($buf[1],$buf[2])}");
	} else { @pos = lxq("query layerservice ${attrType}.pos ? $buf[1]"); }

	#lxout("layer : $layer");
	#lxout("pos : @pos");

}

sub queryLayer {
	my $meshID = lxq("query sceneservice mesh.id ? @_");
	my $layerN = lxq("query layerservice layer.N ?");
	for ($i = 1; $i < ($layerN + 1) ; $i++)
	{
		$layerID = lxq("query layerservice layer.id ? $i");
		if ($layerID eq $meshID) {
  		last;
  	}
	}
}

sub alignVerts {
	my $args = "";
	if ($modoVersion >= 500) { $args = "false false"; }

	if($ARGV[0] =~ /x/i) {
		if (($symmAxis eq "x") && ($pos[0] < 0)) { $pos[0] *= -1; }
		lx("vert.set X $pos[0] $args");
	}
	if($ARGV[0] =~ /y/i) {
		if (($symmAxis eq "y") && ($pos[1] < 0)) { $pos[1] *= -1; }
		lx("vert.set Y $pos[1] $args");
	}
	if($ARGV[0] =~ /z/i) {
		if (($symmAxis eq "z") && ($pos[2] < 0)) { $pos[2] *= -1; }
		lx("vert.set Z $pos[2] $args");
	}

}
