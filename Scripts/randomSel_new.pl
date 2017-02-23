#perl
#AUTHOR: Seneca Menard
#version 1.1 (M3 temp)
#This script is to randomly select or deselect VERT, EDGES, or POLYS using the percentage you enter.
#-it selects by default.
#-if you want to deselect, append "deselect" to the script.  ie, bind a hotkey to this : "@randomSelNew.pl deselect"

my $mainlayer = lxq("query layerservice layers ? main");
srand;

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SCRIPT ARGUMENTS
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
foreach my $arg (@ARGV){
	if		($arg =~ /deselect/i)	{our $deselect = 1;		}
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#USER VALUES
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#create the sene_randomSel variable if it didn't already exist.
if (lxq("query scriptsysservice userValue.isdefined ? sene_randomSel") == 0)
{
	lxout("-The sene_randomSel cvar didn't exist so I just created one");
	lx( "user.defNew sene_randomSel type:[float] life:[temporary]");
	lx("user.def sene_randomSel username [% of elems to select?]");
	lx("user.value sene_randomSel [50]");
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#MAIN ROUTINE
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
lx("user.value sene_randomSel ?");
my $random = lxq("user.value sene_randomSel ?")/100;

if( lxq( "select.typeFrom {vertex;edge;polygon;item} ?" ) ) {
	our $elem = "verts";
	our $elemName = "vertex";
}
elsif( lxq( "select.typeFrom {edge;polygon;item;vertex} ?" ) ) {
	our $elem = "edges";
	our $elemName = "edge";
}
elsif( lxq( "select.typeFrom {polygon;item;vertex;edge} ?" ) ) {
	our $elem = "polys";
	our $elemName = "polygon";
}
else{
	die("You must be in VERT, EDGE, or POLY MODE");
}

if ($deselect == 1)		{	our $selMode = "remove";	}
else					{	our $selMode = "add";		}

my @elems = lxq("query layerservice $elem ? visible");
my $count = 0;
foreach my $elem (@elems){
	my $chance = rand;
	if ($chance < $random){
		if ($elemName eq "edge"){
			my @verts = split (/[^0-9]/, $elem);
			lx("select.element $mainlayer $elemName $selMode index:[@verts[1]] index2:[@verts[2]]");
			#lx("select.element $mainlayer $elemName $selMode index:[@verts[2]] index2:[@verts[1]]");  #might need this because of the edgesel fail, but let's keep it out for now.
		}else{
			lx("select.element $mainlayer $elemName $selMode $elem");
		}
	}
}


