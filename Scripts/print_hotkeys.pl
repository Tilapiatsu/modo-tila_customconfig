#perl
#version 2.3
#author : Seneca Menard
#This script is so you can type in a command and it'll print out all the hotkeys that use that command.  So if you bound some key a couple of years ago and can't remember where in the world you bound it, this script will find it for you.  :)
#It searches both your custom hotkeys as well as the default modo hotkeys and prints them out separately.
#By default, it looks for the default modo cfg file.  If you're one of those folks that saves your hotkeys out to a separate cfg file, just append the path name of the cfg file to the script.

#arguments :
# "noPopup" : The script by default loads up the event log window, regardless of whether or not one was already visible.  Append this to the end of the hotkey command to stop this.  ie : "@print_hotkeys.pl noPopup"
# **your custom cfg file path** : Type in the exact path to your custom hotkey cfg file if you're one of those folks who use those.  Also, make sure it's in quotes if there are any spaces in it.
#an example would be to bind a hotkey to this :             print_hotkeys.pl noPopup "C:\Documents and Settings\seneca\Application Data\Luxology\MyCustomConfig.cfg"

#(7-25-09 bugfix) : it can now find the modo 401 cfg file, now that it knows what the version number of modo401 is.
#(10-22-09 bugfix) : it can now find the modo 402 cfg file, now that it knows what the version number of modo401 is.
#(1-13-09 bugfix) : duh..  Apparently you can just ask modo what cfg file you're using, so I don't have to make guesses anymore and this script will now work with all future versions of modo.  yay!

#setup
my $os = lxq("query platformservice ostype ?");
my $osSlash = findOSSlash();
my $resrcPath = lxq("query platformservice path.path ? resource");
my @configFiles = (
	lxq("query platformservice path.path ? configname"),
	$resrcPath . $osSlash . "inmapdefault.cfg",
	$resrcPath . $osSlash . "renderkeymaps.cfg"
);
OSPathNameFix($_) for @configFiles;
my @hotkeys;
my @defaultHotkeys;

#script arguments
foreach my $arg (@ARGV){
	if ($arg =~ /noPopup/i)		{	our $noPopup = 1;		}
	else						{	our $cfgFile = $arg;	}
}

#either use default cfg or manually specified one.
if ($cfgFile ne ""){
	lxout("[->] : Loading custom cfg specified in the cvar :\n$cfgFile");
	@configFiles[0] = $cfgFile;
}

