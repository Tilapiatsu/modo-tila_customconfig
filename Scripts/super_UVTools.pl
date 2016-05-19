#perl
#AUTHOR: Seneca Menard
#version 3.888
# TEMP !!! : randomize needs a uv offset so they don't stick and rotation needs to pay attention to the texture size!
# TEMP !!! : 1D DISCO needs to be rewritten to read uvs selected, not verts, and it also needs to work on non-disco verts for tiling models.
# TEMP !!! : repair selected needs to create the material(s) if they don't exist.
# TEMP !!! : unrotate is finding a small edge first and creating a group and the larger edge is falling into the predefined group, but the larger edge should be creating the group itself, that way it's more accurate.  So i probably need to do the loop that creates teh groups sorted by edges from longest to shortest, that way the long one makes the group, as it's usually more accurate.

#There's too many features to go over and that's why there's now three videos on the website that cover the features.

#How to install this script :
# 1) To install it, put the super_UVToolsCard.cfg and super_UVToolsCard.png into your scripts dir (ie, c:/documents and settings/seneca/application data/luxology/scripts/)
# 2) Put the cardToolsForm.CFG in your CFG folder. (C:\Documents and Settings\{-username-}\Application Data\Luxology\Configs)
# 3) Load up modo and go to (toolbar-->layout-->window-->new window)
# 4) click on the arrow in the top right corner of the new window and set it to CARD VIEW
# 5) right click on the top header part of the window and set it to "SUPER UVs"
# 6) Now load a new window (toolbar-->layout-->windows-->new window)
# 7) Now set that new window to be a FORM VIEW (right click on the window's top right arrow-->APPLICATION-->FORM VIEW)
# 8) Now choose the superUVToolsMini form for the form view window (right click on the dark strip at the top of the window-->sen_Super UVs Mini)

#HOTKEY SCRIPT ARGUMENTS :
# "grabApplyMaterial"		: There's one feature that's not assigned to those GUIs, and that's the "grabApplyMaterial command"..  To install that, bind a hotkey to "@super_uvTools.pl grabApplyMaterial"
# "selectImage"				: When you're uving, you sometimes wanna see the image in the uv window.  So now just hold your mouse over a poly and fire the hotkey and it'll select that image.  To install that, bind a hotkey to "@super_uvTools.pl selectImage"
# "autoEdgeSel peeler"		: This is to run the batch peeler command without having to select an edge row on each first, so it saves a bit of time.  Just select all your pipe polys and run the script with those arguments.  ie : "@super_uvTools.pl autoEdgeSel peeler"
# "polySew					: Same as modo's move and sew, only it doesn't require an edge selection.  what it does is sew the first selected polygons to the second, based off of their shared disco uv edges.
# "selectAllClips"			: I bind this to ctrl-A in the clips window so it will select all clips like I expect.
# "scaleMeshesToPixelSize"	: This will scale your selected geometry to match the (world units vs game units) measurement system.  Handy if you wanna know how big you can scale something before it starts becoming too low res....

#FORMS YOU HAVE TO CHANGE :
# - There's three features that are supposed to go into the CLIPS WINDOW's context menu, and to assign those do this : (FORM EDITOR-->CONTEXT MENU-->CLIPS MENU) and add these two buttons : "@super_UVTools.pl apply_this_material"  "@super_UVTools.pl apply_this_material+uv" "@super_UVTools.pl openClipsInPhotoshop"
# - There's one feature that was added to the SHADER TREE WINDOW.  You can right click on a material in there and choose apply and it'll apply it.  To assign that, go here (FORM EDITOR-->CONTEXT MENU-->SHADER TREE MENUS-->SHADER TREE: SHADER) and add this command : "@super_uvTools.pl ST_apply_this_material"
# - There's two features that are supposed to go into the SHADER TREE context menu, and to assign those do this : (FORM EDITOR-->CONTEXT MENU-->SHADER TREE MENUS-->SHADER TREE : SHADER) and add these two buttons : "@super_UVTools.pl ST_apply_this_material" "@super_UVTools.pl ST_selectTheseMaterials"
# - There's two features that are used for selecting CLIPS or MATERIAL GROUPS by name patterns.. So if you want to select all the material groups in teh scene with the word "metal" in it, you'll just run that script and type that in.  Here's the commands you need to bind to those hotkeys or buttons : "@super_UVTools.pl selTheseMasks" and "@super_UVTools.pl selectTheseClips"


#(4-14-07 features+fixes) :
# - It now accepts images from any game paths and will truncate the data.
# - It now auto-finds image of different types.
# - It now has an option to only load images that fit certain name filters.
# - You can now selectively repair materials and not have to do all of them.  It uses the materials on the polys you have selected.
# - The anchor now has top,right,bottom, and left added.
# - The texture move size buttons are back.  (forgot to put 'em in the form cfg)
# - Finally fixed the modo bug where when you'd load the scene again, all the image paths would be corrupted by modo. That's all fixed now.
#(8-18-07 change) : when you apply a material thru the clips context menu, it'll now set the "grabbed material" cvar to be that material so you can apply it again by using the applyGrabbedMaterial command
#(8-21-07 feature) : Hold your mouse over a poly and fire "@super_uvTools.pl selectImage" and it'll select the image that's applied to the poly under the mouse.  If you want to clear the image from the uv window, just fire the same command with your mouse over nothing or a poly that doesn't have an image assigned.
#(9-19-07 fix) : found a small bug with planarAuto
#(11-9-07 fix) : found a layer restore bug with atlas
#(12-27-07 feature) : put in temp hack to not grab material from background objects if shading is set to wireframe.
#(1-3-08 feature) : The shader tree now has a right click command to apply a material. Look in the "FORMS YOU HAVE TO CHANGE" info mentioned up above on how to install that button.
#(2-4-08 fix) : if you were trying to move uvs with a gridsnap of 0.5, it wouldn't work properly.
#(2-4-08 fix) : the material path name removal user value is now defaulted to "" so it won't cause problems anymore.
#(2-13-08 fix) : 302 changed the material naming system and the script is now updated for that.
#(2-13-08 feature) : Now has the ability to select all clips with the name pattern you type in for quick finds : "@super_UVTools.pl selectTheseClips"
#(2-13-08 feature) : Now has the ability to select all masks with the name pattern you type in for quick finds : "@super_UVTools.pl selTheseMasks"
#(3-21-08 feature) : Now has the ability to select all polygons assigned to the masks that you currently have selected in the shader tree.  (put this button "@super_UVTools.pl ST_selectTheseMaterials" in the shader tree context menu)
#(4-19-08 fix) : there was a bug with the uv island determination code and I kept putting it off because i knew it was gonna be hard to fix (plus i rarely saw it so it wasn't all that important to me), but I finally put the time and effort into burying that bastard for good. :)
#(4-20-08 fix) : the script now works with the mac OS.
#(5-13-08 feature) : Now has the ability to randomize the position,scale,rotation of the selected uv islands.  Plus, you can turn on grid snap so they only rotate with increments of 15 degrees or move in units of 0.5, etc..  Plus, you can have it only move or scale in 1 dimension by putting in a randomize value of 0 in the axis you don't want to randomize.
#(5-15-08 feature) : Added the ability to open an image in photoshop or whatever paint program you use from inside the clips window.  To assign that, do this : (FORM EDITOR-->CONTEXT MENU-->CLIPS MENU) and add this button : "@super_UVTools.pl openClipsInPhotoshop".   Also, go into the GLOBAL OPTIONS in the superUVSMini form and make sure the image editor path is correct.  I put the photoshop3 path there by default as a guess.
#(5-19-08 feature) : 1D DISCO UV FLATTEN : When you're making tiling models, you have to make sure that the verts on both the top and bottom have their uvs aligned.  Using this feature, you'll select the verts on the top and bottom and run this script and it'll align them in the dimension you need.
#(5-20-08 fix) : grabApplyMaterial would fail if the mainlayer was active, but not visible because I would go into item mode to be able to have the script work with other layers and when I do that, the mainlayer would disappear because it's visibility was off.  It now forces it to be visible and then puts it back if it needs to.
#(5-23-08 feature) : SORT MATERIALS : you can now sort either ALL or THE SELECTED materials alphabetically in the shader tree so they're easier to find.  "@super_UVTools.pl sortMaterials"  or  "@super_UVTools.pl onlySelected sortMaterials"
#(5-30-08 fix) : rewrote the material sorting algo so that it works properly with numbers.
#(7-31-08 fix) : the (apply parts per uv island) sub wasn't firing the cleanup sub.
#(9-25-08 feature) : AUTO EDGE SELECTION BATCH PEELER : If you have about a hundred pipes to run peeler on at once, it can be a pain to select the edge loops first.  So now, with this new command, you can just select your pipes' polys and it'll select an edge row on each pipe and then run peeler on each.  This isn't in the gui yet, so here's the command you can bind to a hotkey : "@super_uvTools.pl autoEdgeSel peeler"
#(12-18-08 fix) : I went and removed the square brackets so that the numbers will always be read as metric units and also because my prior safety check would leave the unit system set to metric system if the script was canceled because changing that preference doesn't get undone if a script is cancelled.
#(12-18-08 fix) : (apply this material fix) : if you have a shader tree mask that no polys are currently using, you can't query it's ptag value and you thus can't know what it's name is. So I put in a hack to assume that the visible name in the shader tree is what the ptag is.  It should work 99% of the time, unless the user changed it by right clicking on it (which is the only way to rename a mask without actually altering the ptag it was using, which IMO should just be removed)
#(1-14-09 fix) : found a small bug when finding the image sizes on materials with uppercase letters
#(1-29-09 fix) : it now properly restores the visibility of mesh instances
#(1-30-09 fix) : removed a meaningless popup that would occur the first time you run the script.
#(2-14-08 feature) : POLY SEW : normally to sew one uv island to another, you have to select some disco edges and then run the sew command, but the problem with that is that you can't sew in the 3d view because you can't select disco edges in it.  So, the fix is that you select the polys you want to sew and then the polys you want them to be sewn to and the script will find their shared edges and select those disco edges and do th sew.
#(2-21-09 feature) : ALL JPEGS ARE HALF SIZE : what we do all the time is take our TGAs and convert them to JPEGs with 25% of the size, that way we can see the same textures in modo without bogging it down.  Of course, if you want to apply a world-sized texture projection, you're going to not have the correct scale if you used the JPEGs image size, because they don't have the real image size that the actual TGAs do.  So basically, turn this option on if you want to use shrunk jpegs, but have them use the correct world space projection size.
#(2-21-09 feature) : NEW REBUILD MATERIALS FEATURES : now has an option to do selective rebuilds, ranging from all materials in the scene, all selected materials, all the materials that the selected polys are using, to materials with certain names.  Plus, say a material has both a TGA or JPEG and you want to pick which one of those it would grab, well, by default it'd use that (MATERIAL REPAIR FILE PREFERENCE ORDER) option to determine which image to grab.  Well now we've got an additional button for all the rebuild buttons that defaults to finding JPGs first, so you can press the regular rebuild button to grab the TGA (assuming TGA was before JPG in your preference order option) and the JPG REPAIR button to load a JPG instead.
#(2-27-09 fix) : i noticed that in order for photoshop to open an image, it must be using backslashes in the path.
#(3-10-09 feature) : SELECT THE POLYS THAT THE SELECTED CLIPS ARE ASSIGNED TO : So you can right click on a clip and select all the polys in the scene that are using that material.  usage : @super_UVTools.pl CL_selectThesePolys
#(3-15-09 fix) : UNROTATE DOESN'T REQUIRE POLY SELECTIONS ANYMORE AND ALSO WORKS WITH EDGES NOW : if you wanted to do a manual unrotate, you used to have to select two verts and the connected polys.  Not anymore.  Just select some verts or an edge and that's it.  (and don't forget that unrotate works with multiple uv islands at once, too)
#(3-15-09 fix) : GRAB/APPLY MATERIAL : put in a better algo to assure that the main layer is going to be visible and doesn't disappear when you grab a material.
#(3-31-09 fix) : 401 changed their pixel blending routine, so i updated the script for that.
#(3-31-09 bugfix) : found it's possible to have an active layer that's neither selected nor visible and put in a fix.
#(4-23-09 bugfix) : removing border edges in the auto edge sel peeler script to fix a problem with edge loop selection
#(6-30-09 feature) : added the ability to unrotate to the nearest U or V axis instead of unrotating to either of the two.
#(7-7-09 feature) : added the ability to keep the uv island's aspect ratio when you do a 90 degree rotation.  (handy if you do a uv bbox paste and found out that the texture needed to be rotated 90.  that way you can rotate 90, but keep the bbox shape the same)
#(7-7-09 bugfix) : in my UV quantize code, there was rounding errors because of modo's limitation in the number of numbers it'll store in a user value, so i'm now using a string instead of a number to get around that problem.
#(8-21-09 feature) : searchMaterialsAndApply : Say you want to apply some neon material, but you don't see it in sight and so you can't grabApply it, and you don't wanna type in it's name, so you won't do it manually.  Well, with this command, you can type in some words and it'll return the materials that had those words in it and you can then apply one of those found materials.
#(10-28-09 feature) : Scale UVs To Pixel Size : Before this feature, the only way to make sure your uvs were matching the "world space size" was to apply a world space uv projection, so that meant you could only match the pixel size if it was ok to do planar world space projections.  But what if you wanted to use the unwrap tool?  That would not match the pixel size and so your texture would be too high res or low res.  Well, I added a new button right below the world space size number so that you can press that and all selected uv islands will be scaled to match the pixel size ratio.  Note, this command uses the uv anchor feature, so use that to control where the islands get scaled from.  Also, this command is only for doing scales, not stretches, so if your uvs are not properly proportional to itself, this script is not going to fix that.
#(11-5-09 feature) : added the ability to right click on an image and open the directory it's in with windows explorer.
#(11-24-09 fix) : The auto-edge-select-peeler was guessing the wrong edges to select quite often because it was only querying which edge was longest from one chosen poly.  That wasn't enough polys to query, so now it's querying every 4th poly.  It's slower than querying only one poly, but not as slow as it could be if i queried all the polys, so this should be good enough in all cases to select a correct edge loop.
#(12-8-09 feature) : TGA->JPEG subroutine will now check out the JPEGs if needed.
#(1-25-10 feature) : added moveOneUnit sub (which allows you to nudge your selected uvs over 1 whole unit.
#(1-29-10 feature) : Added three new buttons next to the 3 shrink1Pixel buttons that now let you shrink the uvs by however many pixels you want.
#(2-8-10 fix) : moveOneUnit sub now makes sure you're in the right actr.
#(2-8-10 feature) : Now added a new button to the Rebuild popup that looks for any materials that didn't exist in the shader tree and now creates and rebuilds them.
#(2-19-10 feature) : uv hot spots tool.  a vid will be required to explain what it does.
#(3-2-10 feature) : added a feature and bugfix to uv hot spots tool.  You can now edit preexisting uv layouts. (so you can change your mind later on some hotspots)
#(3-2-10 fix) : put in a ptyp query fix.
#(3-5-10 feature) : uv bbox paste now has an autorotate option
#(5-2-10 fix) : put in a force image size for materials that don't exist.
#(6-7-10 feature) : new feature to allow you to merge disco uvs that are within a certain distance from each other.  the cvar is "uvDistMerge".  you can also type in a number as another script cvar and that will set the merge distance.
#(6-18-10 fix) : my repair missing materials sub was failing to select the RENDER node.
#(6-22-10 fix) : put in a divide by zero safety check for the STRETCH TO PIXEL SIZE sub.
#(6-24-10 fix) : PS:CS5 broke my old saveSmallerJPEG.exe, so i had to create a new one just for CS5.
#(7-9-10 hack) : I rebound the unwrap button to just turn on modo's tool as a temp workaround for not putting in proper support for batch unwrapping.
#(8-14-10 fix) : added CS4 64 support for the TGA->JPEG routine.
#(9-3-10 feature) : added "selectAllClips" command.
#(9-7-10 fix) : found a case insensitivity
#(9-13-10 feature) : added ability to load a material's individual files into PS. (it's hardcoded to only load the TGAs now though.)
#(9-21-10 feature) : The TGA to JPEG conversion subroutine now adds the JPEGs you just created to the perforce checkin list.
#(10-6-10 fix) : stopped a divide by zero bug with uvHotSpotTool
#(10-13-10 fix) : found out that material queries only work on the current layer and so i rewrote the rebuild nonexistant materials script to select them one by one to get correct material lists.
#(10-15-10 feature) : poly uv sew will now always sew to the opposite side of the uv island and so you don't get any overlapping uvs anymore.  :)
#(11-15-10 feature) : saveMeshPreset now saves JPEGs to the LXLs and will load the TGA used in the m2 if there is no TGA matching the material name.
#(12-12-10 fix) : optimized fixFacetMaterials sub and fixed a bug with repair missing materials
#(12-15-10 fix) : saveMeshPreset routine now lets you only reload LXLs that are older than X hours, so that if modo crashed when you were doing a force reload, you can do another force reload and skip the new files.
#(12-20-10 fix) : in 501, applying a material or changing uvs isn't assigning new poly indices and so i had to remove a poly indice change assumption from the apply material + uvs routine.
#(12-21-10 feature) : added "scaleMeshesToPixelSize" subroutine which will scale your selected polys to their world space texture sizes.  (so you can match a model's scale to it's texture res).  If you have an object that has multiple pieces to it, you should run apply a "poly part" to the mesh and also add a cvar called "part" to the script as well so it knows to group polys by their parts. ie : @super_UVTools.pl part scaleMeshesToPixelSize
#(1-4-11 fix) : i stopped the moveOneUnit script from working if you aren't in polygon mode and don't any polys selected.
#(1-26-11 fix) : i changed the uv fit algo to now randomize in both U and V so as to increase the odds that no uv islands will get merged on accident when randomize uvs is on.  Same for uv hotspot
#(1-27-11 fix) : the subroutine that selects the clip assigned to the poly under the mouse will now temporarily force the mainlayer's visibility on so the item selection mouseclick doesn't fail.
#(2-24-11 feature) : added the ability to apply a random material (and material color) per uv island.  This command is in the "Extras:" menu in the super_UVsMini form btw.
#(2-24-11 fix) : the new randomize V feature was not working properly with scale.

lxout("Running superUVs");
my $cfgPath = lxq("query platformservice path.path ? user");
my $scriptsPath = lxq("query platformservice path.path ? Scripts");
my $os = lxq("query platformservice ostype ?");
my $osSlash = findOSSlash();
my $modoVer = lxq("query platformservice appversion ?");
my $mainscene = lxq("query sceneservice scene.index ? current");
my $mainlayer = lxq("query layerservice layers ? main");
my $mainlayerID = lxq("query layerservice layer.id ? $mainlayer");
if (lxq("query sceneservice item.isSelected ? $mainlayerID") == 0){lx("select.subItem {$mainlayerID} add mesh;triSurf;meshInst;camera;light;backdrop;groupLocator;replicator;locator;deform;locdeform;chanModify;chanEffect 0 0");}
my $pi=3.14159265358979323;
my $selectionMode;
if ($modoVer < 400){our $pixBlend = "false";}else{our $pixBlend = "nearest";}
srand;

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#USER VARIABLES
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
userValueTools(sene_texMove,integer,config,sene_texMove,"","","",0,10240,"",0);
userValueTools(sene_texAnchor,integer,config,sene_texAnchor,"top_left;top_right;bottom_right;bottom_left;center;off;top;right;bottom;left","","",0,9,"",3);
userValueTools(sene_texScale,float,config,UV_scale,"","","",xxx,xxx,"",1);
userValueTools(sene_texFitU,float,config,UV_1dFit_Scale_U,"","","",xxx,xxx,"",1);
userValueTools(sene_texFitV,float,config,UV_1dFit_Scale_V,"","","",xxx,xxx,"",1);
userValueTools(sene_surfaceGrab,string,config,Surface_name_and_projection,"","","",xxx,xxx,"",empty);
userValueTools(sene_randomize,boolean,config,UV_randomize,"","","",xxx,xxx,"",1);
if ((lxq("query scriptsysservice userValue.isdefined ? sene_quantizeU") == 1) && (lxq("user.def sene_quantizeU attr:type ?") ne "string")){!!lx("user.defdelete sene_quantizeU");} #ver 3.4 changed these from float to string, so i'm nuking and recreating them
if ((lxq("query scriptsysservice userValue.isdefined ? sene_quantizeV") == 1) && (lxq("user.def sene_quantizeV attr:type ?") ne "string")){!!lx("user.defdelete sene_quantizeV");}
userValueTools(sene_quantizeU,string,config,U_quantize,"","","",xxx,xxx,"",1);
userValueTools(sene_quantizeV,string,config,V_quantize,"","","",xxx,xxx,"",1);
#----------------------------------------------------------------------------------------------------
userValueTools(sene_matRepairTypeA,boolean,config,matRepairTypeA,"","","",xxx,xxx,"",1);
userValueTools(sene_matRepairTypeB,boolean,config,matRepairTypeB,"","","",xxx,xxx,"",1);
userValueTools(sene_matRepairTypeC,boolean,config,matRepairTypeC,"","","",xxx,xxx,"",1);
#----------------------------------------------------------------------------------------------------
userValueTools(sene_matRepairNameA,string,config,matRepairNameA,"","","",xxx,xxx,"",textures);
userValueTools(sene_matRepairNameB,string,config,matRepairNameA,"","","",xxx,xxx,"",models);
userValueTools(sene_matRepairNameC,string,config,matRepairNameA,"","","",xxx,xxx,"",land);
#----------------------------------------------------------------------------------------------------
userValueTools(sene_matRepairPath,string,config,matRepairPath,"","","",xxx,xxx,"","");
userValueTools(sene_matRepairDelIMGs,boolean,config,delNonMainImages,"","","",xxx,xxx,"",1);
userValueTools(sene_matRepairFileOrder,string,config,preferredFileOrder,"","","",xxx,xxx,"","tga,jpg,png,psd,gif,bmp,jpeg");
userValueTools(sene_matRepairImgFilter,string,config,"File loader extensions","","","",xxx,xxx,"","tga,jpg");
#----------------------------------------------------------------------------------------------------
userValueTools(sene_randUVMove,boolean,config,"random UV Move","","","",xxx,xxx,"",1);
userValueTools(sene_randUVScale,boolean,config,"random UV Scale","","","",xxx,xxx,"",1);
userValueTools(sene_randUVRotate,boolean,config,"random UV Rotate","","","",xxx,xxx,"",1);
userValueTools(sene_randUVMoveQuant,boolean,config,"random UV Move Quantization","","","",xxx,xxx,"",1);
userValueTools(sene_randUVScaleQuant,boolean,config,"random UV Scale Quantization","","","",xxx,xxx,"",1);
userValueTools(sene_randUVRotateQuant,boolean,config,"random UV Rotate Quantization","","","",xxx,xxx,"",1);
userValueTools(sene_randUVMoveQuantU,float,config,"random U Move Quantization Amount","","","",xxx,xxx,"",1,1);
userValueTools(sene_randUVMoveQuantV,float,config,"random V Move Quantization Amount","","","",xxx,xxx,"",1,1);
userValueTools(sene_randUVScaleQuantU,float,config,"random U Scale Quantization Amount","","","",xxx,xxx,"",1,1);
userValueTools(sene_randUVScaleQuantV,float,config,"random V Scale Quantization Amount","","","",xxx,xxx,"",1,1);
userValueTools(sene_randUVRotateQuantAmt,float,config,"random UV Rotate Quantization Amount","","","",xxx,xxx,"",1);
userValueTools(sene_randUVMoveU,percent,config,"random U Move Amount","","","",xxx,xxx,"",100,1);
userValueTools(sene_randUVMoveV,percent,config,"random V Move Amount","","","",xxx,xxx,"",100,1);
userValueTools(sene_randUVScaleU,percent,config,"random U Scale Amount","","","",xxx,xxx,"",100,1);
userValueTools(sene_randUVScaleV,percent,config,"random V Scale Amount","","","",xxx,xxx,"",100,1);
userValueTools(sene_randUVRotateAmt,percent,config,"random UV Rotation Amount","","","",0,1,"",100);
#----------------------------------------------------------------------------------------------------
userValueTools(sene_imgEditPath,string,config,"image editor path","","","",xxx,xxx,"","C:\/Program Files\/Adobe\/Adobe Photoshop CS3\/Photoshop.exe");
userValueTools(sene_jpgHalfSize,boolean,config,"All JPGs are half size","","","",xxx,xxx,"",0);
userValueTools(sene_UVBufferFit,string,config,"UV FIT buffer size","","","",xxx,xxx,"","1,1,0.5,0.5");
userValueTools(sene_sutImageAA,boolean,config,"image Antialiasing","","","",xxx,xxx,"",0);

#make sure they're loaded:
my $sene_texMove =				lxq("user.value sene_texMove ?");
my $sene_texAnchor = 			lxq("user.value sene_texAnchor ?");
my $sene_texScale =				lxq("user.value sene_texScale ?");
my $sene_texFitU = 				lxq("user.value sene_texFitU ?");
my $sene_texFitV = 				lxq("user.value sene_texFitV ?");
my $sene_surfaceGrab = 			lxq("user.value sene_surfaceGrab ?");
my $sene_randomize = 			lxq("user.value sene_randomize ?");
my $sene_quantizeU = 			lxq("user.value sene_quantizeU ?");
my $sene_quantizeV =			lxq("user.value sene_quantizeV ?");
my $sene_matRepairTypeA =		lxq("user.value sene_matRepairTypeA ?");
my $sene_matRepairTypeB = 		lxq("user.value sene_matRepairTypeB ?");
my $sene_matRepairTypeC = 		lxq("user.value sene_matRepairTypeC ?");
my $sene_matRepairNameA =		lxq("user.value sene_matRepairNameA ?");
my $sene_matRepairNameB =		lxq("user.value sene_matRepairNameB ?");
my $sene_matRepairNameC =		lxq("user.value sene_matRepairNameC ?");
my $sene_matRepairPath = 		lxq("user.value sene_matRepairPath ?");
my $sene_matRepairDelIMGs =		lxq("user.value sene_matRepairDelIMGs ?");
my $sene_matRepairFileOrder = 	lxq("user.value sene_matRepairFileOrder ?");
my $sene_matRepairImgFilter = 	lxq("user.value sene_matRepairImgFilter ?");
my $sene_randUVMove = 			lxq("user.value sene_randUVMove ?");
my $sene_randUVScale = 			lxq("user.value sene_randUVScale ?");
my $sene_randUVRotate = 		lxq("user.value sene_randUVRotate ?");
my $sene_randUVMoveQuant = 		lxq("user.value sene_randUVMoveQuant ?");
my $sene_randUVScaleQuant = 	lxq("user.value sene_randUVScaleQuant ?");
my $sene_randUVRotateQuant = 	lxq("user.value sene_randUVRotateQuant ?");
my $sene_randUVMoveQuantU = 	lxq("user.value sene_randUVMoveQuantU ?");
my $sene_randUVMoveQuantV = 	lxq("user.value sene_randUVMoveQuantV ?");
my $sene_randUVScaleQuantU = 	lxq("user.value sene_randUVScaleQuantU ?");
my $sene_randUVScaleQuantV = 	lxq("user.value sene_randUVScaleQuantV ?");
my $sene_randUVRotateQuantAmt =	lxq("user.value sene_randUVRotateQuantAmt ?");
my $sene_randUVMoveU = 			lxq("user.value sene_randUVMoveU ?");
my $sene_randUVMoveV = 			lxq("user.value sene_randUVMoveV ?");
my $sene_randUVScaleU = 		lxq("user.value sene_randUVScaleU ?");
my $sene_randUVScaleV = 		lxq("user.value sene_randUVScaleV ?");
my $sene_randUVRotateAmt = 		lxq("user.value sene_randUVRotateAmt ?");
my $sene_imgEditPath = 			lxq("user.value sene_imgEditPath ?");
my $sene_jpgHalfSize = 			lxq("user.value sene_jpgHalfSize ?");
my $sene_UVBufferFit = 			lxq("user.value sene_UVBufferFit ?");
my $sene_sutImageAA = 			lxq("user.value sene_sutImageAA ?");

my @fileOrder = split(/[^a-zA-Z]/, $sene_matRepairFileOrder);

#round out the quantU and quantV string numbers
if ($sene_quantizeU =~ /[^0-9\.e\-]/)	{$sene_quantizeU = 1; lx("user.value sene_quantizeU $sene_quantizeU");}
if ($sene_quantizeV =~ /[^0-9\.e\-]/)	{$sene_quantizeV = 1; lx("user.value sene_quantizeV $sene_quantizeV");}


#shader build + bump/diff/spec repair cvars
my @files;
if (($sene_matRepairPath =~ /rage/i) || ($sene_matRepairPath =~ /doom/i))	{	our $mtrExtension = "m2";	our $mtrDirName = "m2";			}
else																		{	our $mtrExtension = "mtr";	our $mtrDirName = "materials";	}
my $shaderDir = $sene_matRepairPath;
   $shaderDir =~ s/[\\\/]$//g;
   if ($sene_matRepairPath =~ /rage/i)	{$shaderDir = $shaderDir . &findOSSlash . decls . &findOSSlash . $mtrDirName;}
   else									{$shaderDir = $shaderDir . &findOSSlash . decls . &findOSSlash . $mtrDirName;}

my %shaderText;
my %decipherShaders;
my $hack_powermipToRefl = 1;

#debug log file (for both repair materials and save mesh preset)
my $saveMeshPresetLogFile = "c:\/saveMeshPresetLog.txt";
if ((0) && ($cfgPath =~ /seneca/i)){our $debugSaveMesh = 1;}

#make sure the CHANGED texAnchor variable list is updated.
lx(qq(user.def sene_texAnchor list "top_left;top_right;bottom_right;bottom_left;center;off;top;right;bottom;left"));

#hotspot file
my $hotSpotFile = $sene_matRepairPath . "\/decls\/art_scripts\/super_UVTools_hotSpotList.cfg";
OSPathNameFix($hotSpotFile);

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SCRIPT ARGUMENTS
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
foreach my $arg (@ARGV){
	if    ($arg eq "prop")			{	our $prop = 1;			}
	elsif ($arg eq "U")				{	our $U = 1;				}
	elsif ($arg eq "V")				{	our $V = 1;				}
	elsif ($arg eq "X")				{	our $axis = 0;			}
	elsif ($arg eq "Y")				{	our $axis = 1;			}
	elsif ($arg eq "Z")				{	our $axis = 2;			}
	elsif ($arg eq "up")			{	our $up = 1;			}
	elsif ($arg eq "down")			{	our $down = 1;			}
	elsif ($arg eq "left")			{	our $left = 1;			}
	elsif ($arg eq "right")			{	our $right = 1;			}
	elsif ($arg eq "avg")			{	our $avgProp = 1;		}
	elsif ($arg eq "CCW")			{	our $CCW = 1;			}
	elsif ($arg eq "origin")		{	our $origin = 1;		}
	elsif ($arg eq "autoAngle")		{	our $autoAngle = 1;		}
	elsif ($arg eq "ignoreTexSize")	{	our $ignoreTexSize = 1;	}
	elsif ($arg eq "U-")			{	our $U = 0;				}
	elsif ($arg eq "U+")			{	our $U = 2;				}
	elsif ($arg eq "V-")			{	our $V = 0;				}
	elsif ($arg eq "V+")			{	our $V = 2;				}
	elsif ($arg eq "selected")		{	our $selected = 1;		}
	elsif ($arg eq "noUnrotate")	{	our $noUnrotate = 1;	}
	elsif ($arg eq "autoEdgeSel")	{	our $autoEdgeSel = 1;	}
	elsif ($arg eq "jpg")			{	our $jpg = 1;			}
	elsif ($arg eq "filter")		{	our $filter = 1;		}
	elsif ($arg eq "bumpDiffSpec")	{	our $bumpDiffSpec = 1;	}
	elsif ($arg eq "forceOverwrite"){	our $forceOverwrite = 1;}
	elsif ($arg eq "lxlOverwrite")	{	our $lxlOverwrite = 1;	}
	elsif ($arg eq "print")			{	our $print = 1;			}
	elsif ($arg eq "dialog")		{	our $dialog = 1;		}
	elsif ($arg eq "part")			{	our $part = 1;			}
	elsif ($arg eq "apply_this_material"){
		lxout("[->] I'M APPLYING THE SHADER THAT THIS CLIP BELONGS TO.");
		&validateGameDir;
		&selectVmap;
		&apply_this_material;
	}
	elsif ($arg eq "apply_this_material+uv"){
		lxout("[->] I'M APPLYING THE SHADER THAT THIS CLIP BELONGS TO AND APPLYING WORLD SPACE UVs.");
		&validateGameDir;
		&safetyChecks;
		&selectVmap;
		&apply_this_material;
		if ($modoVer < 500){@polys = fixReorderedArray(@polys);}
		&clipSizeList;
		&splitPolysIntoTexSizeGroups;
		&world_space_uvs;
		&restoreSelection;
		&cleanup;
	}
	elsif ($arg eq "load_new_shader"){
		lxout("[->] I'M LOADING A NEW SHADER+IMAGE.");
		&validateGameDir;
		&selectVmap;
		&load_new_shader;
	}
	elsif ($arg eq "repair_shaders"){
		lxout("[->] REPAIRING SHADERS : (ie, i'm adding images to the shaders that don't have any, and i'm removing dupe images).");
		my @verifyMainlayerVisibilityList = verifyMainlayerVisibility();
		&validateGameDir;
		&selectVmap;
		&repair_shaders;
		if (($modoVer > 300) &&($selected != 1)){&deleteUnusedTxLocators;}
		verifyMainlayerVisibility(\@verifyMainlayerVisibilityList);
		lx("select.subItem {$mainlayerID} set mesh;camera;light;backdrop;groupLocator;replicator;locator;deform;locdeform;chanModify;chanEffect 0 0");
	}
	elsif ($arg eq "world_space_uvs"){
		lxout("[->] APPLYING WORLD SPACE UVs.");
		&validateGameDir;
		&safetyChecks;
		&selectVmap;
		&clipSizeList;
		&splitPolysIntoTexSizeGroups;
		&world_space_uvs;
		&restoreSelection;
		&cleanup;
	}
	elsif ($arg eq "planar"){
		lxout("[->] APPLYING PLANAR UVs.");
		&validateGameDir;
		our $subroutine = planar;
		our $needBbox = 1;
		&safetyChecks;
		&selectVmap;
		&generalUVs;
		if (($autoAngle == 1) && ($noUnrotate != 1)){
			&clipSizeList;
			&splitPolysIntoTexSizeGroups;
			&unRotate;
			&restoreSelection;
		}
		&cleanup;
	}
	elsif ($arg eq "cylindrical"){
		lxout("[->] APPLYING CYLINDRICAL UVs.");
		our $subroutine = cylindrical;
		our $needBbox = 1;
		&safetyChecks;
		&selectVmap;
		&generalUVs;
		&cleanup;
	}
	elsif ($arg eq "spherical"){
		lxout("[->] APPLYING SPHERICAL UVs.");
		our $subroutine = spherical;
		our $needBbox = 1;
		&safetyChecks;
		&selectVmap;
		&generalUVs;
		&cleanup;
	}
	elsif ($arg eq "atlas"){
		lxout("[->] APPLYING ATLAS UVs.");
		our $subroutine = atlas;
		our $needBbox = 1;
		&safetyChecks;
		&selectVmap;
		&generalUVs;
		&cleanup;
	}
	elsif ($arg eq "camPlanar"){
		lxout("APPLYING CAMERA PROJECTED UVs.");
		our $subroutine = camPlanar;
		&safetyChecks;
		&selectVmap;
		&generalUVs;
		&cleanup;
	}
	elsif ($arg eq "unwrap"){
		lxout("[->] APPLYING BATCH UNWRAP UVs.");
		lx("!!tool.set uv.unwrap on");
		#our $subroutine = unwrap;
		#&safetyChecks;
		#&selectVmap;
		#&generalUVs;
		#&cleanup;
	}
	elsif ($arg eq "prop1dFit"){
		lxout("[->] APPLYING A UV FIT.");
		&validateGameDir;
		&safetyChecks;
		&selectVmap;
		&splitUVGroups;
		&prop1dFit;
		&restoreSelection;
		&cleanup;
	}
	elsif ($arg eq "quickScale"){
		lxout("[->] SCALING THE UVs (quickly).");
		&safetyChecks;
		&selectVmap;
		&quickScale;
		&cleanup;
	}
	elsif ($arg eq "scale"){
		lxout("[->] SCALING THE UVs.");
		&validateGameDir;
		&safetyChecks;
		&selectVmap;
		our @polys = lxq("query layerservice polys ? selected");
		&splitUVGroups;
		&scale;
		&restoreSelection;
		&cleanup;
	}
	elsif ($arg eq "move"){
		lxout("[->] MOVING THE UVS");
		&validateGameDir;
		&safetyChecks;
		&selectVmap;
		&clipSizeList;
		&splitPolysIntoTexSizeGroups;
		&move;
		&restoreSelection;
		&cleanup;
	}
	elsif ($arg eq "flip"){
		lxout("[->] FLIPPING THE UVs.");
		&rememberTool;
		&safetyChecks;
		&selectVmap;
		&splitUVGroups;
		&flip;
		&restoreSelection;
		&cleanup;
	}
	elsif ($arg eq "rotate"){
		lxout("[->] ROTATING THE UVs.");
		&validateGameDir;
		&rememberTool;
		&safetyChecks;
		&selectVmap;
		&clipSizeList;
		&splitPolysIntoTexSizeGroups;
		&rotate;
		&restoreSelection;
		&cleanup;
	}
	elsif ($arg eq "shrink1pixel"){
		lxout("[->] SHRINKING THE UVs 1 PIXEL (to get around the pixel bleed problem)");
		&validateGameDir;
		&safetyChecks;
		&selectVmap;
		&clipSizeList;
		&splitPolysIntoTexSizeGroups;
		&shrink1pixel;

		&restoreSelection;
		&cleanup;
	}
	elsif ($arg eq "uvAlign"){
		lxout("[->] LINING UP THE UVs SO THEY MATCH");
		&safetyChecks;
		&selectVmap;
		&splitUVGroups;
		&uvAlign;
		&restoreSelection;
		&cleanup;
	}
	elsif ($arg eq "grabApplyMaterial"){
		lxout("[->] GRAB THE MATERIAL OF LAST POLY AND APPLY IT TO ALL THE OTHER POLYS");
		&grabMaterial;
		&applyGrabbedMaterial;
	}
	elsif ($arg eq "applyGrabbedMaterial"){
		lxout("[->] APPLYING THE LAST GRABBED MATERIAL TO THE SELECTED POLYS");
		&applyGrabbedMaterial;
	}
	elsif ($arg eq "unRotate"){
		lxout("[->] UNROTATE EACH UV SET");
		&validateGameDir;
		&safetyChecks;
		&selectVmap;
		&clipSizeList;
		&unRotate;
		&restoreSelection;
		&cleanup;
	}
	elsif ($arg eq "unRandomizeUVs"){
		lxout("[->] UNRANDOMIZE EACH UV SET");
		&safetyChecks;
		&selectVmap;
		&splitUVGroups;
		&unRandomizeUVs;
		&restoreSelection;
		&cleanup;
	}
	elsif ($arg eq "quantizeUVs"){
		lxout("[->] QUANTIZE EACH UV SET");
		&validateGameDir;
		&safetyChecks;
		&selectVmap;
		&splitUVGroups;
		&quantizeUVs;
		&restoreSelection;
		&cleanup;
	}
	elsif ($arg eq "peeler"){
		lxout("[->] PEEL EACH UV SET");
		&safetyChecks;
		&selectVmap;
		if ($autoEdgeSel == 1){&selectEdgeLoops;}
		&peeler;
		&restoreSelection;
		&cleanup;
	}
	elsif ($arg eq "centerUVs"){
		lxout("[->] CENTER EACH UV SET");
		&safetyChecks;
		&selectVmap;
		&splitUVGroups;
		&centerUVs;
		&restoreSelection;
		&cleanup;
	}
	elsif ($arg eq "selectImage"){
		&validateGameDir;
		&selectMaterialImage;
	}
	elsif ($arg eq "ST_apply_this_material"){
		&ST_apply_this_material;
	}
	elsif ($arg eq "ST_selectTheseMaterials"){
		&ST_selectTheseMaterials;
	}
	elsif ($arg eq "selectTheseMaterials"){
		&selectTheseMaterials;
	}
	elsif ($arg eq "selectTheseClips"){
		&selectTheseClips;
	}
	elsif ($arg eq "selectAllClips"){
		&selectAllClips;
	}
	elsif ($arg eq "TGA_JPGconversion"){
		&validateGameDir;
		&TGA_JPGconversion;
	}
	elsif ($arg eq "selTheseMasks"){
		&selTheseMasks;
	}
	elsif ($arg eq "applyPartPerUVGroup"){
		&safetyChecks;
		&selectVmap;
		&splitUVGroups;
		&applyPartPerUVGroup;
		&cleanup;
	}
	elsif ($arg eq "randomizeUVs"){
		&safetyChecks;
		&selectVmap;
		&splitUVGroups;
		&randomizeUVs;
		&restoreSelection;
		&cleanup;
	}
	elsif ($arg eq "openClipsInPhotoshop"){
		&validateGameDir;
		&openClipsInPhotoshop;
	}
	elsif ($arg eq "flattenDiscoUVs"){
		&selectVmap;
		&flattenDiscoUVs;
	}
	elsif ($arg eq "sortMaterials"){
		&sortMaterials;
	}
	elsif ($arg eq "quantizePresets"){
		&quantizePresets;
	}
	elsif ($arg eq "polySew"){
		&safetyChecks;
		&selectVmap;
		&splitUVGroups;
		&polySew;
		&cleanup;
	}
	elsif ($arg eq "sendPolyImagesToPS"){
		&sendPolyImagesToPS;
	}
	elsif ($arg eq "CL_selectThesePolys"){
		&validateGameDir;
		&CL_selectThesePolys;
	}
	elsif ($arg eq "uvBufferFit"){
		if (lx("select.count polygon ?") == 0){die("\\\\n.\\\\n[---------------------------------------------You don't have any polys selected, so I'm killing the script.--------------------------------------------]\\\\n[--PLEASE TURN OFF THIS WARNING WINDOW by clicking on the (In the future) button and choose (Hide Message)--] \\\\n[-----------------------------------This window is not supposed to come up, but I can't control that.---------------------------]\\\\n.\\\\n");}
		&safetyChecks;
		&selectVmap;
		&splitUVGroups;
		&uvBufferFit;
		&restoreSelection;
		&cleanup;
	}
	elsif ($arg eq "searchMaterialsAndApply"){
		&applySearchFoundMaterial;
	}
	elsif ($arg eq "scaleMeshesToPixelSize"){
		&validateGameDir;
		&safetyChecks;
		&selectVmap;
		&clipSizeList;
		&splitPolysIntoTexSizeGroups;
		&scaleMeshesToPixelSize;
		if ($meshCount > 1){&restoreSelection;}
		&cleanup;
	}elsif ($arg eq "scaleToPixelSize"){
		&validateGameDir;
		&safetyChecks;
		&selectVmap;
		&clipSizeList;
		&splitPolysIntoTexSizeGroups;
		&scaleToPixelSize;
		&restoreSelection;
		&cleanup;
	}elsif ($arg eq "openDirInExplorer"){
		&openDirInExplorer;
	}elsif ($arg eq "deleteTheseClips"){
		&deleteTheseClips;
	}elsif ($arg eq "openPSDsInPhotoshop"){
		&openPSDsInPhotoshop;
	}elsif ($arg eq "openSpecificImageInPS"){
		&validateGameDir;
		&openSpecificImageInPS;
	}elsif ($arg eq "checkoutTrue"){
		our $checkoutClips = 1;
	}elsif ($arg eq "checkoutClips"){
		&checkoutClips;
	}elsif ($arg eq "clip_selectMaterials"){
		&validateGameDir;
		&clip_selectMaterials;
	}elsif ($arg eq "moveOneUnit"){
		&safetyChecks;
		&moveOneUnit;
		&cleanup;
	}elsif ($arg eq "repairMissingMaterials"){
		&validateGameDir;
		&repairMissingMaterials;
		&selectVmap;
		&repair_shaders;
		&fixFacetMaterials(@newlyCreatedPtags);
		if (($modoVer > 300) &&($selected != 1)){&deleteUnusedTxLocators;}
	}elsif ($arg eq "uvHotSpotTool"){
		&validateGameDir;
		&hotSpotTextFileInitialization;
		if (($U != 1) && ($V != 1)){
			&safetyChecks;
			&selectVmap;
			&splitUVGroups;
		}
		&uvHotSpotTool;
		if (($U != 1) && ($V != 1)){
			&restoreSelection;
			&cleanup;
		}
	}elsif ($arg eq "saveMeshPresets"){
		our $saveMesh = 1;
		our $up = 1;
		&validateGameDir;
		&saveMeshPresets;
	}elsif ($arg eq "fixFacetMaterials"){
		&validateGameDir;
		&fixFacetMaterials;
	}elsif ($arg eq "uvDistMerge"){
		&selectVmap;
		&uvDistMerge;
	}elsif ($arg eq "viewUVIslands"){
		&safetyChecks;
		&selectVmap;
		&splitUVGroups;
		&viewUVIslands;
	}elsif ($arg eq "barycentric"){
		&selectVmap;
		&barycentric;
	}elsif ($arg eq "applyMatrPerIsland"){
		&safetyChecks;
		if (@polys == 0){@polys = lxq("query layerservice polys ? all");}
		&selectVmap;
		&splitUVGroups;
		&applyMatrPerIsland;
	}
}





#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#HOT SPOT TEXT FILE INITIALIZATION
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub hotSpotTextFileInitialization{
	if (($V == 1) || ($X == 1)){
		if ((-e $hotSpotFile) && (!-W $hotSpotFile)){	system("p4 edit \"$hotSpotFile\"");										}
	}elsif (!-e $hotSpotFile)						{	die("This uv hotspot locations file does not exist! : $hotSpotFile");	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SAFETY CHECKS (all are modded so you can turn off various parts if needed)
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#usage : safetyChecks();  or safetyChecks(skipPolys,skipSymm,skipWorkplane,skipActr);
sub safetyChecks{
	foreach my $arg (@_){
		if		($arg =~ /skipPolys/i)		{	our $skipPolys = 1;		}
		elsif	($arg =~ /skipSymm/i)		{	our $skipSymm = 1;		}
		elsif	($arg =~ /skipWorkplane/i)	{	our $skipWorkplane = 1;	}
		elsif	($arg =~ /skipActr/i)		{	our $skipActr = 1;		}
	}

	#polys
	our @polys;
	our @xPolys;
	our @yPolys;
	our @zPolys;
	if ($skipPolys != 1){
		@polys = lxq("query layerservice polys ? selected");
	}

	#symmetry
	our $symmAxis = lxq("select.symmetryState ?");
	if ($skipSymm != 1){
		if ($symmAxis ne "none"){
			lx("select.symmetryState none");
		}
	}

	#Remember what the workplane was and turn it off
	our @WPmem;
	if ($skypWorkplane != 1){
		@WPmem[0] = lxq ("workPlane.edit cenX:? ");
		@WPmem[1] = lxq ("workPlane.edit cenY:? ");
		@WPmem[2] = lxq ("workPlane.edit cenZ:? ");
		@WPmem[3] = lxq ("workPlane.edit rotX:? ");
		@WPmem[4] = lxq ("workPlane.edit rotY:? ");
		@WPmem[5] = lxq ("workPlane.edit rotZ:? ");
		lx("workPlane.reset ");
	}

	#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	#REMEMBER SELECTION SETTINGS and then set it to selectauto  ((MODO2 FIX))
	#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	#sets the ACTR preset
	our $seltype;
	our $selAxis;
	our $selCenter;
	our $actr = 1;

	if ($skipActr != 1){
		if( lxq( "tool.set actr.select ?") eq "on")				{	$seltype = "actr.select";		}
		elsif( lxq( "tool.set actr.selectauto ?") eq "on")		{	$seltype = "actr.selectauto";	}
		elsif( lxq( "tool.set actr.element ?") eq "on")			{	$seltype = "actr.element";		}
		elsif( lxq( "tool.set actr.screen ?") eq "on")			{	$seltype = "actr.screen";		}
		elsif( lxq( "tool.set actr.origin ?") eq "on")			{	$seltype = "actr.origin";		}
		elsif( lxq( "tool.set actr.local ?") eq "on")			{	$seltype = "actr.local";		}
		elsif( lxq( "tool.set actr.pivot ?") eq "on")			{	$seltype = "actr.pivot";		}
		elsif( lxq( "tool.set actr.auto ?") eq "on")			{	$seltype = "actr.auto";			}
		else
		{
			$actr = 0;
			lxout("custom Action Center");
			if( lxq( "tool.set axis.select ?") eq "on")			{	 $selAxis = "select";			}
			elsif( lxq( "tool.set axis.element ?") eq "on")		{	 $selAxis = "element";			}
			elsif( lxq( "tool.set axis.view ?") eq "on")		{	 $selAxis = "view";				}
			elsif( lxq( "tool.set axis.origin ?") eq "on")		{	 $selAxis = "origin";			}
			elsif( lxq( "tool.set axis.local ?") eq "on")		{	 $selAxis = "local";			}
			elsif( lxq( "tool.set axis.pivot ?") eq "on")		{	 $selAxis = "pivot";			}
			elsif( lxq( "tool.set axis.auto ?") eq "on")		{	 $selAxis = "auto";				}
			else												{	 $actr = 1;  $seltype = "actr.auto"; lxout("You were using an action AXIS that I couldn't read");}

			if( lxq( "tool.set center.select ?") eq "on")		{	 $selCenter = "select";			}
			elsif( lxq( "tool.set center.element ?") eq "on")	{	 $selCenter = "element";		}
			elsif( lxq( "tool.set center.view ?") eq "on")		{	 $selCenter = "view";			}
			elsif( lxq( "tool.set center.origin ?") eq "on")	{	 $selCenter = "origin";			}
			elsif( lxq( "tool.set center.local ?") eq "on")		{	 $selCenter = "local";			}
			elsif( lxq( "tool.set center.pivot ?") eq "on")		{	 $selCenter = "pivot";			}
			elsif( lxq( "tool.set center.auto ?") eq "on")		{	 $selCenter = "auto";			}
			else												{ 	 $actr = 1;  $seltype = "actr.auto"; lxout("You were using an action CENTER that I couldn't read");}
		}
		lx("tool.set actr.auto on");
	}
}




#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#REMEMBER TOOL SUB
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub rememberTool{
	if		(lxq( "tool.set xfrm.move ?") eq "on")			{	our $tool = "xfrm.move";			our $restoreTool = 1;		}
	elsif	(lxq("tool.set xfrm.rotate ?") eq "on")			{	our $tool = "xfrm.rotate";			our $restoreTool = 1;		}
	elsif 	(lxq("tool.set xfrm.stretch ?") eq "on")		{	our $tool = "xfrm.stretch";			our $restoreTool = 1;		}
	elsif 	(lxq("tool.set xfrm.scale ?") eq "on")			{	our $tool = "xfrm.scale";			our $restoreTool = 1;		}
	elsif	(lxq("tool.set Transform ?") eq "on")			{	our $tool = "Transform";			our $restoreTool = 1; 		}
	elsif	(lxq("tool.set TransformMove ?") eq "on")		{	our $tool = "TransformMove";		our $restoreTool = 1;		}
	elsif	(lxq("tool.set TransformRotate ?") eq "on")		{	our $tool = "TransformRotate";		our $restoreTool = 1;		}
	elsif	(lxq("tool.set TransformScale ?") eq "on")		{	our $tool = "TransformScale";		our $restoreTool = 1;		}
	elsif	(lxq("tool.set TransformUScale ?") eq "on")		{	our $tool = "TransformUScale";		our $restoreTool = 1;		}
}



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SELECT THE PROPER VMAP  #MODO301
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub selectVmap{
	my $vmaps = lxq("query layerservice vmap.n ? all");
	my %uvMaps;
	my @selectedUVmaps;
	my $finalVmap;

	lxout("-Checking which uv maps to select or deselect");

	for (my $i=0; $i<$vmaps; $i++){
		if (lxq("query layerservice vmap.type ? $i") eq "texture"){
			if (lxq("query layerservice vmap.selected ? $i") == 1){push(@selectedUVmaps,$i);}
			my $name = lxq("query layerservice vmap.name ? $i");
			$uvMaps{$i} = $name;
		}
	}

	#ONE SELECTED UV MAP
	if (@selectedUVmaps == 1){
		lxout("     -There's only one uv map selected <> $uvMaps{@selectedUVmaps[0]}");
		$finalVmap = @selectedUVmaps[0];
	}

	#MULTIPLE SELECTED UV MAPS  (try to select "Texture")
	elsif (@selectedUVmaps > 1){
		my $foundVmap;
		foreach my $vmap (@selectedUVmaps){
			if ($uvMaps{$vmap} eq "Texture"){
				$foundVmap = $vmap;
				last;
			}
		}
		if ($foundVmap != "")	{
			lx("!!select.vertexMap $uvMaps{$foundVmap} txuv replace");
			lxout("     -There's more than one uv map selected, so I'm deselecting all but this one <><> $uvMaps{$foundVmap}");
			$finalVmap = $foundVmap;
		}
		else{
			lx("!!select.vertexMap $uvMaps{@selectedUVmaps[0]} txuv replace");
			lxout("     -There's more than one uv map selected, so I'm deselecting all but this one <><> $uvMaps{@selectedUVmaps[0]}");
			$finalVmap = @selectedUVmaps[0];
		}
	}

	#NO SELECTED UV MAPS (try to select "Texture" or create it)
	elsif (@selectedUVmaps == 0){
		lx("!!select.vertexMap Texture txuv replace") or $fail = 1;
		if ($fail == 1){
			lx("!!vertMap.new Texture txuv {0} {0.78 0.78 0.78} {1.0}");
			lxout("     -There were no uv maps selected and 'Texture' didn't exist so I created this one. <><> Texture");
		}else{
			lxout("     -There were no uv maps selected, but 'Texture' existed and so I selected this one. <><> Texture");
		}

		my $vmaps = lxq("query layerservice vmap.n ? all");
		for (my $i=0; $i<$vmaps; $i++){
			if (lxq("query layerservice vmap.name ? $i") eq "Texture"){
				$finalVmap = $i;
			}
		}
	}

	#ask the name of the vmap just so modo knows which to query.
	my $name = lxq("query layerservice vmap.name ? $finalVmap");
}



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SPLIT THE POLYGONS INTO TOUCHING UV GROUPS (and build the uvBBOX)
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub splitUVGroups{
	lxout("[->] Running splitUVGroups subroutine");
	our %touchingUVList = ();
	our %uvBBOXList = ();
	my %originalPolys;
	my %vmapTable;
	my @scalePolys = @polys;
	my $round = 0;
	foreach my $poly (@scalePolys){
		$originalPolys{$poly} = 1;
	}

	#---------------------------------------------------------------------------------------
	#LOOP1
	#---------------------------------------------------------------------------------------
	#[1] :	(create a current uvgroup array) : (add the first poly to it) : (set 1stpoly to 1 in originalpolylist) : (build uv list for it)
	while (@scalePolys != 0){
		#setup
		my %ignorePolys = ();
		my %totalPolyList;
		my @uvGroup = @scalePolys[0];
		my @nextList = @scalePolys[0];
		my $loop = 1;
		my @verts = lxq("query layerservice poly.vertList ? @scalePolys[0]");
		my @vmapValues = lxq("query layerservice poly.vmapValue ? @scalePolys[0]");
		my %vmapDiscoTable = ();
		$totalPolyList{@scalePolys[0]} = 1;
		$ignorePolys{@scalePolys[0]} = 1;

		#clear the vmapTable for every round and start it from scratch
		%vmapTable = ();
		for (my $i=0; $i<@verts; $i++){
			$vmapTable{@verts[$i]}[0] = @vmapValues[$i*2];
			$vmapTable{@verts[$i]}[1] = @vmapValues[($i*2)+1];
		}

		#build the temp uvBBOX
		my @tempUVBBOX = (999999999,999999999,-999999999,-999999999); #I'm pretty sure this'll never be capped.
		$uvBBOXList{$round} = \@tempUVBBOX;

		#put the first poly's uvs into the bounding box.
		for (my $i=0; $i<@verts; $i++){
			if ( @vmapValues[$i*2] 		< 	$uvBBOXList{$round}[0] )	{	$uvBBOXList{$round}[0] = @vmapValues[$i*2];		}
			if ( @vmapValues[($i*2)+1]	< 	$uvBBOXList{$round}[1] )	{	$uvBBOXList{$round}[1] = @vmapValues[($i*2)+1];	}
			if ( @vmapValues[$i*2] 		> 	$uvBBOXList{$round}[2] )	{	$uvBBOXList{$round}[2] = @vmapValues[$i*2];		}
			if ( @vmapValues[($i*2)+1]	> 	$uvBBOXList{$round}[3] )	{	$uvBBOXList{$round}[3] = @vmapValues[($i*2)+1];	}
		}



		#---------------------------------------------------------------------------------------
		#LOOP2
		#---------------------------------------------------------------------------------------
		while ($loop == 1){
			#[1] :	(make a list of the verts on nextlist's polys) :
			my %vertList;
			my %newPolyList;
			foreach my $poly (@nextList){
				my @verts = lxq("query layerservice poly.vertList ? $poly");
				$vertList{$_} = 1 for @verts;
			}

			#clear nextlist for next round
			@nextList = ();


			#[2] :	(make a newlist of the polys connected to the verts) :
			foreach my $vert (keys %vertList){
				my @vertListPolys = lxq("query layerservice vert.polyList ? $vert");

				#(ignore the ones that are [1] in the originalpolyList or not in the list)
				foreach my $poly (@vertListPolys){
					if (($originalPolys{$poly} == 1) && ($ignorePolys{$poly} != 1)){
						$newPolyList{$poly} = 1;
						$totalPolyList{$poly} = 1;
					}
				}
			}


			#[3] :	(go thru all the polys in the new newlist and see if their uvs are touching the newlist's uv list) : (if they are, add 'em to the uvgroup and nextlist) :
			#(build the uv list for the newlist) : (add 'em to current uvgroup array)
			foreach my $poly (keys %newPolyList){
				my @verts = lxq("query layerservice poly.vertList ? $poly");
				my @vmapValues = lxq("query layerservice poly.vmapValue ? $poly");
				my $last;

				for (my $i=0; $i<@verts; $i++){
					if ($last == 1){last;}

					for (my $j=0; $j<@{$vmapTable{@verts[$i]}}; $j=$j+2){
						#if this poly's matching so add it to the poly lists.
						if ("(@vmapValues[$i*2],@vmapValues[($i*2)+1])" eq "(@{$vmapTable{@verts[$i]}}[$j],@{$vmapTable{@verts[$i]}}[$j+1])"){
							push(@uvGroup,$poly);
							push(@nextList,$poly);
							$ignorePolys{$poly} = 1;

							#this poly's matching so i'm adding it's uvs to the uv list
							for (my $u=0; $u<@verts; $u++){
								if ($vmapDiscoTable{@verts[$u].",".@vmapValues[$u*2].",".@vmapValues[($u*2)+1]} != 1){
									push(@{$vmapTable{@verts[$u]}} , @vmapValues[$u*2]);
									push(@{$vmapTable{@verts[$u]}} , @vmapValues[($u*2)+1]);
									$vmapDiscoTable{@verts[$u].",".@vmapValues[$u*2].",".@vmapValues[($u*2)+1]} = 1;
								}
							}

							#this poly's matching, so I'll create the uvBBOX right now.
							for (my $i=0; $i<@verts; $i++){
								if ( @vmapValues[$i*2] 		< 	$uvBBOXList{$round}[0] )	{	$uvBBOXList{$round}[0] = @vmapValues[$i*2];		}
								if ( @vmapValues[($i*2)+1]	< 	$uvBBOXList{$round}[1] )	{	$uvBBOXList{$round}[1] = @vmapValues[($i*2)+1];	}
								if ( @vmapValues[$i*2] 		> 	$uvBBOXList{$round}[2] )	{	$uvBBOXList{$round}[2] = @vmapValues[$i*2];		}
								if ( @vmapValues[($i*2)+1]	> 	$uvBBOXList{$round}[3] )	{	$uvBBOXList{$round}[3] = @vmapValues[($i*2)+1];	}
							}
							$last = 1;
							last;
						}
					}
				}
			}

			#This round of UV grouping is done.  Time for the next round.
			if (@nextList == 0){
				$touchingUVList{$round} = \@uvGroup;
				$round++;
				$loop = 0;
				@scalePolys = removeListFromArray(\@scalePolys, \@uvGroup);
			}
		}
	}

	my $keyCount = (keys %touchingUVList);
	lxout("     -There are ($keyCount) uv groups");
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#UV HOT SPOT CREATE OR SAVE OR USE TOOL
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub uvHotSpotTool{
	#==================================================================
	#A : BUILD UV HOT SPOT POLY----------------------------------------
	#==================================================================
	if ($U == 1){
		#select clip and find size
		my $clips = lxq("query layerservice clip.n ? all");
		my @selectedClips;
		for (my $i=0; $i<$clips; $i++){
			if (lxq("query sceneservice clip.isSelected ? $i") == 1){
				push(@selectedClips,$i);
			}
		}

		if (@selectedClips == 0){
			lx("clip.load");
			if (lxres != 0){	die("The user hit the cancel button");	}
			@selectedClips = lxq("query layerservice clip.n ? all") - 1;
		}

		my $clipFile = lxq("query layerservice clip.file ? {$selectedClips[-1]}");
		my $clipInfo = lxq("query layerservice clip.info ? {$selectedClips[-1]}");
		my @clipSize = split(/\D+/, $clipInfo);
		my $width = @clipSize[1];
		my $height = @clipSize[2];
		if (($sene_jpgHalfSize == 1) && (($clipFile =~ /.jpg/i) || ($clipFile =~ /.jpeg/i))){
			$width *= 4;
			$height *= 4;
		}
		my @cubeCenter = ($width * .5 , $height * .5);


		#build plane
		lx("scene.new");
		lx("tool.set prim.cube on");
		lx("tool.setAttr prim.cube cenX {$cubeCenter[0]}");
		lx("tool.setAttr prim.cube sizeX {$width}");
		lx("tool.setAttr prim.cube cenY {$cubeCenter[1]}");
		lx("tool.setAttr prim.cube sizeY {$height}");
		lx("tool.setAttr prim.cube cenZ 0.5");
		lx("tool.setAttr prim.cube sizeZ 0.0");
		lx("tool.setAttr prim.cube axis 2");
		lx("tool.doApply");
		lx("tool.set prim.cube off");
		lx("poly.flip");

		#apply texture
		shaderTreeTools(buildDbase);
		lx("texture.new {$clipFile}");
		lx("texture.parent {@{$shaderTreeIDs{polyRender}}[0]} [-1]");
		if ($sene_sutImageAA == 0){
			lx("item.channel imageMap\$aa false");
			lx("item.channel imageMap\$pixBlend $pixBlend");
		}
		lx("select.element $mainlayer polygon set 0");
		lx("uv.rotate");
		lx("viewport.fitSelected");
		lx("poly.setPart ref");
	}


	#==================================================================
	#B : STORE TO A REFERENCE------------------------------------------
	#==================================================================
	elsif ($X == 1){
		#TEMP : put in the image browser window
	}



	#==================================================================
	#C : STORE VALUES FROM POLYS---------------------------------------
	#==================================================================
	elsif ($V == 1){
		my @shaderText;
		my $clipFile = lxq("query layerservice clip.file ? 0");
		my $clipInfo = lxq("query layerservice clip.info ? 0");
		my @clipSize = split(/\D+/, $clipInfo);

		#whether or not we should shrink the bboxes.
		my $pixelAmount = quickDialog("Shrink by how many pixels?",float,0,"","");

		#whether to use alg A or B
		my $alg = quickDialog("Use which algorithm?\n \nA = Resolution important\nB = Aspect Ratio important",string,A,"","");
		while (1){
			if ($alg =~ /a/i){
				$alg = a;
				last;
			}elsif ($alg =~ /b/i){
				$alg = b;
				last;
			}else{
				popup("ERROR : You didn't type in 'A' or 'B' \n \nThis script is asking you which algorithm should be used.\nA = good for textures that cover all the bbox size spectrums evenly\nB = good for textures that have random uv bbox sizes with large gaps");
				$alg = quickDialog("Use which algorithm?\n \nA = Even distribution\nB = Uneven distribution",string,A,"","");
			}
		}

		#whether to allow randomizations or not
		my $allowTextureFlipping = quickDialog("Randomized texture flipping:\n \nU and/or V = 'UV'\nHorizontal Only = 'U'\nVertical only = 'V'",string,"UV","","");
		if 		(($allowTextureFlipping =~ /u/i) && ($allowTextureFlipping =~ /v/i))	{	$allowTextureFlipping = "UV";	}
		elsif	($allowTextureFlipping =~ /u/i)											{	$allowTextureFlipping = "U";	}
		else																			{	$allowTextureFlipping = "V";	}

		#find bboxes
		selectVmap();
		my @polys = lxq("query layerservice polys ? visible");
		my %uvBBOXTable;
		my $count = 0;
		foreach my $poly (@polys){
			$count++;
			my @uvBBOX = uvBBOX($poly); #(bboxcenter,bbox)
			if ( ($uvBBOX[2] < .1) && ($uvBBOX[3] < .1) && ($uvBBOX[4] > .9) && ($uvBBOX[5] > .9) ){
				lxout("skipping this polygon because it's taking up the whole uv pane : (poly $poly)");
				next;
			}

			if ($pixelAmount != 0){
				my $reduceU = (1 / $clipSize[1]) * $pixelAmount;
				my $reduceV = (1 / $clipSize[2]) * $pixelAmount;
				$uvBBOX[2] += $reduceU * .5;
				$uvBBOX[3] += $reduceV * .5;
				$uvBBOX[4] -= $reduceU * .5;
				$uvBBOX[5] -= $reduceV * .5;
			}

			my $width = $uvBBOX[4] - $uvBBOX[2];
			my $height = $uvBBOX[5] - $uvBBOX[3];

			if ($width > $height){
				@{$uvBBOXTable{$width + 0.00000001*$count}} = ($width, $height, $uvBBOX[2], $uvBBOX[3], $uvBBOX[4], $uvBBOX[5], "U");
			}else{
				@{$uvBBOXTable{$height + 0.00000001*$count}} = ($height, $width, $uvBBOX[2], $uvBBOX[3], $uvBBOX[4], $uvBBOX[5], "V");
			}
		}

		#do a 2d sort of the uvbbox values
		my @uvBBOXSortList = keys %uvBBOXTable;
		@uvBBOXSortList = sort { $a <=> $b } @uvBBOXSortList;
		for (my $i=0; $i<@uvBBOXSortList; $i++){
			my $u = 1;
			while ($u <= $i){
				if ( (@{$uvBBOXTable{@uvBBOXSortList[$i]}}[0] <= @{$uvBBOXTable{@uvBBOXSortList[$i-$u]}}[0]) && (@{$uvBBOXTable{@uvBBOXSortList[$i]}}[1] < @{$uvBBOXTable{@uvBBOXSortList[$i-$u]}}[1]) ){
					$u++;
				}else{
					last;
				}
			}
			if ($u > 1){
				my $temp = $uvBBOXSortList[$i];
				splice(@uvBBOXSortList, $i, 1);
				splice(@uvBBOXSortList, $i-($u-1), 0, $temp);
			}
		}

		#write out the values
		OSPathNameFix($clipFile);
		my $clipName = clipNameFix($clipFile);
		push(@shaderText, "\tProperties line:algorithm=$alg,UVflipping=$allowTextureFlipping");
		foreach my $key (@uvBBOXSortList ){
			my $textLine = @{$uvBBOXTable{$key}}[0] .",". @{$uvBBOXTable{$key}}[1] .",". @{$uvBBOXTable{$key}}[2].",". @{$uvBBOXTable{$key}}[3].",". @{$uvBBOXTable{$key}}[4].",". @{$uvBBOXTable{$key}}[5].",".@{$uvBBOXTable{$key}}[6];
			push(@shaderText,"\t" . $textLine);
		}
		writeNewOrReplaceShader($clipName,\@shaderText,$hotSpotFile,"write");
	}

	#==================================================================
	#D : EDIT VALUES---------------------------------------------------
	#==================================================================
	elsif ($prop == 1){
		#select clip and find size
		my $clips = lxq("query layerservice clip.n ? all");
		my @selectedClips;
		for (my $i=0; $i<$clips; $i++){
			if (lxq("query sceneservice clip.isSelected ? $i") == 1){
				push(@selectedClips,$i);
			}
		}

		if (@selectedClips == 0){
			lx("clip.load");
			if (lxres != 0){	die("The user hit the cancel button");	}
			@selectedClips = lxq("query layerservice clip.n ? all") - 1;
		}

		my $clipFile = lxq("query layerservice clip.file ? {$selectedClips[-1]}");
		my $clipInfo = lxq("query layerservice clip.info ? {$selectedClips[-1]}");
		my @clipSize = split(/\D+/, $clipInfo);
		my $width = @clipSize[1];
		my $height = @clipSize[2];
		if (($sene_jpgHalfSize == 1) && (($clipFile =~ /.jpg/i) || ($clipFile =~ /.jpeg/i))){
			$width *= 4;
			$height *= 4;
		}
		my @cubeCenter = ($width * .5 , $height * .5);

		#build plane
		lx("scene.new");
		lx("tool.set prim.cube on");
		lx("tool.setAttr prim.cube cenX {$cubeCenter[0]}");
		lx("tool.setAttr prim.cube sizeX {$width}");
		lx("tool.setAttr prim.cube cenY {$cubeCenter[1]}");
		lx("tool.setAttr prim.cube sizeY {$height}");
		lx("tool.setAttr prim.cube cenZ 0.5");
		lx("tool.setAttr prim.cube sizeZ 0.0");
		lx("tool.setAttr prim.cube axis 2");
		lx("tool.doApply");
		lx("tool.set prim.cube off");
		lx("poly.flip");

		#apply texture
		shaderTreeTools(buildDbase);
		lx("texture.new {$clipFile}");
		lx("texture.parent {@{$shaderTreeIDs{polyRender}}[0]} [-1]");
		if ($sene_sutImageAA == 0){
			lx("item.channel imageMap\$aa false");
			lx("item.channel imageMap\$pixBlend $pixBlend");
		}
		lx("select.element $mainlayer polygon set 0");
		lx("uv.rotate");
		lx("viewport.fitSelected");
		lx("poly.setPart ref");

		#find material
		my $material = $clipFile;
		OSPathNameFix($material);
		$material =~ s/$sene_matRepairPath//i;
		$material =~ s/\..*//;
		my $shaderTextArrayRef = writeNewOrReplaceShader($material,"void",$hotSpotFile,"read");
		my $errorPrintMaterial = $material;

		if (${$shaderTextArrayRef}[1] =~ /reference/i){
			${$shaderTextArrayRef}[1] =~ s/reference : //i;	#nuke reference :
			${$shaderTextArrayRef}[1] =~ s/^[\s\t]*//; 		#nuke beginning spaces
			${$shaderTextArrayRef}[1] =~ s/[\t\s]*$//; 		#nuke trailing spaces
			${$shaderTextArrayRef}[1] =~ s/[\{\}]//g;  		#nuke brackets
			chomp(${$shaderTextArrayRef}[1]);
			$shaderTextArrayRef = writeNewOrReplaceShader(@{$shaderTextArrayRef}[1],"void",$hotSpotFile,"read");
			$errorPrintMaterial = @{$shaderTextArrayRef}[1];
		}

		#get rid of tabs and spaces
		for (my $i=0; $i<@{$shaderTextArrayRef}; $i++){${$shaderTextArrayRef}[$i] =~ s/[\t\s]//g;}

		if ($shaderTextArrayRef == 0){
			lxout("[->] : Skipping this material because I couldn't find it's uv hotspot shader : $errorPrintMaterial");
			next;
		}

		#build planes
		for (my $i=2; $i<@{$shaderTextArrayRef}; $i++){
			my @values = split(/,/, @{$shaderTextArrayRef}[$i]);
			my @planeCenter = ( ($values[2]+$values[4])*$width*.5 , ($values[3]+$values[5])*$height*.5);
			my $planeWidth = ($values[4] - $values[2]) * $width;
			my $planeHeight = ($values[5] - $values[3]) * $height;

			lx("tool.set prim.cube on");
			lx("tool.setAttr prim.cube cenX {$planeCenter[0]}");
			lx("tool.setAttr prim.cube sizeX {$planeWidth}");
			lx("tool.setAttr prim.cube cenY {$planeCenter[1]}");
			lx("tool.setAttr prim.cube sizeY {$planeHeight}");
			lx("tool.setAttr prim.cube cenZ 0.0");
			lx("tool.setAttr prim.cube sizeZ 0.0");
			lx("tool.setAttr prim.cube axis 2");
			lx("tool.doApply");
			lx("tool.set prim.cube off");
		}

		#uv planes
		lx("select.type polygon");
		lx("select.all");
		lx("tool.set uv.create on");
		lx("tool.reset");
		lx("tool.attr uv.create mode manual");
		lx("tool.attr uv.create proj planar");
		lx("tool.attr uv.create axis 2");
		lx("tool.attr uv.create sizX {$width}");
		lx("tool.attr uv.create sizY {$height}");
		lx("tool.attr uv.create sizZ {0.5}");
		lx("tool.attr uv.create cenX {$cubeCenter[0]}");
		lx("tool.attr uv.create cenY {$cubeCenter[1]}");
		lx("tool.attr uv.create cenZ {$cubeCenter[2]}");
		lx("tool.doApply");
		lx("tool.set uv.create off");
	}

	#==================================================================
	#E : USE VALUES----------------------------------------------------
	#==================================================================
	else{

		#group the selected polys per material
		my $perc = 0.05;
		my %polyMaterialTable;
		my @polys = lxq("query layerservice polys ? selected");
		foreach my $poly (@polys){
			my $material = lxq("query layerservice poly.material ? $poly");
			push(@{$polyMaterialTable{$material}},$poly);
		}


		#uv applications done per material.
		foreach my $material (keys %polyMaterialTable){
			lxout("======================================================");
			lxout("material = $material");
			lxout("======================================================");

			my %uvBBOXTable;
			my %uvBBOXTableTree;
			my @uvBBOXSortList;
			my $shaderTextArrayRef = writeNewOrReplaceShader($material,"void",$hotSpotFile,"read");
			my $errorPrintMaterial = $material;

			if (${$shaderTextArrayRef}[1] =~ /reference/i){
				${$shaderTextArrayRef}[1] =~ s/reference : //i;	#nuke reference :
				${$shaderTextArrayRef}[1] =~ s/^[\s\t]*//; 		#nuke beginning spaces
				${$shaderTextArrayRef}[1] =~ s/[\t\s]*$//; 		#nuke trailing spaces
				${$shaderTextArrayRef}[1] =~ s/[\{\}]//g;  		#nuke brackets
				chomp(${$shaderTextArrayRef}[1]);
				$shaderTextArrayRef = writeNewOrReplaceShader(@{$shaderTextArrayRef}[1],"void",$hotSpotFile,"read");
				$errorPrintMaterial = @{$shaderTextArrayRef}[1];
			}

			#get rid of tabs and spaces
			for (my $i=0; $i<@{$shaderTextArrayRef}; $i++){${$shaderTextArrayRef}[$i] =~ s/[\t\s]//g;}

			if ($shaderTextArrayRef == 0){
				lxout("[->] : Skipping this material because I couldn't find it's uv hotspot shader : $errorPrintMaterial");
				next;
			}

			#determine algorithm A or B
			my $valuesLine = ${$shaderTextArrayRef}[1];
			$valuesLine =~ s/.*://i;
			my @valueArray = split(/,/, $valuesLine);
			foreach my $value (@valueArray){
				if ($value =~ /algorithm/i){
					our $alg = $value;
					$alg =~ s/algorithm=//;
					lxout("[->] : Using algorithm $alg on $material");
					last;
				}
			}

			#determine flipping axes
			foreach my $value (@valueArray){
				if ($value =~ /UVflipping/i){
					our $flipAxes = $value;
					$flipAxes =~ s/UVflipping=//;
					lxout("[->] : Using flip axis : $flipAxes");
					last;
				}
			}
			if ($flipAxes eq ""){our $flipAxes = "UV";}


			#build uvbbox tables
			for (my $i=2; $i<@{$shaderTextArrayRef}; $i++){
				my @words = split(/,/, ${$shaderTextArrayRef}[$i]);
				my $uniqueKey = $words[0] + 0.00000001 * $i;
				@{$uvBBOXTable{$uniqueKey}} = @words;
				push(@uvBBOXSortList,$uniqueKey);
			}

			#build uvbbox tree (width)
			my %todoList;
			my $todoListArrayVal = 0;
			my $currentWidth = @{$uvBBOXTable{@uvBBOXSortList[0]}}[0];
			my $count = 0;
			for (my $i=0; $i<@uvBBOXSortList; $i++){
				if ( abs(1 - ($currentWidth /  @{$uvBBOXTable{@uvBBOXSortList[$i+$u]}}[0])) <= $perc ){
					push(@{$todoList{$count}},$i);
				}else{
					$count++;
					push(@{$todoList{$count}},$i);
					$currentWidth = @{$uvBBOXTable{$uvBBOXSortList[$i]}}[0];
					$todoListArrayVal++;
				}
			}

			#build uvbbox tree (height)
			foreach my $key (keys %todoList){
				my $keyCount = @{$todoList{$key}};
				my $width =		@{$uvBBOXTable{@uvBBOXSortList[@{$todoList{$key}}[0]]}}[0];
				my $height =	@{$uvBBOXTable{@uvBBOXSortList[@{$todoList{$key}}[0]]}}[1];

				for (my $i=0; $i<@{$todoList{$key}}; $i++){
					my $heightA = @{$uvBBOXTable{@uvBBOXSortList[@{$todoList{$key}}[$i]]}}[1];
					#lxout("heightA = $heightA");

					if (abs(1 - ($height / $heightA)) <= $perc){
						#lxout("   $key : yes <> $height <> $heightA");
						push(@{$uvBBOXTableTree{$width}{$height}} , \@{$uvBBOXTable{@uvBBOXSortList[@{$todoList{$key}}[$i]]}});
					}else{
						#lxout("   $key : no <> $height <> $heightA");
						$height = $heightA;
						push(@{$uvBBOXTableTree{$width}{$height}} , \@{$uvBBOXTable{@uvBBOXSortList[@{$todoList{$key}}[$i]]}});
					}
				}
			}

			#now move/scale each uv island, but skip the ones that aren't using this material
			foreach my $key (keys %touchingUVList){
				my $uvGroupMaterial = lxq("query layerservice poly.material ? @{$touchingUVList{$key}}[0]");
				if ($material ne $uvGroupMaterial){ next; }
				my $longSide;
				my $shortSide;
				my $rotate = 0;
				my $width = @{$uvBBOXList{$key}}[2] - @{$uvBBOXList{$key}}[0];
				my $height = @{$uvBBOXList{$key}}[3] - @{$uvBBOXList{$key}}[1];
				if ($width == 0){$width = .001;}
				if ($height == 0){$height = .001;}
				my @center = ( ((@{$uvBBOXList{$key}}[2] + @{$uvBBOXList{$key}}[0]) * .5) , ((@{$uvBBOXList{$key}}[3] + @{$uvBBOXList{$key}}[1]) * .5) );
				my @move;
				my @scale;
				my $rotateAmount = 0;

				if ($width > $height){
					$longSide = $width;
					$shortSide = $height;
				}else{
					$longSide = $height;
					$shortSide = $width;
					$rotate = 1;
				}

				my $closestWidthKey = 9999999999;
				my $closestHeightKey = 9999999999;
				#find the closest uvbbox algorithm A
				if ($alg =~ /a/i){
					my $diffA = 9999999999;
					my $diffB = 9999999999;

					foreach my $keyA (keys %uvBBOXTableTree){
						if ( abs($keyA - $longSide) < $diffA){
							$diffA = abs($keyA - $longSide);
							$closestWidthKey = $keyA;
							#lxout("yes : keyA=$keyA <> width=$longSide");
						}else{
							#lxout("no  : keyA=$keyA <> width=$longSide");
						}
					}

					foreach my $keyB (keys %{$uvBBOXTableTree{$closestWidthKey}}){
						if ( abs($keyB - $shortSide) < $diffB){
							$diffB = abs($keyB - $shortSide);
							$closestHeightKey = $keyB;
							#lxout("yes : keyB=$keyB <> height=$shortSide");
						}else{
							#lxout("no  : keyB=$keyB <> height=$shortSide");
						}
					}
				}

				#find the closest uvbbox algorithm B
				elsif ($alg =~ /b/i){
					my $bestMetaScore = -100;
					foreach my $keyA (sort keys %uvBBOXTableTree){
						foreach my $keyB (sort keys %{$uvBBOXTableTree{$keyA}}){
							my $aspectRatio = ($longSide / $shortSide) / ($keyA / $keyB);
							my $pixelRatio = ((2/$shortSide) * $longSide * $shortSide) / ((2/$shortSide) * $keyA * $keyB);
							my $metaScore;
							$bugCount++;

							if ($aspectRatio < 1)	{	$metaScore = $aspectRatio;				}
							else					{	$metaScore = 1/$aspectRatio;			}
							#my $msb = roundNumberString($metaScore,4);

							if ($pixelRatio < 1)	{
								my $subtract = (1-$pixelRatio) * .5;
								#lxout("    pixelRatio = $pixelRatio <> subtract = $subtract");
								$metaScore -= $subtract;
							}
							else					{
								my $subtract = (1-(1/$pixelRatio)) * .5;
								#lxout("subtract = $subtract");
								$metaScore -= $subtract;
							}
							#my $a = roundNumberString($longSide,4);
							#my $b = roundNumberString($shortSide,4);
							#my $c = roundNumberString($keyA,5);
							#my $d = roundNumberString($keyB,5);
							#my $e = roundNumberString($aspectRatio,4);
							#my $f = roundNumberString($pixelRatio,4);
							#my $g = roundNumberString($metaScore,4);
							#lxout("long=$a <> short=$b    <>    keyA=$c <> keyB=$d    <>    aspR=$e <> pixR=$f <> msb=$msb <> ms=$g");
							if ($metaScore > $bestMetaScore){
								#lxout("     winner!");
								$bestMetaScore = $metaScore;
								$closestWidthKey = $keyA;
								$closestHeightKey = $keyB;
							}
						}
					}
				}
				else{
					die("The chosen algorithm was neither A nor B so I'm cancelling the script!");
				}

				my @listofBBOXes = @{$uvBBOXTableTree{$closestWidthKey}{$closestHeightKey}};
				my $bboxCount = $#listofBBOXes;
				my $bboxToChoose = 0;
				if ($bboxCount > 0){
					#randomize first bbox choice
					if (!defined @{$listofBBOXes[0]}[7]) { @{$listofBBOXes[0]}[7] = int(rand($bboxCount) + .5); }
					my $lastUsedBBOX = @{$listofBBOXes[0]}[7];
					if ($lastUsedBBOX == $bboxCount){
						@{$listofBBOXes[0]}[7] = 0;
					}else{
						$bboxToChoose = $lastUsedBBOX + 1;
						@{$listofBBOXes[0]}[7] = $lastUsedBBOX + 1;
					}
				}
				my @bbox = @{$listofBBOXes[$bboxToChoose]};
				my @bboxCenter = ( ($bbox[2]+$bbox[4]) * .5 , ($bbox[3]+$bbox[5]) * .5 );

				#determine scale amounts
				if ( (($rotate == 1) && ($bbox[6] =~ /u/i)) || (($rotate == 0) && ($bbox[6] =~ /v/i)) ){
					$rotateAmount = 	90;
					if ($bbox[6] =~ /u/i)	{	@scale =	($bbox[0] / $height , $bbox[1] / $width);	}
					else					{	@scale =	($bbox[1] / $height , $bbox[0] / $width);	}
												@move =		($bboxCenter[0] - $center[0] , $bboxCenter[1] - $center[1]);
				}else{
					if ($bbox[6] =~ /u/i)	{	@scale =	($bbox[0] / $width , $bbox[1] / $height);	}
					else					{	@scale =	($bbox[1] / $width , $bbox[0] / $height);	}
												@move =		( $bboxCenter[0] - $center[0] , $bboxCenter[1] - $center[1] );
				}

				#randomize uv pos
				my $seed = 0;
				my $seed2 = 0;
				if ($sene_randomize == 1){ $seed = int(128*rand)-64;}
				if ($sene_randomize == 1){ $seed2 = int(128*rand)-64;}
				$move[0] += $seed;
				$move[1] += $seed2;
				$bboxCenter[0] += $seed;
				$bboxCenter[1] += $seed2;

				#randomize uv flip
				if ($axis == 1){
					if ( ($flipAxes =~ /u/i) && (rand > 0.5) ){ $scale[0] *= -1; }
					if ( ($flipAxes =~ /v/i) && (rand > 0.5) ){ $scale[1] *= -1; }
				}

				lx("select.drop polygon");
				foreach my $poly (@{$touchingUVList{$key}}){	lx("select.element $mainlayer polygon add $poly");	}

				#move
				lx("tool.viewType UV");
				lx("tool.set xfrm.move on");
				lx("tool.reset");
				lx("tool.xfrmDisco {1}");
				lx("tool.setAttr axis.auto axis {2}");
				lx("tool.setAttr center.auto cenU {$bboxCenter[0]}");
				lx("tool.setAttr center.auto cenV {$bboxCenter[1]}");
				lx("tool.setAttr xfrm.move U {$move[0]}");
				lx("tool.setAttr xfrm.move V {$move[1]}");
				lx("tool.doApply");
				lx("tool.set xfrm.move off");

				#rotate
				if ($rotateAmount != 0){
					lx("tool.set xfrm.rotate on");
					lx("tool.reset");
					lx("tool.xfrmDisco {1}");
					lx("tool.setAttr center.auto cenU {$bboxCenter[0]}");
					lx("tool.setAttr center.auto cenV {$bboxCenter[1]}");
					lx("tool.setAttr axis.auto axis {2}");
					lx("tool.setAttr xfrm.rotate angle [$rotateAmount]");
					lx("tool.doApply");
					lx("tool.set xfrm.rotate off");
				}

				#scale
				lx("tool.set xfrm.stretch on");
				lx("tool.reset");
				lx("tool.xfrmDisco {1}");
				lx("tool.setAttr axis.auto axis {2}");
				lx("tool.setAttr center.auto cenU {$bboxCenter[0]}");
				lx("tool.setAttr center.auto cenV {$bboxCenter[1]}");
				lx("tool.setAttr xfrm.stretch factX {$scale[0]}");
				lx("tool.setAttr xfrm.stretch factY {$scale[1]}");
				lx("tool.doApply");
				lx("tool.set xfrm.stretch off");
			}
		}
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#LOOK AT ALL THE SELECTED POLYGONS AND GROUP 'EM INTO DIFFERENT TEXTURE SIZE GROUPS
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub splitPolysIntoTexSizeGroups{
	lxout("[->] Running splitPolysIntoTexSizeGroups subroutine");
	our %polyGroups = ();

	my $textureGroupCount = (keys %clipSizeList);
	lxout("     -There are ($textureGroupCount) texture size groups");

	#put every poly into it's own texture size hash table.
	foreach my $poly (@polys){
		my $material = lc(lxq("query layerservice poly.material ? $poly"));
		OSPathNameFix($material);
		my $size = $clipNameList{$material};
		if ($size eq ""){$size = "256,256";}
		push(@{$polyGroups{$size}}, $poly);
	}
}




#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#LOAD A TEXTURE AND CREATE A MATERIAL FOR IT.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub load_new_shader{
	#load the file requester
	lx("dialog.setup fileOpenMulti");
	if (($modoVer > 300) && ($sene_matRepairImgFilter ne "*") && ($sene_matRepairImgFilter ne "") && ($sene_matRepairImgFilter ne "*.*") && ($sene_matRepairImgFilter =~ /[a-z]/i)){
		$sene_matRepairImgFilter =~ s/\*//;	$sene_matRepairImgFilter =~ s/\.//;
		my @imageFilters  = split(/[^a-zA-Z]/, $sene_matRepairImgFilter);
		my $imageFilter;
		foreach my $filter (@imageFilters){	$imageFilter .= "*." . $filter . ";"; }
		$imageFilter =~ s/\;$//;
		lx("dialog.title [Choose image to create a material with. (filter = $imageFilter)]");
		lx("dialog.fileTypeCustom format:{sim} username:{Image to load} loadPattern:{$imageFilter} saveExtension:{tga}");
	}else{
		lxout("[->] You're either running a version modo older than 301 or your 'LOAD + APPLY FILE BROWSER FILTER' was '' or '*' or '*.*' and so I'm loading all images and not using the file browser filter");
		lx("dialog.title {Choose image to create a material with. (filter = all images)}");
		lx("dialog.fileType image");
	}
	lx("dialog.open");
	my @files = lxq("dialog.result ?");
	OSPathNameFix(@files[0]);
	if (!defined @files[0]){	die("\n.\n[-------------------------------------------There was no file loaded, so I'm killing the script.---------------------------------------]\n[--PLEASE TURN OFF THIS WARNING WINDOW by clicking on the (In the future) button and choose (Hide Message)--] \n[-----------------------------------This window is not supposed to come up, but I can't control that.---------------------------]\n.\n");	}
	my $clipName = clipNameFix(@files[0]);

	#------------------------------------------------------------------------------------------
	#IF THE MATERIAL ALREADY EXISTS, JUST APPLY IT.
	#------------------------------------------------------------------------------------------
	my @idPtag = findPtagMask($clipName);
	if (@idPtag > 1){
		lxout("     -This material (@idPtag[1]) already exists, so I'm not creating a new material");
		lx("poly.setMaterial {@idPtag[1]}");
	}

	#------------------------------------------------------------------------------------------
	#IF THE MATERIAL DOESN'T EXIST, CREATE IT.
	#------------------------------------------------------------------------------------------
	else{
		#create and assign the new material
		lx("material.new [$clipName] [1]");  #the [1] tells it to assign that material.

		#find the ID of the material group I just created.
		my $newMaterialID;
		my $txLayers = lxq("query sceneservice txLayer.n ? all");
		for (my $i=0; $i<$txLayers; $i++){
			if (lxq("query sceneservice txLayer.type ? $i") eq "mask"){
				if (lxq("query sceneservice channel.value ? ptag") eq $clipName){
					$newMaterialID = lxq("query sceneservice txLayer.id ? $i");
					last;
				}
			}
		}

		#add the texture.
		lx("texture.new [@files[0]]");
		lx("texture.parent [$newMaterialID] [-1]");
		if ($sene_sutImageAA == 0){
			lx("item.channel imageMap\$aa false");
			lx("item.channel imageMap\$pixBlend $pixBlend");
		}
		lx("select.type polygon");
	}
}



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#CORRECT AND VALIDATE THE GAME DIR
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub validateGameDir{
	if ($sene_matRepairPath =~ /[a-z0-9]/i){
		OSPathNameFix($sene_matRepairPath);
		$sene_matRepairPath =~ s/\s*$//;
		my $lastChar = substr($sene_matRepairPath, -1, 1);
		if (($lastChar ne "\\") && ($lastChar ne "\/")){
			if ($osSlash eq "\\")	{$sene_matRepairPath .= "\\";}
			else					{$sene_matRepairPath .= "\/";}
		}
		if (-e $sene_matRepairPath){}else{popup("----------------MATERIAL REPAIR ERROR SO I'M NOW CANCELLING THE SCRIPT----------------\nThe shader system works by having materials with names linked to their assigned image path, \nand the user value to mention which folders to remove from the material names doesn't exist.  \nThis is the current user value : $sene_matRepairPath"); die;}
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#FIND IF A TEXTURE EXISTS SUB
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub findTexture{
	if (@_[0] =~ /\:/)	{	our $fullPath = @_[0];							}
	else				{	our $fullPath = $sene_matRepairPath . @_[0];	}

	#if the user has the JPEG override on, force JPG and JPEG to be at the front of the list.
	if ($jpg == 1){unshift(@fileOrder,jpg,jpeg);}

	foreach my $type (@fileOrder){
		if (-e $fullPath . "." . $type){
			$fullPath = $fullPath . "." . $type;
			OSPathNameFix($fullPath);

			lxout("$jpg <> $fullPath");
			return $fullPath;
		}
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#GO THRU ALL MATERIALS AND MAKE SURE THEY HAVE IMAGES ASSIGNED TO THEM.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub repair_shaders{
	#---------------------------------------------------
	#get a list of "mask" layers.
	#---------------------------------------------------
	our $failCount;
	my @masks;
	my @repairMaterials;
	my @deleteMaterials;
	my $checkMaterialNames;
	if (  ($sene_matRepairDelIMGs == 1) || ((($sene_matRepairTypeA == 1)&&($sene_matRepairNameA  ne ""))  ||  (($sene_matRepairTypeB == 1)&&($sene_matRepairNameB ne ""))  ||  (($sene_matRepairTypeC == 1)&&($sene_matRepairNameC  ne ""))) ){
		lxout("[->] CHECKING MATERIAL NAME FILTERS because they weren't all off or blank and/or the 'delete images' option was on.");
		$checkMaterialNames = 1;
	}
	#1 : SELECTED POLYS MATERIALS : (build a list of mask IDs)
	if ($selected == 1){
		lxout("[->] Repairing SELECTED poly materials");
		my %materials;
		my @polys = lxq("query layerservice polys ? selected");
		foreach my $poly (@polys){
			my $material = lxq("query layerservice poly.material ? $poly");
			OSPathNameFix($material);
			$materials{$material} = 1;
		}

		my $txLayers = lxq("query sceneservice txLayer.n ? all");
		for (my $i=0; $i<$txLayers ; $i++){
			if (lxq("query sceneservice txLayer.type ? $i") eq "mask"){
				my $ptag = lxq("query sceneservice channel.value ? ptag");
				OSPathNameFix($ptag);

				foreach my $material (keys %materials){
					if (lc($ptag) eq lc($material)){
						lxout("-       THIS MATERIAL GROUP matches this ptag : $material");
						my $maskID = lxq("query sceneservice txLayer.id ? $i");
						push(@masks,$maskID);
						last;
					}
				}
			}
		}
	}
	#2 : SELECTED MATERIALS : build a list of MASKS from selected polys and then find their item IDs
	elsif ($V == 1){
		lxout("[->] Repairing SELECTED materials");
		my $txLayerCount = lxq("query sceneservice txLayer.n ? all");
		for (my $i=0; $i<$txLayerCount; $i++){
			if (lxq("query sceneservice txLayer.type ? $i") eq "mask"){
				my $maskID = lxq("query sceneservice txLayer.id ? $i");
				if (lxq("query sceneservice txLayer.isSelected ? $maskID") == 1){
					push(@masks,$maskID);
				}
			}
		}
	}
	#3 : MATERIAL NAME FILTERS : (build a list of mask IDs)
	elsif ($filter == 1){
		lxout("[->] Repairing materials with a specific name");
		my $filterName = quickDialog("Material name filter :",string,"","","");
		my $txLayerCount = lxq("query sceneservice txLayer.n ? all");
		for (my $i=0; $i<$txLayerCount; $i++){
			if (lxq("query sceneservice txLayer.type ? $i") eq "mask"){
				my $name = lxq("query sceneservice txLayer.name ? $i");
				if ($name =~ /$filterName/){
					push(@masks,lxq("query sceneservice txLayer.id ? $i"));
				}
			}
		}
	}
	#4 : ALL MATERIALS : (build a list of mask IDs)
	else{
		lxout("[->] Repairing ALL materials");
		my $txLayers = lxq("query sceneservice txLayer.n ? all");
		for (my $i=0; $i<$txLayers; $i++){
			my $type = lxq("query sceneservice txLayer.type ? $i");
			if ($type eq "mask"){
				my $maskID = lxq("query sceneservice txLayer.id ? $i");
				push(@masks,$maskID);
			}
		}
	}

	#go through all collected MASKS and run them through the filters.
	foreach my $mask (@masks){
		if ($checkMaterialNames == 0){
			push(@repairMaterials,$mask);
		}
		else{
			my $name = lxq("query sceneservice item.name ? $mask");
			if ( ($sene_matRepairTypeA == 1) && ($sene_matRepairNameA ne "") && ($name =~ $sene_matRepairNameA) ){
				lxout("     -This material fits filter 1 ($name) <> ($sene_matRepairNameA)");
				push(@repairMaterials,$mask);
			}
			elsif ( ($sene_matRepairTypeB == 1) && ($sene_matRepairNameB ne "") && ($name =~ $sene_matRepairNameB) ){
				lxout("     -This material fits filter 2 ($name) <> ($sene_matRepairNameB)");
				push(@repairMaterials,$mask);
			}
			elsif ( ($sene_matRepairTypeC == 1) && ($sene_matRepairNameC ne "") && ($name =~ $sene_matRepairNameC) ){
				lxout("     -This material fits filter 3 ($name) <> ($sene_matRepairNameC)");
				push(@repairMaterials,$mask);
			}
			else{
				lxout("     -This material ($name) didn't fit any filters");
				push(@deleteMaterials,$mask);
			}
		}
	}



	#---------------------------------------------------
	#now do the actual repairing
	#---------------------------------------------------
	#build the shader list if doing a full BUMP/DIFF/SPEC repair
	if ($bumpDiffSpec == 1){
			opendir($shaderDir,$shaderDir) || die("Cannot opendir $shaderDir");
			@files = (sort readdir($shaderDir));
			my @ptags;
			foreach my $mask (@repairMaterials){
				my $name = lxq("query sceneservice txLayer.name ? $mask");
				push(@ptags,lxq("query sceneservice channel.value ? ptag"));
			}

			createShaderArray(@ptags);
			&decipherShaders();
			close($shaderDir);
			if ($saveMesh == 1)	{	shaderTreeTools(buildDbase,forceUpdate);	}
			else				{	shaderTreeTools(buildDbase);				}
	}

	#go through the REPAIR MATERIALS list and repair them
	foreach my $mask (@repairMaterials){
		#TEMP : delete all the images because I can't determine their filenames yet.
		my @children = lxq("query sceneservice txLayer.children ? $mask");
		foreach my $child (@children){
			if (lxq("query sceneservice txLayer.type ? $child") eq "imageMap"){
				lx("select.subItem [$child] set textureLayer;render;environment;light");
				lx("texture.delete");
			}
		}

		my $name = lxq("query sceneservice txLayer.name ? $mask");
		my $ptagName = lxq("query sceneservice channel.value ? ptag");
		OSPathNameFix($ptagName);
		$file = findTexture($ptagName);
		if ( ($saveMesh == 1) && ($file eq "") ){$failCount++;}

		#[->] : Either do a diff only repair
		if ($bumpDiffSpec != 1){
			lxout("[->] : Doing a DIFF only repair");
			lxout("     -I'm assigning this file ($file) to this material ($name)");
			if ($file ne ""){
				if ($debugSaveMesh == 1){
					open (FILE, ">>$saveMeshPresetLogFile") or die("I couldn't open the file : $saveMeshPresetLogFile");
					print FILE $file."\n";
					close(FILE);
				}

				lx("!!texture.new [$file]");
				lx("!!texture.parent $mask");
				if ($sene_sutImageAA == 0){
					lx("!!item.channel imageMap\$aa false");
					lx("!!item.channel imageMap\$pixBlend $pixBlend");
				}
			}else{
				lxout("This file didn't exist : $file");
			}
		}

		#[->] : Or do a full BUMP/DIFF/SPEC repair
		else{
			lxout("[->] : Doing a full BUMP/DIFF/SPEC repair");
			shaderTreeTools(ptag,delChildType,$name,imageMap);
			shaderTreeTools(ptag,delChildType,$name,constant);
			if ($saveMesh == 1)	{	constructPresetIconMatrs($ptagName);	}
			else				{	constructMaterials($ptagName);			}
		}
	}



	#go through the DELETE MATERIALS list and delete the images.
	if ($sene_matRepairDelIMGs == 1){
		foreach my $mask (@deleteMaterials){
			my @children = lxq("query sceneservice item.children ? $mask");
			foreach my $child (@children){
				if (lxq("query sceneservice item.type ? $child") eq "imageMap"){
					my $name = lxq("query sceneservice item.name ? $child");
					lxout("I'm deleting this image ($name) because <filters are on>, <image is outside filters range>, and the <delete images option is on>");
					lx("select.subItem [$child] set textureLayer;render;environment;light");
					lx("texture.delete");
				}
			}
		}
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#CLIPS WINDOW : SELECT THESE MATERIALS
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub CL_selectThesePolys{
	my $clips = lxq("query layerservice clip.n ? all");
	my @selectedClips;
	for (my $i=0; $i<$clips; $i++){
		if (lxq("query sceneservice clip.isSelected ? $i") == 1){
			push(@selectedClips,$i);
		}
	}

	#build a list of used materials to skip selecting the ones that don't exist.
	my $materials = lxq("query layerservice material.n ? all");
	my %materialTable;
	for (my $i=0; $i<$materials; $i++){
		$materialTable{lxq("query layerservice material.name ? $i")} = 1;
	}


	#get the clip "name" and select the materials if they're being used.
	foreach my $clip (@selectedClips){
		my $fullFileName = lxq("query layerservice clip.file ? $clip");
		my $clipName = clipNameFix($fullFileName);
		if (exists $materialTable{$clipName})	{	lx("select.polygon add material face {$clipName}");													}
		else									{	lxout("This image ($clipName) doesn't have any polys using it, so I didn't select that material");	}
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#APPLY THE SELECTED CLIP MATERIAL TO THE SELECTED POLYGONS.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub apply_this_material{
	my $clips = lxq("query layerservice clip.n ? all");
	my @selectedClips;
	for (my $i=0; $i<$clips; $i++){
		if (lxq("query sceneservice clip.isSelected ? $i") == 1){
			push(@selectedClips,$i);
		}
	}

	#get the clip "name"
	my $fullFileName = lxq("query layerservice clip.file ? @selectedClips[-1]");
	my $clipName = clipNameFix($fullFileName);

	#check to see if the material exists.  if it does, apply it.
	my @idPtag = findPtagMask($clipName);
	if (@idPtag > 1){
		lx("poly.setMaterial [@idPtag[1]]");
	}

	#if the material doesn't exist, I have to create it and apply it.
	else{
		lxout("The material you tried to apply didn't exist so I had to create it.");
		lx("poly.setMaterial [$clipName]");

		#find the group that the new material's in and parent the texture to it.
		my $txLayers = lxq("query sceneservice txLayer.n ? all");
		for (my $i=0; $i<$txLayers; $i++){
			if (lxq("query sceneservice txLayer.isSelected ? $i") == 1){
				my $parent = lxq("query sceneservice txLayer.parent ? $i");
				lx("texture.new [$fullFileName]");
				lx("texture.parent [$parent] [-1]");
				if ($sene_sutImageAA == 0){
					lx("item.channel imageMap\$aa false");
					lx("item.channel imageMap\$pixBlend $pixBlend");
				}
				last;
			}
		}
	}

	#Now set the user.value
	lx("!!user.value sene_surfaceGrab {@idPtag[1]}");
}




#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#PLANAR + CYLINDRICAL + SPHERICAL + ATLAS UVS
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub generalUVs{  #OK.  convert to verts.  add to selSet.  cut/paste the polys.  do the work.  select the verts and merge 'em.
	my $i = 1;
	my %polyList;
	#--------------------------------------------------------
	#[-1] : turn off all other layers, because it'll run into conflicts if I don't
	#--------------------------------------------------------
	my @fgLayers = lxq("query layerservice layers ? fg");
	my @bgLayers = lxq("query layerservice layers ? bg");
	for (my $i=0; $i<@fgLayers; $i++){
		my $id = lxq("query layerservice layer.id ? @fgLayers[$i]");
		@fgLayers[$i] = $id;
	}
	for (my $i=0; $i<@bgLayers; $i++){
		my $id = lxq("query layerservice layer.id ? @bgLayers[$i]");
		@bgLayers[$i] = $id;
	}
	addInstancesToBGList(\@bgLayers);

	lxout("fgLayers = @fgLayers");
	lxout("bgLayers = @bgLayers");
	$mainlayerID = lxq("query layerservice layer.id ? $mainlayer");
	my $vmapName = lxq("query layerservice vmap.name ? $finalVmap");  #only firing this because layers ? fg breaks the mainlayer
	lx("select.subItem [$mainlayerID] set mesh;meshInst;camera;light;txtrLocator;backdrop;groupLocator [0] [1]");

	#--------------------------------------------------------
	#[0] : remember the polys
	#--------------------------------------------------------
	lx("select.type polygon");
	lx("select.editSet senetemp add");

	#--------------------------------------------------------
	#[1] : convert to verts
	#--------------------------------------------------------
	lx("select.convert vertex");

	#--------------------------------------------------------
	#[2] : add to selSet
	#--------------------------------------------------------
	lx("select.editSet senetemp add");

	#--------------------------------------------------------
	#[3] : cut/paste the polys
	#--------------------------------------------------------
	lx("select.type polygon");
	lx("select.cut");
	lx("select.invert");
	lx("select.paste");
	lx("select.invert");

	#--------------------------------------------------------
	#[4] : do the actual work
	#--------------------------------------------------------
	@polys = lxq("query layerservice polys ? selected");  #overwrite the global polys list.
	for (@polys) {$polyList{$_} = 1; }

	while (keys %polyList != 0)
	{
		#COUNT
		my $value = (keys %polyList);
		lxout("-Round $i of UVing : There are $value poly(s) left to UV ");

		#select the first polyset
		my @polyListKeys = (keys %polyList); #find the first key in the hash table
		lx("select.drop polygon");
		lx("select.element [$mainlayer] polygon add @polyListKeys[0]");
		lx("select.connect");
		my @currentPolys = lxq("query layerservice polys ? selected");
		#popup("-Currently UVing $#currentPolys polys");

		#get bounding box (if needed)
		if ($needBbox == 1)
		{
			lx("select.convert vertex");
			our @verts = lxq("query layerservice verts ? selected");
			our @bbox = boundingbox(@verts);
			our @bboxSize = ((@bbox[3]-@bbox[0]),(@bbox[4]-@bbox[1]),(@bbox[5]-@bbox[2]));
			@bboxCenter = (((@bbox[0]+@bbox[3]) / 2) , ((@bbox[1]+@bbox[4]) / 2) , ((@bbox[2]+@bbox[5]) / 2));
			#lxout("-bbox = @bbox");
			#lxout("-bboxSize = @bboxSize");
			#lxout("-bboxCenter = @bboxCenter");
			#lxout("-axis = $axis");
		}

		#apply whatever UVs.
		lx("select.type polygon");
		&$subroutine;

		#cull the %polyList
		for (@currentPolys) {delete $polyList{$_};}
		$i++;
	}

	#--------------------------------------------------------
	#[5] : select the verts, merge 'em back and remove the selSet
	#--------------------------------------------------------
	lx("select.drop vertex");
	lx("select.useSet senetemp select");
	lx("!!vert.merge auto {0} {1 um}");
	lx("select.editSet senetemp remove");

	#--------------------------------------------------------
	#[6] : reselect all the original polys
	#--------------------------------------------------------
	lx("select.drop polygon");
	lx("select.useSet senetemp select");
	lx("select.editSet senetemp remove");

	#--------------------------------------------------------
	#[7] : put all the visible layers back.
	#--------------------------------------------------------
	if (@fgLayers > 1){
		for (my $i=1; $i<@fgLayers; $i++){
			lx("layer.setVisibility @fgLayers[$i] [-1] [1]");
		}
	}
	if (@bgLayers > 0){
		for (my $i=0; $i<@bgLayers; $i++){
			lx("layer.setVisibility @bgLayers[$i] [-1] [1]");
		}
	}
}



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#APPLY PEELER UVS
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub peeler{
	lxout("[->] Running Peeler subroutine");
	my @totalPolyList;
	my @edges = lxq("query layerservice edges ? selected");
	sortRowStartup(edgesSelected,@edges);

	#Run the peeler script on each edge Row.
	foreach my $vertRow (@vertRowList){

		my @verts = split (/[^0-9]/, $vertRow);

		#delete the UVs attached to the edge row
		my @polys = lxq("query layerservice edge.polyList ? (@verts[0],@verts[1])");
		lx("select.type polygon");
		lx("select.element $mainlayer polygon set @polys[0]");
		lx("select.connect");
		my @polys = lxq("query layerservice polys ? selected");
		push(@totalPolyList,@polys);
		foreach my $poly (@polys) { lx("select.element $mainlayer polygon add $poly"); }
		lx("uv.delete");

		#select only this edgerow's edges
		lx("select.drop edge");
		for (my $i = 0; $i<$#verts; $i++){
			my @array = (@verts[$i],@verts[$i+1]);
			lx("select.element $mainlayer edge add @array[0] @array[1]");
		}

		#run the peeler
		lx("tool.set uv.peeler on");
		lx("tool.reset");
		lx("tool.doApply");
		lx("tool.set uv.peeler off");
	}

	#send the total poly list back to the main system so I can select them.
	our @polys = @totalPolyList;
}



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#APPLY WORLDSPACE UVS
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub world_space_uvs{
	lxout("[->] Running world_space_uvs subroutine");
	my $i = 0;
	my @backupPolys = @polys;
	foreach my $array (keys %polyGroups){
		$i++;
		@polys = @{$polyGroups{$array}};
		my @size = split(/,/, $array);
		lxout("-round [$i] size = @size <><> polys = $#polys");

		#take the polys and split 'em in the 3 axis groups
		&split3axes;

		if (@xPolys > 0){
			lx("select.drop polygon");
			foreach my $poly (@xPolys){lx("select.element $mainlayer polygon add $poly");	}
			&uvProjection(0, 0, (@size[1]*$sene_texScale)/2, (@size[0]*$sene_texScale)/2, 0, @size[1]*$sene_texScale, @size[0]*$sene_texScale);
		}

		if (@yPolys > 0){
			lx("select.drop polygon");
			foreach my $poly (@yPolys){lx("select.element $mainlayer polygon add $poly");	}
			&uvProjection(1, (@size[0]*$sene_texScale)/2, 0, (@size[1]*$sene_texScale)/2, @size[0]*$sene_texScale, 0, -1 * (@size[1]*$sene_texScale)); #I'm putting the -1 on the z scale because modo's z projection is inverted because of their coordinate system.
		}

		if (@zPolys > 0){
			lx("select.drop polygon");
			foreach my $poly (@zPolys){lx("select.element $mainlayer polygon add $poly");	}
			&uvProjection(2, (@size[0]*$sene_texScale)/2, (@size[1]*$sene_texScale)/2, 0, @size[0]*$sene_texScale, @size[1]*$sene_texScale, 0);
		}
	}

	#restore the original polys array
	@polys = @backupPolys;
}




#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SEPARATE THE POLYS INTO 3 AXES
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub split3axes{
	#reset the poly arrays
	undef(@xPolys);
	undef(@yPolys);
	undef(@zPolys);

	#rebuild the arrays
	foreach my $poly (@polys){
		my @normal = lxq("query layerservice poly.normal ? $poly");


		#check X
		my $xDotProduct = abs(@normal[0]*1+@normal[1]*0+@normal[2]*0);
		#lxout("poly ($poly) X dp = $xDotProduct");
		if ($xDotProduct > 0.7){
			#lxout("This poly($poly) is X : ($xDotProduct)");
			push(@xPolys,$poly);
		}


		#check Y
		else{
			my $yDotProduct = abs(@normal[0]*0+@normal[1]*1+@normal[2]*0);
			#lxout("poly ($poly) Y dp = $yDotProduct");

			if ($yDotProduct > 0.7){
				#lxout("This poly($poly) is Y : ($yDotProduct)");
				push(@yPolys,$poly);
			}


			#check Z
			else{
				#lxout("($poly) is not X or Y, so it's gotta be Z");
				push(@zPolys,$poly);
			}
		}
	}
}



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#UV PROJECTION SUB
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub uvProjection{
	my $axis 			= @_[0];
	my $cenX			= @_[1];
	my $cenY			= @_[2];
	my $cenZ			= @_[3];
	my $sizX			= @_[4];
	my $sizY			= @_[5];
	my $sizZ			= @_[6];

	#popup("axis=$axis || cenX=$cenX || cenY=$cenY || cenZ=$cenZ || sizX=$sizX || sizY=$sizY || sizZ=$sizZ");

	lx("tool.set uv.create on");
	lx("tool.reset");
	lx("tool.setAttr uv.create proj planar");
	lx("tool.setAttr uv.create mode manual");
	lx("tool.attr uv.create axis {$axis}");
	lx("tool.setAttr uv.create cenX {$cenX}");
	lx("tool.setAttr uv.create cenY {$cenY}");
	lx("tool.setAttr uv.create cenZ {$cenZ}");
	lx("tool.attr uv.create sizX {$sizX} ");
	lx("tool.attr uv.create sizY {$sizY}");
	lx("tool.attr uv.create sizZ {$sizZ}");
	lx("tool.doApply");
	lx("tool.set uv.create off");
}



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#PROPORTIONAL 1 DIMENSIONAL UV FIT.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub prop1dFit{
	lxout("[->] PROP1DFIT subroutine");
	my $numKeys = (keys %touchingUVList);

	for (my $key=0; $key<$numKeys; $key++){
		my $seed = 0;
		my $seed2 = 0;
		if ($sene_randomize == 1){ $seed = int(128*rand)-64;}
		if ($sene_randomize == 1){ $seed2 = int(128*rand)-64;}

		#select the current uvgroup's polys.
		lx("select.drop polygon");
		foreach my $poly (@{$touchingUVList{$key}}){	lx("select.element $mainlayer polygon add $poly");	}

		#learn the MOVE distance
		my @uvDist;
		if 		($sene_texAnchor eq "top_left")		{	@uvDist = ((-1*@{$uvBBOXList{$key}}[0]) , (-1*@{$uvBBOXList{$key}}[3]));																}
		elsif	($sene_texAnchor eq "top_right")	{	@uvDist = ((-1*@{$uvBBOXList{$key}}[2]) , (-1*@{$uvBBOXList{$key}}[3]));																}
		elsif	($sene_texAnchor eq "bottom_right")	{	@uvDist = ((-1*@{$uvBBOXList{$key}}[2]) , (-1*@{$uvBBOXList{$key}}[1]));																}
		elsif	($sene_texAnchor eq "bottom_left")	{	@uvDist = ((-1*@{$uvBBOXList{$key}}[0]) , (-1*@{$uvBBOXList{$key}}[1]));																}
		elsif	($sene_texAnchor eq "center")		{	@uvDist = (0.5 - ((@{$uvBBOXList{$key}}[2]+@{$uvBBOXList{$key}}[0])/2) , 0.5 - ((@{$uvBBOXList{$key}}[3]+@{$uvBBOXList{$key}}[1])/2));	}
		elsif	($sene_texAnchor eq "top")			{	@uvDist = (0.5 - ((@{$uvBBOXList{$key}}[2]+@{$uvBBOXList{$key}}[0])/2) , (-1*@{$uvBBOXList{$key}}[3]));									}
		elsif	($sene_texAnchor eq "right")		{	@uvDist = ((-1*@{$uvBBOXList{$key}}[2]) , 0.5 - ((@{$uvBBOXList{$key}}[3]+@{$uvBBOXList{$key}}[1])/2));									}
		elsif	($sene_texAnchor eq "bottom")		{	@uvDist = (0.5 - ((@{$uvBBOXList{$key}}[2]+@{$uvBBOXList{$key}}[0])/2) , (-1*@{$uvBBOXList{$key}}[1]));									}
		elsif	($sene_texAnchor eq "left")			{	@uvDist = ((-1*@{$uvBBOXList{$key}}[0]) , 0.5 - ((@{$uvBBOXList{$key}}[3]+@{$uvBBOXList{$key}}[1])/2));									}
		elsif	($sene_texAnchor eq "off")			{
			if ($U == 1){
				@uvDist = (-1*@{$uvBBOXList{$key}}[0] , 0);
			}else{
				@uvDist = (0 , -1*@{$uvBBOXList{$key}}[1]);
			}
		}

		#learn the average proportional STRETCH and SCALE distance
		if ($avgProp == 1){ #TEMP : this doesn't work very well.
			my $uDiff =		1/abs(@{$uvBBOXList{$key}}[2]-@{$uvBBOXList{$key}}[0]);
			my $vDiff =		1/abs(@{$uvBBOXList{$key}}[3]-@{$uvBBOXList{$key}}[1]);
			my $oldUDiff =	1/abs(@{$uvBBOXList{0}}[2]-@{$uvBBOXList{0}}[0]);
			my $oldVDiff =	1/abs(@{$uvBBOXList{0}}[3]-@{$uvBBOXList{0}}[1]);

			my $uMatch = 	$vDiff * ($oldVDiff / $vDiff);
			my $vMatch = 	$uDiff * ($oldUDiff / $uDiff);

			$uDiff = 		$uDiff * $sene_texFitU;
			$vDiff =		$vDiff * $sene_texFitV;
			$uMatch = 		$uMatch * $sene_texFitV;
			$vMatch =		$vMatch * $sene_texFitU;

			#stop the first round from using it's numbers on itself
			if ($key == 0){
				$uMatch = $vDiff;
				$vMatch = $uDiff;
			}

			if ($U == 1)	{	our @uvScale = ($uDiff,$vMatch);		}
			elsif ($V == 1)	{	our @uvScale = ($vDiff,$uMatch);		}
			else			{	our @uvScale = ($uDiff,$vDiff);			}

		#learn the normal STRETCH and SCALE distance
		}else{
			if ($U == 1)	{	our @uvScale = ((1/abs(@{$uvBBOXList{$key}}[2]-@{$uvBBOXList{$key}}[0]))*$sene_texFitU , 1);																		}
			elsif ($V == 1)	{	our @uvScale = (1 , (1/abs(@{$uvBBOXList{$key}}[3]-@{$uvBBOXList{$key}}[1]))*$sene_texFitV);																		}
			else			{	our @uvScale = ((1/abs(@{$uvBBOXList{$key}}[2]-@{$uvBBOXList{$key}}[0]))*$sene_texFitU , (1/abs(@{$uvBBOXList{$key}}[3]-@{$uvBBOXList{$key}}[1]))*$sene_texFitV);	}
		}

		#MOVE THE UVs
		if ($sene_texAnchor ne "off"){
			my $moveU = $uvDist[0]+$seed;
			my $moveV = $uvDist[1]+$seed2;

			lx("tool.viewType UV");
			lx("tool.set xfrm.move on");
			lx("tool.reset");
			lx("tool.xfrmDisco {1}");
			lx("tool.setAttr axis.auto axis {2}");
			lx("tool.setAttr center.auto cenU {@{$uvBBOXList{$key}}[0]}");
			lx("tool.setAttr center.auto cenV {@{$uvBBOXList{$key}}[1]}");
			lx("tool.setAttr xfrm.move U {$moveU}");
			lx("tool.setAttr xfrm.move V {$moveV}");
			lx("tool.doApply");
			lx("tool.set xfrm.move off");
		}

		#SCALE the UVs
		if ($prop == 1){
			lx("tool.viewType UV");
			lx("tool.set xfrm.scale on");
			lx("tool.reset");
			lx("tool.xfrmDisco {1}");
			lx("tool.setAttr axis.auto axis {2}");
			#ANCHOR = OFF
			if ($sene_texAnchor eq "off"){
				my $uCenter  = (@{$uvBBOXList{$key}}[2]+@{$uvBBOXList{$key}}[0])/2+$seed;
				my $vCenter  = (@{$uvBBOXList{$key}}[3]+@{$uvBBOXList{$key}}[1])/2;
				lx("tool.setAttr center.auto cenU {$uCenter}");
				lx("tool.setAttr center.auto cenV {$vCenter}");
			}
			#ANCHOR = CENTER :
			elsif ($sene_texAnchor eq "center"){
				my $cenU = $seed+0.5;
				my $cenV = $seed2+0.5;
				lx("tool.setAttr center.auto cenU {$cenU}");
				lx("tool.setAttr center.auto cenV {$cenV}");
			}
			#ANCHOR = TOP OR BOTTOM :
			elsif (($sene_texAnchor eq "top") || ($sene_texAnchor eq "bottom")){
				my $cenU = $seed+0.5;
				my $cenV = $seed2+0.5;
				lx("tool.setAttr center.auto cenU {$cenU}");
				lx("tool.setAttr center.auto cenV {$cenV}");
			}
			#ANCHOR = LEFT OR RIGHT :
			elsif (($sene_texAnchor eq "left") || ($sene_texAnchor eq "right")){
				lx("tool.setAttr center.auto cenU {$seed}");
				lx("tool.setAttr center.auto cenV {$seed2}");
			}
			#ANCHOR = CORNERS:
			else{
				lx("tool.setAttr center.auto cenU {$seed}");
				lx("tool.setAttr center.auto cenV {$seed2}");
			}
			my $factor = (@uvScale[0]*@uvScale[1]);
			lx("tool.setAttr xfrm.scale factor {$factor}"); #hack to merge the scale and stretch values into 1 array.
			lx("tool.doApply");
			lx("tool.set xfrm.scale off");
		}

		#STRETCH the UVs
		else{
			lx("tool.viewType UV");
			lx("tool.set xfrm.stretch on");
			lx("tool.reset");
			lx("tool.xfrmDisco {1}");
			lx("tool.setAttr axis.auto axis {2}");
			#ANCHOR = OFF
			if ($sene_texAnchor eq "off"){
				my $uCenter  = (@{$uvBBOXList{$key}}[2]+@{$uvBBOXList{$key}}[0])/2+$seed;
				my $vCenter  = (@{$uvBBOXList{$key}}[3]+@{$uvBBOXList{$key}}[1])/2;
				lx("tool.setAttr center.auto cenU {$uCenter}");
				lx("tool.setAttr center.auto cenV {$vCenter}");
			}
			#ANCHOR = CENTER :
			elsif ($sene_texAnchor eq "center"){
				my $cenU = $seed+0.5;
				my $cenV = $seed2+0.5;
				lx("tool.setAttr center.auto cenU {$cenU}");
				lx("tool.setAttr center.auto cenV {$cenV}");
			}
			#ANCHOR = TOP OR BOTTOM :
			elsif (($sene_texAnchor eq "top") || ($sene_texAnchor eq "bottom")){
				my $cenU = $seed+0.5;
				my $cenV = $seed2+0.5;
				lx("tool.setAttr center.auto cenU {$cenU}");
				lx("tool.setAttr center.auto cenV {$cenV}");
			}
			#ANCHOR = LEFT OR RIGHT :
			elsif (($sene_texAnchor eq "left") || ($sene_texAnchor eq "right")){
				lx("tool.setAttr center.auto cenU {$seed}");
				lx("tool.setAttr center.auto cenV {$seed2}");
			}
			#ANCHOR = CORNERS:
			else{
				lx("tool.setAttr center.auto cenU {$seed}");
				lx("tool.setAttr center.auto cenV {$seed2}");
			}
			lx("tool.setAttr xfrm.stretch factX {@uvScale[0]}");
			lx("tool.setAttr xfrm.stretch factY {@uvScale[1]}");
			lx("tool.doApply");
			lx("tool.set xfrm.stretch off");
		}
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#VIEW UV ISLANDS SUB : view each uv island one at a time
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub viewUVIslands{
	my @keyList = (keys %touchingUVList);
	for (my $i=0; $i<@keyList; $i++){
		lx("unhide");
		lx("select.drop polygon");
		foreach my $poly (@{$touchingUVList{@keyList[$i]}}){lx("select.element $mainlayer polygon add $poly");}
		lx("hide.unsel");

		lx("tool.viewType UV");
		lx("viewport.fitSelected");
		lx("tool.viewType xyz");
		lx("viewport.fitSelected");

		my $result = quickDialog("ROUND $i of $#keyList\n \nA=continue\nB=stop\nC=cancel\nD=undo\nany number=FF or RW",string,A,"","");
		if		($result =~ /b/i)			{last;			}
		elsif	($result =~ /c/i)			{die;			}
		elsif	($result =~ /d/i)			{$i -= 2;		}
		elsif	($result =~ /^-*[\d\.]+$/)	{$i += $result;	}
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#QUANTIZE THE UVS TO THE USER VALUE DEFINED AMOUNT.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub uvDistMerge{
	if (lxq( "select.typeFrom {vertex;edge;polygon;item} ?" ) == 1)		{	our $mode = "verts";	$selectionMode = "vertex";	}
	elsif (lxq( "select.typeFrom {edge;polygon;item;vertex} ?" ) == 1)	{	our $mode = "edges";	$selectionMode = "edge";	}
	elsif (lxq( "select.typeFrom {polygon;item;vertex;edge} ?" ) == 1)	{	our $mode = "polys";	$selectionMode = "polygon";	}
	else {die("\\\\n.\\\\n[---------------------------------------------You're not in vert, edge, or polygon mode.--------------------------------------------]\\\\n[--PLEASE TURN OFF THIS WARNING WINDOW by clicking on the (In the future) button and choose (Hide Message)--] \\\\n[-----------------------------------This window is not supposed to come up, but I can't control that.---------------------------]\\\\n.\\\\n");}

	if ($mode ne "verts"){ lx("select.convert vertex"); }
	my @verts = lxq("query layerservice verts ? selected");
	my $uvDistCutoff = 0.000001;
	if ($numberValue != 0){$uvDistCutoff = $numberValue;}
	if ($dialog == 1){$uvDistCutoff = quickDialog("merge uvs that are\nthis close together",string,"0.000001");}
	lxout("uvDistCutoff = $uvDistCutoff");

	foreach my $vert (@verts){
		my @polys = lxq("query layerservice vert.polyList ? $vert");
		my @uvPos = (999999999999,999999999999);
		my @polyVertsToMove;

		#TEMP : what i have to do is put each uv value into a hash table.  then go thru next uv values and if disp between that and the hash table is < merge dist, put it in that hash table group.  so it will then group all uv positions that are close to one another all from one single vert.  then it should average their total positions and scale them to their origins.
		foreach my $poly (@polys){
			my @vertList = lxq("query layerservice poly.vertList ? $poly");
			my @vmapValues = lxq("query layerservice poly.vmapValue ? $poly");
			lxout("   $poly\n   @vertList\n   @vmapValues");

			for (my $i=0; $i<@vertList; $i++){
				if ($vertList[$i] == $vert){
					if (@uvPos[0] == 999999999999){
						@uvPos = ($vmapValues[$i*2],$vmapValues[($i*2)+1]);
						lxout("$vert $poly origin : @uvPos");
					}else{
						my @bleh = ($vmapValues[$i*2],$vmapValues[($i*2)+1]);

						my $disp = ( abs($uvPos[0] - $vmapValues[$i*2]) + abs($uvPos[1] - $vmapValues[($i*2)+1]) );
						lxout("disp = $disp <> @bleh");
						if		($disp < $uvDistCutoff)		{	push(@polyVertsToMove,$poly);	lxout("$vert $poly merge : @uvPos");}
					}
					last;
				}
			}
		}

		if (@polyVertsToMove > 0){
			lxout("polyVertsToMove = @polyVertsToMove");
			lx("select.drop vertex");
			lx("select.element layer:$mainlayer type:vert mode:add index:{$vert} index3:{$_}") for @polyVertsToMove;

			lx("tool.viewType uv");
			lx("!!tool.set actr.auto on");
			lx("!!tool.set xfrm.stretch on");
			lx("!!tool.reset");
			lx("!!tool.setAttr center.auto cenU {$uvPos[0]}");
			lx("!!tool.setAttr center.auto cenV {$uvPos[1]}");
			lx("!!tool.setAttr xfrm.stretch factX {0}");
			lx("!!tool.setAttr xfrm.stretch factY {0}");
			lx("!!tool.setAttr xfrm.stretch factZ 1");
			lx("!!tool.doApply");
			lx("!!tool.set xfrm.stretch off");
		}
	}

	lx("select.type $selectionMode");
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#QUANTIZE THE UVS TO THE USER VALUE DEFINED AMOUNT.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub quantizeUVs{
	my $Ugrid = lxq("user.value sene_quantizeU ?");
	my $Vgrid = lxq("user.value sene_quantizeV ?");


	foreach my $key (keys %touchingUVList){
		#select the current uvgroup's polys.
		lx("select.drop polygon");
		foreach my $poly (@{$touchingUVList{$key}}){	lx("select.element $mainlayer polygon add $poly");	}

		#learn the scale amount
		my $width = (@{$uvBBOXList{$key}}[2] - @{$uvBBOXList{$key}}[0]);
		my $height = (@{$uvBBOXList{$key}}[3] - @{$uvBBOXList{$key}}[1]);
		my $widthRound = roundNumber($width,$Ugrid);
		my $heightRound = roundNumber($height,$Vgrid);
		#make sure the rounded number isn't lower than the min round.
		if ($widthRound < $Ugrid){	$widthRound = $Ugrid;	}
		if ($heightRound < $Vgrid){	$heightRound = $Vgrid;	}
		my $scaleU =  $widthRound / $width;
		my $scaleV =  $heightRound / $height;


		#learn the move amount
		my @bboxCenter = 		( (@{$uvBBOXList{$key}}[2] + @{$uvBBOXList{$key}}[0])*0.5 , (@{$uvBBOXList{$key}}[3] + @{$uvBBOXList{$key}}[1])*0.5 );
		my @scaledBottomLeft =	( (@bboxCenter[0] - ($widthRound*0.5)) , (@bboxCenter[1] - ($heightRound*0.5)) );
		my $moveDistU = 		(roundNumber(@scaledBottomLeft[0],$Ugrid) - @scaledBottomLeft[0]);
		my $moveDistV = 		(roundNumber(@scaledBottomLeft[1],$Vgrid) - @scaledBottomLeft[1]);

		#time to scale the UVs
		lx("tool.viewType UV");
		lx("tool.set xfrm.stretch on");
		lx("tool.reset");
		lx("tool.xfrmDisco {1}");
		lx("tool.setAttr axis.auto axis {2}");
		lx("tool.setAttr center.auto cenU {@bboxCenter[0]}");
		lx("tool.setAttr center.auto cenV {@bboxCenter[1]}");
		lx("tool.setAttr xfrm.stretch factX {$scaleU}");
		lx("tool.setAttr xfrm.stretch factY {$scaleV}");
		lx("tool.doApply");
		lx("tool.set xfrm.stretch off");

		#time to move the UVs
		lx("tool.set xfrm.move on");
		lx("tool.reset");
		lx("tool.xfrmDisco {1}");
		lx("tool.setAttr axis.auto axis {2}");
		lx("tool.setAttr center.auto cenU {@bboxCenter[0]}");
		lx("tool.setAttr center.auto cenV {@bboxCenter[1]}");
		lx("tool.setAttr xfrm.move U {$moveDistU}");
		lx("tool.setAttr xfrm.move V {$moveDistV}");
		lx("tool.doApply");
		lx("tool.set xfrm.move off");
	}
}



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#QUICK SCALE OF THE UVs 200%
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub quickScale{
	lxout("[->] Running a single scale from the origin.");

	lx("tool.viewType UV");
	lx("tool.set xfrm.stretch on");
	lx("tool.reset");
	lx("tool.xfrmDisco {1}");
	lx("tool.setAttr axis.auto axis {2}");
	lx("tool.setAttr center.auto cenU {0}");
	lx("tool.setAttr center.auto cenV {0}");

	#DETERMINING WHETHER TO STRETCH UP OR DOWN, and with U and/or V.
	if ($up == 1){
		if ($U == 1){	lx("tool.setAttr xfrm.stretch factX {0.5}");	}else{	lx("tool.setAttr xfrm.stretch factX {1}");	}
		if ($V == 1){	lx("tool.setAttr xfrm.stretch factY {0.5}");	}else{	lx("tool.setAttr xfrm.stretch factY {1}");	}
	}else{
		if ($U == 1){	lx("tool.setAttr xfrm.stretch factX {2}");	}else{	lx("tool.setAttr xfrm.stretch factX {1}");	}
		if ($V == 1){	lx("tool.setAttr xfrm.stretch factY {2}");	}else{	lx("tool.setAttr xfrm.stretch factY {1}");	}
	}

	lx("tool.doApply");
	lx("tool.set xfrm.stretch off");
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SCALE MESHES TO PIXEL SIZE
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub scaleMeshesToPixelSize{
	foreach my $array (keys %polyGroups){
		@polys = @{$polyGroups{$array}};
		my @size = split(/,/, $array);
		my %todoPolyList;
		$todoPolyList{$_} = 1 for @polys;
		our $meshCount;

		while (keys %todoPolyList > 0){
			my @connectedPolys;

			if ($part == 1){
				my $poly = (keys %todoPolyList)[0];
				my $part = lxq("query layerservice poly.part ? {$poly}");
				if ($part eq "Default"){
					lxout("skipping part selection because the part name is 'Default'");
					@connectedPolys = listTouchingPolys2((keys %todoPolyList)[0]);
				}else{
					lx("select.drop polygon");
					lx("!!select.polygon add part face {$part}");
					@connectedPolys = lxq("query layerservice polys ? selected");
					our $skipPolyResel = 1;
				}
			}else{
				@connectedPolys = listTouchingPolys2((keys %todoPolyList)[0]);
			}
			delete $todoPolyList{$_} for @connectedPolys;
			my @polysToCompare = gatherEveryXElemsFromArray(\@connectedPolys,10);
			my $scalarAverage;
			my $scalarAvgCount;
			$meshCount++;

			#find each edge length and compare the dist
			foreach my $poly (@polysToCompare){
				my @vertList = lxq("query layerservice poly.vertList ? $poly");
				my @vmapValues = lxq("query layerservice poly.vmapValue ? $poly");
				$scalarAvgCount += @vertList;

				for (my $i=-1; $i<$#vertList; $i++){
					my @pos1 = lxq("query layerservice vert.pos ? $vertList[$i]");
					my @pos2 = lxq("query layerservice vert.pos ? $vertList[$i+1]");
					my @vector = arrMath(@pos1,@pos2,subt);
					my $dist3D = sqrt(($vector[0]*$vector[0])+($vector[1]*$vector[1])+($vector[2]*$vector[2]));

					my @uvPos1 = ( $vmapValues[$i*2] , $vmapValues[$i*2+1] );
					my @uvPos2 = ( $vmapValues[$i*2+2] , $vmapValues[$i*2+3] );
					my @uvVector = arrMath(@uvPos1,0,@uvPos2,0,subt);
					my @pixelVector = arrMath(@uvVector,$size[0],$size[1],0,mult);
					my $distUV = sqrt(($pixelVector[0]*$pixelVector[0])+($pixelVector[1]*$pixelVector[1])+($pixelVector[2]*$pixelVector[2]));

					my $distComparison = $dist3D / ($distUV * $sene_texScale);
					$scalarAverage += $distComparison;
				}
			}

			#now determine bbox center, sel polys and scale them.
			my @bboxCenter;
			foreach my $poly (@connectedPolys){
				my @polyPos = lxq("query layerservice poly.pos ? $poly");
				$bboxCenter[0] += $polyPos[0];
				$bboxCenter[1] += $polyPos[1];
				$bboxCenter[2] += $polyPos[2];
			}
			@bboxCenter = arrMath(@bboxCenter,$#connectedPolys+1,$#connectedPolys+1,$#connectedPolys+1,div);
			my $scaleAmount = 1 / ($scalarAverage / $scalarAvgCount);

			if ($skipPolyResel != 1){
				lx("select.drop polygon");
				lx("select.element $mainlayer polygon add $_") for @connectedPolys;
			}
			lx("tool.viewType xyz");
			lx("tool.set xfrm.scale on");
			lx("tool.reset");
			lx("tool.attr center.auto cenX {$bboxCenter[0]}");
			lx("tool.attr center.auto cenY {$bboxCenter[1]}");
			lx("tool.attr center.auto cenZ {$bboxCenter[2]}");
			lx("tool.setAttr xfrm.scale factor {$scaleAmount}");
			lx("tool.doApply");
			lx("tool.set xfrm.scale off");
			lxout("Scaling mesh by this amount : $scaleAmount");
		}
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SCALE UVS TO MATCH PIXEL SIZE
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub scaleToPixelSize{
	foreach my $array (keys %polyGroups){
		$i++;
		@polys = @{$polyGroups{$array}};
		my @size = split(/,/, $array);
		if ( (@size[0] == 0) && (@size[1] == 0) ){
			our $sizeSmallest = 256;
			our @imgAspRatioScalar = (1,1);
		}elsif (@size[1] < @size[0]){
			our $sizeSmallest = @size[1];
			our @imgAspRatioScalar = (@size[0]/@size[1],1);
		}else{
			our $sizeSmallest = @size[0];
			our @imgAspRatioScalar = (1,@size[0]/@size[1]);
		}

		&splitUVGroups;
		foreach my $key (keys %touchingUVList){
			my $fakeDist = 0;
			my $fakeUVDist = 0;
			my $fakeUScale = 9999999;
			my $fakeVScale = 9999999;

			lx("select.drop polygon");
			foreach my $poly (@{$touchingUVList{$key}})	{lx("select.element $mainlayer polygon add $poly");}

			my @polyToDoList = @{$touchingUVList{$key}};
			foreach my $poly (@polyToDoList){
				my $vertCount = lxq("query layerservice poly.numVerts ? $poly");
				my @verts = lxq("query layerservice poly.vertList ? $poly");
				my @vmapValues = lxq("query layerservice poly.vmapValue ? $poly");
				if (($U != 1) && (@size[0] != @size[1])){
					for (my $i=0; $i<@vmapValues; $i=$i+2){
						@vmapValues[$i] *= @imgAspRatioScalar[0];
						@vmapValues[$i+1] *= @imgAspRatioScalar[1];
					}
				}

				my @polyVertPosList;
				foreach my $vert (@verts){push(@polyVertPosList,lxq("query layerservice vert.pos ? $vert"));}

				for (my $i=-1; $i<$vertCount-1; $i++){
					#bbox stretch
					if ($U == 1){
						my $disp = ( abs(@polyVertPosList[3*$i+3] - @polyVertPosList[3*$i]) + abs(@polyVertPosList[3*$i+4] - @polyVertPosList[3*$i+1]) + abs(@polyVertPosList[3*$i+5] - @polyVertPosList[3*$i+2]) );
						my @fuv = ( abs(@vmapValues[2*$i+2] - @vmapValues[2*$i]) , abs(@vmapValues[2*$i+3] - @vmapValues[2*$i+1]) );
						if ($fuv[0] > $fuv[1]){
							if ($fakeUScale == 9999999)	{	$fakeUScale	= $fuv[0] / $disp;							}
							else						{	$fakeUScale = ($fakeUScale + ($fuv[0] / $disp)) * .5;	}
						}else{
							if ($fakeVScale == 9999999)	{	$fakeVScale	= $fuv[1] / $disp;							}
							else						{	$fakeVScale = ($fakeVScale + ($fuv[1] / $disp)) * .5;	}
						}
					}
					#bbox scale
					else{
						$fakeDist += ( abs(@polyVertPosList[3*$i+3] - @polyVertPosList[3*$i]) + abs(@polyVertPosList[3*$i+4] - @polyVertPosList[3*$i+1]) + abs(@polyVertPosList[3*$i+5] - @polyVertPosList[3*$i+2]) );
						$fakeUVDist += ( abs(@vmapValues[2*$i+2] - @vmapValues[2*$i]) + abs(@vmapValues[2*$i+3] - @vmapValues[2*$i+1]) );
					}
				}
			}
			if ($U == 1){
				our @scaleAmount = ($fakeUScale,$fakeVScale);
				if		($scaleAmount[0] == 9999999){	$scaleAmount[0] = $fakeVScale;	}
				elsif	($scaleAmount[1] == 9999999){	$scaleAmount[1] = $fakeUScale;	}
				if ($scaleAmount[0] == 0){$scaleAmount[0] = 0.00001;}
				if ($scaleAmount[1] == 0){$scaleAmount[1] = 0.00001;}
				@scaleAmount = ( 1 / ($scaleAmount[0] * $size[0]) , 1 / ($scaleAmount[1] * $size[1]) );
				@scaleAmount = ( $scaleAmount[0] * 1/$sene_texScale , $scaleAmount[1] * 1/$sene_texScale );

				#scale only in U
				if ($axis == 1){@scaleAmount = ($scaleAmount[0]/$scaleAmount[1],1);}
				#scale only in V
				elsif ($axis == 2){@scaleAmount = (1,$scaleAmount[1]/$scaleAmount[0]);}

			}else{
				our @scaleAmount = ( 1 / (($fakeUVDist * $sizeSmallest) / ($fakeDist * (1/$sene_texScale)) ) , 1 / (($fakeUVDist * $sizeSmallest) / ($fakeDist * (1/$sene_texScale)) ));
			}

			lx("tool.viewType UV");
			lx("tool.set xfrm.stretch on");
			lx("tool.reset");
			lx("tool.xfrmDisco {1}");
			lx("tool.setAttr axis.auto axis {2}");
			lx("tool.setAttr center.auto cenU {0}");
			lx("tool.setAttr center.auto cenV {0}");

			#THE STRETCH TOOL'S CENTER, BASED OFF OF THE ANCHOR POINT.
			if ($sene_texAnchor eq "top_left")	{
				lx("tool.setAttr center.auto cenU {@{$uvBBOXList{$key}}[0]}");
				lx("tool.setAttr center.auto cenV {@{$uvBBOXList{$key}}[3]}");
			}elsif ($sene_texAnchor eq "top_right"){
				lx("tool.setAttr center.auto cenU {@{$uvBBOXList{$key}}[2]}");
				lx("tool.setAttr center.auto cenV {@{$uvBBOXList{$key}}[3]}");
			}elsif ($sene_texAnchor eq "bottom_right"){
				lx("tool.setAttr center.auto cenU {@{$uvBBOXList{$key}}[2]}");
				lx("tool.setAttr center.auto cenV {@{$uvBBOXList{$key}}[1]}");
			}elsif ($sene_texAnchor eq "bottom_left"){
				lx("tool.setAttr center.auto cenU {@{$uvBBOXList{$key}}[0]}");
				lx("tool.setAttr center.auto cenV {@{$uvBBOXList{$key}}[1]}");
			}elsif ($sene_texAnchor eq "top"){
				my $cenU = (@{$uvBBOXList{$key}}[0] + @{$uvBBOXList{$key}}[2]) * .5;
				lx("tool.setAttr center.auto cenU {$cenU}");
				lx("tool.setAttr center.auto cenV {@{$uvBBOXList{$key}}[3]}");
			}elsif ($sene_texAnchor eq "right"){
				my $cenV = (@{$uvBBOXList{$key}}[1] + @{$uvBBOXList{$key}}[3]) * .5;
				lx("tool.setAttr center.auto cenU {@{$uvBBOXList{$key}}[2]}");
				lx("tool.setAttr center.auto cenV {$cenV}");
			}elsif ($sene_texAnchor eq "bottom"){
				my $cenU = (@{$uvBBOXList{$key}}[0] + @{$uvBBOXList{$key}}[2]) * .5;
				lx("tool.setAttr center.auto cenU {$cenU}");
				lx("tool.setAttr center.auto cenV {@{$uvBBOXList{$key}}[1]}");
			}elsif ($sene_texAnchor eq "left"){
				my $cenV = (@{$uvBBOXList{$key}}[1] + @{$uvBBOXList{$key}}[3]) * .5;
				lx("tool.setAttr center.auto cenU {@{$uvBBOXList{$key}}[0]}");
				lx("tool.setAttr center.auto cenV {$cenV}");
			}elsif ($sene_texAnchor eq "center"){
				my $cenU = (@{$uvBBOXList{$key}}[0] + @{$uvBBOXList{$key}}[2]) * .5;
				my $cenV = (@{$uvBBOXList{$key}}[1] + @{$uvBBOXList{$key}}[3]) * .5;
				lx("tool.setAttr center.auto cenU {$cenU}");
				lx("tool.setAttr center.auto cenV {$cenV}");
			}else{
				lx("tool.setAttr center.auto cenU {0}");
				lx("tool.setAttr center.auto cenV {0}");
			}

			lx("tool.setAttr xfrm.stretch factX {$scaleAmount[0]}");
			lx("tool.setAttr xfrm.stretch factY {$scaleAmount[1]}");
			lx("tool.doApply");
			lx("tool.set xfrm.stretch off");
		}
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SCALE UP THE UVs 200%
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub scale{
	lxout("[->] Scaling the UVs uses the Anchor Point, and it's here : ($sene_texAnchor)");

	foreach my $key (keys %touchingUVList){
		lx("select.drop polygon");
		foreach my $poly (@{$touchingUVList{$key}})	{lx("select.element $mainlayer polygon add $poly");}

		lx("tool.viewType UV");
		lx("tool.set xfrm.stretch on");
		lx("tool.reset");
		lx("tool.xfrmDisco {1}");
		lx("tool.setAttr axis.auto axis {2}");

		#THE STRETCH TOOL'S CENTER, BASED OFF OF THE ANCHOR POINT.
		if ($sene_texAnchor eq "top_left")	{
			lx("tool.setAttr center.auto cenU {@{$uvBBOXList{$key}}[0]}");
			lx("tool.setAttr center.auto cenV {@{$uvBBOXList{$key}}[3]}");
		}elsif ($sene_texAnchor eq "top_right"){
			lx("tool.setAttr center.auto cenU {@{$uvBBOXList{$key}}[2]}");
			lx("tool.setAttr center.auto cenV {@{$uvBBOXList{$key}}[3]}");
		}elsif ($sene_texAnchor eq "bottom_right"){
			lx("tool.setAttr center.auto cenU {@{$uvBBOXList{$key}}[2]}");
			lx("tool.setAttr center.auto cenV {@{$uvBBOXList{$key}}[1]}");
		}elsif ($sene_texAnchor eq "bottom_left"){
			lx("tool.setAttr center.auto cenU {@{$uvBBOXList{$key}}[0]}");
			lx("tool.setAttr center.auto cenV {@{$uvBBOXList{$key}}[1]}");
		}elsif ($sene_texAnchor eq "top"){
			my $cenU = (@{$uvBBOXList{$key}}[0] + @{$uvBBOXList{$key}}[2]) * .5;
			lx("tool.setAttr center.auto cenU {$cenU}");
			lx("tool.setAttr center.auto cenV {@{$uvBBOXList{$key}}[3]}");
		}elsif ($sene_texAnchor eq "right"){
			my $cenV = (@{$uvBBOXList{$key}}[1] + @{$uvBBOXList{$key}}[3]) * .5;
			lx("tool.setAttr center.auto cenU {@{$uvBBOXList{$key}}[2]}");
			lx("tool.setAttr center.auto cenV {$cenV}");
		}elsif ($sene_texAnchor eq "bottom"){
			my $cenU = (@{$uvBBOXList{$key}}[0] + @{$uvBBOXList{$key}}[2]) * .5;
			lx("tool.setAttr center.auto cenU {$cenU}");
			lx("tool.setAttr center.auto cenV {@{$uvBBOXList{$key}}[1]}");
		}elsif ($sene_texAnchor eq "left"){
			my $cenV = (@{$uvBBOXList{$key}}[1] + @{$uvBBOXList{$key}}[3]) * .5;
			lx("tool.setAttr center.auto cenU {@{$uvBBOXList{$key}}[0]}");
			lx("tool.setAttr center.auto cenV {$cenV}");
		}elsif ($sene_texAnchor eq "center"){
				my $cenU = (@{$uvBBOXList{$key}}[0] + @{$uvBBOXList{$key}}[2]) * .5;
				my $cenV = (@{$uvBBOXList{$key}}[1] + @{$uvBBOXList{$key}}[3]) * .5;
				lx("tool.setAttr center.auto cenU {$cenU}");
				lx("tool.setAttr center.auto cenV {$cenV}");
		}else{
			my $cenU = (@{$uvBBOXList{$key}}[0]+@{$uvBBOXList{$key}}[2])/2;
			my $cenV = (@{$uvBBOXList{$key}}[1]+@{$uvBBOXList{$key}}[3])/2;
			lx("tool.setAttr center.auto cenU {$cenU}");
			lx("tool.setAttr center.auto cenV {$cenV}");
		}

		#DETERMINING WHETHER TO STRETCH UP OR DOWN, and with U and/or V.
		if ($up == 1){
			if ($U == 1){	lx("tool.setAttr xfrm.stretch factX {0.5}");	}else{	lx("tool.setAttr xfrm.stretch factX {1}");	}
			if ($V == 1){	lx("tool.setAttr xfrm.stretch factY {0.5}");	}else{	lx("tool.setAttr xfrm.stretch factY {1}");	}
		}else{
			if ($U == 1){	lx("tool.setAttr xfrm.stretch factX {2}");		}else{	lx("tool.setAttr xfrm.stretch factX {1}");	}
			if ($V == 1){	lx("tool.setAttr xfrm.stretch factY {2}");		}else{	lx("tool.setAttr xfrm.stretch factY {1}");	}
		}

		lx("tool.doApply");
		lx("tool.set xfrm.stretch off");
	}
}





#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
#SHRINK UVS 1 PIXEL
#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
sub shrink1pixel{
	#back the original polys array up.
	my @backupPolys = @polys;

	#this is the special case cvar which allows us to shrink the uvs by X pixels
	if ($print == 1){our $pixelAmount = quickDialog("Shrink by how many pixels?",float,1,"","");	}
	else			{our $pixelAmount = 1;															}

	foreach my $size (keys %polyGroups){
		my @size = split(/,/,$size);
		@polys = @{$polyGroups{$size}};

		&splitUVGroups;
		foreach my $key (keys %touchingUVList){
			my @currentPolys = @{$touchingUVList{$key}};
			my @uvBBOX = @{$uvBBOXList{$key}};
			my @uvBBOXCenter = ( (@uvBBOX[2]+@uvBBOX[0])/2 , (@uvBBOX[3]+@uvBBOX[1])/2);
			#reselect the current polys
			lx("select.drop polygon");
			foreach my $poly (@currentPolys){	lx("select.element $mainlayer polygon add $poly");	}

			#find the value I have to scale to, to shrink 1 pixel
			my $uSize;
			my $vSize;
			$uSize = (@uvBBOX[2]-@uvBBOX[0])*@size[0];
			$uSize = ($uSize-$pixelAmount)/$uSize;
			$vSize = (@uvBBOX[3]-@uvBBOX[1])*@size[1];
			$vSize = ($vSize-$pixelAmount)/$vSize;
			#popup("uvBBOX = @uvBBOX <> uvBBOXCenter = @uvBBOXCenter");
			#popup("uSize = $uSize <> vSize = $vSize");

			#perform the scale
			lx("tool.viewType UV");
			lx("tool.set xfrm.stretch on");
			lx("tool.reset");
			lx("tool.xfrmDisco {1}");
			lx("tool.setAttr axis.auto axis {2}");
			lx("tool.setAttr center.auto cenU {@uvBBOXCenter[0]}");
			lx("tool.setAttr center.auto cenV {@uvBBOXCenter[1]}");

			if ($U == 1)	{	lx("tool.setAttr xfrm.stretch factX {$uSize}");	}
			else			{	lx("tool.setAttr xfrm.stretch factX {1}");		}
			if ($V == 1)	{	lx("tool.setAttr xfrm.stretch factY {$vSize}");	}
			else			{	lx("tool.setAttr xfrm.stretch factY {1}");		}

			lx("tool.doApply");
			lx("tool.set xfrm.stretch off");
		}
	}

	#restore the original polys array
	@polys = @backupPolys;
}




#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
#MOVE ONE UNIT subroutine
#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
sub moveOneUnit{
	if (lxq( "select.typeFrom {polygon;item;vertex;edge} ?" ) == 0){die("You're not in polygon mode and so I'm cancelling the script");}
	if (@polys == 0){die("You don't have any polys selected and so I'm cancelling the script");}

	if		($up == 1)		{our $u = 0; our $v = 1;}
	elsif	($down == 1)	{our $u = 0; our $v = -1;}
	elsif	($left == 1)	{our $u = -1; our $v = 0;}
	elsif	($right == 1)	{our $u = 1; our $v = 0;}

	lx("tool.viewType UV");
	lx("tool.set xfrm.move on");
	lx("tool.xfrmDisco true");
	lx("tool.setAttr axis.auto startX 0.2707");
	lx("tool.setAttr axis.auto startY 0.0");
	lx("tool.setAttr axis.auto startZ 0.0");
	lx("tool.setAttr axis.auto endX 0.0");
	lx("tool.setAttr axis.auto endY 0.2707");
	lx("tool.setAttr axis.auto endZ 0.0");
	lx("tool.attr xfrm.move U {$u}");
	lx("tool.attr xfrm.move V {$v}");
	lx("tool.doApply");
	lx("tool.set xfrm.move off");
}


#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
#MOVE UVs subroutine
#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
sub move{
	foreach my $size (keys %polyGroups){
		my @currentPolys = @{$polyGroups{$size}};
		lx("select.drop polygon");
		foreach my $poly (@currentPolys){	lx("select.element $mainlayer polygon add $poly");	}


		my @size = split/,/,$size;
		lx("tool.viewType UV");
		lx("tool.set xfrm.move on");
		lx("tool.reset");
		lx("tool.xfrmDisco {1}");
		lx("tool.setAttr center.auto cenU {0}");
		lx("tool.setAttr center.auto cenV {0}");
		lx("tool.setAttr axis.auto axis {2}");

		#move amount
		my $moveAmount;
		if 		($sene_texMove == 0)	{	$moveAmount = 0.5;		}
		elsif	($sene_texMove == 1)	{	$moveAmount = 1;		}
		elsif	($sene_texMove == 2)	{	$moveAmount = 4;		}
		elsif	($sene_texMove == 3)	{	$moveAmount = 16;		}
		elsif	($sene_texMove == 4)	{	$moveAmount = 64;		}
		else							{	$moveAmount = 256;		}

		#move direction
		if ($up == 1){
			my $v = -1*($moveAmount/@size[1]);
			lx("tool.setAttr xfrm.move V {$v}");
		}
		elsif ($down == 1){
			my $v = $moveAmount/@size[1];
			lx("tool.setAttr xfrm.move V {$v}");
		}
		elsif ($left == 1){
			my $u = $moveAmount/@size[0];
			lx("tool.setAttr xfrm.move U {$u}");
		}
		elsif ($right == 1){
			my $u = -1*($moveAmount/@size[0]);
			lx("tool.setAttr xfrm.move U {$u}");
		}

		lx("tool.doApply");
		lx("tool.set xfrm.move off");
	}
}


#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
#FLIP UVs subroutine
#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
sub flip{
	lxout("[->] UV FLIP subroutine");

	foreach my $key (keys %touchingUVList){
		lx("select.drop polygon");
		foreach my $poly (@{$touchingUVList{$key}})	{lx("select.element $mainlayer polygon add $poly");}

		lx("tool.viewType UV");
		lx("tool.set xfrm.stretch on");
		lx("tool.reset");
		lx("tool.xfrmDisco {1}");
		lx("tool.setAttr axis.auto axis {2}");

		#scale center
		my $cenU = (@{$uvBBOXList{$key}}[0]+@{$uvBBOXList{$key}}[2])/2;
		my $cenV = (@{$uvBBOXList{$key}}[1]+@{$uvBBOXList{$key}}[3])/2;
		lx("tool.setAttr center.auto cenU {$cenU}");
		lx("tool.setAttr center.auto cenV {$cenV}");

		#scale amount
		if ($U == 1){	lx("tool.setAttr xfrm.stretch factX {-1}");	}else{	lx("tool.setAttr xfrm.stretch factX {1}");	}
		if ($V == 1){	lx("tool.setAttr xfrm.stretch factY {-1}");	}else{	lx("tool.setAttr xfrm.stretch factY {1}");	}

		lx("tool.doApply");
		lx("tool.set xfrm.stretch off");
	}
}


#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
#LOCALLY ROTATE UVs subroutine
#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
sub localRotate{
	lxout("[->] UV LOCAL ROTATION subroutine");

	foreach my $size (keys %polyGroups){
		my @size = split(/,/, $size);
		@polys = @{$polyGroups{$size}}; #force "split" to find the polys
		splitUVGroups;



		#LOOK AT EACH UVGROUP AND ROTATE EACH OF THEM FROM THEIR NEAREST TEXTURE-CORNER
		foreach my $key (keys %touchingUVList){
			#SELECT THE CURRENT UV GROUP-----------------------------------
			lx("select.drop polygon");
			foreach my $poly (@{$touchingUVList{$key}}){
				lx("select.element $mainlayer polygon add $poly");
			}
			#GET THE UVBBOX
			my @uvBBOX  = @{$uvBBOXList{$key}};
			my @uvBBOXCenter = (((@uvBBOX[0]+@uvBBOX[2])/2),((@uvBBOX[1]+@uvBBOX[3])/2));



			#ROTATE TIME-------------------------------------------------------------
			lx("tool.viewType UV");
			lx("tool.set xfrm.rotate on");
			lx("tool.reset");
			lx("tool.xfrmDisco {1}");
			lx("tool.setAttr center.auto cenU {0}");
			lx("tool.setAttr center.auto cenV {0}");
			lx("tool.setAttr axis.auto axis {2}");
			#ROTATION DIRECTION
			if ($CCW == 1)	{	lx("tool.setAttr xfrm.rotate angle {-90}");	}
			else			{	lx("tool.setAttr xfrm.rotate angle {90}");	}
			lx("tool.doApply");
			lx("tool.set xfrm.rotate off");



			#STRETCH TIME-------------------------------------------------------------
			if (($size != "") || (@size[0] != @size[1])){
				lxout("     -Stretching the uvs to match the texture size difference ($size)");
				my $factX = @size[1]/@size[0];
				my $factY = @size[0]/@size[1];
				lx("tool.set xfrm.stretch on");
				lx("tool.reset");
				lx("tool.xfrmDisco {1}");
				lx("tool.setAttr center.auto cenU {0}");
				lx("tool.setAttr center.auto cenV {0}");
				lx("tool.setAttr axis.auto axis {2}");
				lx("tool.setAttr xfrm.stretch factX {$factX}");
				lx("tool.setAttr xfrm.stretch factY {$factY}");
				lx("tool.doApply");
				lx("tool.set xfrm.stretch off");
			}
		}
	}
}




#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
#ROTATE UVs subroutine
#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
sub rotate{
	if ($origin == 1)	{		lxout("[->] UV ROTATION subroutine (rotating from zero");		}
	else				{		lxout("[->] UV ROTATION subroutine");							}

	foreach my $size (keys %polyGroups){
		my @size = split(/,/, $size);
		my @currentPolys = @{$polyGroups{$size}};
		my @UVbboxCenter = uvBBOX(@currentPolys);

		#ROTATE TIME-------------------------------------------------------------
		lx("tool.viewType UV");
		lx("tool.set xfrm.rotate on");
		lx("tool.reset");
		lx("tool.xfrmDisco {1}");
		lx("tool.setAttr axis.auto axis {2}");

		#ROTATION CENTER
		if ($origin == 1){
			lx("tool.setAttr center.auto cenU {0}");
			lx("tool.setAttr center.auto cenV {0}");
		}else{
			lx("tool.setAttr center.auto cenU {@UVbboxCenter[0]}");
			lx("tool.setAttr center.auto cenV {@UVbboxCenter[1]}");
		}

		#ROTATION DIRECTION
		if ($CCW == 1)	{	lx("tool.setAttr xfrm.rotate angle {-90}");	}
		else			{	lx("tool.setAttr xfrm.rotate angle {90}");	}
		lx("tool.doApply");
		lx("tool.set xfrm.rotate off");

		#STRETCH TIME-------------------------------------------------------------
		if ($prop == 1){
			lxout("     -Stretching the uvs so they keep their bbox proportion");
			lx("tool.set xfrm.stretch on");
			lx("tool.reset");
			lx("tool.xfrmDisco {1}");

			if ($origin == 1){
				lx("tool.setAttr center.auto cenU {0}");
				lx("tool.setAttr center.auto cenV {0}");
			}else{
				lx("tool.setAttr center.auto cenU {@UVbboxCenter[0]}");
				lx("tool.setAttr center.auto cenV {@UVbboxCenter[1]}");
			}
			my $sizeX = (@uvBBOX[2]-@uvBBOX[0]) / (@uvBBOX[3]-@uvBBOX[1]);
			my $sizeY = (@uvBBOX[3]-@uvBBOX[1]) / (@uvBBOX[2]-@uvBBOX[0]);
			lx("tool.setAttr axis.auto axis {2}");
			lx("tool.setAttr xfrm.stretch factX {$sizeX}");
			lx("tool.setAttr xfrm.stretch factY {$sizeY}");
			lx("tool.doApply");
			lx("tool.set xfrm.stretch off");
		}
		elsif (($size != "") || (@size[0] != @size[1])){
			lxout("     -Stretching the uvs to match the texture size difference ($size)");
			lx("tool.set xfrm.stretch on");
			lx("tool.reset");
			lx("tool.xfrmDisco {1}");

			if ($origin == 1){
				lx("tool.setAttr center.auto cenU {0}");
				lx("tool.setAttr center.auto cenV {0}");
			}else{
				lx("tool.setAttr center.auto cenU {@UVbboxCenter[0]}");
				lx("tool.setAttr center.auto cenV {@UVbboxCenter[1]}");
			}
			my $sizeX = (@size[1]/@size[0]);
			my $sizeY = (@size[0]/@size[1]);
			lx("tool.setAttr axis.auto axis {2}");
			lx("tool.setAttr xfrm.stretch factX {$sizeX}");
			lx("tool.setAttr xfrm.stretch factY {$sizeY}");
			lx("tool.doApply");
			lx("tool.set xfrm.stretch off");
		}
	}
}


#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
#POLY SEW (will find the disco edges on island 1 and sew them to the disco edges on island 2)
#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
sub polySew{
	my @edgesToSelect;

	#find the uv group that has the first selected poly in it.
	my $foundTouchingUVList = -1;
	foreach my $key (keys %touchingUVList){
		foreach my $poly (@{$touchingUVList{$key}})	{
			if ($poly == @polys[0]){
				$foundTouchingUVList = $key;
				last;
			}
		}
	}

	#now build a list of all the edges in the found uv group.
	my %edgesTable;
	foreach my $poly (@{$touchingUVList{$foundTouchingUVList}})	{
		my @verts = lxq("query layerservice poly.vertList ? $poly");
		for (my $i=0; $i<@verts; $i++){
			if (@verts[$i-1] < @verts[$i]){
				push(@{$edgesTable{@verts[$i-1].",".@verts[$i]}},$poly);
			}else{
				push(@{$edgesTable{@verts[$i].",".@verts[$i-1]}},$poly);
			}
		}
	}

	#now go through all the other selected uv islands, and put the matching edges into the matching edge list;
	lx("select.drop edge");
	foreach my $key (keys %touchingUVList){
		if ($key != $foundTouchingUVList){
			foreach my $poly (@{$touchingUVList{$key}})	{
				my @verts = lxq("query layerservice poly.vertList ? $poly");
				for (my $i=0; $i<@verts; $i++){
					if (@verts[$i-1] < @verts[$i]){
						if (@{$edgesTable{@verts[$i-1].",".@verts[$i]}} > 0){
							lx(qq(select.element $mainlayer edge add @verts[$i-1] @verts[$i] @{$edgesTable{@verts[$i-1].",".@verts[$i]}}[0]));
							push(@edgesToSelect,($verts[$i-1],$verts[$i]));
						}
					}else{
						if (@{$edgesTable{@verts[$i].",".@verts[$i-1]}} > 0){
							lx(qq(select.element $mainlayer edge add @verts[$i] @verts[$i-1] @{$edgesTable{@verts[$i].",".@verts[$i-1]}}[0]));
							push(@edgesToSelect,($verts[$i],$verts[$i-1]));
						}
					}
				}
			}
		}
	}

	#now flip the uvs to do a non-overlapping uv sew
	if (1){
		my @edgePolys = lxq("query layerservice edge.polyList ? ($edgesToSelect[0],$edgesToSelect[1])");
		my $polyUVArea1 = findPolyUVAreaHack($edgePolys[0]);
		my $polyUVArea2 = findPolyUVAreaHack($edgePolys[1]);
		if ( (($polyUVArea1 > 0) && ($polyUVArea2 < 0)) || (($polyUVArea1 < 0) && ($polyUVArea2 > 0)) ){
			lx("select.drop polygon");
			foreach my $poly (@{$touchingUVList{$foundTouchingUVList}})	{lx("select.element $mainlayer polygon add $poly");}
			lx("tool.viewType UV");
			lx("tool.set xfrm.stretch on");
			lx("tool.reset");
			lx("tool.xfrmDisco {1}");
			lx("tool.setAttr axis.auto axis {2}");
			lx("tool.setAttr center.auto cenU {0}");
			lx("tool.setAttr center.auto cenV {0}");
			lx("tool.setAttr xfrm.stretch factX {-1}");
			lx("tool.setAttr xfrm.stretch factY {1}");
			lx("tool.doApply");
			lx("tool.set xfrm.stretch off");
			lx("select.type edge");
		}
	}

	lx("!!uv.sewMove disco");
	lx("select.type polygon");
}

#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
#FIND POLY UV AREA (works on only one poly and returns double the true area and should not be abs)
#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
#usage : findPolyUVAreaHack($poly);
sub findPolyUVAreaHack{
	my $area;
	my @vmapValues = lxq("query layerservice poly.vmapValue ? $_[0]");

	for (my $i=-2; $i<@vmapValues-2; $i=$i+2){
		my $blah = ($vmapValues[$i] * $vmapValues[$i+3]) - ($vmapValues[$i+2]*$vmapValues[$i+1]);
		$area += $blah;
	}
	my $trueArea = abs($area) / 2; #not actually needed for this script though and so it's ignored and not returning the true area
	return ($area);
}




#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
#ALIGN THE UV GROUPS TO OUTERMOST DIRECTION
#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
sub uvAlign{
	my $uvGroupCount = keys %uvBBOXList;
	my @lastUVBBOX = @{$uvBBOXList{$uvGroupCount-1}};

	for (my $key = 0; $key<$uvGroupCount-1; $key++){
		my $seed = 0;
		if ($sene_randomize == 1){ $seed = int(128*rand)-64;}
		#select the group
		lx("select.drop polygon");
		foreach my $poly (@{$touchingUVList{$key}})	{lx("select.element $mainlayer polygon add $poly");}

		#find the diff between this bounding box and the last bounding box.
		my @uvBBOX = @{$uvBBOXList{$key}};
		my @uvDiff;

		#args
		if 		($up == 1)		{	@uvDiff = (0,@lastUVBBOX[3]-@uvBBOX[3]+$seed);	}
		elsif	($down == 1)	{	@uvDiff = (0,@lastUVBBOX[1]-@uvBBOX[1]+$seed);	}
		elsif	($left == 1)	{	@uvDiff = (@lastUVBBOX[0]-@uvBBOX[0]+$seed,0);	}
		else					{	@uvDiff = (@lastUVBBOX[2]-@uvBBOX[2]+$seed,0);	}

		#move time
		lx("tool.viewType UV");
		lx("tool.set xfrm.move on");
		lx("tool.reset");
		lx("tool.xfrmDisco {1}");
		lx("tool.setAttr axis.auto axis {2}");
		lx("tool.setAttr center.auto cenU {0}");
		lx("tool.setAttr center.auto cenV {0}");
		lx("tool.setAttr xfrm.move U {@uvDiff[0]}");
		lx("tool.setAttr xfrm.move V {@uvDiff[1]}");
		lx("tool.doApply");
		lx("tool.set xfrm.move off");
	}
}

#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
#UNROTATE EACH POLYGROUP
#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
sub unRotate{
	#remember the selection type
	if (lxq( "select.typeFrom {vertex;edge;polygon;item} ?" ) == 1)		{	our $mode = verts;	$selectionMode = "vertex";	}
	elsif (lxq( "select.typeFrom {edge;polygon;item;vertex} ?" ) == 1)	{	our $mode = edges;	$selectionMode = "edge";	}

	#force select polys if in vert or edge mode.
	if (($mode eq "verts") || ($mode eq "edges")){
		my %polyTable;
		if ($mode eq "edges"){lx("select.convert vertex");}
		my @uvs = lxq("query layerservice uvs ? selected");
		foreach my $uv (@uvs){
			$uv =~ s/[()]//g;
			$uv =~ s/,.*//;
			$polyTable{$uv} = 1;
		}
		lx("select.drop polygon");
		foreach my $poly (keys %polyTable){
			lx("select.element $mainlayer polygon add $poly");
		}
		lx("select.polygonConnect uv");
		@polys = lxq("query layerservice polys ? selected");
	}

	#backup the @polys array, because we're going to overwrite it for the uvGroups.
	my @polysBackup = @polys;

	#split polys into tex size groups
	&splitPolysIntoTexSizeGroups;

	#go through each image size group.
	foreach my $size (keys %polyGroups){
		#select all the polys in this image size group
		my @size = split(/,/, $size);
		@polys = @{$polyGroups{$size}};

		#remove the image's scale from the polys
		if ((@size[0] != @size[1]) && ($ignoreTexSize != 1)){
			lxout("The image size is not 1x1, so I'm scaling the uvs (@size)");
			lx("select.drop polygon");
			for (my $i=0; $i<@polys; $i++) { lx("select.element $mainlayer polygon add @polys[$i]");}
			my $scale = @size[0]/@size[1];
			lx("tool.viewType UV");
			lx("tool.set xfrm.stretch on");
			lx("tool.reset");
			lx("tool.xfrmDisco {1}");
			lx("tool.setAttr center.auto cenU {0}");
			lx("tool.setAttr center.auto cenV {0}");
			lx("tool.setAttr xfrm.stretch factX {$scale}");
			lx("tool.setAttr xfrm.stretch factY {1}");
			lx("tool.setAttr xfrm.stretch factZ {1}");
			lx("tool.doApply");
			lx("tool.set xfrm.stretch off");
		}


		#---------------------------------------------------------------------------------------------------
		#---------------------------------------------------------------------------------------------------
		#GO THROUGH ALL THE POLYS IN THIS CURRENT IMAGE SIZE GROUP.
		#---------------------------------------------------------------------------------------------------
		#---------------------------------------------------------------------------------------------------

		&splitUVGroups;

		#TEMP TEMP TEMP : for some reason, I'm not able to get the vmapTable at this point!!!

		foreach my $key (keys %touchingUVList){
			my $longestEdge;
			my $longestLength=0;
			my @longestLengthGroup;
			my @similarEdges;
			my %vectorTable;
			my %vectorDirTable;
			my @averageVector;
			my $angle;

			#select the current UV GROUP
			lx("select.drop polygon");
			foreach my $poly (@{$touchingUVList{$key}})	{lx("select.element $mainlayer polygon add $poly");}


			#---------------------------------------------------------------------------------------------------
			#---------------------------------------------------------------------------------------------------
			#IF IN VERT MODE, DO THE MANUAL UNROTATE
			#---------------------------------------------------------------------------------------------------
			#---------------------------------------------------------------------------------------------------
			if (($mode eq "verts") || ($mode eq "edges")){
				my %uvTable;
				my @foundUVs = ();
				my $firstUVVert = -1;

				#find the verts for this UV set.
				my @uvs = lxq("query layerservice uvs ? selected");
				if (@uvs < 2){die("You must have at least two verts selected in order to unrotate the uvs");}

				#build the uv table (poly)=>(vert)
				foreach my $uv (@uvs){
					my @polyVert = split(/[^0-9]/,$uv);
					push(@{$uvTable{@polyVert[1]}},@polyVert[2]);
				}

				#find which of the selected uvs belong to this uv island
				my %vertList;
				foreach my $poly (@{$touchingUVList{$key}}){
					foreach my $tablePoly (keys %uvTable){
						if ($poly == $tablePoly){
							foreach my $vert (@{$uvTable{$tablePoly}}){
								if ($firstUVVert != $vert){
									push(@foundUVs, "(" . $tablePoly . "," . $vert . ")" );
									$firstUVVert = $vert;
								}
							}
						}
					}
					if (@foundUVs > 1){last;}
				}

				#get the angle between the first and last vert.
				#lxout("foundUVs = @foundUVs");
				my @pos1 = lxq("query layerservice uv.pos ? @foundUVs[0]");
				my @pos2 = lxq("query layerservice uv.pos ? @foundUVs[1]");
				my @vector = ((@pos2[0]-@pos1[0]),(@pos2[1]-@pos1[1]));
				$angle = vectorToAngle(@vector);
			}



			#---------------------------------------------------------------------------------------------------
			#---------------------------------------------------------------------------------------------------
			#IF NOT IN VERT MODE, DO THE AUTOMATIC UNROTATE
			#---------------------------------------------------------------------------------------------------
			#---------------------------------------------------------------------------------------------------
			else{
				#find the UV borders
				&findUVBorders(@{$touchingUVList{$key}});

				#-------------------------------------------------------------------
				#[1A] : build the UV border edge vector table.
				#-------------------------------------------------------------------
				foreach my $edge (keys %edgeTable){
					my @verts = split(/,/, $edge);
					my @edgePolys = split(/,/, $edgeTable{$edge});
					foreach my $poly (@edgePolys){
						my @pos1 = split(/,/,$vmapTable{$poly.",".@verts[0]});
						my @pos2 = split(/,/,$vmapTable{$poly.",".@verts[1]});
						my @vector = ((@pos2[0]-@pos1[0]),(@pos2[1]-@pos1[1]));

						#correct the vector
						@vector = correctVectorDir(@vector[0],@vector[1]);

						$vectorTable{$poly.",".$edge} = \@vector;
						#lxout("edge($edge) <> poly($poly) <> pos1(@pos1) <> pos2(@pos2)");
						#lxout("edge($edge) <> vector=@vector");
					}
				}

				#-------------------------------------------------------------------
				#[1B] :build the grouped hash table of all the vectors (array value 1 is the fakeDist pile)
				#-------------------------------------------------------------------
				foreach my $vector (keys %vectorTable){
					my $fakeDist = abs(@{$vectorTable{$vector}}[0])+abs(@{$vectorTable{$vector}}[1]);
					my @currentVector = vectorToUnitVector(@{$vectorTable{$vector}});
					#lxout("vector = $vector <><> @currentVector");
					my $tableCheck = 0;
					foreach my $key (keys %vectorDirTable){
						my @keyVector = split/,/,$key;
						my $dp = (@currentVector[0]*@keyVector[0]+@currentVector[1]*@keyVector[1]);
						#add this vector to this table key array if it's similar enough
						if ($dp > 0.999){
							@{$vectorDirTable{$key}}[0] += $fakeDist;
							push(@{$vectorDirTable{$key}}, $vector);
							$tableCheck = 1;
							last;
						}
					}
					#there are no table key arrays that are similar enough so I'm creating a new one.
					if ($tableCheck == 0){
						push(@{$vectorDirTable{@currentVector[0].",".@currentVector[1]}}, $fakeDist);
						push(@{$vectorDirTable{@currentVector[0].",".@currentVector[1]}}, $vector);
					}
				}

				#-------------------------------------------------------------------
				#[1C] : now look through the vector dir table and find the biggest edge pile length.
				#-------------------------------------------------------------------
				foreach my $key (keys %vectorDirTable){
					#my $count = @{$vectorDirTable{$key}}-1;
					#lxout("key = $key <> ($count) edge groups\n@{$vectorDirTable{$key}}");
					if (@{$vectorDirTable{$key}}[0] > $longestLength){	$longestLength = @{$vectorDirTable{$key}}[0];	};
				}

				#-------------------------------------------------------------------
				#[1D] : now find all the edge piles that match the biggest edge pile length
				#-------------------------------------------------------------------
				foreach my $key (keys %vectorDirTable){
					if ((@{$vectorDirTable{$key}}[0] / $longestLength) > 0.9){
						#lxout("This group ($key) is similar enough to the longestLength");
						push (@longestLengthGroup,$key);
					}
				}

				#-------------------------------------------------------------------
				#[1EA] : if there's ONE edge pile, use it's first vector.
				#-------------------------------------------------------------------
				if (@longestLengthGroup == 1){
					lxout("[->] ONE major edge group");
					my @finalVector = split/,/,@longestLengthGroup[0];
					$angle = vectorToAngle(@finalVector);
				}

				#-------------------------------------------------------------------
				#[1EB] : if there's TWO edge piles and they're alinear, use the first.  if they're not alinear, average them.
				#-------------------------------------------------------------------
				elsif (@longestLengthGroup == 2){
					lxout("[->] TWO major edge groups");
					my @finalVector1 = split/,/,@longestLengthGroup[0];
					my @finalVector2 = split/,/,@longestLengthGroup[1];
					my $dp = (@finalVector1[0]*@finalVector2[0]+@finalVector1[1]*@finalVector2[1]);

					#alinear
					if (($dp > -0.01) && ($dp < 0.01)){
						$angle = vectorToAngle(@finalVector1);
					}

					#not alinear
					else{
						my @finalVector  = ((@finalVector1[0]+@finalVector2[0])/2 , (@finalVector1[1]+@finalVector2[1])/2);
						$angle = vectorToAngle(@finalVector);
					}
				}

				#-------------------------------------------------------------------
				#[1EC] : if there's MORE THAN TWO edge piles, use their averaged angles.
				#-------------------------------------------------------------------
				else{
					lxout("[->] More than TWO major edge groups");
					for (my $i=0; $i<@longestLengthGroup; $i++){
						my @vector = split/,/,@longestLengthGroup[$i];
						@averageVector = ( (@averageVector[0]+@vector[0]), (@averageVector[1]+@vector[1]) );
					}
					@averageVector = ( (@averageVector[0]/@longestLengthGroup) , (@averageVector[1]/@longestLengthGroup) );
					$angle = vectorToAngle(@averageVector);
				}
			}


			#-------------------------------------------------------------------
			#NOW I MUST ROUND OUT THE ANGLE.
			#-------------------------------------------------------------------
			if (($U == 0) && ($V == 0)){
				if    ($angle < 0)		{	$angle = $angle + 360;	} #don't allow negative angles
				if    ($angle > 315)	{	$angle = 360 - $angle;	}
				elsif ($angle > 270)	{	$angle = 270 - $angle;	}
				elsif ($angle > 225)	{	$angle = 270 - $angle;	}
				elsif ($angle > 180)	{	$angle = 180 - $angle;	}
				elsif ($angle > 135)	{	$angle = 180 - $angle;	}
				elsif ($angle > 90)		{	$angle = 90 - $angle;	}
				elsif ($angle > 45)		{	$angle = 90 - $angle;	}
				else					{	$angle = 360 - $angle;	}
			}elsif ($U == 1){
				lxout("[->] : unrotating horizontally");
				if    ($angle < 0)								{	$angle = $angle + 360;	}
				if	  ($angle > 180)							{	$angle = $angle - 180;	}
				if    ((abs(180 - $angle)) <= abs($angle))		{	$angle = 180 - $angle;	}
				else											{	$angle = -$angle;		}
			}else{
				lxout("[->] : unrotating vertically");
				if    ($angle < 0)								{	$angle = $angle + 360;	}
				if	  ($angle > 180)							{	$angle = $angle - 180;	}
				if    ((abs(270 - $angle)) <= abs(90 - $angle))	{	$angle = 270 - $angle;	}
				else											{	$angle = 90 - $angle;	}
			}

			#-------------------------------------------------------------------
			#ROTATE THE UVS
			#-------------------------------------------------------------------
			my $cenU = (@{$uvBBOXList{$key}}[0]+@{$uvBBOXList{$key}}[2])/2;
			my $cenV = (@{$uvBBOXList{$key}}[1]+@{$uvBBOXList{$key}}[3])/2;
			lx("tool.viewType UV");
			lx("tool.set xfrm.rotate on");
			lx("tool.reset");
			lx("tool.xfrmDisco {1}");
			lx("tool.setAttr axis.auto axis {2}");
			lx("tool.setAttr axis.auto upX {0}");
			lx("tool.setAttr axis.auto upY {1}");
			lx("tool.setAttr axis.auto upZ {0}");
			lx("tool.setAttr center.auto cenU {$cenU}");
			lx("tool.setAttr center.auto cenV {$cenV}");
			lx("tool.setAttr xfrm.rotate angle {$angle}");
			lx("tool.doApply");
			lx("tool.set xfrm.rotate off");
			#put the selection mode back if i was in verts before.
			if ($mode eq "verts"){lx("select.type vertex");}
		}


		#-------------------------------------------------------------------
		#put the image scale back for this image scale group
		#-------------------------------------------------------------------
		if ((@size[0] != @size[1]) && ($ignoreTexSize != 1)){
			lx("select.drop polygon");
			for (my $i=0; $i<@polys; $i++) { lx("select.element $mainlayer polygon add @polys[$i]");}
			my $scale = @size[1]/@size[0];
			lx("tool.viewType UV");
			lx("tool.set xfrm.stretch on");
			lx("tool.reset");
			lx("tool.setAttr center.auto cenU {0}");
			lx("tool.setAttr center.auto cenV {0}");
			lx("tool.setAttr xfrm.stretch factX {$scale}");
			lx("tool.setAttr xfrm.stretch factY {1}");
			lx("tool.setAttr xfrm.stretch factZ {1}");
			lx("tool.doApply");
			lx("tool.set xfrm.stretch off");
		}
	}

	#restore the original polys list  (we only overwrote it because we were using selectUVGroups per image size set.
	@polys = @polysBackup;
}


#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
#UNRANDOMIZE EACH UV SET
#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
sub unRandomizeUVs{
	foreach my $key (keys %touchingUVList){
		#select the poly group
		lx("select.drop polygon");
		foreach my $poly (@{$touchingUVList{$key}})	{lx("select.element $mainlayer polygon add $poly");}
		my @uvBBOX = @{$uvBBOXList{$key}};
		my @uvBBOXCenter = ( (@{$uvBBOXList{$key}}[2]+@{$uvBBOXList{$key}}[0])/2 , (@{$uvBBOXList{$key}}[3]+@{$uvBBOXList{$key}}[1])/2);
		my @uvDiff = (@uvBBOXCenter[0] , @uvBBOXCenter[1]);
		if (@uvDiff[0] < 0){@uvDiff[0] = @uvDiff[0]-1;}
		if (@uvDiff[1] < 0){@uvDiff[1] = @uvDiff[1]-1;}
		@uvDiff = (int(@uvDiff[0] * -1) , int(@uvDiff[1] * -1));
		#move time
		lx("tool.viewType UV");
		lx("tool.set xfrm.move on");
		lx("tool.reset");
		lx("tool.xfrmDisco {1}");
		lx("tool.setAttr axis.auto axis {2}");
		lx("tool.setAttr center.auto cenU {0}");
		lx("tool.setAttr center.auto cenV {0}");
		lx("tool.setAttr xfrm.move U {@uvDiff[0]}");
		lx("tool.setAttr xfrm.move V {@uvDiff[1]}");
		lx("tool.doApply");
		lx("tool.set xfrm.move off");
	}
}



#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
#CENTER EACH UV SET
#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
sub centerUVs{
	foreach my $key (keys %touchingUVList){
		my $seed = 0;
		if ($sene_randomize == 1){ $seed = int(128*rand)-64;}

		my $moveDistU;
		my $moveDistV;

		#select the current uvgroup's polys.
		lx("select.drop polygon");
		foreach my $poly (@{$touchingUVList{$key}}){	lx("select.element $mainlayer polygon add $poly");	}

		#find the bbox and move dist
		my @uvBBOX = @{$uvBBOXList{$key}};
		if (defined $U){
			if    ($U == 0)	{	$moveDistU = 0 - @uvBBOX[0] + $seed;						}
			elsif ($U == 1)	{	$moveDistU = 0.5 - ((@uvBBOX[0] + @uvBBOX[2])*.5) + $seed;	}
			elsif ($U == 2)	{	$moveDistU = 1 - @uvBBOX[2] + $seed;						}
		}
		if (defined $V){
			if    ($V == 0)	{	$moveDistV = 0 - @uvBBOX[1] + $seed;						}
			elsif ($V == 1)	{	$moveDistV = 0.5 - ((@uvBBOX[1] + @uvBBOX[3])*.5) + $seed;	}
			elsif ($V == 2)	{	$moveDistV = 1 - @uvBBOX[3] + $seed;						}
		}

		if (!defined $moveDistU){	$moveDistU = 0;	}
		if (!defined $moveDistV){	$moveDistV = 0;	}

		#move time
		lx("tool.viewType UV");
		lx("tool.set xfrm.move on");
		lx("tool.reset");
		lx("tool.xfrmDisco {1}");
		lx("tool.setAttr axis.auto axis {2}");
		lx("tool.setAttr center.auto cenU {0}");
		lx("tool.setAttr center.auto cenV {0}");
		lx("tool.setAttr xfrm.move U {$moveDistU}");
		lx("tool.setAttr xfrm.move V {$moveDistV}");
		lx("tool.doApply");
		lx("tool.set xfrm.move off");
	}
}


#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
#APPLY RANDOM MOVEMENT , SCALE , AND ROTATION TO SELECTED UV GROUPS
#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
sub randomizeUVs{
	foreach my $key (keys %touchingUVList){
		lx("select.drop polygon");
		lx("select.element $mainlayer polygon add $_") for @{$touchingUVList{$key}};
		lx("tool.viewType UV");

		if ($sene_randUVMove == 1){
			my $uMove = ((2 * rand) - 1) * $sene_randUVMoveU;
			my $vMove = ((2 * rand) - 1) * $sene_randUVMoveV;
			if ($sene_randUVMoveQuant == 1){
				$uMove = roundNumber($uMove , $sene_randUVMoveQuantU);
				$vMove = roundNumber($vMove , $sene_randUVMoveQuantV);
			}
			lxout("($uMove,$vMove)");

			my $cenU = (@{$uvBBOXList{$key}}[0]+@{$uvBBOXList{$key}}[2])/2;
			my $cenV = (@{$uvBBOXList{$key}}[1]+@{$uvBBOXList{$key}}[3])/2;
			lx("tool.set xfrm.move on");
			lx("tool.reset");
			lx("tool.xfrmDisco {1}");
			lx("tool.setAttr axis.auto axis {2}");
			lx("tool.setAttr center.auto cenU {$cenU}");
			lx("tool.setAttr center.auto cenV {$cenV}");
			lx("tool.setAttr xfrm.move U {$uMove}");
			lx("tool.setAttr xfrm.move V {$vMove}");
			lx("tool.doApply");
			lx("tool.set xfrm.move off");
		}
		if ($sene_randUVScale == 1){
			my $uScale = ((2 * rand)-1) * $sene_randUVScaleU + 1;
			my $vScale = ((2 * rand)-1) * $sene_randUVScaleV + 1;
			if ($sene_randUVScaleQuant == 1){
				$uScale = roundNumber($uScale , $sene_randUVScaleQuantU);
				$vScale = roundNumber($vScale , $sene_randUVScaleQuantV);
				if ($uScale == 0){$uScale = $sene_randUVScaleQuantU;}
				if ($vScale == 0){$vScale = $sene_randUVScaleQuantV;}
			}else{
				if ($uScale == 0){$uScale = $sene_randUVScaleU;}
				if ($vScale == 0){$vScale = $sene_randUVScaleV;}
			}

			lxout("($uScale,$vScale)");

			my $cenU = (@{$uvBBOXList{$key}}[0]+@{$uvBBOXList{$key}}[2])/2;
			my $cenV = (@{$uvBBOXList{$key}}[1]+@{$uvBBOXList{$key}}[3])/2;
			lx("tool.set xfrm.stretch on");
			lx("tool.reset");
			lx("tool.xfrmDisco {1}");
			lx("tool.setAttr axis.auto axis {2}");
			lx("tool.setAttr center.auto cenU {$cenU}");
			lx("tool.setAttr center.auto cenV {$cenV}");
			if ($sene_randUVScaleU == 0)	{lx("tool.setAttr xfrm.stretch factX {1}");}
			else							{lx("tool.setAttr xfrm.stretch factX {$uScale}");}
			if ($sene_randUVScaleV == 0)	{lx("tool.setAttr xfrm.stretch factY {1}");}
			else							{lx("tool.setAttr xfrm.stretch factY {$vScale}");}
			lx("tool.doApply");
			lx("tool.set xfrm.stretch off");
		}
		if ($sene_randUVRotate == 1){
			my $angle = ((2 * rand) - 1) * 360 * $sene_randUVRotateAmt;
			if ($sene_randUVRotateQuant == 1){$angle = roundNumber($angle , $sene_randUVRotateQuantAmt);}
			lxout("($angle)");

			my $cenU = (@{$uvBBOXList{$key}}[0]+@{$uvBBOXList{$key}}[2])/2;
			my $cenV = (@{$uvBBOXList{$key}}[1]+@{$uvBBOXList{$key}}[3])/2;
			lx("tool.set xfrm.rotate on");
			lx("tool.reset");
			lx("tool.xfrmDisco {1}");
			lx("tool.setAttr axis.auto axis {2}");
			lx("tool.setAttr center.auto cenU {$cenU}");
			lx("tool.setAttr center.auto cenV {$cenV}");
			lx("tool.setAttr xfrm.rotate angle {$angle}");
			lx("tool.doApply");
			lx("tool.set xfrm.rotate off");
		}
	}
}

#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
#SEARCH THE SHADER TREE FOR MATERIAL AND APPLY IT
#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
sub applySearchFoundMaterial{
	my @materials;
	my $txLayers = lxq("query sceneservice txLayer.n ? ");
	for (my $i=0; $i<$txLayers; $i++){
		if (lxq("query sceneservice txLayer.type ? $i") eq "mask"){
			my $ptag = lxq("query sceneservice channel.value ? ptag");
			push(@materials,$ptag);
		}
	}

	my @foundMaterials;
	my $text = quickDialog("Material find:",string,"","","");
	my @text = split(/\s/,$text);

	foreach my $material (@materials){
		my $failure = 0;
		foreach my $word (@text){
			if ($material !~ /$word/i){
				$failure = 1;
				last;
			}
		}

		if ($failure == 0){
			push(@foundMaterials,$material);
		}
	}

	if (@foundMaterials > 20){
		lxout("There are too many materials found ($#foundMaterials) for me to post them all, so I'm canceling the script");
	}else{
		my $string = "";
		for (my $i=0; $i<@foundMaterials; $i++){
			if (@foundMaterials[$i] =~ /[\\\/]/){
				my @words = split(/[\\\/]/,@foundMaterials[$i]);
				$string .= $i+1 . " = " . @words[-1] . "\n";
			}else{
				$string .= $i+1 . " = " . @foundMaterials[$i] . "\n";
			}
		}
		if ($string ne "")	{our $material = @foundMaterials[quickDialog($string,integer,1,1,$#foundMaterials+1) - 1];}
		else				{die("That search request returned no results");}
		lx("!!poly.setMaterial {$material}");
	}
}

#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
#GRAB THE LAST POLY's MATERIAL SUB
#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
sub grabMaterial{
	my $shadingMode = lxq("viewport.3dView background:?");

	#make sure the main layer is visible!
	my @verifyMainlayerVisibilityList = verifyMainlayerVisibility();

	#only select the item if the current viewport isn't set to wireframe mode.
	if ($shadingMode ne "wire"){
		our $fgLayerCount1 = lxq("query layerservice layer.n ? fg");
		lx("select.type item");
		lx("select.3DElementUnderMouse add");
		our $fgLayerCount2 = lxq("query layerservice layer.n ? fg");
	}

	my $poly = lxq("query view3dservice element.over ? POLY");

	if ($shadingMode ne "wire"){
		if ($fgLayerCount1 < $fgLayerCount2){	lx("select.3DElementUnderMouse remove");	}
		lx("select.type polygon");
	}

	my @poly = split(/,/, $poly);
	if  ($poly =~ /,/){
		my $layer = @poly[0]+1;
		my $layerName1 = lxq("query layerservice layer.name ? $layer");
		my $material = lxq("query layerservice poly.material ? @poly[1]");
		my $layerName2 = lxq("query layerservice layer.name ? $mainlayer");
		lx("!!user.value sene_surfaceGrab [$material]");
	}
	else{die("Your mouse apparently wasn't any geometry in a 3d viewport, so I'm canceling the script");}

	#put back the mainlayer visibility.
	verifyMainlayerVisibility(\@verifyMainlayerVisibilityList);
}




#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
#APPLY THE GRABBED MATERIAL SUB
#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
sub applyGrabbedMaterial{
	$sene_surfaceGrab = lxq("user.value sene_surfaceGrab ?");
	lx("poly.setMaterial [$sene_surfaceGrab] default:[1]");
}


#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
#SELECT THE IMAGE ON THE MATERIAL ON THE POLY UNDER THE MOUSE
#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
sub selectMaterialImage{
	#make mainlayer visible so item selection doesn't fail.
	my @verifyMainlayerVisibilityList = verifyMainlayerVisibility();

	my $fgLayerCount1 = lxq("query layerservice layer.n ? fg");
	lx("select.type item");
	lx("select.3DElementUnderMouse add");
	my $fgLayerCount2 = lxq("query layerservice layer.n ? fg");
	my $view = lxq("query view3dservice mouse.view ?");
	my $poly = lxq("query view3dservice element.over ? POLY");
	if ($fgLayerCount1 < $fgLayerCount2){	lx("select.3DElementUnderMouse remove");	}
	lx("select.type polygon");

	my @poly = split(/,/, $poly);
	if  ($poly =~ /,/){
		my $layer = @poly[0]+1;
		my $layerName1 = lxq("query layerservice layer.name ? $layer");
		our $material = lxq("query layerservice poly.material ? @poly[1]");
		my $layerName2 = lxq("query layerservice layer.name ? $mainlayer");
	}

	my $path = lxq("user.value sene_matRepairPath ?");
	$path =~ s/\\$//;
	$path =~ s/\/$//;
	lxout("material = $material");
	if ($material !~ /\:/)	{	$material = $path."\/".$material;	}
	else					{	lxout("This material had a drive letter in it's path and so I'm not appending the game dir");	}
	OSPathNameFix($material);
	$material = lc($material);

	if ($material ne ""){
		my $clips = lxq("query layerservice clip.n ? all");
		my $found = 0;
		for (my $i=0; $i<$clips; $i++){
			my $fileName = lxq("query layerservice clip.file ? $i");
			$fileName =~ s/\.[a-z]+//;
			OSPathNameFix($fileName);
			$fileName = lc($fileName);
			if ($fileName eq $material){
				my $clipID = lxq("query layerservice clip.id ? $i");
				lx("select.subItem {$clipID} set mediaClip");
				$found = 1;
				last;
			}
		}
		if ($found == 0){
			lxout(".Deselecting items because your mouse wasn't over a poly that had an image on it and\nso I want to deselect images to make the uv view clear");
			lx("select.drop item");
			lx("select.type polygon");
		}
	}else{
		lxout("..Deselecting items because your mouse wasn't over a poly that had an image on it and\nso I want to deselect images to make the uv view clear");
		lx("select.drop item");
		lx("select.type polygon");
	}

	#restore the mainlayer visibility
	verifyMainlayerVisibility(\@verifyMainlayerVisibilityList);
}


#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
#DELETE THE UNUSED TEXTURE LOCATORS
#------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------
sub deleteUnusedTxLocators{
	my $txLayers = lxq("query sceneservice txLayer.n ? all");
	my %txLayerTable;
	my @totalTextureLocators;
	my @usedTextureLocators;
	for (my $i=0; $i<$txLayers; $i++){
		my $type = lxq("query sceneservice txLayer.type ? $i");
		if (($type eq "imageMap") || ($type eq "dots") || ($type eq "grid") || ($type eq "checker") || ($type eq "noise") || ($type eq "cellular") || ($type eq "wood") || ($type eq "gradient") || ($type eq "constant")){
			my $id = lxq("query sceneservice txLayer.id ? $i");
			lx("select.subItem [$id] set textureLayer;render;environment;mediaClip");
			my $name = lxq("texture.setLocator [$id] locator:?");
			push(@usedTextureLocators, $name);
		}
	}

	my $itemCount = lxq("query sceneservice item.n ? all");
	for (my $i=0; $i<$itemCount; $i++){
		my $type = lxq("query sceneservice item.type ? $i");
		if ($type eq "txtrLocator"){
			my $name = lxq("query sceneservice item.name ? $i");
			my $id = lxq("query sceneservice item.id ? $i");
			push(@totalTextureLocators,$name);
			$txLayerTable{$name} = $id;
		}
	}

	my @unusedTextureLocators = removeListFromArray(\@totalTextureLocators,\@usedTextureLocators);

	for (my $i=0; $i<@unusedTextureLocators; $i++){
		my $id = $txLayerTable{@unusedTextureLocators[$i]};
		lxout("Deleting this texture locator : @unusedTextureLocators[$i]");
		lx("select.subItem [$id] set mesh;meshInst;camera;light;txtrLocator;backdrop;groupLocator;locator;deform [0] [1]");
		lx("!!item.delete");
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SHADER TREE : SELECT THESE MATERIALS
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub ST_selectTheseMaterials{
	lxout("[->] : SHADER TREE : SELECT THESE MATERIALS SUB");

	my %materials;
	my @layers = lxq("query layerservice layers ? visible");
	foreach my $layer (@layers){
		my $name = lxq("query layerservice layer.name ? $layer");
		my $materialCount = lxq("query layerservice material.n ? all");
		for (my $i=0; $i<$materialCount; $i++){
			my $name = lxq("query layerservice material.name ? $i");
			$materials{$name} = 1;
		}
	}


	my @masks = lxq("query sceneservice selection ? mask");
	foreach my $mask (@masks){
		my $name = lxq("query sceneservice item.name ? $mask");
		my $ptag = lxq("query sceneservice channel.value ? ptag");
		if ($materials{$ptag} == 1){
			lx("select.polygon add material face {$ptag}");
		}else{
			lxout("this material isn't being used : $ptag");
		}
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SHADER TREE : APPLY THIS MATERIAL
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub ST_apply_this_material{
	my $txLayers = lxq("query sceneservice txLayer.n ? all");
	for (my $i=0; $i<$txLayers; $i++){
		if ((lxq("query sceneservice txLayer.type ? $i") eq "mask") && (lxq("query sceneservice txLayer.isSelected ? $i") == 1)){
			my $id = lxq("query sceneservice txLayer.id ? $i");
			lx("select.subItem {$id} set textureLayer;render;environment;mediaClip;locator");
			my $ptag = lxq("mask.setPTag ?");
			if ($ptag ne "(none)"){
				lx("poly.setMaterial {$ptag}");
			}else{
				my $name = lxq("query sceneservice txLayer.name ? $i");
				if ($name =~ /Matr: /) {$name =~ s/Matr: //;}
				if ($name ne ""){lx("poly.setMaterial {$name}");}
			}
			last;
		}
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#APPLY PART PER UV GROUP : (good for uv welding)
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub applyPartPerUVGroup{
	my @alphabet = (a..z,0..9);
	my @reorderingList;

	foreach my $key (keys %touchingUVList){
		my $seed = 0;
		my $randomPart = "";
		for (my $i=0; $i<12; $i++){
			my $letter = @alphabet[int(@alphabet*rand)];
			$randomPart .= $letter;
		}


		#select the current uvgroup's polys and apply the part
		lx("select.drop polygon");
		for (my $i=0; $i<@{$touchingUVList{$key}}; $i++){
			my $count = 0;
			my $currentPoly = @{$touchingUVList{$key}}[$i];
			foreach my $number (@reorderingList){if ($number < $currentPoly){$count++;}}
			$currentPoly -= $count;
			lx("select.element $mainlayer polygon add $currentPoly");
		}
		lx("poly.setPart {$randomPart}");

		push(@reorderingList,@{$touchingUVList{$key}});
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#CLIP_SELECT MATERIALS : will select all masks in ST based off of clips that are selected
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub clip_selectMaterials{
	my @masksToSelect;
	my $clipCount = lxq("query layerservice clip.n ? all");
	&shaderTreeTools(buildDbase);

	#deselect all masks
	my @masksToDeselect = lxq("query sceneservice selection ? mask");
	lx("select.subItem {$_} remove textureLayer;render;environment;light;camera;mediaClip;txtrLocator") for @masksToDeselect;

	#select all clip defined masks
	for (my $i=0; $i<$clipCount; $i++){
		if (lxq("query sceneservice clip.isSelected ? $i") == 1){
			my $fileName = lxq("query layerservice clip.file ? $i");
			$fileName = clipNameFix($fileName);
			my $maskID = shaderTreeTools(ptag, maskID, $fileName);
			if ($maskID ne ""){
				lx("select.subItem {$maskID} add textureLayer;render;environment;light;camera;mediaClip;txtrLocator")
			}else{
				lxout("couldn't find maskID for -$fileName-");
			}
		}
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#DELETE THESE CLIPS
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub deleteTheseClips{
	my $clips = lxq("query layerservice clip.n ? all");
	my @selectedClips;
	for (my $i=0; $i<$clips; $i++){
		if (lxq("query sceneservice clip.isSelected ? $i") == 1){
			my $filePath = lxq("query layerservice clip.file ? $i");
			if ($os =~ /win/i){$filePath =~ s/\//\\/g;}
			push(@selectedClips,$filePath);
		}
	}

	my $printLine = "Are you sure you wish to delete these images?";
	$printLine .= "\n" . $_ for @selectedClips;

	system "del $_" for @selectedClips;
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#OPEN CLIP DIRS
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub openDirInExplorer{
	my $clips = lxq("query layerservice clip.n ? all");
	my @selectedClips;
	for (my $i=0; $i<$clips; $i++){
		if (lxq("query sceneservice clip.isSelected ? $i") == 1){
			my $filePath = lxq("query layerservice clip.file ? $i");
			if ($os =~ /win/i){$filePath =~ s/\//\\/g;}
			push(@selectedClips,$filePath);
		}
	}

	lxout("selectedClips = @selectedClips");
	foreach my $path (@selectedClips){
		#my @words = split(/\\/,$path);
		#my $newPath;
		#for (my $i=0; $i<$#words; $i++){$newPath .= @words[$i] . "\\";}
		system "explorer \/select,$path";
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#CHECK OUT CLIPS
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub checkoutClips{
	my $clips = lxq("query layerservice clip.n ? all");
	my @selectedClips;
	for (my $i=0; $i<$clips; $i++){
		if (lxq("query sceneservice clip.isSelected ? $i") == 1){
			my $filePath = lxq("query layerservice clip.file ? $i");
			if ($os =~ /win/i){$filePath =~ s/\//\\/g;}
			$filePath =~ s/\..*//;
			my $tgaPath = $filePath . ".tga";
			my $psdPath = $filePath . ".psd";
			if (-e $tgaPath){system("p4 edit \"$tgaPath\"");}
			if (-e $psdPath){system("p4 edit \"$psdPath\"");}
		}
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#OPEN SPECIFIC IMAGE IN PHOTOSHOP
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub openSpecificImageInPS{
	my @imagesToOpen;
	opendir($shaderDir,$shaderDir) || die("Cannot opendir $shaderDir");
	@files = (sort readdir($shaderDir));

	my $clipCount = lxq("query sceneservice clip.n ? all");
	my @shaderNames;
	for (my $i=0; $i<$clipCount; $i++){
		if (lxq("query sceneservice clip.isSelected ? $i") == 1){
			my $filePath = lxq("query sceneservice clip.refPath ? $i");
			$filePath = clipNameFix($filePath);
			push(@shaderNames,$filePath);
		}
	}

	createShaderArray(@shaderNames);
	&decipherShaders();
	close($shaderDir);
	foreach my $key (keys %decipherShaders){
		my $bump =		"";
		my $diffuse =	"";
		my $specular =	"";
		my $power =		"";
		my $height	=	"";


		#gather file paths
		my @bumpImageInfo = split(/,/,@{$decipherShaders{$key}}[3]);
		if		($bumpImageInfo[0] eq "A"){$bump = $bumpImageInfo[1]; $height = $bumpImageInfo[2];}
		elsif	($bumpImageInfo[0] eq "B"){$bump = $bumpImageInfo[1];}
		elsif	($bumpImageInfo[0] eq "H"){$height = $bumpImageInfo[2];}

		my @diffuseImageInfo = split(/,/,@{$decipherShaders{$key}}[4]);
		if (@diffuseImageInfo[0] ne "constantColor"){$diffuse = @diffuseImageInfo[0];}

		my @specularImageInfo = split(/,/,@{$decipherShaders{$key}}[5]);
		if (@specularImageInfo[0] eq "constantColor"){$specular = @specularImageInfo[0];}

		if (@{$decipherShaders{$key}}[1] =~ /[a-z]/i){$power = @{$decipherShaders{$key}}[1];}

		#lxout("bump = $bump");
		#lxout("diffuse = $diffuse");
		#lxout("specular = $specular");
		#lxout("power = $power");
		#lxout("height = $height");

		#build array
		if		(($U == 1) && ($bump ne ""))		{	push(@imagesToOpen,$bump);		}
		elsif	(($V == 1) && ($diffuse ne ""))		{	push(@imagesToOpen,$diffuse);	}
		elsif	(($axis == 0) && ($specular ne ""))	{	push(@imagesToOpen,$specular);	}
		elsif	(($axis == 1) && ($power ne ""))	{	push(@imagesToOpen,$power);		}
		elsif	(($axis == 2) && ($height ne ""))	{	push(@imagesToOpen,$height);	}
	}

	#send array of files to photoshop
	if (@imagesToOpen > 0){
		s/\//\\/g for @imagesToOpen;
		system $sene_imgEditPath,@imagesToOpen;
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#OPEN PSDS IN PHOTOSHOP
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub openPSDsInPhotoshop{
	my $clips = lxq("query layerservice clip.n ? all");
	my @selectedClips;
	for (my $i=0; $i<$clips; $i++){
		if (lxq("query sceneservice clip.isSelected ? $i") == 1){
			my $filePath = lxq("query layerservice clip.file ? $i");
			if ($os =~ /win/i){$filePath =~ s/\//\\/g;}
			$filePath =~ s/\..*//;
			my $tgaPath = $filePath . ".tga";
			my $psdPath = $filePath . ".psd";
			my $psbPath = $filePath . ".psb";
			if (-e $tgaPath){
				if ((!-W $tgaPath) && ($checkoutClips == 1)){system("p4 edit \"$tgaPath\"");lxout("checking out TGA : $tgaPath");}
			}
			if (-e $psdPath){
				if ((!-W $psdPath) && ($checkoutClips == 1)){system("p4 edit \"$psdPath\"");lxout("checking out PSD : $psdPath");}
				push(@selectedClips,$psdPath);
			}elsif (-e $psbPath){
				if ((!-W $psbPath) && ($checkoutClips == 1)){system("p4 edit \"$psbPath\"");lxout("checking out PSB : $psbPath");}
				push(@selectedClips,$psbPath);
			}elsif (-e $tgaPath){
				lxout("[->] : This psd ($psdPath) doesn't exist and so I'm opening the TGA instead");
				push(@selectedClips,$tgaPath);
			}
		}
	}

	if (($sene_imgEditPath ne "") && (-e $sene_imgEditPath)){
		if (@selectedClips > 0){
			lxout("selectedClips = @selectedClips");
			system $sene_imgEditPath,@selectedClips;
		}else{
			lxout("No TGAs or PSDs appeared to exist in relation to the currently selected clips, so I can't open them");
		}
	}else{
		die("The selected clips can't be opened because the image editor path in the GLOBAL OPTIONS window of the superUVsMini form is pointing to an exe that doesn't actually exist.  Please change that file path to be the correct file path (ie, W:/rage/base) and try running the script again.  If you're not working on a game like Doom or Rage that has a special naming structure, then leave the GAME PATH option blank");
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#OPEN CLIPS IN PHOTOSHOP
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub openClipsInPhotoshop{
	my $clips = lxq("query layerservice clip.n ? all");
	my @selectedClips;
	for (my $i=0; $i<$clips; $i++){
		if (lxq("query sceneservice clip.isSelected ? $i") == 1){
			my $filePath = lxq("query layerservice clip.file ? $i");
			if ($os =~ /win/i){$filePath =~ s/\//\\/g;}
			if ($checkoutClips == 1){system("p4 edit \"$filePath\"");}
			push(@selectedClips,$filePath);
		}
	}

	if (($sene_imgEditPath ne "") && (-e $sene_imgEditPath)){
		lxout("selectedClips = @selectedClips");
		system $sene_imgEditPath,@selectedClips;
	}else{
		die("The selected clips can't be opened because the image editor path in the GLOBAL OPTIONS window of the superUVsMini form is pointing to an exe that doesn't actually exist.  Please change that file path to be the correct file path (ie, W:/rage/base) and try running the script again.  If you're not working on a game like Doom or Rage that has a special naming structure, then leave the GAME PATH option blank");
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#TGA --> JPG conversion
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub TGA_JPGconversion{
	lxout("[->] : TGA_JPGconversion subroutine");
	my $txLayerCount = lxq("query sceneservice txLayer.n ? all");
	my $exe;
	if ($modoVer < 500)	{	$exe = $cfgPath .  "\/Scripts\/ImageConvert.exe";	}
	else				{	$exe = $scriptsPath . "\/ImageConvert.exe";			}

	OSPathNameFix($exe);
	if (!-e $exe){die("Can't run script because ImageConvert.exe is missing.  It's supposed to be copied into your scripts dir : ($scriptsPath)");}
	my @images = "";

	#all currently open images
	if ($U == 1){
		my $clipCount = lxq("query layerservice clip.n ? all");
		for (my $i=0; $i<$clipCount; $i++){push(@images,lxq("query layerservice clip.file ? $i"));}
	}
	#all currently open images with a file path filter
	elsif ($V == 1){
		my $nameFilter = quickDialog("Enter the name filter :",string,"","","");
		if ($nameFilter eq ""){die("No file path filter was typed in, so I'm cancelling the script");}

		my $clipCount = lxq("query layerservice clip.n ? all");
		for (my $i=0; $i<$clipCount; $i++){
			my $filePath = lxq("query layerservice clip.file ? $i");
			if ($filePath =~ /$nameFilter/){
				push(@images,$filePath);
			}
		}
	}
	#all images that the materials should point to
	elsif ($up == 1){
		my $txLayerCount = lxq("query sceneservice txLayer.n ? all");
		for (my $i=0; $i<$txLayerCount; $i++){
			if (lxq("query sceneservice txLayer.type ? $i") eq "mask"){
				my $id = lxq("query sceneservice txLayer.id ? $i");
				my $ptag = lxq("query sceneservice channel.value ? ptag");
				my $filePath = $sene_matRepairPath . $ptag . ".tga";
				push(@images,$filePath);
			}
		}
	}
	#all the selected polys' images
	elsif ($down == 1){
		my %ptagList;
		my @polys = lxq("query layerservice polys ? selected");
		foreach my $poly (@polys){
			my $ptag = lxq("query layerservice poly.material ? $poly");
			$ptagList{$ptag} = 1;
		}
		foreach my $key (keys %ptagList){
			my $filePath = $sene_matRepairPath . $key . ".tga";
			push(@images,$filePath);
		}
	}
	#all the selected clips
		elsif ($left == 1){
		my $clips = lxq("query layerservice clip.n ? all");
		my @selectedClips;
		for (my $i=0; $i<$clips; $i++){
			if (lxq("query sceneservice clip.isSelected ? $i") == 1){
				push(@selectedClips,$i);
			}
		}
		foreach my $clip (@selectedClips){
			my $filePath = lxq("query layerservice clip.file ? $clip");
			$filePath =~ s/\..*/\.tga/i;
			push(@images,$filePath);
		}
	}
	#no arguments entered, so cancel script
	else	{die("The script was run without the proper arguments, so it didn't know which images it should convert to JPGs.");}



	#[-----------------------------------------------------------]
	# now go through all found clips and run the process on them.
	#[-----------------------------------------------------------]
	foreach my $filePath (@images){
		OSPathNameFix($filePath);
		my $jpgPath = $filePath;
		$jpgPath =~ s/\.tga/.jpg/;

		my $photoshopPath = $filePath;
		OSPathNameFix($filePath);
		if (-e $filePath){
			if (-e $jpgPath){
				if (($forceOverwrite == 1) && (($sene_matRepairPath =~ /rage/i) || ($sene_matRepairPath =~ /doom/i))){
					if (!-w $jpgPath)	{system("p4 edit \"$jpgPath\"");}
					if (!-w $jpgPath)	{popup("The p4 checkout is failing for ($jpgPath) and so it appears that you're not logged into perforce and so I'm cancelling the script");					}
					system $exe,"$photoshopPath","$jpgPath",85,2;
					lxout("This TGA was just force converted to a JPG : $photoshopPath");
				}else{
					lxout("This TGA already had a JPG of the same name ($jpgPath) so I'm skipping it.");
				}
			}else{
				system $exe,"$photoshopPath","$jpgPath",85,2;
				lxout("This TGA was just converted to a JPG : $photoshopPath");

				if (($sene_matRepairPath =~ /rage/i) || ($sene_matRepairPath =~ /doom/i)){
					system("p4 add \"$jpgPath\"");
				}
			}
		}else{
			lxout("This material's ptag points to a TGA that doesn't exist : $filePath");
		}
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SELECT THESE MASKS SUB
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub selTheseMasks{
	lxout("===========================================================================================");
	lxout("===========================================================================================");
	lxout("Now selecting all the masks that match those parameters");
	lxout("===========================================================================================");
	lxout("===========================================================================================");

	my $nameList = quickDialog("Type in the material names\nyou want to select\n(seperated by commas)",string,"","","");
	my @names = split(/,/, $nameList);
	my @foundMasks;

	my $txLayers = lxq("query sceneservice txLayer.n ? all");
	for (my $i=0; $i<$txLayers; $i++){
		if (lxq("query sceneservice txLayer.type ? $i") eq "mask"){
			my $name = lxq("query sceneservice txLayer.name ? $i");
			foreach my $checkName (@names){
				if ($name =~ /$checkName/i){
					my @children = lxq("query sceneservice txLayer.children ? $i"); #now add the found mask's material to the selection list
					foreach my $child (@children){
						if (lxq("query sceneservice txLayer.type ? $child") eq "advancedMaterial"){
							push(@foundMasks,$child);
						}
					}
					push(@foundMasks, lxq("query sceneservice txLayer.id ? $i"));
				}
			}
		}
	}

	if ($print == 1){
		my $number = @foundMasks * .5;
		my $text;
		if (@foundMasks < 40){
			foreach my $id (@foundMasks){
				if (lxq("query sceneservice txLayer.type ? $id") eq "mask"){
					my $name = lxq("query sceneservice txLayer.name ? $id");
					$text .= "\n" . $name;
				}
			}
		}
		popup("There are ($number) found masks. $text");
	}

	for (my $i=0; $i<@foundMasks; $i++){
		if ($i > 0){
			lx("select.subItem [@foundMasks[$i]] add textureLayer;render;environment;mediaClip;locator");
		}else{
			lx("select.subItem [@foundMasks[$i]] set textureLayer;render;environment;mediaClip;locator");
		}
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SEND SELECTED POLYS' DIFFUSE MAPS TO PHOTOSHOP (works with multiple layers selected)
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub sendPolyImagesToPS{
	my %polys;
	my @firstLastPolys = createPerLayerElemList(poly,\%polys);
	my %materialList;
	my @materials;
	foreach my $layer (keys %polys){
		my $layerName = lxq("query layerservice layer.name ? $key");
		foreach my $poly (@{$polys{$layer}}){
			$materialList{lxq("query layerservice poly.material ? $poly")} = 1;
		}
	}
	foreach my $material (keys %materialList){ # TEMP : this should be going through all clips to find the file extension it should be opening.  I'm going to hardcode it to open TGAs now though.
		if ($material !~ /:/){$material = $sene_matRepairPath . "\/" . $material;}
		$material =~ s/\//\\/g;
		$material = $material . "\.tga";
		push(@materials,$material);
	}

	system $sene_imgEditPath,@materials;
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#QUANTIZE PRESETS SUB
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub quantizePresets{
	if ($down == 1){
		$sene_quantizeU *= .5;
		$sene_quantizeV *= .5;
	}elsif ($up == 1){
		$sene_quantizeU *= 2;
		$sene_quantizeV *= 2;
	}elsif ($left == 1){
		$sene_quantizeU = .5;
		$sene_quantizeV = .5;
	}elsif ($right == 1){
		$sene_quantizeU = .25;
		$sene_quantizeV = .25;
	}elsif ($avgProp == 1){
		$sene_quantizeU = .125;
		$sene_quantizeV = .125;
	}else{
		$sene_quantizeU = 1;
		$sene_quantizeV = 1;
	}

	lx("!!user.value sene_quantizeU $sene_quantizeU");
	lx("!!user.value sene_quantizeV $sene_quantizeV");
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#UV BUFFER FIT SUB (similar to alignFit)
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub uvBufferFit{
	#store the polys to the buffer
	if ($U == 1){
		lxout("[->] : Storing the UV bbox of the current selection");
		my @keys = (keys %touchingUVList);
		my $width = (@{$uvBBOXList{@keys[0]}}[2] - @{$uvBBOXList{@keys[0]}}[0]);
		my $height = (@{$uvBBOXList{@keys[0]}}[3] - @{$uvBBOXList{@keys[0]}}[1]);
		my @center = ((@{$uvBBOXList{@keys[0]}}[2] + @{$uvBBOXList{@keys[0]}}[0]) * .5 , (@{$uvBBOXList{@keys[0]}}[3] + @{$uvBBOXList{@keys[0]}}[1]) * .5);
		my $string = $width . "," . $height . "," . @center[0] . "," . @center[1];
		lx("user.value sene_UVBufferFit {$string}");
	}
	#fit the polys to the buffer
	else{
		my @uvBuffer = split(/,/, $sene_UVBufferFit);
		if ($uvBuffer[0] > $uvBuffer[1])	{our $uvBufferLargestSize = 0;}
		else								{our $uvBufferLargestSize = 1;}

		lx("tool.viewType UV");
		foreach my $key (keys %touchingUVList){
			lx("select.drop polygon");
			lx("select.element $mainlayer polygon add $_") for @{$touchingUVList{$key}};

			my $width = (@{$uvBBOXList{$key}}[2] - @{$uvBBOXList{$key}}[0]);
			my $height = (@{$uvBBOXList{$key}}[3] - @{$uvBBOXList{$key}}[1]);
			my $largestAxis;
			if ($width > $height)	{$largestAxis = 0;}
			else					{$largestAxis = 1;}

			my @center = ((@{$uvBBOXList{$key}}[2] + @{$uvBBOXList{$key}}[0]) * .5 , (@{$uvBBOXList{$key}}[3] + @{$uvBBOXList{$key}}[1]) * .5);
			my @disp = (-1*(@center[0]-@uvBuffer[2]) , -1*(@center[1]-@uvBuffer[3]));

			if (($autoAngle == 1) && ($uvBufferLargestSize != $largestAxis)){
				our @stretchAmount = (@uvBuffer[0]/$height , @uvBuffer[1]/$width);
			}else{
				our @stretchAmount = (@uvBuffer[0]/$width , @uvBuffer[1]/$height);
			}

			lx("tool.set xfrm.move on");
			lx("tool.reset");
			lx("tool.xfrmDisco {1}");
			lx("tool.setAttr axis.auto axis {2}");
			lx("tool.setAttr center.auto cenU {@center[0]}");
			lx("tool.setAttr center.auto cenV {@center[1]}");
			lx("tool.setAttr xfrm.move U {@disp[0]}");
			lx("tool.setAttr xfrm.move V {@disp[1]}");
			lx("tool.doApply");
			lx("tool.set xfrm.move off");

			if (($autoAngle == 1) && ($uvBufferLargestSize != $largestAxis)){
				lx("tool.set xfrm.rotate on");
				lx("tool.reset");
				lx("tool.xfrmDisco {1}");
				lx("tool.setAttr axis.auto axis {2}");
				lx("tool.setAttr center.auto cenU {@uvBuffer[2]}");
				lx("tool.setAttr center.auto cenV {@uvBuffer[3]}");
				lx("tool.setAttr xfrm.rotate angle {90}");
				lx("tool.doApply");
				lx("tool.set xfrm.rotate off");
			}

			lx("tool.set xfrm.stretch on");
			lx("tool.reset");
			lx("tool.xfrmDisco {1}");
			lx("tool.setAttr axis.auto axis {2}");
			lx("tool.setAttr center.auto cenU {@uvBuffer[2]}");
			lx("tool.setAttr center.auto cenV {@uvBuffer[3]}");
			lx("tool.setAttr xfrm.stretch factX {@stretchAmount[0]}");
			lx("tool.setAttr xfrm.stretch factY {@stretchAmount[1]}");
			lx("tool.doApply");
			lx("tool.set xfrm.stretch off");
		}
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SAVE MESH PRESET SUB
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub saveMeshPresets{
	our %dirResult;
	our %exclusionList;
	my @ignoreDirs = (work,_test,temp,bentpanel,buildings,deven_temp,erectoset,foliage,jerry_test,mal_temp,matt,mausoleums,northern_highway,prop,rocks,ryan,steve_temp,terrain,test,umdeco,plateau_bridge);
	my @matchFilePatterns = ("\\\.lwo");
	my @ignoreFilePatterns = ("work\\\.lwo","work\\\.ase","_base","base\\\.lwo","_render","_hi","_high","_hp","blockout","temp");

	#if forceoverwrite on, ask for a minimum age that needs to be overwritten
	if ($lxlOverwrite == 1){our $minAge = quickDialog("Only overwrite LXLs that are older than X hours:",float,1,"","");}


	#================================
	#DETERMINE WHICH FILES TO LOAD
	#================================
	#FIND FILES : dir
	if ($U == 1){
		lx("dialog.setup style:dir");
		lx("dialog.open");
		if (lxres != 0){	die("The user hit the cancel button");	}
		my $dir = lxq("dialog.result ?");
		dir($dir,\@ignoreDirs,\@matchFilePatterns,\@ignoreFilePatterns);
	}
	#FIND FILES : manual selection
	else{
		lx("dialog.setup fileOpenMulti");
		lx("dialog.title [Files to save as mesh presets:]");
		lx("dialog.fileTypeCustom format:[slwo] username:[LWO] loadPattern:[*.lwo] saveExtension:[lwo]");
		lx("dialog.open");
		my @files = lxq("dialog.result ?");
		for (my $i=$#files; $i>-1; $i--){
			if ((-s $files[$i]) > 2000000){
				lxout("skipping file ($files[$i] because it's filesize is over 2mb");
				splice(@files,$i,1);
				next;
			}
			foreach my $pattern (@ignoreFilePatterns){
				if ($files[$i] =~ /$pattern/i){
					lxout("skipping file ($files[$i] because it's matching a name rejection pattern");
					splice(@files,$i,1);
					last;
				}
			}
		}

		if (lxres != 0){	die("The user hit the cancel button");	}
		foreach my $file (@files){$dirResult{$file} = 1;}
	}

	#================================
	#LOAD SCENE, RENDER ICON, SAVE LXL
	#================================
	foreach my $file (keys %dirResult){
		#print out debug info to text file
		if ($debugSaveMesh == 1){
			open (FILE, ">>$saveMeshPresetLogFile") or die("I couldn't open the file : $saveMeshPresetLogFile");
			print FILE $file."\n";
			close(FILE);
		}

		my $lxlFileName = $file;
		$lxlFileName =~ s/\.l[xw]o/\.lxl/i;
		if (-e $lxlFileName){
			if ($lxlOverwrite == 1){
				my $fileModHours = -M $lxlFileName;
				$fileModHours *= 24;
				if ($fileModHours < $minAge){
					lxout("skipping this file because it's apparently not old enough : $lxlFileName (file age = $fileModHours)");
					next;
				}

				if (!-w $lxlFileName){
					system("p4 edit \"$lxlFileName\"");
				}
			}else{
				lxout("[->] : Skipping this file ($lxlFileName) because it already exists");
				next;
			}
		}

		lx("!!scene.open {$file}");
		my $layerName = lxq("query layerservice layer.name ? main");


		#ignore potentially large scenes
		if (lxq("query layerservice material.n ?") > 20){
			lxout("[->] : Skipping this file ($lxlFileName) because it has over 30 materials and that doesn't sound like a map object");
			lx("!!scene.close");
			next;
		}

		#temp fix smoothing angle
		#lx("!!select.itemType advancedMaterial");
		#lx("!!item.channel advancedMaterial\$smAngle 20.0");


		#================================
		#FIND CORRECT UV MAP
		#================================
		my $correctVmap = -1;
		my $vmapWithActualUVs = -1;
		my @uvMaps = lxq("query layerservice vmaps ? texture");
		foreach my $vmap (@uvMaps){
			my $vmapName = lxq("query layerservice vmap.name ? $vmap");
			my @vmapValues = lxq("query layerservice poly.vmapValue ? 0");
			foreach my $vmapPos (@vmapValues){
				if ($vmapPos != 0){
					$vmapWithActualUVs = $vmap;
					last;
				}
			}

			if ($vmapName eq "Texture"){$correctVmap = $vmap;}
		}

		if ($correctVmap != -1){
			my $vmapName = lxq("query layerservice vmap.name ? $correctVmap");
			my @vmapValues = lxq("query layerservice poly.vmapValue ? 0");
			foreach my $vmapPos (@vmapValues){
				if ($vmapPos != 0){
					$vmapWithActualUVs = $correctVmap;
					last;
				}
			}
		}

		#IF ONLY ONE UV MAP
		if (@uvMaps == 1){
			#not Texture
			if ($vmapWithActualUVs != $correctVmap){
				lxout("1 : found only one uv map but it's not Texture");
				my $vmapName = lxq("query layerservice vmap.name ? $vmapWithActualUVs");
				lx("!!select.vertexMap {$vmapName} txuv replace");
				lx("!!vertMap.name Texture txuv active");
			}
			#Texture
			else{
				lxout("2 : found only one uv map and it's Texture");
				my $vmapName = lxq("query layerservice vmap.name ? $vmapWithActualUVs");
				lx("!!select.vertexMap {$vmapName} txuv replace");
			}
		}
		#IF MULTIPLE UV MAPS
		elsif (@uvMaps > 1){
			#not Texture
			if ($vmapWithActualUVs != $correctVmap){
				lxout("3 : found multiple uv maps and it's not Texture");
				foreach my $currentVmap (@uvMaps){
					if ($currentVmap != $vmapWithActualUVs){
						my $vmapName = lxq("query layerservice vmap.name ? $currentVmap");
						lx("!!select.vertexMap {$vmapName} txuv add");
					}
				}
				lx("!!vertMap.delete txuv");
				my @newUVMaps = lxq("query layerservice vmaps ? texture");
				my $vmapName = lxq("query layerservice vmap.name ? $newUVMaps[0]");
				lx("!!select.vertexMap {$vmapName} txuv replace");
				lx("!!vertMap.name Texture txuv active");
			}
			#Texture
			else{
				lxout("4 : found multiple uv maps and it's Texture");
				foreach my $currentVmap (@uvMaps){
					if ($currentVmap != $vmapWithActualUVs){
						my $vmapName = lxq("query layerservice vmap.name ? $currentVmap");
						lx("!!select.vertexMap {$vmapName} txuv add");
					}
				}
				lx("!!vertMap.delete txuv");
				my @newUVMaps = lxq("query layerservice vmaps ? texture");
				my $vmapName = lxq("query layerservice vmap.name ? $newUVMaps[0]");
				lx("!!select.vertexMap {$vmapName} txuv replace");
			}
		}
		#IF NO UV MAPS
		else{
			lxout("[->] : skipping this model ($lxlFileName) because it has NO uv maps");
			lx("!!scene.close");
			next;
		}


		#================================
		#DELETE CLIP POLYS
		#================================
		my $materialCount = lxq("query layerservice material.n ? all");
		for (my $i=$materialCount-1; $i>-1; $i--){
			my $name = lxq("query layerservice material.name ? $i");
			if		($name =~ /collision\d*$/i){
				lxout("[->] : deleting collision polys");
				lx("!!select.drop polygon");
				lx("!!select.polygon add material face {$name}");
				lx("!!delete");
			}
		}

		#================================
		#FIT CAMERA
		#================================
		my @layerBounds = lxq("query layerservice layer.bounds ? $mainlayer");
		my @layerSize = ( $layerBounds[3] - $layerBounds[0] , $layerBounds[4] - $layerBounds[1] , $layerBounds[5] - $layerBounds[2] );
		my $largestSize = returnMaxValue(@layerSize);
		lxout("layerSize = @layerSize");
		lxout("largestSize = $largestSize");
		my @layerCenter = ( ($layerBounds[0]+$layerBounds[3]) * .5 , ($layerBounds[1]+$layerBounds[4]) * .5 , ($layerBounds[2]+$layerBounds[5]) * .5 );
		my $v1 = 0.6123*$largestSize*4;
		my $v2 = 0.5*$largestSize*4;
		my @camPos = ( $layerCenter[0] + $v1 , $layerCenter[1] + $v2 , $layerCenter[2] + $v1 );
		my $camFocDepth = sqrt(($v1*$v1)+($v2*$v2)+($v1*$v1));
		lx("!!select.itemType camera");
		lx("!!transform.channel pos.X {$camPos[0]}");
		lx("!!transform.channel pos.Y {$camPos[1]}");
		lx("!!transform.channel pos.Z {$camPos[2]}");
		lx("!!transform.channel rot.X {-30.0}");
		lx("!!transform.channel rot.Y {45}");
		lx("!!item.channel camera\$target {$camFocDepth}");
		my $fov = lxq("camera.hfov ?") * .7;
		lx("!!camera.hfov {$fov}");

		#================================
		#CLEAN UP MATERIAL NAMES
		#================================


		#================================
		#CHANGE RENDER SETTINGS
		#================================
		lx("!!select.itemType polyRender");
		lx("!!render.res 0 256");
		lx("!!render.res 1 256");
		lx("!!item.channel ambRad 0.5");
		lx("select.itemType renderOutput");
		my @renderOutputs = lxq("query sceneservice selection ? renderOutput");
		foreach my $id (@renderOutputs){
			lx("select.subItem {$id} set textureLayer;render;environment;light;camera;mediaClip;txtrLocator");
			lx("item.channel renderOutput\$gamma 1.6");
		}

		#================================
		#FIX MATERIAL PROPERTIES
		#================================

		lx("select.itemType advancedMaterial");
		lx("item.channel advancedMaterial\$diffAmt 1");
		lx("item.channel advancedMaterial\$specAmt 0.01");
		lx("item.channel advancedMaterial\$rough 0.5");
		lx("item.channel advancedMaterial\$subsAmt 0");
		lx("item.channel advancedMaterial\$tranAmt 0");
		lx("item.channel advancedMaterial\$radiance 0");
		lx("item.channel advancedMaterial\$bump 1");
		lx("item.channel advancedMaterial\$reflAmt 0");

		#================================
		#APPLY JPEGs
		#================================
		TGA_JPGconversion();
		$jpg = 1; $bumpDiffSpec = 0;
		$failCount = 0;
		repair_shaders();

		#================================
		#SAVE PRESET
		#================================
		lx("!!select.itemType mesh");
		lx("!!item.presetStore mask:mesh filename:{$lxlFileName}");

		#================================
		#APPLY TGAs FOR SHOT *too slow*
		#================================
		if ($failCount > 0){
			$bumpDiffSpec = 1; $jpg = 0;
			&repair_shaders;
		}

		#================================
		#SAVE ICON
		#================================
		lx("render");
		if (lxres != 0){ die("The user hit the cancel button");	}
		lx("!!select.filepath {$lxlFileName} mode:set");
		lx("!!select.preset {$lxlFileName} mode:set");
		lx("!!preset.thumbReplace image:render");
		lx("!!scene.close");
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#FIX FACET MATERIALS SUB
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#usage : if no arguments, then it will repair all.  If you send it a ptag argument, it'll only fix that one.
#example : fixFacetMaterials();
#example : fixFacetMaterials("textures/common/256","textures/common/256_grey");
sub fixFacetMaterials{
	lxout("[->] : Running fixFacetMaterials sub");
	opendir($shaderDir,$shaderDir) || die("Cannot opendir $shaderDir");
	@files = (sort readdir($shaderDir));
	my @ptags;

	my %materialTable;
	my $layerCount = lxq("query layerservice layer.n ? all");
	for (my $i=0; $i<$layerCount; $i++){
		my $layerName = lxq("query layerservice layer.name ? $i");
		my $materialCount = lxq("query layerservice material.n ? all");
		for (my $i=0; $i<$materialCount; $i++){
			my $materialName = lxq("query layerservice material.name ? $i");
			$materialTable{$materialName} = 1;
		}
	}

	if (@_ == 0){	createShaderArray(keys %materialTable);	}
	else		{	createShaderArray(@_);					}
	close($shaderDir);
	&shaderTreeTools(buildDbase);

	foreach my $key (keys %shaderText){
		foreach my $line (@{$shaderText{$key}}){
			if ($line =~ /renderbump/i){
				my $smAngle;
				if ($line =~ /\/\*/){
					my @splitLine = split(/\/\*/,$line);
					$splitLine[1] =~ s/[^\d\.]//g;
					$smAngle = $splitLine[1];
				}else{
					$smAngle = 180;
				}

				my $ptag = shaderTreeTools(ptag, materialID, $key);
				lx("select.subItem {$ptag} set textureLayer;render;environment;light;camera;mediaClip;txtrLocator");
				lx("item.channel advancedMaterial\$smooth {1}");
				lx("item.channel advancedMaterial\$smAngle {$smAngle}");
				last;
			}
		}
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#CLEANUP SUB
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub cleanup{
	#symmetry restore
	if ($skipSymm != 1){
		if ($symmAxis ne "none"){
			lxout("turning symm back on ($symmAxis)"); lx("select.symmetryState $symmAxis");
		}
	}

	#Put the workplane back
	if ($skipWorkplane != 1){
		lx("workPlane.edit {@WPmem[0]} {@WPmem[1]} {@WPmem[2]} {@WPmem[3]} {@WPmem[4]} {@WPmem[5]}");
	}

	#Set the action center settings back
	if ($skipActr != 1){
		if ($actr == 1) {	lx( "tool.set {$seltype} on" ); }
		else { lx("tool.set center.$selCenter on"); lx("tool.set axis.$selAxis on"); }
	}

	#restore the last used tool
	if ($restoreTool == 1) {lx("tool.set $tool on");}

	#restore selection mode (if any)
	if ($selectionMode ne ""){lx("select.type $selectionMode");}
}




#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------SUBROUTINES--------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------------------------------------------
#THIS ROUTINE BUILDS A VMAP TABLE FOR ALL POLYS UV'S AND THEN FINDS ALL BORDER UV EDGES
#-------------------------------------------------------------------------------------------------------------------------------------------------------
sub findUVBorders{
	lxout("[->] Running Find Border UV Edges subroutine");
	my @polys = @_;
	our %vmapTable=();
	our %edgeTable=();

	my @list = (keys %edgeTable);

	foreach my $poly (@polys){
		my @verts = lxq("query layerservice poly.vertList ? $poly");
		my @vmapValues  = lxq("query layerservice poly.vmapValue ? $poly");

		#build vmapTable
		for (my $i=0; $i<@verts; $i++){
			$vmapTable{$poly.",".@verts[$i]}=@vmapValues[$i*2].",".@vmapValues[$i*2+1];
		}

		#find the border edges
		for (my $i=-1; $i<$#verts; $i++){
			my $edge;
			if (@verts[$i]<@verts[$i+1])	{	$edge = @verts[$i].",".@verts[$i+1];	}
			else						{	$edge = @verts[$i+1].",".@verts[$i];	}
			#here we'll check to see if the edge is in the table.  If it isn't, we'll add the poly.
			#if it is, we'll check that poly's edge to see if it has the same vmaps. If so, we'll ignore it. If not, we'll add the poly.
			if (!exists $edgeTable{$edge}){
				$edgeTable{$edge} = $poly;
			}
			else{
				my @verts = split(/,/, $edge);
				if   (($vmapTable{$poly.",".@verts[0]} != $vmapTable{$edgeTable{$edge}.",".@verts[0]}) ||
				      ($vmapTable{$poly.",".@verts[1]} != $vmapTable{$edgeTable{$edge}.",".@verts[1]})){
					#lxout("This poly's($poly) edge ($edge) doesn't match the other poly's($edgeTable{$edge}) edge ($edge)");
					$edgeTable{$edge}=$edgeTable{$edge}.",".$poly;
				}else{
					#lxout("canceling this edge ($edge)");
					delete $edgeTable{$edge};
				}
			}
		}
	}

	#foreach my $edge (sort keys %edgeTable){
	#	lxout("edge ($edge) is a (BORDER UV EDGE) and is used on these polys : $edgeTable{$edge}");
	#}
	my $borderEdgeCount = (keys %edgeTable);
	lxout("     -There are ($borderEdgeCount) border edges");
}



#----------------------------------------------------------------------------------
#PUT THE ORIGINAL POLY SELECTION BACK
#----------------------------------------------------------------------------------
sub restoreSelection{
	lx("select.drop polygon");
	foreach my $poly (@polys){
		lx("select.element $mainlayer polygon add $poly");
	}
}

#----------------------------------------------------------------------------------
#FIX A REORDERED POLY ARRAY  (note, it destroys selection order)
#----------------------------------------------------------------------------------
sub fixReorderedArray{
	my $arrayCount = $#_;
	my $polyCount  = lxq("query layerservice poly.n ? all") - 1;
	my @array = (($polyCount-$arrayCount)..$polyCount);
	return @array;
}

#----------------------------------------------------------------------------------
#LIST ALL DISCO UVS
#----------------------------------------------------------------------------------
sub discoUVList{
	lxout("[->] Building the list of disco UVs.");
	our %discoList=();
	my @uvs = lxq("query layerservice uvs ? all");
	foreach my $uv (@uvs){
		if ($uv !~ /-1/){
			$uv =~ tr/()//d;
			$uv =~ s/,\d*//;
			$discoList{$uv} = 1;
		}
	}
}

#----------------------------------------------------------------------------------
#BARYCENTRIC UVS
#----------------------------------------------------------------------------------
sub barycentric{
	lx("tool.set uv.create on");
	lx("tool.attr uv.create proj barycentric");
	lx("tool.doApply");
	lx("tool.set uv.create off");
}

#----------------------------------------------------------------------------------
#CAMERA PROJECTED PLANAR
#----------------------------------------------------------------------------------
sub camPlanar{  #TEMP.   I dont know which viewport is active!!!!
	lxout("[->] Using CAMERA PROJECTED PLANAR UVS");
	lx("viewport.fitSelected");
	lx("tool.set uv.viewProj on");
	lx("tool.doApply");
	lx("tool.set uv.viewProj off");
}

#----------------------------------------------------------------------------------
#PLANAR UVs
#----------------------------------------------------------------------------------
sub planar{
	lxout("[->] PLANAR UVS");
	if ($autoAngle == 1){
		lx("viewport.fitSelected");
		lx("viewport.alignSelected");
		lx("tool.set uv.viewProj on");
		lx("tool.reset");
		lx("tool.doApply");
		lx("tool.set uv.viewProj off");
	}else{
		lx("tool.set uv.create on");
		lx("tool.reset");
		lx("tool.attr uv.create proj planar");
		lx("tool.attr uv.create mode manual");
		lx("tool.setAttr uv.create cenX {@bboxCenter[0]}");
		lx("tool.setAttr uv.create cenY {@bboxCenter[1]}");
		lx("tool.setAttr uv.create cenZ {@bboxCenter[2]}");
		lx("tool.setAttr uv.create sizX {@bboxSize[0]}");
		lx("tool.setAttr uv.create sizY {@bboxSize[1]}");
		lx("tool.setAttr uv.create sizZ {@bboxSize[2]}");
		lx("tool.setAttr uv.create seam {0}");
		lx("tool.setAttr uv.create axis {$axis}");
		lx("tool.doApply");
		lx("tool.set uv.create off");
	}
}

#----------------------------------------------------------------------------------
#CYLINDRICAL UVS
#----------------------------------------------------------------------------------
sub cylindrical{
	lxout("[->] CYLINDRICAL UVS");
	if ($autoAngle == 1){
		&determineAngle;
		lx("tool.set uv.create on");
		lx("tool.reset");
		lx("tool.attr uv.create proj cylindrical");
		lx("tool.attr uv.create mode manual");
		lx("tool.setAttr uv.create seam {0}");
		lx("tool.setAttr uv.create cenX {0}");
		lx("tool.setAttr uv.create cenY {0}");
		lx("tool.setAttr uv.create cenZ {0}");
		lx("tool.setAttr uv.create sizX {@bboxSize[0]}");
		lx("tool.setAttr uv.create sizY {@bboxSize[1]}");
		lx("tool.setAttr uv.create sizZ {@bboxSize[2]}");
		lx("tool.setAttr uv.create axis {$axis}");
		lx("tool.doApply");
		lx("tool.set uv.create off");
		lx("uv.fit [0] [0]");
		lx("workplane.reset");
	}else{
		lx("tool.set uv.create on");
		lx("tool.reset");
		lx("tool.attr uv.create proj cylindrical");
		lx("tool.attr uv.create mode manual");
		lx("tool.setAttr uv.create cenX {@bboxCenter[0]}");
		lx("tool.setAttr uv.create cenY {@bboxCenter[1]}");
		lx("tool.setAttr uv.create cenZ {@bboxCenter[2]}");
		lx("tool.setAttr uv.create sizX {@bboxSize[0]}");
		lx("tool.setAttr uv.create sizY {@bboxSize[1]}");
		lx("tool.setAttr uv.create sizZ {@bboxSize[2]}");
		lx("tool.setAttr uv.create seam {0}");
		lx("tool.setAttr uv.create axis {$axis}");
		lx("tool.doApply");
		lx("tool.set uv.create off");
	}
}

#----------------------------------------------------------------------------------
#SPHERICAL UVS
#----------------------------------------------------------------------------------
sub spherical{
	lxout("[->] SPHERICAL UVS");
	if ($autoAngle == 1){
		&determineAngle;
		lx("tool.set uv.create on");
		lx("tool.reset");
		lx("tool.attr uv.create proj spherical");
		lx("tool.attr uv.create mode manual");
		lx("tool.setAttr uv.create cenX {0}");
		lx("tool.setAttr uv.create cenY {0}");
		lx("tool.setAttr uv.create cenZ {0}");
		lx("tool.setAttr uv.create sizX {@bboxSize[0]}");
		lx("tool.setAttr uv.create sizY {@bboxSize[1]}");
		lx("tool.setAttr uv.create sizZ {@bboxSize[2]}");
		lx("tool.setAttr uv.create seam {0}");
		lx("tool.setAttr uv.create axis {$axis}");
		lx("tool.doApply");
		lx("tool.set uv.create off");
		lx("uv.fit [0] [0]");
		lx("workplane.reset");
	}else{
		lx("tool.set uv.create on");
		lx("tool.reset");
		lx("tool.attr uv.create proj spherical");
		lx("tool.attr uv.create mode manual");
		lx("tool.setAttr uv.create cenX {@bboxCenter[0]}");
		lx("tool.setAttr uv.create cenY {@bboxCenter[1]}");
		lx("tool.setAttr uv.create cenZ {@bboxCenter[2]}");
		lx("tool.setAttr uv.create sizX {@bboxSize[0]}");
		lx("tool.setAttr uv.create sizY {@bboxSize[1]}");
		lx("tool.setAttr uv.create sizZ {@bboxSize[2]}");
		lx("tool.setAttr uv.create seam {0}");
		lx("tool.setAttr uv.create axis {$axis}");
		lx("tool.doApply");
		lx("tool.set uv.create off");
	}
}

#----------------------------------------------------------------------------------
#ATLAS UVS
#----------------------------------------------------------------------------------
sub atlas{
	lxout("[->] ATLAS UVS");

	lx("tool.set uv.create on");
	lx("tool.reset");
	lx("tool.attr uv.create proj atlas");
	lx("tool.doApply");
	lx("tool.set uv.create off");
}

#----------------------------------------------------------------------------------
#UNWRAP UVS
#----------------------------------------------------------------------------------
sub unwrap{
	lxout("[->]	UNWRAP UVS");

	lx("tool.set uv.unwrap on");
	lx("tool.reset");
	lx("tool.setAttr uv.unwrap iter 1600");
	lx("tool.doApply");
	lx("tool.set uv.unwrap off");
}


#----------------------------------------------------------------------------------
#1D FLATTEN DISCO UVS
#----------------------------------------------------------------------------------
sub flattenDiscoUVs{
	my @verts = lxq("query layerservice verts ? selected");
	if ($V == 1)	{our $axis = 1;}
	else			{our $axis = 0;}

	foreach my $vert (@verts){
		my %vmapTable;

		my @polyList = lxq("query layerservice vert.polyList ? $vert");
		foreach my $poly (@polyList){
			my @vertList = lxq("query layerservice poly.vertList ? $poly");
			my @vmapValues = lxq("query layerservice poly.vmapValue ? $poly");
			for (my $i=0; $i<@vertList; $i++){
				if (@vertList[$i] == $vert){
					$vmapTable{@vmapValues[($i*2)+$axis]} = 1;
					my $bleh = @vmapValues[($i*2)+$axis];
					last;
				}
			}
		}

		my $count = (keys %vmapTable);
		my $finalValue;
		foreach my $key (keys %vmapTable){$finalValue += $key;}
		$finalValue = $finalValue / $count;

		lx("select.element $mainlayer vertex set $vert");
		lx("vertMap.setValue {1} {$axis} {$finalValue}");
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#APPLY MATERIAL PER UV ISLAND sub
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub applyMatrPerIsland{
	my $numKeys = (keys %touchingUVList);
	my @alphabet = (a..z,0..9);
	my @changedPolys;
	for (my $key=0; $key<$numKeys; $key++){
		my @currentPolys = sort { $a <=> $b } @{$touchingUVList{$key}};
		if ($modoVer < 500){returnCorrectIndice(\@currentPolys,\@changedPolys);}

		lx("select.drop polygon");
		lx("select.element $mainlayer polygon add $_") for @currentPolys;
		my $randMatrName;	for (my $i=0; $i<16; $i++){$randMatrName .= $alphabet[rand(@alphabet)];}
		lx("!!poly.setMaterial {$randMatrName}");

		my @materialSelection = lxq("query sceneservice selection ? advancedMaterial");
		my @materialColor = (rand(1),rand(1),rand(1));
		lx("item.channel diffCol.R {$materialColor[0]} set {$materialSelection[0]}");
		lx("item.channel diffCol.G {$materialColor[1]} set {$materialSelection[0]}");
		lx("item.channel diffCol.B {$materialColor[2]} set {$materialSelection[0]}");
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#ROUND NUMBERS sub
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub roundNumber{
	$original = @_[0];
	$roundTo = @_[1];
	my $flip = 0;
	if ($original < 0){
		$original *= -1;
		$flip = 1;
	}

	#lxout("original = $original <><> roundTo = $roundTo");

	#ROUNDING TO A NUMBER LESS THAN ONE.
	if ($roundTo < 1){
		my $extra = $original - int($original);
		my $div = $extra/$roundTo;
		my $divExtra = $div - int($div);
		if ($divExtra < 0.5)	{	$div = int($div);		}
		else					{	$div = int($div)+1;	}
		$final = int($original) + ($roundTo*$div);
		if ($flip == 1){ $final *= -1; }
		return $final;
	}

	#ROUNDING TO A NUMBER GREATER THAN ONE.
	else{
		my $div = $original/$roundTo;
		my $extra = $div;
		$extra =  $extra - int($extra);
		if ($extra < 0.5)	{	$div = int($div);		}
		else				{	$div = int($div)+1;	}
		my $final = $div * $roundTo;
		if ($flip == 1){$final *= -1;}
		return $final;
	}
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#THIS WILL ROUND THE CURRENT NUMBER to the string length you define (and fill in empty space with 0s as well)  #modded so that if arg 3 is 1, i won't zero pad
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#USAGE : my $roundedNumberString = roundNumberString(0.2565486158,5,1);  #modded so that if arg 3 is 1, i won't zero pad
sub roundNumberString{
	$_ = "@_[0]";
	my $count = s/.//g;
	my $roundedNumber = "@_[0]";
	if ($count > @_[1])		{$roundedNumber = substr($roundedNumber, 0, @_[1]);}
	elsif (($count < @_[1]) && (@_[2] == 0)){  #modded so that if arg 3 is 1, i won't zero pad
		if ($roundedNumber =~ /\./)	{$roundedNumber .= 0 x (@_[1] - $count);	}
		else						{{$roundedNumber .= "." . 0 x ((@_[1] - 1) - $count);	}	}
	}
	return($roundedNumber);
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SELECT ONE LONG EDGELOOP ON EACH POLY SELECTION ISLAND
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#how it works : it looks at all polys selected, and finds the longest edge on the first poly it sees, then removes that poly mesh from the to do list and goes on to the next.  Then fires select.loop
#requires listTouchingPolys2 sub.
sub selectEdgeLoops{
	lxout("[->] Running selectEdgeLoops subroutine	");
	my @polys = lxq("query layerservice polys ? selected");
	if (@polys == 0){die("You were running the batch peeler script with the automatic edge loop selection feature turned on.  You must have a poly selection in order for this feature to work");}

	my %polyTable;  $polyTable{$_} = 1 for @polys;
	my @edgesToSelect;

	while ((keys %polyTable) > 0){
		my @connectedPolys = listTouchingPolys2((keys %polyTable)[0]);
		delete $polyTable{$_} for @connectedPolys;
		my @todoPolys;  for (my $i=0; $i<@connectedPolys; $i++){push(@todoPolys,$connectedPolys[$i]);}
		my $longestEdge = "";
		my $longestEdgeLength = 0;

		foreach my $poly (@todoPolys){
			my @verts = lxq("query layerservice poly.vertList ? $poly");
			my @edges;	for (my $i=-1; $i<$#verts; $i++){push(@edges,@verts[$i].",".@verts[$i+1]);}

			if ($longestEdge eq ""){
				$longestEdge = $edges[0];
				$longestEdgeLength = lxq("query layerservice edge.length ? ($edges[0])");
			}
			for (my $i=1; $i<@edges; $i++){
				my $edgeLength = lxq("query layerservice edge.length ? ($edges[$i])");
				if ($edgeLength > $longestEdgeLength){
					$longestEdge = @edges[$i];
					$longestEdgeLength = $edgeLength;
				}
			}
		}
		push(@edgesToSelect,$longestEdge);

	}

	lx("select.drop edge");
	for (my $i=0; $i<@edgesToSelect; $i++){
		my @edge = split(/,/, @edgesToSelect[$i]);
		lx("select.element $mainlayer edge add @edge[0] @edge[1]");
	}
	lx("!!select.loop");
	lx("!!select.edge remove bond equal (none)");
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#UV BOUNDING BOX subroutine
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub uvBBOX
{
	lxout("[->] Running uvBBOX subroutine");
	my @polys = @_;
	our @uvBBOX=();
	our @uvBBOXCenter=();

	#------------------------------------------------------------------------------------------------
	#build the UV bbox
	#------------------------------------------------------------------------------------------------

	#create the startup bbox to know exactly where to start.
	my @tempVmap = lxq("query layerservice poly.vmapValue ? @polys[0]");
	@uvBBOX = (@tempVmap[0],@tempVmap[1],@tempVmap[0],@tempVmap[1]);

	foreach my $poly (@polys)
	{
		my @verts = lxq("query layerservice poly.vertList ? $poly");
		my @polyUVPos = lxq("query layerservice poly.vmapValue ? $poly");
		#lxout("verts = @verts");
		#lxout("the UV positions are: @polyUVPos");

		for (my $i=0; $i<@verts; $i++)
		{
			my @UVPos = (@polyUVPos[($i*2)], @polyUVPos[(($i*2)+1)]);
			#lxout("vert (@verts[$i]) pos = @UVPos[0] , @UVPos[1]");

			if (@UVPos[0] < @uvBBOX[0]) { @uvBBOX[0] = @UVPos[0]; }
			if (@UVPos[0] > @uvBBOX[2]) { @uvBBOX[2] = @UVPos[0]; }
			if (@UVPos[1] < @uvBBOX[1]) { @uvBBOX[1] = @UVPos[1]; }
			if (@UVPos[1] > @uvBBOX[3]) { @uvBBOX[3] = @UVPos[1]; }
		}
	}
	@uvBBOXCenter = (((@uvBBOX[0]+@uvBBOX[2])/2),((@uvBBOX[1]+@uvBBOX[3])/2));
	return (@uvBBOXCenter , @uvBBOX);
}




#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#CONVERT A 2D vector to an angle.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub vectorToAngle{
	my @vector = @_;
	my $radian = atan2(@vector[1],@vector[0]);
	my $angle = ($radian*180)/$pi;
	return $angle;
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#REMOVE ARRAY2 FROM ARRAY1 SUBROUTINE
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub removeListFromArray{
	my $array1Copy = @_[0];
	my $array2Copy = @_[1];
	my @fullList = @$array1Copy;
	my @removeList = @$array2Copy;
	for (my $i=0; $i<@removeList; $i++){
		for (my $u=0; $u<@fullList; $u++){
			if (@fullList[$u] eq @removeList[$i]	){
				splice(@fullList, $u,1);
				last;
			}
		}
	}
	return @fullList;
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#CREATE A HASH TABLE OF ALL CLIPS, THEIR SIZES, AND THEIR NAMES.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub clipSizeList{
	lxout("[->] Running ClipSizeList subroutine");
	our %clipSizeList=();
	our %clipNameList=();
	my $clips = lxq("query layerservice clip.n ? all");
	for (my $i=0; $i<$clips; $i++){
		my $fileName = lxq("query layerservice clip.file ? $i");
		my $clipInfo = lxq("query layerservice clip.info ? $i");
		my @clipSize = split(/\D+/, $clipInfo);
		my $width = @clipSize[1];
		my $height = @clipSize[2];
		if (($sene_jpgHalfSize == 1) && ($fileName =~ /jpg/i) || ($fileName =~ /jpeg/i)){$width *= 4; $height *= 4;}

		my $hashName = $width .",". $height;
		my $clipName = lc(clipNameFix($fileName));
		push(@{$clipSizeList{$hashName}}, $clipName);
		$clipNameList{$clipName} = $hashName;
	}
	#print out the clip name / size lists
	#foreach my $array(keys %clipSizeList){
	#	lxout("     -CLIPSIZELIST : ($array) = @{$clipSizeList{$array}}");
	#}
	#foreach my $array(keys %clipNameList){
	#	lxout("     -CLIP NAME LIST : ($array) = $clipNameList{$array}");
	#}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SELECT ALL CLIPS
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub selectAllClips{
	my $clipCount = lxq("query layerservice clip.n ? all");
	for (my $i=0; $i<$clipCount; $i++){
		my $id = lxq("query sceneservice clip.id ? $i");
		lxout("id = $id");
		lx("!!select.subItem {$id} add mediaClip");
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SELECT THESE CLIPS
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub selectTheseClips{
	my $searchTerm = quickDialog("Enter the clip name:",string,"","","");
	my $clipCount = lxq("query layerservice clip.n ? all");
	my $foundCount = 0;
	for (my $i=0; $i<$clipCount; $i++){
		my $filePath = lxq("query layerservice clip.file ? $i");
		#$filePath =~ s/.*[\\\/]//g;
		if ($filePath =~ /$searchTerm/i){
			#lxout("filePath = $filePath");
			my $id = lxq("query layerservice clip.id ? $i");
			lxout("id = $id");
			if ($foundCount == 0)	{lx("select.subItem {$id} set mediaClip");}
			else					{lx("select.subItem {$id} add mediaClip");}
			$foundCount++;
		}
	}

	if (($prop == 1) && ($foundCount > 1))	{popup("There were ($foundCount) clips found that matched the ($searchTerm) term");}
	else									{lxout("There were ($foundCount) clips found that matched the ($searchTerm) term");}

}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SELECT THESE MATERIALS
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub selectTheseMaterials{
	my $nameList = quickDialog("Type in the material names\nyou want to select\n(seperated by commas)",string,"","","");
	my @names = split(/,/, $nameList);
	my @foundMasks;

	my $txLayers = lxq("query sceneservice txLayer.n ? all");
	for (my $i=0; $i<$txLayers; $i++){
		if (lxq("query sceneservice txLayer.type ? $i") eq "mask"){
			my $name = lxq("query sceneservice txLayer.name ? $i");
			foreach my $checkName (@names){
				if ($name =~ /$checkName/i){
					push(@foundMasks, lxq("query sceneservice txLayer.id ? $i"));
				}
			}
		}
	}

	for (my $i=0; $i<@foundMasks; $i++){
		if ($i > 0){
			lx("select.subItem [@foundMasks[$i]] add textureLayer;render;environment;mediaClip;locator");
		}else{
			lx("select.subItem [@foundMasks[$i]] set textureLayer;render;environment;mediaClip;locator");
		}
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SORT MATERIALS
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub sortMaterials{
	my $txLayerCount = lxq("query sceneservice txLayer.n ? all");
	my $topParent;
	my %maskTable;

	if (@ARGV[0] eq "onlySelected"){
		lxout("[->] : Sorting only the selected materials in the shader tree.");
		for (my $i=0; $i<$txLayerCount; $i++){
			if ((lxq("query sceneservice txLayer.type ? $i") eq "mask") && (lxq("query sceneservice txLayer.isSelected ? $i") == 1)){
				my $parent = lxq("query sceneservice txLayer.parent ? $i");
				if ($topParent eq ""){$topParent = $parent;}
				if ($parent eq $topParent){
					my $id = lxq("query sceneservice txLayer.id ? $i");
					my $name = lxq("query sceneservice txLayer.name ? $i");
					$name =~ s/\\/\//g;
					$name =~ lc($name);
					$name =~ s/Matr:\s//;

					$maskTable{$name} = $id;
				}
			}
		}
	}else{
		lxout("[->] : Sorting all the top most materials in the shader tree");
		lx("select.itemType type:polyRender mode:add");
		my $renderID = lxq("query sceneservice selection ? polyRender");
		$topParent = $renderID;
		my @children = lxq("query sceneservice txLayer.children ? $renderID");
		foreach my $child (@children){

			if (lxq("query sceneservice txLayer.type ? $child") eq "mask"){
				my $name = lxq("query sceneservice txLayer.name ? $child");
				$name =~ s/\\/\//g;
				$name =~ lc($name);
				$name =~ s/Matr:\s//;
				$maskTable{$name} = $child;
			}
		}
	}

	my @children = lxq("query sceneservice txLayer.children ? $topParent");
	my %childTable;
	my $highestRankIndex;
	my $highestRankID;
	for (my $i=$#children; $i>-1; $i--){
		my $name = lxq("query sceneservice txLayer.name ? @children[$i]");
		$name =~ s/\\/\//g;
		$name =~ lc($name);
		$name =~ s/Matr:\s//;

		if (exists $maskTable{$name}){
			$highestRankIndex = $i;
			$highestRankID = @children[$i];
			last;
		}
	}

	my @list = sort {
		($c) = ($a =~ /(.*[^0-9])/);
		($d) = ($b =~ /(.*[^0-9])/);
		if ($c eq $d) {   # Last names are the same, sort on first name
			($c) = ($a =~ /([0-9]+$)/);
			($d) = ($b =~ /([0-9]+$)/);
			if ($c > $d)		{return 1;}
			elsif ($c == $d)	{return 0;}
			else				{return -1;}
		}else{
			return $c cmp $d;
		}
	} (keys %maskTable);

	my $count = 0;
	for (my $i=0; $i<@list; $i++){
		lx("select.subItem $maskTable{@list[$i]} set textureLayer;render;environment;mediaClip;locator");
		my $index = $highestRankIndex - $count;
		lx("texture.parent {$topParent} $index");
		$count++;
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#FIND PTAG MASK : (returns id,ptagName)
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub findPtagMask{
	my $name = @_[0];

	my $txLayers = lxq("query sceneservice txLayer.n ? ");
	for (my $i=0; $i<$txLayers; $i++){
		if (lxq("query sceneservice txLayer.type ? $i") eq "mask"){
			my $ptag = lxq("query sceneservice channel.value ? ptag");
			my $ptagMod = $ptag;
			OSPathNameFix($ptagMod);

			if (lc($name) eq lc($ptagMod)){
				lxout("the material ($ptag) exists.");
				return(lxq("query sceneservice txLayer.id ? $i"),$ptag);
			}
		}
	}
	return 0;
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#FIND OS SLASH
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub findOSSlash{
	if ($os =~ /win/i){
		return "\/";
	}else{
		return "\/";
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#PATH NAME FIX SUB : make sure the / syntax is correct for the various OSes.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub OSPathNameFix{
	if ($os =~ /win/i){
		@_[0] =~ s/\\/\//g;
	}else{
		@_[0] =~ s/\\/\//g;
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#CLIP NAME FIX SUB.  (get rid of the path stuff i don't want)
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub clipNameFix{
	$clipName = @_[0];
	$clipName =~ s/\\\\/\\/g;			#get rid of any double \\ marks.  wtf.
	OSPathNameFix($clipName);

	#texture name fix for GAME textures
	if ($sene_matRepairPath ne ""){
		$clipName =~ s/\Q$sene_matRepairPath//i;
		$clipName =~ s/\.[a-zA-Z]+//;
		return $clipName;
	}

	#texture name fix for normal material names
	else{  #TEMP : does this work?  does the rest of the code know texture sizes?
		my @name =  split/\//,$clipName;
		@name[-1] =~ s/\.[a-zA-Z]+//;
		return @name[-1];
	}

}



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#DETERMINE THE  ANGLE SUB
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub determineAngle
{
	lxout("[->] Using Determine angle subroutine");

	#[0] --> CREATE + EDIT the original edge list.  [remove layer info] [remove ( ) ]  (MODO2 HACK!  I'm deselecting all other layers to get around the infinite edge loop bug)
	lx("select.convert edge");
	my %edgeList; #[0]=length [1]=vectorX [2]=vectorY [3]=vectorZ
	my @tempEdgeList = lxq("query layerservice selection ? edge");
	my @edges;
	foreach my $edge (@tempEdgeList){if ($edge =~ /\($mainlayer/){push(@edges,$edge);}}
	s/\(\d{0,},/\(/  for @edges;
	tr/()//d for @edges;

	#[1] --> convert polys to edges and find the longest
	my $longestEdge;
	my $longestEdgeLength = 0;
	foreach my $edge (@edges)
	{
		my $length = lxq("query layerservice edge.length ? ($edge)");
		$edgeList{$edge}[0]=$length;
		if ($length > $longestEdgeLength)
		{
			$longestEdgeLength = $length;
			$longestEdge = $edge;
		}
	}
	lxout("-The longest edge is $longestEdge");

	#[1A] --> Find any other edges that are very similar
	#check for similar in length
	my @similarEdges;
	my $minEdgeLength = $longestEdgeLength * 0.9;
	#lxout("-minEdgeLength = $minEdgeLength");
	my @longestEdgeVector = lxq("query layerservice edge.vector ? ($longestEdge)");
	lxout("longestEdgeVector = @longestEdgeVector");
	@longestEdgeVector = ((@longestEdgeVector[0]/$longestEdgeLength),(@longestEdgeVector[1]/$longestEdgeLength),(@longestEdgeVector[2]/$longestEdgeLength)); #make it a UNIT VECTOR
	foreach my $edge(@edges)
	{
		#lxout("-edge[$edge] length = $edgeList{$edge}[0]");
		if ($edgeList{$edge}[0] >= $minEdgeLength)
		{
			#this edge is similar in length, so now we're gonna check if the dir's the same.
			my @vector = lxq("query layerservice edge.vector ? ($edge)");
			@vector = ((@vector[0]/$edgeList{$edge}[0]),(@vector[1]/$edgeList{$edge}[0]),(@vector[2]/$edgeList{$edge}[0])); #make it a UNIT VECTOR
			my $dotProduct = (@vector[0]*@longestEdgeVector[0]+@vector[1]*@longestEdgeVector[1]+@vector[2]*@longestEdgeVector[2]);
			#lxout("   -dotProduct = $dotProduct");

			if (($dotProduct > $dpCheckValue) || ($dotProduct < $dpCheckValue))
			{
				#HACK : make sure the vector's pointing in the right direction
				if ($dotProduct < -0.8)
				{
					#lxout("-flipping this vector ($edge)");
					@vector = ((@vector[0]*-1),(@vector[1]*-1),(@vector[2]*-1));
				}

				#lxout("-This edge[$edge] is similar in LENGTH AND DIRECTION ($edgeList{$edge}[0])");
				push(@similarEdges,$edge);
				$edgeList{$edge}[1]=@vector[0];
				$edgeList{$edge}[2]=@vector[1];
				$edgeList{$edge}[3]=@vector[2];
			}
		}
	}
	#lxout("similarEdges = @similarEdges");

	if ($debug == 1)
	{
		lx("select.drop edge");
		foreach my $edge (@similarEdges)
		{
			my @verts = split (/[^0-9]/, $edge);
			lx("select.element $mainlayer edge add @verts[0] @verts[1]");
		}
		lxout("Are these the CORRECT similar edges?");
	}

	#[1B] --> Now average all the similar edges together into one
	my @averageEdge;
	foreach my $edge (@similarEdges)
	{
		@averageEdge = ((@averageEdge[0]+$edgeList{$edge}[1]),(@averageEdge[1]+$edgeList{$edge}[2]),(@averageEdge[2]+$edgeList{$edge}[3]));
		#lxout("Adding edge ([$edge] $edgeList{$edge}[1],$edgeList{$edge}[2],$edgeList{$edge}[3]) <> averageEdge = @averageEdge ");
	}
	@averageEdge = ((@averageEdge[0]/@similarEdges),(@averageEdge[1]/@similarEdges),(@averageEdge[2]/@similarEdges));
	#lxout("[->] LONGEST EDGE = @longestEdgeVector");
	#lxout("[->] AVERAGE EDGE = @averageEdge");


	#[2] --> Find the angle of that edge
	my @disp = @averageEdge;
	my $dist = sqrt((@disp[0]*@disp[0])+(@disp[1]*@disp[1])+(@disp[2]*@disp[2]));
	@disp[0,1,2] = ((@disp[0]/$dist),(@disp[1]/$dist),(@disp[2]/$dist));

	#heading=theta <><> pitch=phi <><> Also, by default, (heading 0 = X+) <><> (pitch0 = Y+)
	my $heading = atan2(@disp[2],@disp[0]);
	my $pitch = acos(@disp[1]);
	$heading = ($heading*180)/$pi;
	$pitch= ($pitch*180)/$pi;

	#TEMP TEMP TEMP TEMP TEMP
	#TEMP TMEP TEMP
	#OK, my algo to convert the vector into an angle is incorrect.

	#lxout("------------------------------------------------------------");
	#lxout("    -verts = @verts");
	#lxout("    -disp = @disp");
	#lxout("    -dist = $dist");
	lxout("    -heading = $heading");
	lxout("    -pitch = $pitch");
	#lxout("------------------------------------------------------------");

	#[3] --> Turn the workplane on so we can project the UVs
	my $rot = -1*(90+$heading);
	lx("workPlane.edit {@bboxCenter[0]} {@bboxCenter[1]} {@bboxCenter[2]} {0} {$rot} {0}");
	lx("workplane.rotate 0 {$pitch}");
	lx("select.type polygon");
}



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#BOUNDING BOX SUB
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub boundingbox  #minX-Y-Z-then-maxX-Y-Z
{
	#lxout("[->] Using boundingbox (math) subroutine");
	my @bbVerts = @_;
	my $firstVert = @bbVerts[0];
	my @firstVertPos = lxq("query layerservice vert.pos ? $firstVert");
	my $minX = @firstVertPos[0];
	my $minY = @firstVertPos[1];
	my $minZ = @firstVertPos[2];
	my $maxX = @firstVertPos[0];
	my $maxY = @firstVertPos[1];
	my $maxZ = @firstVertPos[2];
	my @bbVertPos;

	foreach my $bbVert(@bbVerts)
	{
		@bbVertPos = lxq("query layerservice vert.pos ? $bbVert");
		#minX
		if (@bbVertPos[0] < $minX)
		{
			$minX = @bbVertPos[0];
		}
		#maxX
		elsif (@bbVertPos[0] > $maxX)
		{
			$maxX = @bbVertPos[0];
		}

		#minY
		if (@bbVertPos[1] < $minY)
		{
			$minY = @bbVertPos[1];
		}
		#maxY
		elsif (@bbVertPos[1] > $maxY)
		{
			$maxY = @bbVertPos[1];
		}

		#minZ
		if (@bbVertPos[2] < $minZ)
		{
			$minZ = @bbVertPos[2];
		}
		#maxZ
		elsif (@bbVertPos[2] > $maxZ)
		{
			$maxZ = @bbVertPos[2];
		}
	}
	my @bbox = ($minX,$minY,$minZ,$maxX,$maxY,$maxZ);
	return @bbox;
}



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#VECTOR TO UNIT VECTOR subroutine
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub vectorToUnitVector
{
	my @disp = @_;
	my $dist = sqrt((@disp[0]*@disp[0])+(@disp[1]*@disp[1])+(@disp[2]*@disp[2]));
	@disp[0,1,2] = ((@disp[0]/$dist),(@disp[1]/$dist),(@disp[2]/$dist));
	return @disp;
}



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#CORRECT THE VECTOR DIRECTION
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub correctVectorDir{
	my @vector = @_;

	#find important axis
	if (abs(@vector[0]) > abs(@vector[1]))	{	our $importantAxis = 0;	}
	else									{	our $importantAxis = 1;	}

	#if both rounded axes are equal and U is negative, flip it.
	if (int(abs(@vector[0]*1000000)+.5) == int(abs(@vector[1]*1000000)+.5)){
		if (@vector[0] < 0){
			@vector[0] *= -1;
			@vector[1] *= -1;
		}
	}

	#else if the important axis is negative, flip it.
	elsif (@vector[$importantAxis]<0){
		@vector[0] *= -1;
		@vector[1] *= -1;
	}

	return @vector;
}





#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SORT ROWS SETUP subroutine
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub sortRowStartup{

	#------------------------------------------------------------
	#Import the edge list and format it.
	#------------------------------------------------------------
	my @origEdgeList = @_;
	my $edgeQueryMode = shift(@origEdgeList);
	#------------------------------------------------------------
	#(NO) formatting
	#------------------------------------------------------------
	if ($edgeQueryMode eq "dontFormat"){
		#don't format!
	}
	#------------------------------------------------------------
	#(edges ? selected) formatting
	#------------------------------------------------------------
	elsif ($edgeQueryMode eq "edgesSelected"){
		tr/()//d for @origEdgeList;
	}
	#------------------------------------------------------------
	#(selection ? edge) formatting
	#------------------------------------------------------------
	else{
		my @tempEdgeList;
		foreach my $edge (@origEdgeList){	if ($edge =~ /\($mainlayer/){	push(@tempEdgeList,$edge);		}	}
		#[remove layer info] [remove ( ) ]
		@origEdgeList = @tempEdgeList;
		s/\(\d{0,},/\(/  for @origEdgeList;
		tr/()//d for @origEdgeList;
	}


	#------------------------------------------------------------
	#array creation (after the formatting)
	#------------------------------------------------------------
	our @origEdgeList_edit = @origEdgeList;
	our @vertRow=();
	our @vertRowList=();

	our @vertList=();
	our %vertPosTable=();
	our %endPointVectors=();

	our @vertMergeOrder=();
	our @edgesToRemove=();
	our $removeEdges = 0;


	#------------------------------------------------------------
	#Begin sorting the [edge list] into different [vert rows].
	#------------------------------------------------------------
	while (($#origEdgeList_edit + 1) != 0)
	{
		#this is a loop to go thru and sort the edge loops
		@vertRow = split(/,/, @origEdgeList_edit[0]);
		shift(@origEdgeList_edit);
		&sortRow;

		#take the new edgesort array and add it to the big list of edges.
		push(@vertRowList, "@vertRow");
	}


	#Print out the DONE list   [this should normally go in the sorting sub]
	#lxout("- - -DONE: There are ($#vertRowList+1) edge rows total");
	#for ($i = 0; $i < @vertRowList; $i++) {	lxout("- - -vertRow # ($i) = @vertRowList[$i]"); }
}



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SORT ROWS subroutine
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub sortRow
{
	#this first part is stupid.  I need it to loop thru one more time than it will:
	my @loopCount = @origEdgeList_edit;
	unshift (@loopCount,1);

	foreach(@loopCount)
	{
		#lxout("[->] USING sortRow subroutine----------------------------------------------");
		#lxout("original edge list = @origEdgeList");
		#lxout("edited edge list =  @origEdgeList_edit");
		#lxout("vertRow = @vertRow");
		my $i=0;
		foreach my $thisEdge(@origEdgeList_edit)
		{
			#break edge into an array  and remove () chars from array
			@thisEdgeVerts = split(/,/, $thisEdge);
			#lxout("-        origEdgeList_edit[$i] Verts: @thisEdgeVerts");

			if (@vertRow[0] == @thisEdgeVerts[0])
			{
				#lxout("edge $i is touching the vertRow");
				unshift(@vertRow,@thisEdgeVerts[1]);
				splice(@origEdgeList_edit, $i,1);
				last;
			}
			elsif (@vertRow[0] == @thisEdgeVerts[1])
			{
				#lxout("edge $i is touching the vertRow");
				unshift(@vertRow,@thisEdgeVerts[0]);
				splice(@origEdgeList_edit, $i,1);
				last;
			}
			elsif (@vertRow[-1] == @thisEdgeVerts[0])
			{
				#lxout("edge $i is touching the vertRow");
				push(@vertRow,@thisEdgeVerts[1]);
				splice(@origEdgeList_edit, $i,1);
				last;
			}
			elsif (@vertRow[-1] == @thisEdgeVerts[1])
			{
				#lxout("edge $i is touching the vertRow");
				push(@vertRow,@thisEdgeVerts[0]);
				splice(@origEdgeList_edit, $i,1);
				last;
			}
			else
			{
				$i++;
			}
		}
	}
}



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SET UP THE USER VALUE OR VALIDATE IT #modded to have dontOverride feature
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#userValueTools(name,type,life,username,list,listnames,argtype,min,max,action,value,dontOverride);
sub userValueTools{
	if (lxq("query scriptsysservice userValue.isdefined ? @_[0]") == 0){
		lxout("Setting up @_[0]--------------------------");
		lxout("Setting up @_[0]--------------------------");
		lxout("0=@_[0],1=@_[1],2=@_[2],3=@_[3],4=@_[4],5=@_[6],6=@_[6],7=@_[7],8=@_[8],9=@_[9],10=@_[10],11=@_[11]");
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
			if (@_[10] eq ""){lxout("woah.  there's no value in the userVal sub!");	}		}
		elsif (@_[10] == ""){lxout("woah.  there's no value in the userVal sub!");		}
								lx("user.value [@_[0]] [@_[10]]");		lxout("running user value setup 10");
	}else{
		#STRING-------------
		if ((@_[1] eq "string") && (@_[11] != 1)){
			if (lxq("user.value @_[0] ?") eq ""){
				lxout("user value @_[0] was a blank string");
				lx("user.value [@_[0]] [@_[10]]");
			}
		}
		#BOOLEAN------------
		elsif (@_[1] eq "boolean"){

		}
		#LIST---------------
		elsif ((@_[4] ne "") && (@_[11] != 1)){
			if (lxq("user.value @_[0] ?") == -1){
				lxout("user value @_[0] was a blank list");
				lx("user.value [@_[0]] [@_[10]]");
			}
		}
		#ALL OTHER TYPES----
		elsif ((lxq("user.value @_[0] ?") == "") && (@_[11] != 1)){
			lxout("user value @_[0] was a blank number");
			lx("user.value [@_[0]] [@_[10]]");
		}
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#ACOS SUB
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub acos { atan2(sqrt(1 - $_[0] * $_[0]), $_[0]); }


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#POPUP SUB
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub popup #(MODO2 FIX)
{
	lx("dialog.setup yesNo");
	lx("dialog.msg {@_}");
	lx("dialog.open");
	my $confirm = lxq("dialog.result ?");
	if($confirm eq "no"){die;}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#TIMER SUB
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub timer
{
	$end = times;
	#lxout("start=$start");
	#lxout("end=$end");
	$time = $end-$start;
	lxout("             (@_ TIMER==>>$time)");
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#CLOCK SUB
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#@clock = localtime;
sub clock{
	my $name = @_;
	my @currentTime =	localtime();
	my $minutes = 		@currentTime[1] - @clock[1];
	my $seconds = 		@currentTime[0] - @clock[0];
	if (rindex($seconds,/[0-9]/) == 1)	{$seconds = "0" . $seconds;}
	lxout("$name timer = ($minutes:$seconds)");
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#ADD THE INSTANCES TO THE BGLAYERS LIST SO THAT YOU CAN UNHIDE THEM WHEN THE SCRIPT'S DONE (ver 1.1)
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#USAGE : addInstancesToBGList(\@bgLayers);
sub addInstancesToBGList{
	my $items = lxq("query sceneservice item.n ? all");
	for (my $i=0; $i<$items; $i++){
		if (lxq("query sceneservice item.type ? $i") eq "meshInst"){
			my $id = lxq("query sceneservice item.id ? $i");
			my $visible = lxq("layer.setVisibility {$id} ?");
			if ($visible == 1){push (@{$_[0]},$id);}
		}
	}
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#ITEM VISIBILITY QUERY
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#USAGE : if (visibleQuery(mesh024) == 1){}
sub visibleQuery{
	my $name = lxq("query sceneservice item.name ? @_[0]");
	my $channelCount = lxq("query sceneservice channel.n ? all");
	for (my $i=0; $i<$channelCount; $i++){
		if (lxq("query sceneservice channel.name ? $i") eq "visible"){
			if (lxq("query sceneservice channel.value ? $i") ne "off"){
				return 1;
			}else{
				return 0;
			}
		}
	}
}

#------------------------------------------------------------------------------------------------------------
#OPTIMIZED SELECT TOUCHING POLYGONS sub  (if only visible polys, you put a "hidden" check before vert.polyList point)
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#USAGE : my @connectedPolys = listTouchingPolys2(@polys[-$i]);
sub listTouchingPolys2{
	lxout("[->] LIST TOUCHING subroutine");
	my @lastPolyList = @_;
	my $stopScript = 0;
	our %totalPolyList = ();
	my %vertList;
	my %vertWorkList;
	my $vertCount;
	my $i = 0;

	#create temp vertList
	foreach my $poly (@lastPolyList){
		my @verts = lxq("query layerservice poly.vertList ? $poly");
		foreach my $vert (@verts){
			if ($vertList{$vert} == ""){
				$vertList{$vert} = 1;
				$vertWorkList{$vert}=1;
			}
		}
	}

	#--------------------------------------------------------
	#FIND CONNECTED VERTS LOOP
	#--------------------------------------------------------
	while ($stopScript == 0)
	{
		my @currentList = keys(%vertWorkList);
		%vertWorkList=();

		foreach my $vert (@currentList){
			my @verts = lxq("query layerservice vert.vertList ? $vert");
			foreach my $vert(@verts){
				if ($vertList{$vert} == ""){
					$vertList{$vert} = 1;
					$vertWorkList{$vert}=1;
				}
			}
		}

		$i++;

		#stop script when done.
		if (keys(%vertWorkList) == 0){
			#popup("round ($i) : it says there's no more verts in the hash table <><> I've hit the end of the loop");
			$stopScript = 1;
		}
	}

	#--------------------------------------------------------
	#CREATE CONNECTED POLY LIST
	#--------------------------------------------------------
	foreach my $vert (keys %vertList){
		my @polys = lxq("query layerservice vert.polyList ? $vert");
		foreach my $poly(@polys){
			$totalPolyList{$poly} = 1;
		}
	}

	return (keys %totalPolyList);
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#CREATE SHADER LINES HASH TABLE SUB
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub createShaderArray{
	foreach my $shader (@_){
		$shader =~ s/\\/\//g;
		my $startedShaderBrackets = 0;
		my $shaderBrackets = 0;
		if (searchForShader(\@files,$shader) =~ /{/){$shaderBrackets++;}
		while (<m2File>){
			my $string = $_;
			$string =~ s/\/\/.*//;
			if ($string =~ /{/){$shaderBrackets++; $startedShaderBrackets = 1;}
			if ($string =~ /}/){$shaderBrackets--;}
			if ($string =~ /[a-zA-Z0-9_]/){push (@{$shaderText{$shader}},$string);}
			if (($startedShaderBrackets == 1) && ($shaderBrackets == 0)){close(m2File);last;}
		}
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SEARCH M2s FOR SHADER HEADER SUB
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub searchForShader{
	my $shaderName = @_[1];
	$shaderName =~ s/\\/\//g;
	$shaderName =~ s/\//\\\//g;
	my @words = split(/\//,$shaderName);
	lxout("Looking for this material : $shaderName");

	foreach my $file (@{@_[0]}){
		if ($file !~ /$mtrExtension/i){next;}
		my $filePath = $shaderDir . findOSSlash . $file;
		#lxout("filePath = $filePath");

		open (m2File, "<$filePath") or die("I couldn't find the material file");
		my $i = 1;
		while (<m2File>){
			if ($_ =~ /@words[-1]\b/i){
				if ($_ !~ /^\s*\/\//){
					$_ =~ s/(\/\/|\\\\).*//;
					$_ =~ s/\\/\//g;
					if ( ($_ =~ /^$shaderName[^a-zA-Z0-9_\\\/]/i) || ($_ =~ /^[\s\t]*$shaderName[^a-zA-Z0-9_\\\/]/i) || ($_ =~ /^[\s\t]*material\s+$shaderName[^a-zA-Z0-9_\\\/]/i) ){
						lxout("Found it here : $file : (line $i)");
						return $_;
					}
				}
			}
			$i++;
		}
		close(m2File);
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#CONSTRUCT PRESET ICON MATERIALS (same as constructMaterials sub, only it retains the smoothing angle and only loads diffmap)
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#requires shaderTreeTools(buildDbase) to have been run.
#requires decipherShaders to have been run.
sub constructPresetIconMatrs{
	lxout("----->@_[0] construction : it's id is @{$shaderTreeIDs{@_[0]}}[1]");
	lx("select.subItem @{$shaderTreeIDs{@_[0]}}[1] set textureLayer;render;environment;mediaClip;locator");

	#setup
	lx("item.channel advancedMaterial\$diffAmt 1");
	lx("item.channel advancedMaterial\$specAmt 0.01");
	lx("item.channel advancedMaterial\$rough 0.5");
	#lx("item.channel advancedMaterial\$smooth 1");
	#lx("item.channel advancedMaterial\$smAngle 20");
	lx("item.channel advancedMaterial\$subsAmt 0");
	lx("item.channel advancedMaterial\$tranAmt 0");
	lx("item.channel advancedMaterial\$radiance 0");
	lx("item.channel advancedMaterial\$bump 1");
	lx("item.channel advancedMaterial\$reflAmt 0");

	#diffusemap
	if (@{$decipherShaders{@_[0]}}[4] ne ""){
		my @imageInfo = split(/,/,@{$decipherShaders{@_[0]}}[4]);
		if (@imageInfo[0] eq "constantColor"){
			lx("select.subItem @{$shaderTreeIDs{@_[0]}}[1] set textureLayer;render;environment;mediaClip;locator");
			lx("item.channel advancedMaterial\$diffCol {@imageInfo[1] @imageInfo[2] @imageInfo[3]}");
			lxout("   --> DIFFUSEMAP : constantColor (@imageInfo[1],@imageInfo[2],@imageInfo[3])");
		}else{
			if (-e @imageInfo[0]){
				lx("texture.new [@imageInfo[0]]");
				lx("texture.parent @{$shaderTreeIDs{@_[0]}}[0]");
				if ($sene_sutImageAA == 0){
					lx("item.channel imageMap\$aa false");
					lx("item.channel imageMap\$pixBlend $pixBlend");
				}
				lx("item.channel imageMap\$alpha 0");
				if ((@imageInfo[1] != 1) || (@imageInfo[2] != 1) || (@imageInfo[3] != 1)){
					lx("shader.create constant");
					lx("item.channel textureLayer\$blend 6");
					lx("item.channel color {@imageInfo[1] @imageInfo[2] @imageInfo[3]}");
				}
				lxout("   --> DIFFUSEMAP : @imageInfo[0]");
			}else{
				lxout("this diffuse map doesn't exist : @imageInfo[0]");
			}
		}
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#CONSTRUCT MATERIALS (will assemble rage materials, but leave all others alone) ver 1.1
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#requires shaderTreeTools(buildDbase) to have been run.
#requires decipherShaders to have been run.
sub constructMaterials{
	lxout("----->@_[0] construction : it's id is @{$shaderTreeIDs{@_[0]}}[1]");
	lx("select.subItem @{$shaderTreeIDs{@_[0]}}[1] set textureLayer;render;environment;mediaClip;locator");

	#setup
	lx("item.channel advancedMaterial\$diffAmt 1");
	lx("item.channel advancedMaterial\$specAmt 0.01");
	lx("item.channel advancedMaterial\$rough 0.5");
	lx("item.channel advancedMaterial\$smooth 1");
	lx("item.channel advancedMaterial\$smAngle 20");
	lx("item.channel advancedMaterial\$subsAmt 0");
	lx("item.channel advancedMaterial\$tranAmt 0");
	lx("item.channel advancedMaterial\$radiance 0");
	lx("item.channel advancedMaterial\$bump 1");
	lx("item.channel advancedMaterial\$reflAmt 0");

	#renderbump
	if (@{$decipherShaders{@_[0]}}[0] != ""){
		lx("item.channel advancedMaterial\$smAngle 180.0");
		lxout("   --> RENDERBUMP : so i'm setting smoothing to 180");
	}

	#specularscale
	if (@{$decipherShaders{@_[0]}}[2] != ""){
		my $rageSpec = @{$decipherShaders{@_[0]}}[2];

		my $tempSpecMult = @{$decipherShaders{@_[0]}}[1] / 8;
		my $modoSpec = @{$decipherShaders{@_[0]}}[2] * $tempSpecMult;
		lx("item.channel advancedMaterial\$specAmt $modoSpec");
		lxout("   --> SPECULARSCALE : got translated from @{$decipherShaders{@_[0]}}[2] to $modoSpec");
	}

	#powermap | powermip
	if ((@{$decipherShaders{@_[0]}}[1] ne "") && (@{$decipherShaders{@_[0]}}[2] != 0)){
		if (@{$decipherShaders{@_[0]}}[1] =~ /[a-z]/i){
			#powermap
			chomp(@{$decipherShaders{@_[0]}}[1]);
			my $filePath = $sene_matRepairPath . @{$decipherShaders{@_[0]}}[1] . "\.tga";
			if (-e $filePath){
				lx("texture.new [$filePath]");
				lx("texture.parent @{$shaderTreeIDs{@_[0]}}[0]");
				if ($sene_sutImageAA == 0){
					lx("item.channel imageMap\$aa false");
					lx("item.channel imageMap\$pixBlend $pixBlend");
				}
				if ($hack_powermipToRefl == 1)	{	lx("shader.setEffect reflAmount");	}
				else							{	lx("shader.setEffect rough");		}
				lxout("   --> POWERMAP : $filePath");
			}else{
				lxout("this file doesn't exist : $filePath");
			}
		}else{
			#powermip
			my $rageRoughness = @{$decipherShaders{@_[0]}}[1];
			lxout("rageRoughness = $rageRoughness");
			if ($rageRoughness < 4)	{$rageRoughness = 4;}
			elsif ($rageRoughness > 64)	{$rageRoughness = 64;}
			$rageRoughness -= 4;
			$rageRoughness = 1 - (.3 + .7 * (1 - ($rageRoughness / 60)));
			lxout("rageRoughness = $rageRoughness");
			lx("item.channel advancedMaterial\$rough $rageRoughness");
			if ($hack_powermipToRefl == 1){
				my $hackReflection = 1 - $rageRoughness;
				lx("item.channel advancedMaterial\$reflAmt $hackReflection");
			}
			lxout("   --> POWERMIP : got translated from @{$decipherShaders{@_[0]}}[1] to $rageRoughness");
		}
	}

	#bumpmap
	if (@{$decipherShaders{@_[0]}}[3] ne ""){
		my @imageInfo = split(/,/,@{$decipherShaders{@_[0]}}[3]);
		if (@imageInfo[0] eq "B"){
			#@imageInfo[1] =~ s/\//\\\\/g;
			if (-e @imageInfo[1]){
				lx("texture.new [@imageInfo[1]]");
				lx("texture.parent @{$shaderTreeIDs{@_[0]}}[0]");
				if ($sene_sutImageAA == 0){
					lx("item.channel imageMap\$aa false");
					lx("item.channel imageMap\$pixBlend $pixBlend");
				}
				lx("shader.setEffect normal");
				lx("item.channel imageMap\$greenInv true");
				lx("item.channel imageMap\$alpha 0");
				lxout("   --> BUMPMAP : B : @imageInfo[1]");
			}else{
				lxout("this file doesn't exist : @imageInfo[1]");
			}
		}elsif (@imageInfo[0] eq "A"){
			if (-e @imageInfo[1]){
				lx("texture.new [@imageInfo[1]]");
				lx("texture.parent @{$shaderTreeIDs{@_[0]}}[0]");
				if ($sene_sutImageAA == 0){
					lx("item.channel imageMap\$aa false");
					lx("item.channel imageMap\$pixBlend $pixBlend");
				}
				lx("shader.setEffect normal");
				lx("item.channel imageMap\$greenInv true");
				lx("item.channel imageMap\$alpha 0");
			}else{
				lxout("this file doesn't exist : @imageInfo[1]");
			}

			if (-e @imageInfo[2]){
				lx("texture.new [@imageInfo[2]]");
				lx("texture.parent @{$shaderTreeIDs{@_[0]}}[0]");
				if ($sene_sutImageAA == 0){
					lx("item.channel imageMap\$aa false");
					lx("item.channel imageMap\$pixBlend $pixBlend");
				}
				lx("shader.setEffect bump");
				lx("item.channel imageMap\$max [@imageInfo[3]]");
				lx("item.channel imageMap\$alpha 0");
				lxout("   --> BUMPMAP : A :@imageInfo[1] : @imageInfo[2]");
			}else{
				lxout("this file doesn't exist : @imageInfo[2]");
			}
		}elsif (@imageInfo[0] eq "H"){
			if (-e @imageInfo[1]){
				lx("texture.new [@imageInfo[1]]");
				lx("texture.parent @{$shaderTreeIDs{@_[0]}}[0]");
				if ($sene_sutImageAA == 0){
					lx("item.channel imageMap\$aa false");
					lx("item.channel imageMap\$pixBlend $pixBlend");
				}
				lx("shader.setEffect bump");
				lx("item.channel imageMap\$max [@imageInfo[2]]");
				lx("item.channel imageMap\$alpha 0");
				lxout("   --> BUMPMAP : H : @imageInfo[1]");
			}else{
				lxout("this file doesn't exist : @imageInfo[1]");
			}
		}
	}

	#diffusemap
	if (@{$decipherShaders{@_[0]}}[4] ne ""){
		my @imageInfo = split(/,/,@{$decipherShaders{@_[0]}}[4]);
		if (@imageInfo[0] eq "constantColor"){
			lx("select.subItem @{$shaderTreeIDs{@_[0]}}[1] set textureLayer;render;environment;mediaClip;locator");
			lx("item.channel advancedMaterial\$diffCol {@imageInfo[1] @imageInfo[2] @imageInfo[3]}");
			lxout("   --> DIFFUSEMAP : constantColor (@imageInfo[1],@imageInfo[2],@imageInfo[3])");
		}else{
			if (-e @imageInfo[0]){
				lx("texture.new [@imageInfo[0]]");
				lx("texture.parent @{$shaderTreeIDs{@_[0]}}[0]");
				if ($sene_sutImageAA == 0){
					lx("item.channel imageMap\$aa false");
					lx("item.channel imageMap\$pixBlend $pixBlend");
				}
				lx("item.channel imageMap\$alpha 0");
				if ((@imageInfo[1] != 1) || (@imageInfo[2] != 1) || (@imageInfo[3] != 1)){
					lx("shader.create constant");
					lx("item.channel textureLayer\$blend 6");
					lx("item.channel color {@imageInfo[1] @imageInfo[2] @imageInfo[3]}");
				}
				lxout("   --> DIFFUSEMAP : @imageInfo[0]");
			}else{
				lxout("this file doesn't exist : @imageInfo[0]");
			}
		}
	}

	#specularmap
	if (@{$decipherShaders{@_[0]}}[5] ne ""){
		#not using shader alpha
		my @imageInfo = split(/,/,@{$decipherShaders{@_[0]}}[5]);
		if (@imageInfo[0] eq "constantColor"){
			lx("select.subItem @{$shaderTreeIDs{@_[0]}}[1] set textureLayer;render;environment;mediaClip;locator");
			lx("item.channel advancedMaterial\$specCol {@imageInfo[1] @imageInfo[2] @imageInfo[3]}");
			lxout("   --> SPECULARMAP : constantColor (@imageInfo[1],@imageInfo[2],@imageInfo[3])");
		}else{
			if (-e @imageInfo[0]){
				lx("texture.new [@imageInfo[0]]");
				lx("texture.parent @{$shaderTreeIDs{@_[0]}}[0]");
				if ($sene_sutImageAA == 0){
					lx("item.channel imageMap\$aa false");
					lx("item.channel imageMap\$pixBlend $pixBlend");
				}
				lx("shader.setEffect specAmount");
				lx("item.channel imageMap\$alpha 0");
				if ((@imageInfo[1] != 1) || (@imageInfo[2] != 1) || (@imageInfo[3] != 1)){
					my $specularMultAmt = .33 * (@imageInfo[1] + @imageInfo[2] + @imageInfo[3]);
					lx("shader.create constant");
					lx("shader.setEffect specAmount");
					lx("item.channel textureLayer\$blend {6}");
					lx("item.channel value {$specularMultAmt}");
				}
				lxout("   --> SPECULARMAP : @imageInfo[0] : modulate=$specularMultAmt");
			}else{
				lxout("this file doesn't exist : @imageInfo[0]");
			}
		}
	}

	#alpha
	if (@{$decipherShaders{@_[0]}}[6] ne ""){
		my @imageInfo = split(/,/,@{$decipherShaders{@_[0]}}[6]);
		if (-e @imageInfo[0]){
			lx("texture.new [@imageInfo[0]]");
			lx("texture.parent @{$shaderTreeIDs{@_[0]}}[0]");
			if ($sene_sutImageAA == 0){
				lx("item.channel imageMap\$aa false");
				lx("item.channel imageMap\$pixBlend $pixBlend");
			}
			lx("shader.setEffect stencil");
			lx("item.channel imageMap\$alpha 2");
			lx("item.channel imageMap\$redInv true");
			lx("item.channel imageMap\$greenInv true");
			lx("item.channel imageMap\$blueInv true");
			lxout("   --> ALPHA : @imageInfo[0]");
		}else{
			lxout("this file doesn't exist : @imageInfo[0]");
		}
	}

	#add pass
	if (@{$decipherShaders{@_[0]}}[7] ne ""){
		my @imageInfo = split(/,/,@{$decipherShaders{@_[0]}}[7]);
		if (-e @imageInfo[0]){
			lx("texture.new [@imageInfo[0]]");
			lx("texture.parent @{$shaderTreeIDs{@_[0]}}[0]");
			if ($sene_sutImageAA == 0){
				lx("item.channel imageMap\$aa false");
				lx("item.channel imageMap\$pixBlend $pixBlend");
			}
			lx("shader.setEffect lumiColor");
			lx("item.channel imageMap\$alpha 0");

			lx("texture.new [@imageInfo[0]]");
			lx("texture.parent @{$shaderTreeIDs{@_[0]}}[0]");
			if ($sene_sutImageAA == 0){
				lx("item.channel imageMap\$aa false");
				lx("item.channel imageMap\$pixBlend $pixBlend");
			}
			lx("shader.setEffect lumiAmount");
			lx("item.channel imageMap\$alpha 2");
		}else{
			lxout("this file doesn't exist : @imageInfo[0]");
		}

		if ((@imageInfo[1] != 1) || (@imageInfo[2] != 1) || (@imageInfo[3] != 1)){
			lx("shader.create constant");
			lx("item.channel textureLayer\$blend 6");
			lx("item.channel color {@imageInfo[1] @imageInfo[2] @imageInfo[3]}");
			lx("shader.setEffect lumiAmount");
		}
		lxout("   --> ADD PASS : @imageInfo[0]");
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#DECIPHER SHADER SUB (modded to use $sene_matRepairPath instead of $gameDir)
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# requires %decipherShaders;
# requires shaderScaleReturn subroutine
sub decipherShaders{ #(0=renderbump 1=powerscale 2=specularscale 3=localmap 4=diffusemap 5=specularmap 6=transmap 7=additivePass)
	my $transMapSearch = 0;
	my $transMapArrayNum = 0;

	foreach my $key (keys %shaderText){
		@{$decipherShaders{$key}}[2] = 1; #initializing specularscale at 1

		foreach my $line (@{$shaderText{$key}}){
			#lxout("line = $line");
			if ($transMapSearch != 1){
				#7----------BASICADD---------
				if		(($line =~ /stageProgram/i) && ($line =~ /add/i)){
					$transMapSearch = 1;
					$transMapArrayNum = 7;
				}
				#6---------COVERTRANS--------
				elsif	(($line =~ /customprog/i) && ($line =~ /covert/i)){
					$transMapSearch = 1;
					$transMapArrayNum = 6;
				}
				#5--------SPECULARMAP--------
				elsif	($line =~ /specularmap/i){
					my $printLine = $line;
					$printLine =~ s/^.*specularmap\W*//i;
					$printLine =~ s/\\/\//g;
					$printLine =~ s/^clamp[\s\t]+//i;
					$printLine = shaderScaleReturn($printLine);
					@{$decipherShaders{$key}}[5] = $printLine;
				}
				#4---------DIFFUSEMAP--------
				elsif	($line =~ /diffusemap/i){
					my $printLine = $line;
					$printLine =~ s/^.*diffusemap\W*//i;
					$printLine =~ s/\\/\//g;
					$printLine =~ s/^clamp[\s\t]+//i;
					$printLine = shaderScaleReturn($printLine);
					@{$decipherShaders{$key}}[4] = $printLine;
				}
				#3----------BUMPMAP----------
				elsif	($line =~ /bumpmap/i){
					my $printLine = $line;
					$printLine =~ s/^.*bumpmap[\s\t]*//;
					$printLine =~ s/\\/\//g;
					if ($line =~ /addnormals/i){
						my @printLine = split(/heightmap/i, $printLine);
						@printLine[1] =~ s/\n//;				#del \n
						my $bumpAmount = @printLine[1];
						$bumpAmount =~ s/.*,//;					#del (space*,)
						$bumpAmount = numberReturn($bumpAmount);#del non numbers
						@printLine[0] =~ s/^.*\(\W*//;			#del leading*(
						@printLine[0] =~ s/\s*,.*//;			#del ,+
						@printLine[0] =~ s/^clamp[\s\t]+//i;	#del clamp
						@printLine[1] =~ s/,\s*.*//;			#del ,+
						@printLine[1] =~ tr/() \t//d;			#del tabs, spaces, ()
						@printLine[1] =~ s/^clamp[\s\t]+//i;		#del clamp

						if (@printLine[0] !~ /\.tga$/i){@printLine[0] .= ".tga"}
						if (@printLine[1] !~ /\.tga$/i){@printLine[1] .= ".tga"}
						if ($bumpAmount ne ""){$bumpAmount = ",".$bumpAmount;}
						@{$decipherShaders{$key}}[3] = "A,".$sene_matRepairPath.@printLine[0].",".$sene_matRepairPath.@printLine[1].$bumpAmount;
					}elsif ($line =~ /heightmap/i){
						$printLine =~ s/heightmap\W*//;
						$printLine =~ s/^clamp[\s\t]+//i;
						my @printLine = split(/,/,$printLine);
						@printLine[1] =~ s/\D//g;
						if (@printLine[0] !~ /\.tga$/i){@printLine[0] .= ".tga"}
						if (@printLine[1] ne ""){@printLine[1] = ",".@printLine[1];}
						@{$decipherShaders{$key}}[3] = "H,".$sene_matRepairPath.@printLine[0].@printLine[1];
					}else{
						$printLine =~ s/\s$//g;
						$printLine =~ s/\t$//g;
						$printLine =~ s/\n//;
						$printLine =~ s/^clamp[\s\t]+//i;
						if ($printLine !~ /\.tga$/i){$printLine .= ".tga"}
						@{$decipherShaders{$key}}[3] = "B,".$sene_matRepairPath.$printLine;
					}
				}
				#2--------SPECULARSCALE---------
				elsif	($line =~ /specularscale/i){
					my $printLine = $line;
					@{$decipherShaders{$key}}[2] = numberReturn($printLine);
				}
				#1A----------POWERMIP----------
				elsif	($line =~ /powermip/i){
					lxout("YES : POWERMIP=========================================");
					my $printLine = $line;
					@{$decipherShaders{$key}}[1] = numberReturn($printLine);
				}
				#1B----------POWERMAP----------
				elsif	($line =~ /powermap/i){
					lxout("YES : POWERMAP=========================================");
					my $printLine = $line;
					$printLine =~ s/^.*powermap\W*//i;
					$printLine =~ s/\\/\//g;
					$printLine =~ s/^clamp[\s\t]+//i;
					@{$decipherShaders{$key}}[1] = $printLine;
				}
				#0----------RENDERBUMP----------
				elsif	($line =~ /renderbump/i){
					@{$decipherShaders{$key}}[0] = 1;
				}
			}else{
				if ($transMapArrayNum == 6){
					if ($line =~ /covermap/o){
						$transMapSearch = 0;
						my $printLine = $line;
						$printLine =~ s/^.*covermap\W*//i;
						$printLine =~ s/\n//;
						$printLine =~ s/\s//g;
						$printLine =~ s/\t//g;
						$printLine =~ s/\\/\//g;
						$printLine =~ s/^clamp[\s\t]+//i;
						if ($printLine !~ /\.tga$/i){$printLine .= ".tga"}
						@{$decipherShaders{$key}}[6] = $sene_matRepairPath.$printLine;
					}elsif ($line =~ /}/){
						lxout("coverTrans : hit the end of the shader group and couldn't find transmap, so i'm turning transmap search off");
						$transMapSearch = 0;
					}
				}elsif ($transMapArrayNum == 7){
					if ($line =~ /transmap/i){
						$transMapSearch = 0;
						my $printLine = $line;
						$printLine =~ s/^.*transmap\W*//i;
						$printLine =~ s/\\/\//g;
						$printLine =~ s/^clamp[\s\t]+//i;
						$printLine = shaderScaleReturn($printLine);
						@{$decipherShaders{$key}}[7] = $printLine;
					}elsif ($line =~ /}/){
						lxout("basicadd : hit the end of the shader group and couldn't find transmap, so i'm turning transmap search off");
						$transMapSearch = 0;
					}
				}
			}
		}
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SHADER TREE TOOLS SUB (modded to use $sene_matRepairPath instead of $gameDir) (also modded to assume the correct ptyp)
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#HASH TABLE : 0=MASKID 1=MATERIALID   if $shaderTreeIDs{(all)} exists, that means there's some materials that effect all and should be nuked.
#PTAG : MASKID : (PTAG , MASKID , $PTAG) : returns the ptag mask group ID.
#PTAG : MATERIALID : (PTAG , MATERIALID , $PTAG) : returns the first materialID found in the ptag mask group.
#PTAG : MASKEXISTS : (PTAG , MASKEXISTS , $PTAG) : finds out if a ptag mask group exists or not.  0=NO 1=YES 2=YES,BUTNOMATERIALINIT
#PTAG : ADDIMAGE : (0=PTAG , 1=ADDIMAGE , 2=$PTAG , 3=IMAGEPATH , 4=EFFECT , 5=BLENDMODE , 6=UVMAP , 7=BRIGHTNESS , 8=INVERTGREEN , 9=AA) : adds an image to the ptag mask group w/ options.
#PTAG : DELCHILDTYPE : (PTAG , DELCHILDTYPE , $PTAG , TYPE) : deletes all the TYPE items in this ptag's mask group.
#PTAG : CREATEMASK : (PTAG , CREATEMASK , $PTAG) : create a material if it didn't exist before.
#PTAG : CHILDREN : (PTAG , CHILDREN , $PTAG , TYPE) : returns all the children from the ptag mask group.  Only returns children of a certain type if TYPE appended.
#GLOBAL : BUILDDBASE : (BUILDDBASE , ?FORCEUPDATE?) : creates the database to find a ptag's mask or material.  skips routine if the database isn't empty.  use forceupdate to force it again.
#GLOBAL : FINDPTAGFROMID : (FINDPTAGFROMID , ARRAYVALNAME , ARRAYNUMBER) : returns the hash key of the element you sent it and the pos in the array.
#GLOBAL : FINDALLOFTYPE : (FINDALLOFTYPE , TYPE) : returns all IDs that match the type.
#GLOBAL : TOGGLEALLOFTYPE : (TOGGLEALLOFTYPE , ONOFF , TYPE1 , TYPE2, ETC) : will turn everything of a type on or off
#GLOBAL : DELETEALLOFTYPE : (DELETEALLOFTYPE , TYPE) : deletes all of the selected type in the shader tree and updates database
#GLOBAL : DELETEALLALL : (DELETEALLALL) : deletes all the materials in the scene that effect ALL in the scene.
#NOTE : it's forcing all materials to have / and not \, so this isn't 100% legit if you have dupes.
sub shaderTreeTools{
	#lxout("[->] Running ShaderTreeTools sub <@_[0]> <@_[1]>");
	our %shaderTreeIDs;

	#----------------------------------------------------------
	#PTAG SPECIFIC :
	#----------------------------------------------------------
	if (@_[0] eq "ptag"){
		#MASK ID-------------------------
		if (@_[1] eq "maskID"){
			lxout("[->] Running maskID sub");
			shaderTreeTools(buildDbase);

			my $ptag = @_[2];
			$ptag =~ s/\\/\//g;
			return($shaderTreeIDs{@_[2]}[0]);
		}
		#MATERIAL ID---------------------
		elsif (@_[1] eq "materialID"){
			lxout("[->] Running materialID sub");
			shaderTreeTools(buildDbase);

			my $ptag = @_[2];
			$ptag =~ s/\\/\//g;
			return($shaderTreeIDs{@_[2]}[1]);
		}
		#MASK EXISTS---------------------
		elsif (@_[1] eq "maskExists"){
			lxout("[->] Running maskExists sub");
			shaderTreeTools(buildDbase);

			my $ptag = @_[2];
			$ptag =~ s/\\/\//g;
			if (exists $shaderTreeIDs{$ptag}){
				if (@{$shaderTreeIDs{$ptag}}[1] =~ /advancedMaterial/){
					return 1;
				}else{
					return 2;
				}
			}else{
				return 0;
			}
		}
		#ADD IMAGE-----------------------
		elsif (@_[1] eq "addImage"){
			lxout("[->] Running addImage sub");
			shaderTreeTools(buildDbase);

			if (@_[6] ne ""){lx("select.vertexMap @_[6] txuv replace");}

			my $ptag = @_[2];
			$ptag =~ s/\\/\//g;
			my $id = $shaderTreeIDs{$ptag}[0];
			lx("texture.new [@_[3]]");
			lx("texture.parent [$id] [-1]");

			if (@_[4] ne ""){lx("shader.setEffect @_[4]");}
			if (@_[7] ne ""){lx("item.channel imageMap\$max @_[7]");}
			if (@_[8] ne ""){lx("item.channel imageMap\$greenInv @_[8]");}
			if (@_[9] ne ""){lx("item.channel imageMap\$aa 0");  lx("item.channel imageMap\$pixBlend $pixBlend");}
		}
		#DEL CHILD TYPE-------------------
		elsif (@_[1] eq "delChildType"){
			lxout("[->] Running delChildType sub (deleting all @_[3]s)");
			shaderTreeTools(buildDbase);

			my $ptag = @_[2];
			$ptag =~ s/\\/\//g;
			my $id = $shaderTreeIDs{$ptag}[0];
			my @children = shaderTreeTools(ptag,children,$ptag,@_[3]);

			if (@children > 0){
				for (my $i=0; $i<@children; $i++){
					if ($i > 0)	{lx("select.subItem [@children[$i]] add textureLayer;render;environment;mediaClip;locator");}
					else		{lx("select.subItem [@children[$i]] set textureLayer;render;environment;mediaClip;locator");}
				}
				lx("texture.delete");
			}
		}
		#CREATE MASK---------------------
		elsif (@_[1] eq "createMask"){
			lxout("[->] Running createMask sub");
			shaderTreeTools(buildDbase);

			lx("select.subItem [@{$shaderTreeIDs{polyRender}}[0]] set textureLayer;render;environment;mediaClip;locator");
			lx("shader.create mask");
			my @masks = lxq("query sceneservice selection ? mask");
			lx("mask.setPTagType Material");
			lx("mask.setPTag @_[2]");
			lx("shader.create advancedMaterial");
			my @materials = lxq("query sceneservice selection ? advancedMaterial");
			@{$shaderTreeIDs{@_[2]}} = (@masks[0],@materials[0]);
		}
		#CHILDREN------------------------
		elsif (@_[1] eq "children"){
			lxout("[->] Running children sub");
			shaderTreeTools(buildDbase);

			my $ptag = @_[2];
			$ptag =~ s/\\/\//g;
			if (@_[3] eq ""){
				return (lxq("query sceneservice item.children ? $shaderTreeIDs{@_[2]}[0]"));
			}else{
				my @children = lxq("query sceneservice item.children ? $shaderTreeIDs{@_[2]}[0]");
				my @prunedChildren;
				foreach my $child (@children){
					if (lxq("query sceneservice item.type ? $child") eq @_[3]){
						push(@prunedChildren,$child);
					}
				}
				return (@prunedChildren);
			}
		}
	}

	#----------------------------------------------------------
	#GENERAL EDITING :
	#----------------------------------------------------------
	else{
		#BUILD DATABASE------------------
		if (@_[0] eq "buildDbase"){
			if (((keys %shaderTreeIDs) > 1) && ($_[1] ne "forceUpdate")){return;}
			if ($_[1] eq "forceUpdate"){%shaderTreeIDs = ();}

			lxout("[->] Running buildDbase sub");
			my $itemCount = lxq("query sceneservice item.n ? all");
			for (my $i=0; $i<$itemCount; $i++){
				my $type = lxq("query sceneservice item.type ? $i");

				#masks
				if ($type eq "mask"){
					if ((lxq("query sceneservice channel.value ? ptyp") eq "Material") || (lxq("query sceneservice channel.value ? ptyp") eq "")){
						my $id = lxq("query sceneservice item.id ? $i");
						my $ptag = lxq("query sceneservice channel.value ? ptag");
						$ptag =~ s/\\/\//g;

						if ($ptag eq "(all)"){
							push(@{$shaderTreeIDs{"(all)"}},$id);
						}else{
							my @children = lxq("query sceneservice item.children ? $i");
							#lxout("ptag = $ptag <> id = $id");
							@{$shaderTreeIDs{$ptag}}[0] = $id;
							foreach my $child (@children){
								if (lxq("query sceneservice item.type ? $child") eq "advancedMaterial"){
									@{$shaderTreeIDs{$ptag}}[1] = $child;
								}else{
								}
							}
						}
					}else{
						@{$shaderTreeIDs{$ptag}}[0] = "noPtag";
						push(@{$shaderTreeIDs{$ptag}},$id);
					}
				}

				#outputs
				elsif ($type eq "renderOutput"){
					my $id = lxq("query sceneservice item.id ? $i");
					push(@{$shaderTreeIDs{renderOutput}},$id);
				}

				#shaders
				elsif ($type eq "defaultShader"){
					my $id = lxq("query sceneservice item.id ? $i");
					push(@{$shaderTreeIDs{defaultShader}},$id);
				}

				#render output
				elsif ($type eq "polyRender"){
					my $id = lxq("query sceneservice item.id ? $i");
					push(@{$shaderTreeIDs{polyRender}},$id);
				}
			}
		}
		#FIND PTAG FROM ID---------------
		elsif (@_[0] eq "findPtag"){
			foreach my $key (keys %shaderTreeIDs){
				if (@{$shaderTreeIDs{$key}}[1] eq @_[@_[2]]){
					return $key;
				}
			}
		}
		#FIND ALL OF TYPE----------------
		elsif (@_[0] eq "findAllOfType"){
			my @list;
			for (my $i=0; $i<lxq("query sceneservice txLayer.n ? all"); $i++){
				if (lxq("query sceneservice txLayer.type ? $i") eq @_[1]){
					push(@list,lxq("query sceneservice txLayer.id ? $i"));
				}
			}
			return @list;
		}
		#TOGGLE ALL OF TYPE--------------
		elsif (@_[0] eq "toggleAllOfType"){
			for (my $i=0; $i<lxq("query sceneservice item.n ? all"); $i++){
				my $type = lxq("query sceneservice item.type ? $i");
				for (my $u=2; $u<$#_+1; $u++){
					if ($type eq @_[$u]){
						my $id = lxq("query sceneservice item.id ? $i");
						lx("select.subItem [$id] set textureLayer;render;environment");
						lx("item.channel textureLayer\$enable @_[1]");
					}
				}
			}
		}
		#DELETE ALL OF TYPE--------------
		elsif (@_[0] eq "delAllOfType"){
			my @deleteList;

			for (my $i=0; $i<lxq("query sceneservice txLayer.n ? all"); $i++){
				if (lxq("query sceneservice txLayer.type ? $i") eq @_[1]){
					my $id = lxq("query sceneservice txLayer.id ? $i");
					push(@deleteList,$id);

					if (@_[1] eq "mask"){
						my $ptag = shaderTreeTools(findPtag,$id,1);
						$ptag =~ s/\\/\//g;
						delete $shaderTreeIDs{$ptag};
					}elsif  (@_[1] eq "advancedMaterial"){
						my $ptag = shaderTreeTools(findPtag,$id,1);
						$ptag =~ s/\\/\//g;
						lxout("found ptag = $ptag");
						if ($ptag ne ""){delete @{$shaderTreeIDs{$ptag}}[1];}
					}
				}
			}
			foreach my $id (@deleteList){
				lx("select.subItem [$id] set textureLayer;render;environment");
				lx("texture.delete");
			}

		}
		#DELETE ALL (ALL) MATERIALS------
		elsif (@_[0] eq "deleteAllALL"){
			shaderTreeTools(buildDbase);
			my @deleteList;

			if (exists $shaderTreeIDs{"(all)"}){
				foreach my $id (@{$shaderTreeIDs{"(all)"}}){push(@deleteList,$id);}
				delete $shaderTreeIDs{"(all)"};
			}
			foreach my $key (keys %shaderTreeIDs){
				if (@{$shaderTreeIDs{$key}}[0] eq "noPtag"){
					for (my $i=1; $i<@{$shaderTreeIDs{$key}}; $i++){
						push(@deleteList,@{$shaderTreeIDs{$key}}[$i]);
					}
					delete $shaderTreeIDs{$key};
				}
			}

			if (@deleteList > 0){
				lxout("[->] : Deleting these materials because they're not assigned to one ptag :\n@deleteList");
				for (my $i=0; $i<@deleteList; $i++){
					if ($i > 0)	{	lx("select.subItem [@deleteList[$i]] add textureLayer;render;environment");}
					else		{	lx("select.subItem [@deleteList[$i]] set textureLayer;render;environment");}
				}
				lx("texture.delete");
			}
		}
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SHADER SCALE RETURN SUB (modded to use $sene_matRepairPath instead of $gameDir)
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub shaderScaleReturn{
	my $string;
	my @list;
	my $constantColorCheck=0;
	if (@_[0] =~ /constantcolor/i){
		#lxout("@_[0] : this pass has constantcolor applied");
		my $line = @_[0];
		$line =~ s/constantcolor//i;
		$line =~ tr/() \t//d;
		@list = split(/,/,$line);
		unshift(@list,"constantColor");
		if (@list[4] == ""){@list[4] = 1;}
		$constantColorCheck=1;
	}elsif (@_[0] =~ /scale[\s\t]*\(/i){
		#lxout("@_[0] : yes, it has scale applied");
		if (@list[4] == 0){@list[4] == 1;}
		@list = split/,/,@_[0];
		@list[0] =~ s/^.*scale[\s\t]*\(//i;
		@list[0] =~ s/\s//g;
		@list[1] = numberReturn(@list[1]);
		@list[2] = numberReturn(@list[2]);
		@list[3] = numberReturn(@list[3]);
		@list[4] = numberReturn(@list[4]);
	}else{
		#lxout("@_[0] : no, it doesn't have scale applied");
		@list[0] = @_[0];
		@list[0] =~ tr/\n \t//d;
		@list[1] = 1;
		@list[2] = 1;
		@list[3] = 1;
		@list[4] = 1;
	}

	#lxout("end list = @list");
	if ($constantColorCheck == 0){
		if (@list[0] !~ /\.tga$/i){@list[0] .= ".tga"}
		$string = $sene_matRepairPath.@list[0].",".@list[1].",".@list[2].",".@list[3].",".@list[4];
	}else{
		$string = @list[0].",".@list[1].",".@list[2].",".@list[3].",".@list[4];
	}
	return ($string);
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#REPAIR MISSING MATERIALS
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
sub repairMissingMaterials{
	lxout("[->] CREATING MISSING MATERIALS--------------------");
	shaderTreeTools(buildDbase);
	our @newlyCreatedPtags;

	my @fgLayers = lxq("query layerservice layers ? fg");

	my %ptagList;
	my $layerCount = lxq("query layerservice layer.n ? all");
	for (my $i=1; $i<$layerCount+1; $i++){
		my $id = lxq("query layerservice layer.id ? $i");
		lx("select.subItem {$id} set mesh;triSurf;meshInst;camera;light;backdrop;groupLocator;replicator;deform;locdeform;chanModify;chanEffect 0 0");

		my $layerName = lxq("query layerservice layer.name ? $i");
		my $materialCount = lxq("query layerservice material.n ? all");
		for (my $u=0; $u<$materialCount; $u++){
			my $materialName = lxq("query layerservice material.name ? $u");
			$ptagList{$materialName} = 1;
		}
	}

	foreach my $ptag (keys %ptagList){
		if (shaderTreeTools(ptag,maskExists,$ptag) == 0){
			lxout("[->] : shaderTreeTools says this mask doesn't exist : $ptag");
			my $ptagMod = $ptag;
			$ptagMod =~ s/\\/\//g;
			push(@newlyCreatedPtags,$ptagMod);
			lx("select.itemType polyRender");
			lx("shader.create mask");
			lx("item.name {$ptag}");
			lx("mask.setPTagType Material");
			lx("mask.setPTag {$ptag}");
			lx("shader.create advancedMaterial");
		}
	}

	#have to do this before i select masks because select.drop item will desel the masks
	lx("select.drop item");
	for (my $i=0; $i<@fgLayers; $i++){
		my $id = lxq("query layerservice layer.id ? $fgLayers[$i]");
		lx("select.subItem {$id} add mesh;triSurf;meshInst;camera;light;backdrop;groupLocator;replicator;deform;locdeform;chanModify;chanEffect 0 0");
	}


	if (@newlyCreatedPtags > 0){
		my $loopCount = 0;
		shaderTreeTools(buildDbase,forceUpdate);

		foreach my $ptag (@newlyCreatedPtags){
			my $maskID = shaderTreeTools(ptag,maskID,$ptag);
			if ($loopCount == 0)	{	lx("select.subItem {$maskID} set textureLayer;render;environment;light;camera;mediaClip;txtrLocator");	}
			else					{	lx("select.subItem {$maskID} add textureLayer;render;environment;light;camera;mediaClip;txtrLocator");	}
			$loopCount++;
		}
	}
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#CREATE A PER LAYER ELEMENT SELECTION LIST (retuns first and last elems, and ordered list for all layers)
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#usage : my @firstLastPolys = createPerLayerElemList(poly,\%polys);
sub createPerLayerElemList{
	my $hash = @_[1];
	my @totalElements = lxq("query layerservice selection ? @_[0]");
	if (@totalElements == 0){die("\\\\n.\\\\n[---------------------------------------------You don't have any @_[0]s selected and so I'm cancelling the script.--------------------------------------------]\\\\n[--PLEASE TURN OFF THIS WARNING WINDOW by clicking on the (In the future) button and choose (Hide Message)--] \\\\n[-----------------------------------This window is not supposed to come up, but I can't control that.---------------------------]\\\\n.\\\\n");}

	#build the full list
	foreach my $elem (@totalElements){
		$elem =~ s/[\(\)]//g;
		my @split = split/,/,$elem;
		push(@{$$hash{@split[0]}},@split[1]);
	}

	#return the first and last elements
	return(@totalElements[0],@totalElements[-1]);
}


#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#MAINLAYER VISIBILITY ASSURANCE SUBROUTINE (toggles vis of mainlayer and/or parents if any are hidden)
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
# USAGE : (requires mainlayerID)
# my @verifyMainlayerVisibilityList = verifyMainlayerVisibility();	#to collect hidden parents and show them
# verifyMainlayerVisibility(\@verifyMainlayerVisibilityList);		#to hide the hidden parents (and mainlayer) again.
sub verifyMainlayerVisibility{
	my @hiddenParents;

	#hide the items again.
	if (@_ > 0){
		foreach my $id (@{@_[0]}){
			#lxout("[->] : hiding $id");
			lx("layer.setVisibility {$id} 0");
		}
	}

	#show the mainlayer and all the mainlayer parents that are hidden (and retain a list for later use)
	else{
		if( lxq( "select.typeFrom {vertex;edge;polygon;item} ?" ) ){	our $tempSelMode = "vertex";	}
		if( lxq( "select.typeFrom {edge;polygon;item;vertex} ?" ) ){	our $tempSelMode = "edge";		}
		if( lxq( "select.typeFrom {polygon;item;vertex;edge} ?" ) ){	our $tempSelMode = "polygon";	}
		if( lxq( "select.typeFrom {item;vertex;edge;polygon} ?" ) ){	our $tempSelMode = "item";		}
		lx("select.type item");
		if (lxq("layer.setVisibility $mainlayerID ?") == 0){
			lxout("[->] : showing $mainlayerID");
			lx("layer.setVisibility $mainlayerID 1");
			push(@hiddenParents,$mainlayerID);
		}
		lx("select.type $tempSelMode");

		my $parentFind = 1;
		my $currentID = $mainlayerID;
		while ($parentFind == 1){
			my $parent = lxq("query sceneservice item.parent ? {$currentID}");
			if ($parent ne ""){
				$currentID = $parent;

				if (lxq("layer.setVisibility {$parent} ?") == 0){
					#lxout("[->] : showing $parent");
					lx("layer.setVisibility {$parent} 1");
					push(@hiddenParents,$parent);
				}
			}else{
				$parentFind = 0;
			}
		}

		return(@hiddenParents);
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#RETURN THE NUMBER IN THIS STRING SUB
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub numberReturn{
	if (@_[0] =~ m/(\d*\.\d*)/){
		return $1;
	}else{
		my $number = @_[0];
		$number =~ s/\D//g;
		return $number;
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#PRINT ALL THE ELEMENTS IN A HASH TABLE FULL OF ARRAYS
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#usage : printHashTableArray(\%table,table);
sub printHashTableArray{
	lxout("          ------------------------------------Printing @_[1] list------------------------------------");
	my $hash = @_[0];
	foreach my $key (sort keys %{$hash}){
		lxout("          KEY = $key");
		for (my $i=0; $i<@{$$hash{$key}}; $i++){
			lxout("             $i = @{$$hash{$key}}[$i]");
		}
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
#READ OR WRITE SHADER (NEW|OVERWRITE) SUB. (writes out name{data} with tabs)
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#usage : writeNewOrReplaceShader($shaderName,\@shaderText,$textFilePath,read|write);
sub writeNewOrReplaceShader{
	my $shaderName =			@_[0];
	my $shaderTextArrayRef =	@_[1];
	my $textFilePath =			@_[2];
	my $readOrWrite =			@_[3];
	$shaderName =~ s/\\/\//g;
	my $bracketCount = 0;
	my $foundShaderCheck = 0;
	my $currentLine = 0;
	my @shaderLines;
	my @shaderLineNumbers;
	my $lineBump = 1;

	#================================
	#START : the shader text
	#================================
	open (FILE, "<$textFilePath") or popup("This file doesn't exist : $textFilePath");
	while (<FILE>){
		$_ =~ s/\/\/.*//g; #nuke commented text
		my $openingBracketCount = $_ =~ tr/{/{/;
		my $closingBracketCount = $_ =~ tr/}/}/;

		#find the shader start
		if ($bracketCount == 0){
			$_ =~ s/^[\s\t]*//; #nuke beginning spaces
			$_ =~ s/[\t\s]*$//; #nuke trailing spaces
			$_ =~ s/[\{\}]//g;  #nuke brackets
			if (lc($_) eq lc($shaderName)){
				$foundShaderCheck = 1;
				lxout("[->] found ($shaderName) on line # $currentLine");
			}
		}
		$bracketCount += $openingBracketCount;
		$bracketCount -= $closingBracketCount;

		#if shader is found, copy text
		if ($foundShaderCheck == 1){
			if ($bracketCount == 0){
				if ($_ =~ /[a-zA-Z0-9_]/){
					$lineBump = 0;
					$_ =~ s/[\{\}]*//g;
					push(@shaderLines,$_);
					push(@shaderLineNumbers,$currentLine);
				}
				last;
			}else{
				push(@shaderLines,$_);
				push(@shaderLineNumbers,$currentLine);
			}
		}
		$currentLine++;
	}
	close(FILE);

	#================================
	#FINISH : READ : return results
	#================================
	if ($readOrWrite eq "read"){
		if ($foundShaderCheck == 1){
			return (\@shaderLines);
		}else{
			lxout("couldn't find shader : $shaderName ");
			return 0;
		}
	}

	#================================
	#FINISH : WRITE : write out results
	#================================
	elsif ($readOrWrite eq "write"){
		my @newShaderText;

		#write to bottom of file because shader didn't exist
		if ($foundShaderCheck  == 0){
			lxout("[->] : printing new shader");
			open (FILE, ">>$textFilePath") or popup("This file doesn't exist : $textFilePath");
			print FILE "\n" . $shaderName . "{\n";
			print FILE "\t" . $_ . "\n" for @{$shaderTextArrayRef};
			print FILE "}\n";
			close (FILE);
		}

		#overwrite already existing shader.
		else{
			popup("Are you sure you wish to overwrite this shader ?\n$shaderName");
			lxout("[->] : overwriting preexisting shader");
			my @shaderFileText;

			open (FILE, "<$textFilePath") or popup("This file doesn't exist : $textFilePath");
			while (<FILE>){push(@shaderFileText,$_);}
			close (FILE);

			#remove from array
			splice(@shaderFileText, $shaderLineNumbers[0],($shaderLineNumbers[-1] - $shaderLineNumbers[0]) + 1 + $lineBump);
			if (( @shaderFileText[@shaderLineNumbers[0]] !~ /[a-zA-Z0-9_]/ ) && ( @shaderFileText[@shaderLineNumbers[0]-1] !~ /[a-zA-Z0-9_]/ )){
				splice(@shaderFileText, $shaderLineNumbers[0], 1);
			}

			#create new shader text array
			push(@newShaderText,$shaderName . "{\n");
			foreach my $line (@{$shaderTextArrayRef}){
				$line = "\t" . $line . "\n";
				push(@newShaderText,$line);
			}
			push(@newShaderText,"}\n");

			#add to array
			splice(@shaderFileText, $shaderLineNumbers[0],0, @newShaderText);

			#write to file
			open (FILE, ">$textFilePath") or popup("This file doesn't exist : $textFilePath");
			foreach my $line (@shaderFileText){
				print FILE $line;
			}
			close (FILE);
		}
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#BUILD THE EXCLUSION LIST FOR DIR ROUTINE
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub buildExclusionList{
	open (exclusionFile, "<@_[0]") or die("I couldn't find the exclusion file");
	while ($line = <exclusionFile>){
		$line =~ s/\n//;
		$exclusionList{$line} = 1;
	}
	close(exclusionFile);
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#DIR SUB (ver 1.1 proper dir find)
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#requirements 1 : needs buildExclusionList sub if you want to use an external exclusion file.  Also, declare %exclusionList as global
#requirements 2 : needs matchPattern sub
#requirements 3 : Declare %dirResult as global so this routine can be used multiple times and add to that hash table.
#USAGE : dir($checkDir,\@ignoreDirs,\@matchFilePatterns,\@ignoreFilePatterns);
sub dir{
	#get the name of the current dir.
	my $currentDir = @_[0];
	my @tempCurrentDirName = split(/\//, $currentDir);
	my $tempCurrentDirName = @tempCurrentDirName[-1];
	my @directories;

	#open the current dir and sort out it's files and folders.
	opendir($currentDir,$currentDir) || die("Cannot opendir $currentDir");
	my @files = (sort readdir($currentDir));
	shift(@files);
	shift(@files);

	#--------------------------------------------------------------------------------------------
	#SORT THE NAMES TO BE DIRS OR MODELS
	#--------------------------------------------------------------------------------------------
	foreach my $name (@files){
		#LOOK FOR DIRS
		if (-d $currentDir . "\/" . $name){
			if (matchPattern($name,@_[1],-1)){	push (@directories,$currentDir . "\/" . $name);		}
		}

		#LOOK FOR FILES
		elsif ((matchPattern($name,@_[2])) && ($exclusionList{$currentDir . "\/" . $name} != 1) && (matchPattern($name,@_[3],-1))){
			$dirResult{$currentDir . "\/" . $name} = 1;
		}
	}

	#--------------------------------------------------------------------------------------------
	#RUN THE SUBROUTINE ON EACH DIR FOUND.
	#--------------------------------------------------------------------------------------------
	foreach my $dir (@directories){
		&dir($dir,@_[1],@_[2],@_[3]);
	}
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SEE IF ARG0 MATCHES ANY PATTERN IN ARG1ARRAYREF
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#USAGE : if (matchPattern(name,\@checkArray,-1)){lxout("yes");}
sub matchPattern{
	if (@_[2] != -1){
		foreach my $name (@{@_[1]}){
			if (@_[0] =~ /$name/i){return 1;}
		}
		return 0;
	}else{
		foreach my $name (@{@_[1]}){
			if (@_[0] =~ /$name/i){return 0;}
		}
		return 1;
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#RETURN MAX VALUE SUB
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#USAGE : my $maxValue = returnMaxValue(@arrayOfNumbers);
sub returnMaxValue{
	my $max = $_[0];
	foreach my $value (@_){
		if ($value > $max){$max = $value;}
	}
	return $max;
}


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#GATHER EVERY X ELEMS FROM ARRAY
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#usage : my @newArray = gatherEveryXElemsFromArray(\@array,10);  #will return 10 evenly spaced elems from the array
sub gatherEveryXElemsFromArray{
	if (@{$_[0]} < $_[1]){
		return @{$_[0]};
	}else{
		my @newArray;
		for (my $i=0; $i<$_[1]; $i++){
			my $index = 0;
			if ($i > 0)	{	$index = int(@{$_[0]} * (1/$_[1])*$i + .5);	}
			my $arrayValue = @{$_[0]}[$index];
			push(@newArray,@{$_[0]}[$index]);
		}
		return @newArray;
	}
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#RETURN CORRECT INDICES SUB : (this is for finding the new poly indices when they've been corrupted because of earlier poly indice changes)
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#USAGE : returnCorrectIndice(\@currentPolys,\@changedPolys);
#notes : both arrays must be numerically sorted first.  Also, it'll modify both arrays with the new numbers
sub returnCorrectIndice{
	my @firstElems;
	my @lastElems;
	my %inbetweenElems;
	my @newList;

	#1 : find where the elements go in the old array
	foreach my $elem (@{@_[0]}){
		my $loop = 1;
		my $start = 0;
		my $end = $#{@_[1]};

		#less than the array
		if (($elem == 0) || ($elem < @{@_[1]}[0])){
			push(@firstElems,$elem);
		}
		#greater than the array
		elsif ($elem > @{@_[1]}[-1]){
			push(@lastElems,$elem);
		}
		#in the array
		else{
			while($loop == 1){
				my $currentPoint = int((($start + $end) * .5 ) + .5);

				if ($end == $start + 1){
					$inbetweenElems{$elem} = $currentPoint;
					$loop = 0;
				}elsif ($elem > @{@_[1]}[$currentPoint]){
					$start = $currentPoint;
				}elsif ($elem < @{@_[1]}[$currentPoint]){
					$end = $currentPoint;
				}else{
					popup("Oops.  The returnCorrectIndice sub is failing with this element : ($elem)!");
				}
			}
		}
	}

	#2 : now get the new list of elements with their new names
	#inbetween elements
	for (my $i=@firstElems; $i<@{@_[0]} - @lastElems; $i++){
		@{@_[0]}[$i] = @{@_[0]}[$i] - ($inbetweenElems{@{@_[0]}[$i]});
	}
	#last elements
	for (my $i=@{@_[0]}-@lastElems; $i<@{@_[0]}; $i++){
		@{@_[0]}[$i] = @{@_[0]}[$i] - @{@_[1]};
	}

	#3 : now update the used element list
	my $count = 0;
	foreach my $elem (sort { $a <=> $b } keys %inbetweenElems){
		splice(@{@_[1]}, $inbetweenElems{$elem}+$count,0, $elem);
		$count++;
	}
	unshift(@{@_[1]},@firstElems);
	push(@{@_[1]},@lastElems);
}
