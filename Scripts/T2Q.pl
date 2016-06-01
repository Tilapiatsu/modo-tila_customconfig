#perl
# http://www.modomode.jp
# http://vimeo.com/takumi

# User Setting ################################################################
my $DEFAULT_ANGLE = 40;
###############################################################################

if (lxq("query platformservice appversion ?") < 401) {
  lx("dialog.setup warning");
  lx("dialog.title {Warning}");
  lx("dialog.msg {This script must be run on modo 401.\nwww.modomode.jp}");
  lx("dialog.open");
  return;
}

my $appbuild = lxq("query platformservice appbuild ?");
my $selarg = "psubdiv";
if ($appbuild < 41321) {$selarg = "curve"}

my $angle;
my @polylist;
my @expolys;
my @exedges;
my @remedges;
my $end = 0;
my $layer = lxq("query layerservice layer.index ? main");
my @edges = lxq("query layerservice edges ? selected");

if (@edges > 0) {
  my @angles;
  foreach my $edge (@edges) {
    my @polys = lxq("query layerservice edge.polylist ? $edge");
    if (@polys == 2) {
      my $inan = _getangle($polys[0], $polys[1]);
      push(@angles, $inan);
    }
  }
  if (@angles > 0) {
    @angles = sort {$a <=> $b} @angles;
    $angle = $angles[0] - 0.00000009;
  }
}
else {
  if ($ARGV[0] eq 'dialog') {
    lx("user.defNew T2Q.angle angle momentary");
    lx("user.def T2Q.angle min 0.5");
    lx("user.def T2Q.angle username {Minimum Angle}");
    lx("user.def T2Q.angle dialogname {Keep Edges}");
    lx("user.value T2Q.angle $DEFAULT_ANGLE");

    if (lx("user.value T2Q.angle")) {$angle = lxq("user.value  T2Q.angle ?")}
    else {return}
  }
  else {$angle = $ARGV[0] || $DEFAULT_ANGLE}

  $angle = ($angle - 0.0009) * (atan2(1, 1) * 4) / 180;
}

lx("select.drop edge");
lx("select.drop vertex");
lx("!vert.merge auto");
lx("select.drop polygon");
lx("!poly.unify true");
lx("select.drop polygon");

while ($end == 0) {
  if (_fnc() == 0) {last}
}

lx("select.polygon add vertex " . $selarg . " 3");

sub _fnc {
  lx("select.polygon add vertex " . $selarg . " 3");
  my @polys = lxq("query layerservice polys ? selected");
  lx("select.drop polygon");
  my $pcount = @polys;
  lxmonInit($pcount);

  my $polydataA = '';
  my $polydataB = '';
  my $lsideA = '';
  my $lsideB = '';

  foreach my $poly (@polys) {
    if(!lxmonStep) {return 0}

    if (_chklist($poly) == 0) {
      $polydataA = _registpoly($poly);
      $lsideA = $polydataA->{'lside'};
      if (_chklist($lsideA, 'e') == 0) {
        if (_chklist($polydataA->{'otherid'}) == 0) {
          if ($polydataA->{'otherverts'} == 3 and $polydataA->{'samematerial'} == 1) {
            $polydataB = _registpoly($polydataA->{'otherid'});
            $lsideB = $polydataB->{'lside'};
          }

          if ($lsideB ne '') {
            if ($lsideB ne $lsideA) {
              if ($polydataB->{'otherverts'} != 3 or $polydataB->{'samematerial'} == 0 or
                _chklist($lsideB, 'e') == 1) {
                _appendedge($lsideA);
              }
            }
            else {_appendedge($lsideA)}
          }
        }
      }
    }
    $polydataA = '';
    $polydataB = '';
    $lsideA = '';
    $lsideB = '';
  }

  if (@remedges == 0) {
    $end = 1;
  }
  else {
    my @ix;
    lx("select.drop edge");
    foreach my $edge (@remedges) {
      @ix = split(/[^0-9]/, $edge);
      lx("select.element $layer edge add $ix[1] $ix[2]");
    }
    lx("edge.remove false");
    undef @expolys;
    undef @remedges;
    undef @polylist;
  }
  1;
}