#open cfg and read all hotkey lines.
for (my $i=0; $i<@configFiles; $i++){
	open (cfgFile, "<@configFiles[$i]") or die("I couldn't find this cfg file : @configFiles[$i]");
	my $readLines = 0;

	while (<cfgFile>){
		if ($readLines == 1){
			if ($i == 0){	push(@hotkeys,$_);			}
			else		{	push(@defaultHotkeys,$_);	}

			if ($_ =~ /\/atom>/){
				$readLines = 0;
				last;
			}
		}
		if ($_ =~ /atom type=\"InputRemapping\"/){$readLines = 1;}
	}
	close(cfgFile);
}


#find the hotkeys that match, clean 'em and sort 'em
my $searchTerm = quickDialog("Type in the command \nyou're looking for:",string,"","","");
printHotkeys("DEFAULT MODO HOTKEYS",\@defaultHotkeys);
printHotkeys("CUSTOM MODO HOTKEYS",\@hotkeys);
lxout("\n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n ");

sub printHotkeys{
	my @globalKeys = ();
	my @viewportKeys = ();
	my @toolKeys = ();

	my $printMessage = $_[0];

	for (my $i=0; $i<@{$_[1]}; $i++){
		if (@{$_[1]}[$i] =~ /$searchTerm/i){
			my $hotkeyData = @{$_[1]}[$i];
			$hotkeyData =~ s/.*key=\"//;
			$hotkeyData =~ s/\<\/hash>.*//;
			my $hotkeyData2 = $hotkeyData;
			$hotkeyData =~ s/\">.*//;
			$hotkeyData2 =~ s/.*\">//;
			$hotkeyData .= "        ".$hotkeyData2;

			if ($hotkeyData =~ /.global/){
				push(@globalKeys,$hotkeyData);
			}elsif ($hotkeyData =~ /view3DTools/){
				push(@toolKeys,$hotkeyData);
			}else{
				push(@viewportKeys,$hotkeyData);
			}
		}
	}


	#print out the hotkeys that were found
	my $loopCount = 1;
	my $count = @globalKeys + @viewportKeys + @toolKeys;
	lxout("---------------------------------------------------------------------------------------------------------------------");
	lxout("---------------------------------------------------------------------------------------------------------------------");
	lxout("Found ($count) $printMessage hotkeys that are bound to the command you're looking for : ($searchTerm)");
	lxout("---------------------------------------------------------------------------------------------------------------------");
	lxout("---------------------------------------------------------------------------------------------------------------------");
	if (@globalKeys > 0){
		#lxout("-----------------------------------------------------------------------");
		#lxout("GLOBAL HOTKEYS");
		#lxout("-----------------------------------------------------------------------");
		foreach my $key (@globalKeys){
			lxout("($loopCount) \n        $key");
			$loopCount++;
		}
	}
	if (@viewportKeys > 0){
		lxout("--------------------------------------------------------------------------------------------------");
		lxout("$printMessage : VIEWPORT SPECIFIC HOTKEYS");
		lxout("--------------------------------------------------------------------------------------------------");
		foreach my $key (@viewportKeys){
			lxout("($loopCount) \n        $key");
			$loopCount++;
		}
	}
	if (@toolKeys > 0){
		lxout("--------------------------------------------------------------------------------------------------");
		lxout("$printMessage : TOOL SPECIFIC HOTKEYS");
		lxout("--------------------------------------------------------------------------------------------------");
		foreach my $key (@toolKeys){
			lxout("($loopCount) \n        $key");
			$loopCount++;
		}
	}
}


#load a popup window
if (@ARGV[0] ne "noPopup"){
	lx("!!layout.create width:600 height:800");
	lx("!!viewport.restore [] 0 logview");
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

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#FIND OS SLASH #modded for windows but appears to work
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub findOSSlash{
	if ($os =~ /win/i){
		return "\\";
	}else{
		return "\/";
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#OS PATH NAME FIX SUB : make sure the / syntax is correct for the various OSes.  #modded for windows but appears to work
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub OSPathNameFix{
	if ($os =~ /win/i){
		@_[0] =~ s/\\/\\/g;
	}else{
		@_[0] =~ s/\\/\//g;
	}
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#QUICK DIALOG SUB
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#USAGE : quickDialog(username,float,initialValue,min,max);
sub quickDialog{
	if (@_[1] eq "yesNo"){
		lx("dialog.setup yesNo");
		lx("dialog.msg {@_[0]}");
		lx("dialog.open");
		if (lxres != 0){	die("The user hit the cancel button");	}
		return (lxq("dialog.result ?"));
	}else{
		if (lxq("query scriptsysservice userValue.isdefined ? seneTempDialog") == 0){
			lxout("-The seneTempDialog cvar didn't exist so I just created one");
			lx("user.defNew name:[seneTempDialog] life:[temporary]");
		}
		lx("user.def seneTempDialog username [@_[0]]");
		lx("user.def seneTempDialog type [@_[1]]");
		if ((@_[3] != "") && (@_[4] != "")){
			lx("user.def seneTempDialog min [@_[3]]");
			lx("user.def seneTempDialog max [@_[4]]");
		}
		lx("user.value seneTempDialog [@_[2]]");
		lx("user.value seneTempDialog ?");
		if (lxres != 0){	die("The user hit the cancel button");	}
		return(lxq("user.value seneTempDialog ?"));
	}
}


