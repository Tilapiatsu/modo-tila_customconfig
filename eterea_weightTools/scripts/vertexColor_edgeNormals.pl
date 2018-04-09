#perl
#ver. 1.2
#author : Seneca Menard
#This script will apply weight mapping or vertex coloring to all the concave and convex edges visible.

#script arguments : colorMap : that's if you wish to write the edges' color map instead of the weight map.

if (@ARGV[0] eq "colorMap")		{	our $tool = "vertMap.setColor";		selectVmapOfCertainType("rgb");		}
else							{	our $tool = "vertMap.setWeight";	selectVmapOfCertainType("weight");	}

my %concaveAngleList;
my %convexAngleList;
my $mainlayer = lxq("query layerservice layers ? main");
my @edges = lxq("query layerservice edges ? visible");
#lxout("edgeCount = $#edges+1");
foreach my $edge (@edges){
	my $dp;
	my @polyList = lxq("query layerservice edge.polyList ? $edge");

	if (@polyList > 1){
		my @pNormal1 = lxq("query layerservice poly.normal ? @polyList[0]");
		my @pNormal2 = lxq("query layerservice poly.normal ? @polyList[1]");
		my @edgeVector = unitVector(lxq("query layerservice edge.vector ? $edge"));
		my @edgePos = lxq("query layerservice edge.pos ? $edge");

		#maintain cp's going in right dir.
		my @cp1 = crossProduct(\@pNormal1,\@edgeVector);
		my @polyPos = lxq("query layerservice poly.pos ? @polyList[0]");
		my @dirVector1 = unitVector(arrMath(@polyPos,@edgePos,subt));
		if (dotProduct(\@dirVector1,\@cp1) > 0){@cp1 = arrMath(@cp1,-1,-1,-1,mult);}

		my $facingTowards = dotProduct(\@cp1,\@pNormal2);
		my $dp = dotProduct(\@pNormal1,\@pNormal2);

		if ($facingTowards < 0){
			push(@{$concaveAngleList{$dp}},$edge);
		}else{
			push(@{$convexAngleList{$dp}},$edge);
		}
	}
}

lx("select.type edge");
lx("tool.set {$tool} on");
lx("tool.reset");
my $convexCount=0; my $concaveCount=0;
foreach my $key (reverse sort keys %convexAngleList){
	my $dp = $key;
	if($dp < 0){$dp = 0;}
	foreach my $edge (@{$convexAngleList{$key}}){
		$convexCount++;
		if ($dp < 0.97){
			$edge =~ tr/()//d;
			my @verts = split(/,/,$edge);
			lx("select.element $mainlayer edge set @verts[0] @verts[1]");
			if ($tool eq "vertMap.setColor"){
				my $color = 1 - (.5 * $dp);
				lx("tool.setAttr vertMap.setColor Color {$color $color $color}");
			}else{
				my $color = 1 - $dp;
				lx("tool.attr vertMap.setWeight weight {$color}");
			}

			lx("tool.doApply");
			#popup("convex : $color : pause");
		}
	}
}