sub _registpoly {
  my $res;
  foreach my $data (@polylist) {
    if ($data->{'id'} eq $_[0]) {
      $res = $data;
      return $res;
    }
  }
  
  my $mtrs = -1;
  my $otherid = -1;
  my $verts = 0;
  my $edge;
  my @vertlist = sort { $a <=> $b } lxq("query layerservice poly.vertList ? $_[0]");

  my $len0 = lxq("query layerservice edge.length ? ($vertlist[0],$vertlist[1])");
  my $len1 = lxq("query layerservice edge.length ? ($vertlist[0],$vertlist[2])");
  my $len2 = lxq("query layerservice edge.length ? ($vertlist[1],$vertlist[2])");

  if ($len0 > $len1 and $len0 > $len2) {$edge = "($vertlist[0],$vertlist[1])"}
  elsif ($len1 > $len0 and $len1 > $len2) {$edge = "($vertlist[0],$vertlist[2])"}
  else {$edge = "($vertlist[1],$vertlist[2])"}
  
  my $hash;
  foreach my $data (@polylist) {
    if ($data->{'lside'} eq $edge) {
      $hash = $data;
      last;
    }
  }

  if (defined($hash)) {
    $mtrs = $hash->{'samematerial'};
    $otherid = $hash->{'id'};
    $verts = 3;
  }
  else {
    my @polys = lxq("query layerservice edge.polylist ? $edge");

    if (@polys == 2) {
      $mtrs = lxq("query layerservice poly.material ? $polys[0]") eq
        lxq("query layerservice poly.material ? $polys[1]") ? 1 : 0;

      if ($polys[0] == $_[0]) {
        $otherid = $polys[1];
        $verts = lxq("query layerservice poly.numVerts ? $polys[1]");
      }
      else {
        $otherid = $polys[0];
        $verts = lxq("query layerservice poly.numVerts ? $polys[0]");
      }

      if ($verts == 3) {
        my $inangle = _getangle($polys[0], $polys[1]) || -1;
        if ($inangle > $angle) {
          if (_chklist($edge, 'e') == 0) {
            push(@exedges, $edge);
          }
        }
      }
    }
  }

  $res = {
    'id' => $_[0],
    'lside' => $edge,
    'samematerial' => $mtrs,
    'otherid' => $otherid,
    'otherverts' => $verts
  };
  push(@polylist, $res);
  $res;
}

sub _appendedge {
  foreach my $data (@polylist) {
    if ($data->{'lside'} eq $_[0]) {
      push(@remedges, $_[0]);
      push(@expolys, $data->{'id'});
      push(@expolys, $data->{'otherid'});
      last;
    }
  }
}

sub _chklist {
  my $res = 0;
  my $ix = shift;
  my $e = shift || 'p';
  my $arr = $e eq 'e' ? \@exedges : \@expolys;

  foreach my $val (@$arr) {
    if ($val eq $ix) {
      $res = 1;
      last;
    }
  }
  $res;
}

sub _getangle {
  my $res;
  my @normalA = lxq("query layerservice poly.normal ? $_[0]");
  my @normalB = lxq("query layerservice poly.normal ? $_[1]");
  my $denom = sqrt(($normalA[0] ** 2 + $normalA[1] ** 2 + $normalA[2] ** 2) *
                   ($normalB[0] ** 2 + $normalB[1] ** 2 + $normalB[2] ** 2));
  if ($denom > 0) {
    $res = ($normalA[0] * $normalB[0] + $normalA[1] *
            $normalB[1] + $normalA[2] * $normalB[2]) / $denom;
    my $tmp = 1 - $res * $res;
    if ($tmp > 0) {
      $res = atan2(sqrt($tmp), $res);
    }
    else {$res = 0}
  }
  $res;
}
