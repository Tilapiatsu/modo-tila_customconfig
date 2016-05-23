#perl
=comm
| -----------------------------------------------------------------------
| Script: FixUVisland.pl
| Author: Dmitry Bersenev aka Mynglam
| Version 1.0 (10 march 2012)
| -----------------------------------------------------------------------
| Align UV vertices, based on close UV unselected geometry.
| -----------------------------------------------------------------------
| Выравнивает UV выделенных поликов по ближайшим UV невыделенной геометрии.
| -----------------------------------------------------------------------
=cut

if (!lxq("select.typeFrom typelist:{polygon;vertex;edge;item} ?") )
{	die("Worked only in polygon mode.");	}

my @vmaps = lxq("query layerservice vmaps ? selected");
our $vmap = -1;
# смотрим выбрана ли UV карта
foreach $map (@vmaps)
{
	my $map_type = lxq("query layerservice vmap.type ? $map");
	if ($map_type eq "texture")
	{
		$vmap = $map;		
		last;
	}
}
if($vmap == -1) { die("No selected UV Map."); }
my $map_name = lxq("query layerservice vmap.name ? $vmap");
lxout("UV Map ($map_name)");

PreserveToolsAttr();

# пробегаемся по всем невыделенным поликам и запоминаем их UV
lx("select.invert");

my @layers = lxq("query layerservice layers ? fg");

our @uvlock;
foreach $layer (@layers)
{
	lxq("query layerservice layer.index ? $layer");
	my @polys = lxq("query layerservice polys ? selected");
	foreach $poly (@polys)
	{
		lxq("query layerservice vmap.index ? $vmap");
		my @mapvrt = lxq("query layerservice poly.vertList ? $poly");
		my @uv = lxq("query layerservice poly.vmapValue ? $poly");
		for($i=0; $i <= $#mapvrt; $i++)
		{
			if(!FindMatch($uv[$i*2], $uv[$i*2+1], @uvlock)) {
				push @uvlock, $uv[$i*2], $uv[$i*2+1];
			}			
		}
	}
}
my $lockedverts = ($#uvlock+1)/2;
lxout("Locked verts = $lockedverts");

# возвращаемся к выделенным полигонам
lx("select.invert");

# запоминаем их для каждого слоя
our %userpolys;
our $globalpolys = 0;
foreach $layer (@layers)
{
	lxq("query layerservice layer.index ? $layer");
	my $allpolys = lxq("query layerservice poly.N ? all");
	my @polys = lxq("query layerservice polys ? selected");
	if($allpolys == $#polys+1) { next; }
	push @{$userpolys{$layer}}, @polys;
	$globalpolys += $#polys+1;
}

lxmonInit($globalpolys);

# поочередно проходим полики и смещаем UV вертексов к ближайшим из невыделенных
foreach $layer (keys %userpolys)
{
	lxout("Layer($layer): @{$userpolys{$layer}}");
	lxq("query layerservice layer.index ? $layer");
	lxq("query layerservice vmap.index ? $vmap");
	my @polys = @{$userpolys{$layer}};
	foreach $p (@polys)
	{
		my @sv = lxq("query layerservice poly.vertList ? $p");
		my @tv = lxq("query layerservice poly.vmapValue ? $p");
		lx("select.typeFrom vertex");
		for($v = 0; $v <= $#sv; $v++)
		{
			#lxout("Vertex $sv[$v] ($tv[$v*2], $tv[$v*2+1])");
			my @shft = FindCloseShift($tv[$v*2], $tv[$v*2+1]);
			lx("select.element $layer vertex set $sv[$v] 0 $p");
			lx("tool.viewType UV");
			lx("tool.set xfrm.move on");
			lx("tool.reset");
			lx("tool.setAttr xfrm.move U {$shft[0]}");
			lx("tool.setAttr xfrm.move V {$shft[1]}");
			lx("tool.doApply");
			lx("tool.set xfrm.move off");
		}
		if(!lxmonStep()) {
			die("User Abort");
		}
	}
}

RestoreToolsAttr();
lx("select.typeFrom polygon");


sub FindMatch #($uv[$i], $uv[$i+1], @uvlock)
{
	my $u = shift;
	my $v = shift;
	
	for($j = 0; $j <= $#_; $j+=2)
	{
		if($u == $_[$j] && $v == $_[$j+1])
		{
			return 1;
		}
	}
	return 0;
}

sub FindCloseShift
{
	my $res_u, $res_v;
	my $len = 1000;
	my $key;
	
	for($i = 0; $i <= $#uvlock; $i+=2)
	{
		my $ln = Length($_[0], $_[1], $uvlock[$i], $uvlock[$i+1]);
		if($ln < $len)
		{
			$len = $ln;
			$res_u = $uvlock[$i] - $_[0];
			$res_v = $uvlock[$i+1] - $_[1];
			$key = $i;
		}
	}
	#lxout("Minimal length $len");
	#lxout("Closed $uvlock[$key], $uvlock[$key+1]");
	return $res_u, $res_v;
}

sub Length # 0, 1 | 2,3
{
	my @vec = ($_[2]-$_[0], $_[3]-$_[1]);
	return sqrt($vec[0]*$vec[0]+$vec[1]*$vec[1]);
}


sub PreserveToolsAttr
{
	lx("tool.set xfrm.move on");
	lx("tool.makePreset llama_tmp");
	lx("tool.set xfrm.move off");
}

sub RestoreToolsAttr
{
	lx("tool.set xfrm.move on");
	lx("tool.restorePreset llama_tmp");
	#lx("tool.presetKill llama_tmp");
	lx("tool.set xfrm.move off");
}
