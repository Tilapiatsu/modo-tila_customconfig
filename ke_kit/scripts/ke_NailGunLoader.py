#python#

# NailGun Loader 0.1 - Kjell Emanuelsson 2017
# Sets item for NailGun to use - pick item and run loader - then use nailgun
# Note: for Loader 1.0: assignable slots and presets, (kitloading?) in pop up form, with icons etc. ETA: Between 6 months & never

verbose = False

# Loader - Assign item to instance

item = lx.eval('query sceneservice selection ? mesh')

if not item :
	item = lx.eval('query sceneservice selection ? meshInst ')

if item :
	
	item_name = lx.eval('query sceneservice mesh.name ? {%s}' %item)	

	lx.eval('user.value ke_nailgun.item {%s}' %item) 
	lx.eval('user.value ke_nailgun.itemName {%s}' %item_name) 

	if verbose : print "Item Loaded for NailGun: ", item_name, "(%s)" %(item) 
	
else : sys.exit(": --- Selection Error: Mesh Item not selected. --- ")	

