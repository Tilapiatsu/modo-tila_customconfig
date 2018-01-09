#python#

# NailGun 0.1 - Kjell Emanuelsson 2017  (Slow Temp freeze layer version. Proper maths version ETA whoknows...)
#
# Instances "loaded" item to where you point the mouse (on *any* mesh item - *except instances*)
# Pretty much replaces Mesh Paint for the most part for me: An instancing (working) version of the Tack Tool...
#
# Use:  Requires you have used the loader script to pick item to instance. (You can *load* instances!) And then:
#		Either A : Select an element (VERT;POLY;EDGE) and the instance will be fitted to the selection
#			or B : Just point your mouse on any element of any mesh (except instances) to instance  (no selection present / or in item mode)
#
# Future: For 1.0: (Using loader:) Multiple assignable slots and presets, (kitloading?) in pop up form, with icons etc.
#		  (Being able to instance on instances would be neat too, but beyond me atm.)
#		  Symmetry support, maybe just the basic world space workaround...
#		  1.0 ETA: Between 6 months & never ;) a bit of work for not much benefit afaict...
#
# Tip : Might get confused if you're zoomed out too much - Zoom in a bit.

item = []
verbose = False
offset = 0 
# hit = False
# pre_sel = False
subhack = True

# --------------------------------------------------------------------
# UserValue checks
# --------------------------------------------------------------------

# Check for Loaded Item 
if verbose : print "-------------" # Eventlog separator

if not lx.eval('query scriptsysservice userValue.isDefined ? ke_nailgun.item') :
	sys.exit(": --- Loader Error: Mesh Item not Loaded. Please use Loader to select Item for instancing. --- ")		

elif lx.eval('user.value ke_nailgun.item ?') == "None" :	
	sys.exit(": --- Loader Error: Mesh Item not Loaded. Please use Loader to select Item for instancing. --- ")		
	
else : 
	item = lx.eval('user.value ke_nailgun.item ?')
	

# Check for offset value set		
if lx.eval('query scriptsysservice userValue.isDefined ? ke_nailgun.offset') :
	offset = lx.eval('user.value ke_nailgun.offset ?')
	

# --------------------------------------------------------------------		
# Check / Select Target Mesh
# --------------------------------------------------------------------

# Check if elements are selected 
# sel_mode = lx.eval('query layerservice selmode ?')

# if sel_mode == "polygon" : 
	# if lx.eval('query layerservice polys ? selected') : hit, pre_sel = True, True
# elif sel_mode == "edge" : 
	# if lx.eval('query layerservice edges ? selected') : hit, pre_sel = True, True
# elif sel_mode == "vertex" :
	# if lx.eval('query layerservice verts ? selected') : hit, pre_sel = True, True
# else : pass


# Otherwise use mouse pos 
# if not pre_sel:

lx.eval('select.typeFrom item')

try : lx.eval('select.3DElementUnderMouse set')
except : 
	if lx.eval('query sceneservice selection ? mesh') : pass
	else : sys.exit(": --- Selection Error: Mouse not over Mesh? --- ")		

lx.eval('select.type polygon')
	
try : lx.eval('select.3DElementUnderMouse set')
except : sys.exit(": --- Selection Error: Mouse not over valid mesh/element? --- ")	

if   lx.eval('query layerservice polys ? selected') : hit = True
elif lx.eval('query layerservice edges ? selected') : hit = True
elif lx.eval('query layerservice verts ? selected') : hit = True	
else : sys.exit(": --- Selection Error: Mouse not over Mesh? --- ")	

mouse_pos = lx.eval('query view3dservice mouse.hitPos ?')

if subhack : # making temp freeze layer 
	# lx.eval('select.connect') # might be (too) bad for complex meshes...
	lx.eval('select.expand')
	
	lx.eval('select.copy')
	lx.eval('layer.new')
	lx.eval('select.paste')
	lx.eval('poly.freeze face false 2 true true true true 5.0 false Morph')
	new_layer = lx.eval('query layerservice layers ? selected')	
	new_ID = lx.eval1('query layerservice layer.ID ? {%s}' %new_layer)
	
	# redo selection with better fitting...
	try : lx.eval('select.3DElementUnderMouse set')
	except : sys.exit(": --- No selected mesh or active layer under mouse. Aborting. ---")


	lx.eval('workplane.fitSelect')
	
	# remove temp layer
	lx.eval('select.typeFrom item')
	lx.eval('delete')

# if hit :

if not subhack : 
	lx.eval('workplane.fitSelect')
	mouse_pos = lx.eval('query view3dservice mouse.hitPos ?')



# WP adjustments
# if not pre_sel or subhack:	
lx.eval('workplane.edit %s %s %s' %(mouse_pos[0], mouse_pos[1], mouse_pos[2]))	

if offset != 0 :
	lx.eval('workPlane.offset 1 {%s}' %offset)	

if verbose : 
	item_name = lx.eval('query sceneservice mesh.name ? {%s}' %item)
	print "NailGun loaded Item: ", item_name, "(%s)" %(item) 
	if not pre_sel : print "Target mesh position:" , mouse_pos

	
# --------------------------------------------------------------------		
# Instance, Parent and Place
# --------------------------------------------------------------------

# New instance	
lx.eval('select.item {%s}' %item )	
lx.eval('item.duplicate instance:true locator false true')
instance = lx.eval('query sceneservice selection ? meshInst')

# Parent to Loaded source mesh (for easier scene managment)
lx.eval('item.parent {%s} {%s} 0 inPlace:1' % (instance, item))

# Place using WP pos/rot
lx.eval('select.center {%s}' %instance)
lx.eval('center.matchWorkplanePos')
lx.eval('center.matchWorkplaneRot')
lx.eval('workPlane.reset')
lx.eval('select.typeFrom item')

if verbose : print "Instance: ", instance

#eof