foreach my $key (reverse sort keys %concaveAngleList){
	my $dp = $key;
	if($dp < 0){$dp = 0;}
	foreach my $edge (@{$concaveAngleList{$key}}){
		$concaveCount++;
		if ($dp < 0.97){
			$edge =~ tr/()//d;
			my @verts = split(/,/,$edge);
			lx("select.element $mainlayer edge set @verts[0] @verts[1]");

			if ($tool eq "vertMap.setColor"){
				my $color = .5 * $dp;
				lx("tool.setAttr vertMap.setColor Color {$color $color $color}");
			}else{
				my $color = -1 + $dp;
				lx("tool.attr vertMap.setWeight weight {$color}");
			}

			lx("tool.doApply");
			#popup("concave : $color : pause");
		}
	}
}
lx("tool.set {$tool} off");
lx("select.drop edge");

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#SELECT THE PROPER VMAP OF A SPECIFIC TYPE SUB (creates if doesn't exist) v2.1
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#usage : selectVmapOfCertainType("rgb");
#note : 
#requires popupMultChoice sub
sub selectVmapOfCertainType{
	my @foundVmaps;
	my $vmapCount = lxq("query layerservice vmap.n ? all");
	my $chosenVmapName = "";
	
	#translate types to names that modo reads
	my %translateTable;
		$translateTable{"weight"}		= "wght";
		$translateTable{"subvweight"}	= "subd";
		$translateTable{"texture"}		= "txuv";
		$translateTable{"morph"}		= "morf";
		$translateTable{"spot"}			= "spot";
		$translateTable{"rgb"}			= "rgb";
		$translateTable{"rgba"}			= "rgba";
		$translateTable{"pick"}			= "pick";
		$translateTable{"normal"}		= "norm";
		$translateTable{"edgepick"}		= "epck";
		#particlesize, particledissolve, transform, vector, tangentbasis are not showing up in queried vmaps so i'm temporarily giving them the internal names
		$translateTable{"psiz"}			= "psiz";
		$translateTable{"pdis"}			= "pdis";
		$translateTable{"xfrm"}			= "xfrm";
		$translateTable{"vect"}			= "vect";
		$translateTable{"tbas"}			= "tbas";
		
	#look for vmaps of said type
	for (my $i=0; $i<$vmapCount; $i++){
		if (lxq("query layerservice vmap.type ? $i") eq $_[0]){
			if (lxq("query layerservice vmap.selected ? $i") == 1){
				my $name = lxq("query layerservice vmap.name ? $i");
				lxout("[->] SELECTVMAPOFCERTAINTYPE : '$name' was of the type we're looking for and is already selected so i don't need to do anything");
				return;
			}else{
				push(@foundVmaps,lxq("query layerservice vmap.name ? $i"));
			}
		}
	}

	#if only one found, use it.
	if (@foundVmaps == 1){
		lxout("[->] : Only one $_[0] vmap exists, so I'm selecting it : $foundVmaps[0]");
		$chosenVmapName = $foundVmaps[0];
		lx("select.vertexMap name:{$chosenVmapName} type:{$translateTable{$_[0]}} mode:{replace}");
	}
	
	#if >1 found, use popup window to pick which one
	elsif (@foundVmaps > 1){
		my $options = "";
		for (my $i=0; $i<@foundVmaps; $i++){	$options .= $foundVmaps[$i] . ";";	}
		$chosenVmapName = popupMultChoice("Which vmap to select? :",$options,0);
		lx("select.vertexMap name:{$chosenVmapName} type:{$translateTable{$_[0]}} mode:{replace}");
	}
	
	#no vmaps existed so i'm creating one.
	else{
		lxout("[->] : No $type vmaps existed, so I had to create one");											
		if 		($translateTable{$_[0]} eq "rgb")	{	lx("vertMap.new Color rgb false {0.78 0.78 0.78}");												}
		elsif	($translateTable{$_[0]} eq "rgba")	{	lx("vertMap.new Color rgba false {0.78 0.78 0.78} 1.0");										}
		elsif	($translateTable{$_[0]} eq "wght")	{	lx("vertMap.new Weight wght false {0.78 0.78 0.78}");											}
		elsif	($translateTable{$_[0]} eq "txuv")	{	lx("vertMap.new UVChannel_1 txuv false {0.78 0.78 0.78} 1.0");									}
		elsif	($translateTable{$_[0]} eq "norm")	{	lx("vertMap.new {Vertex Normal} norm false {0.78 0.78 0.78} 1.0");								}
		elsif	($translateTable{$_[0]} eq "morf")	{	lx("vertMap.new Morph morf false {0.78 0.78 0.78} 1.0");										}
		elsif	($translateTable{$_[0]} eq "spot")	{	lx("vertMap.new AMorph spot false {0.78 0.78 0.78} 1.0");										}
		elsif	($translateTable{$_[0]} eq "pick")	{	lx("vertMap.new Pick pick false {0.78 0.78 0.78} 1.0");											}
		elsif	($translateTable{$_[0]} eq "epck")	{	lx("vertMap.new {Edge Pick} epck false {0.78 0.78 0.78} 1.0");									}
		elsif	($translateTable{$_[0]} eq "psiz")	{	lx("vertMap.new {Particle Size} psiz color:{0.78 0.78 0.78}");									}
		elsif	($translateTable{$_[0]} eq "pdis")	{	lx("vertMap.new {Particle Dissolve} pdis true {0.78 0.78 0.78} 1.0");							}
		elsif	($translateTable{$_[0]} eq "xfrm")	{	lx("vertMap.new {Transform} type:xfrm init:true color:{0.78 0.78 0.78} value:1.0");				}
		elsif	($translateTable{$_[0]} eq "vect")	{	lx("vertMap.new name:vect type:xfrm init:true color:{0.78 0.78 0.78} value:1.0");				}
		elsif	($translateTable{$_[0]} eq "tbas")	{	lx("vertMap.new name:{Tangent Basis} type:tbas init:true color:{0.78 0.78 0.78} value:1.0");	}
		
		$vmapCount++;
		for (my $i=0; $i<$vmapCount; $i++){
			if ((lxq("query sceneservice vmap.type ? $i") eq "$_[0]") && (lxq("query layerservice vmap.selected ? $i") == 1)){
				$chosenVmapName = lxq("query layerservice vmap.name ? $i");
				last;
			}
		}
	}
	
	#find indice of chosen vmap name and then ask it's name so the future modo queries will now work.
	my $foundIndice = 0;
	for (my $i=0; $i<$vmapCount; $i++){
		my $name = lxq("query layerservice vmap.name ? $i");
		if ($name eq $chosenVmapName){
			$foundIndice = 1;
			last;
		}
	}
	if ($foundIndice == 0){lxout("Hmm.  Couldn't query the name of teh selected vmap so something went wrong");}
}


