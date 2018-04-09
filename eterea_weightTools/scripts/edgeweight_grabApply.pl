#perl
#AUTHOR: Seneca Menard
#version 1.0
#This script applies the last selected element's edgeweighting value to all the other selected elements  (it only works with verts and edges btw)

my $mainlayer = lxq("query layerservice layers ? main");
my @weightMaps = lxq("query layerservice vmaps ? weight");
my $weightMapSelected = 0;

foreach my $weightMap (@weightMaps){
	if (lxq("query layerservice vmap.selected ? $weightMap") == 1){
		lxout("-There was a weightmap already selected, so I'm keeping it selected");
		$weightMapSelected = 1;
	}
}

#only select "subdivision" if no vmaps are selected.
if ($weightMapSelected == 0){	lx("select.vertexMap Subdivision subd replace");	}

#query the last selected's vmap value.
my $vmapValue;
if		(lxq( "select.typeFrom {vertex;polygon;item;edge} ?" )){
	my @verts = lxq("query layerservice verts ? selected");
	$vmapValue = lxq("query layerservice vert.vmapValue ? $verts[-1]");
}elsif	(lxq( "select.typeFrom {edge;vertex;polygon;item} ?" )){
	my @edges = lxq("query layerservice selection ? edge");
	$edges[-1] =~ s/\([0-9]+,/(/;
	$vmapValue = lxq("query layerservice edge.creaseWeight ? {$edges[-1]}");
}else{
	lxout("This script only works with verts or edges and you weren't in either of those two selection modes so the script is being canceled.");
}

#apply the weightmap tool
lx("tool.set vertMap.setWeight on");
lx("tool.setAttr vertMap.setWeight weight {$vmapValue}");
lx("tool.doApply");
lx("tool.set vertMap.setWeight off");

lxout("Applied this weighting amount : $vmapValue");