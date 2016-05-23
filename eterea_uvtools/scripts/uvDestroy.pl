#perl
#AUTHOR: Seneca Menard
#version 1.3
#This script is to go and delete ALL of the UVs in the current model.  MODO seems to keep
#creating new uv sets all the time, so i created this script to get rid of 'em all with one click.
#(1-11-07 feature) : The script now has an argument to have it only delete the uvs in the current layers you're in.  To do that, append "not_all_layers" to the script.  ie : "@uvDestroy.pl not_all_layers"
#(9-7-07 bugfix) : fixed for M3.

my @fgLayers = lxq("query layerservice layers ? fg");
my @bgLayers = lxq("query layerservice layers ? bg");
my @vmapList = lxq("query layerservice vmaps ?");
my $vmapType;
my $vMap;
my $vmapName;
my @correctVmaps;


#------------------------------------------------------------------------------------------------
#Find all the uv maps
#------------------------------------------------------------------------------------------------
foreach my $vMap (@vmapList)
{
	$vmapType = lxq("query layerservice vmap.type ? $vMap");
	if ($vmapType eq "texture"){
		$vmapName = lxq("query layerservice vmap.name ? $vMap");
		push(@correctVmaps,$vmapName);
	}
}


#------------------------------------------------------------------------------------------------
#Go through all layers and delete all the UV maps.
#------------------------------------------------------------------------------------------------
if (@ARGV[0] eq "not_all_layers")	{	our @layers = lxq("query layerservice layers ? main");	}
else								{	our @layers = lxq("query layerservice layers ? all");	}

foreach my $layer (@layers){
	lx("select.layer number:[$layer] mode:[set] bg:[0] children:[0]");

	foreach my $correct(@correctVmaps){
		lx("!!select.vertexMap [$correct] [txuv] [replace]");
		lx("!!vertMap.delete type:txuv");
	}
}


#------------------------------------------------------------------------------------------------
#Restore the original layer visibilities
#------------------------------------------------------------------------------------------------
#FG LAYERS-------
for (my $i=0; $i<@fgLayers; $i++){
	if ($i == 0){	lx("select.layer number:[@fgLayers[$i]] mode:[set] bg:[0] children:[0]");	}
	else		{	lx("select.layer number:[@fgLayers[$i]] mode:[add] bg:[0] children:[0]");	}
}
#don't need to do bgLayers because they're still visible.



#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#POPUP SUB
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#USAGE : popup("What I wanna print");

sub popup #(MODO2 FIX)
{
	lx("dialog.setup yesNo");
	lx("dialog.msg {@_}");
	lx("dialog.open");
	my $confirm = lxq("dialog.result ?");
	if($confirm eq "no"){die;}
}