#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#QUICK DIALOG SUB v2.1
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#USAGE : quickDialog(username,float,initialValue,min,max);
sub quickDialog{
	if (@_[1] eq "yesNo"){
		lx("dialog.setup yesNo");
		lx("dialog.msg {$_[0]}");
		lx("dialog.open");
		if (lxres != 0){	die("The user hit the cancel button");	}
		return (lxq("dialog.result ?"));
	}else{
		if (lxq("query scriptsysservice userValue.isdefined ? seneTempDialog") == 1){
			lx("user.defDelete seneTempDialog");
		}
		lx("user.defNew name:[seneTempDialog] type:{$_[1]} life:[momentary]");		
		lx("user.def seneTempDialog username [$_[0]]");
		if (($_[3] != "") && ($_[4] != "")){
			lx("user.def seneTempDialog min [$_[3]]");
			lx("user.def seneTempDialog max [$_[4]]");
		}
		lx("user.value seneTempDialog [$_[2]]");
		lx("user.value seneTempDialog ?");
		if (lxres != 0){	die("The user hit the cancel button");	}
		return(lxq("user.value seneTempDialog ?"));
	}
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#UNIT VECTOR SUBROUTINE
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#USAGE : my @unitVector = unitVector(@vector);
sub unitVector{
	my $dist1 = sqrt((@_[0]*@_[0])+(@_[1]*@_[1])+(@_[2]*@_[2]));
	@_ = ((@_[0]/$dist1),(@_[1]/$dist1),(@_[2]/$dist1));
	return @_;
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#CROSSPRODUCT SUBROUTINE (ver 1.1)
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#USAGE : my @crossProduct = crossProduct(\@vector1,\@vector2);
sub crossProduct{
	return ( (${$_[0]}[1]*${$_[1]}[2])-(${$_[1]}[1]*${$_[0]}[2]) , (${$_[0]}[2]*${$_[1]}[0])-(${$_[1]}[2]*${$_[0]}[0]) , (${$_[0]}[0]*${$_[1]}[1])-(${$_[1]}[0]*${$_[0]}[1]) );
}


#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#DOT PRODUCT subroutine (ver 1.1)
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#USAGE : my $dp = dotProduct(\@vector1,\@vector2);
sub dotProduct{
	return (	(${$_[0]}[0]*${$_[1]}[0])+(${$_[0]}[1]*${$_[1]}[1])+(${$_[0]}[2]*${$_[1]}[2])	);
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#PERFORM MATH FROM ONE ARRAY TO ANOTHER subroutine
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#USAGE : my @disp = arrMath(@pos2,@pos1,subt);
sub arrMath{
	my @array1 = (@_[0],@_[1],@_[2]);
	my @array2 = (@_[3],@_[4],@_[5]);
	my $math = @_[6];

	my @newArray;
	if		($math eq "add")	{	@newArray = (@array1[0]+@array2[0],@array1[1]+@array2[1],@array1[2]+@array2[2]);	}
	elsif	($math eq "subt")	{	@newArray = (@array1[0]-@array2[0],@array1[1]-@array2[1],@array1[2]-@array2[2]);	}
	elsif	($math eq "mult")	{	@newArray = (@array1[0]*@array2[0],@array1[1]*@array2[1],@array1[2]*@array2[2]);	}
	elsif	($math eq "div")	{	@newArray = (@array1[0]/@array2[0],@array1[1]/@array2[1],@array1[2]/@array2[2]);	}
	return @newArray;
}

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

