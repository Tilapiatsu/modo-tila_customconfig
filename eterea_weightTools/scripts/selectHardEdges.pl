#perl
#AUTHOR: Seneca Menard
#version 2.0

#This script is to select or deselect subd weighted edges.  Also, you can have it only select edges that are touching your currently selected edges.
#The script comes with a form called "sen_selectHardEdges" and you should use that to run the script.

userValueTools(sen_selectHardEdgeCutoff,float,config,"Weight Cutoff:","","","",-1,1,"",0.9);
my $mainlayer = lxq("query layerservice layers ? main");
my $hardnessCutoff = 0.9;

#===============================
#script arguments
#===============================
foreach my $arg (@ARGV){
	if		($arg =~ /touchingOnly/i)	{	our $touchingOnly = 1;		}
	elsif	($arg =~ /deselect/i)		{	our $deselect = 1;			}
	if		($arg =~ /[0-9]/)			{	$hardnessCutoff = $arg;		}
}

#===============================
#determine which sub to run
#===============================
if ($touchingOnly == 1)					{	&selectTouching;			}
else									{	&selectAll;					}




#===============================
#select all sub
#===============================
sub selectAll{
	my @edges = lxq("query layerservice edges ? visible");
	my @edgesToSelect;
	my $selectMode = "add";
	if ($deselect == 1){$selectMode = "remove";}

	foreach my $edge (@edges){
		my $weight = lxq("query layerservice edge.creaseWeight ? $edge");
		if ($weight > $hardnessCutoff){
			push(@edgesToSelect, "$edge");
		}
	}

	foreach my $edge (@edgesToSelect){
		$edge =~ s/\(//;
		$edge =~ s/\)//;
		my @verts = split(/,/, $edge);
		lx("select.element $mainlayer edge {$selectMode} $verts[0] $verts[1] ");
	}
}

#===============================
#select touching sub
#===============================
sub selectTouching{
	my @edgesToSelect;
	my @todoVerts;
	my %checkedVerts;
	my @edges = lxq("query layerservice edges ? selected");
	if (@edges == 0){die("\\\\n.\\\\n[---------------------------------------------You don't have any edges selected.--------------------------------------------]\\\\n[--PLEASE TURN OFF THIS WARNING WINDOW by clicking on the (In the future) button and choose (Hide Message)--] \\\\n[-----------------------------------This window is not supposed to come up, but I can't control that.---------------------------]\\\\n.\\\\n");}

	foreach my $edge (@edges){
		my @verts = split (/[^0-9]/, $edge);
		push(@todoVerts,$verts[1]);
		push(@todoVerts,$verts[2]);
	}

	for (my $i=0; $i<@todoVerts; $i++){
		if ($checkedVerts{$todoVerts[$i]} != 1){
			my @vertList = lxq("query layerservice vert.vertList ? $todoVerts[$i]");
			foreach my $connectedVert (@vertList){
				my $edge;
				if ($todoVerts[$i] < $connectedVert)	{	$edge = "(" . $todoVerts[$i] . "," . $connectedVert . ")";	}
				else									{	$edge = "(" . $connectedVert . "," . $todoVerts[$i] . ")";	}

				my $weight = lxq("query layerservice edge.creaseWeight ? $edge");
				if ($weight > $hardnessCutoff){
					push(@edgesToSelect, "$edge");
					push(@todoVerts, $connectedVert);
				}
			}
		}
		$checkedVerts{$todoVerts[$i]} = 1;
	}

	foreach my $edge (@edgesToSelect){
		my @verts = split (/[^0-9]/, $edge);
		lx("select.element $mainlayer edge add $verts[1] $verts[2]");
	}
}

















#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#EXTRA SUBROUTINES
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#SET UP THE USER VALUE OR VALIDATE IT   (no popups)
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#userValueTools(name,type,life,username,list,listnames,argtype,min,max,action,value);
sub userValueTools{
	if (lxq("query scriptsysservice userValue.isdefined ? @_[0]") == 0){
		lxout("Setting up @_[0]--------------------------");
		lxout("Setting up @_[0]--------------------------");
		lxout("0=@_[0],1=@_[1],2=@_[2],3=@_[3],4=@_[4],5=@_[6],6=@_[6],7=@_[7],8=@_[8],9=@_[9],10=@_[10]");
		lxout("@_[0] didn't exist yet so I'm creating it.");
		lx( "user.defNew name:[@_[0]] type:[@_[1]] life:[@_[2]]");
		if (@_[3] ne "")	{	lxout("running user value setup 3");	lx("user.def [@_[0]] username [@_[3]]");	}
		if (@_[4] ne "")	{	lxout("running user value setup 4");	lx("user.def [@_[0]] list [@_[4]]");		}
		if (@_[5] ne "")	{	lxout("running user value setup 5");	lx("user.def [@_[0]] listnames [@_[5]]");	}
		if (@_[6] ne "")	{	lxout("running user value setup 6");	lx("user.def [@_[0]] argtype [@_[6]]");		}
		if (@_[7] ne "xxx")	{	lxout("running user value setup 7");	lx("user.def [@_[0]] min @_[7]");			}
		if (@_[8] ne "xxx")	{	lxout("running user value setup 8");	lx("user.def [@_[0]] max @_[8]");			}
		if (@_[9] ne "")	{	lxout("running user value setup 9");	lx("user.def [@_[0]] action [@_[9]]");		}
		if (@_[1] eq "string"){
			if (@_[10] eq ""){lxout("woah.  there's no value in the userVal sub!");							}		}
		elsif (@_[10] == ""){lxout("woah.  there's no value in the userVal sub!");									}
								lx("user.value [@_[0]] [@_[10]]");		lxout("running user value setup 10");
	}else{
		#STRING-------------
		if (@_[1] eq "string"){
			if (lxq("user.value @_[0] ?") eq ""){
				lxout("user value @_[0] was a blank string");
				lx("user.value [@_[0]] [@_[10]]");
			}
		}
		#BOOLEAN------------
		elsif (@_[1] eq "boolean"){

		}
		#LIST---------------
		elsif (@_[4] ne ""){
			if (lxq("user.value @_[0] ?") == -1){
				lxout("user value @_[0] was a blank list");
				lx("user.value [@_[0]] [@_[10]]");
			}
		}
		#ALL OTHER TYPES----
		elsif (lxq("user.value @_[0] ?") == ""){
			lxout("user value @_[0] was a blank number");
			lx("user.value [@_[0]] [@_[10]]");
		}
	}
}