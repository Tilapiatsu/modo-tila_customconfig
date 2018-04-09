#python

# ----------------------------------------------------------------------------------------------------------------
# NAME: etr_loadCheckgrid.py
# VERS: 2.0
# DATE: September 10, 2017
#
# MADE: Cristobal Vila, etereaestudios.com (with some snippets by Mark Rossi)
#
# USES: To load custom checkgrids from the 'eterea_uvtools' kit
#		This new script completely replaces a previous one, called 'loadImageMap.py' created by Mark Rossi
# ----------------------------------------------------------------------------------------------------------------


from os.path import normpath, exists

# Argument (should match our image map names, exactly)
myarg = lx.arg()


#----------------------------------------------------------------------------------------------------------------
# Main functions
#----------------------------------------------------------------------------------------------------------------

# Query actual selection mode
def fn_selmode(*types):
	if not types:
		types = ('vertex', 'edge', 'polygon', 'item', 'pivot', 'center', 'ptag')
	for t in types:
		if lx.eval('select.typeFrom %s;vertex;edge;polygon;item;pivot;center;ptag ?' %t):
			return t
mySelMode = fn_selmode()


# Dialog for when there is not a default 'Base Shader' or it's not a direct child of Render Item
def fn_dialogAdvice():
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {Eterea UV Checkgrids}')
	lx.eval('dialog.msg {Be sure to have an overall shader called exactly "Base Shader".\n\
			And it should be a direct child of your Render Item.}')
	lx.eval('dialog.open')
	sys.exit()


# Function to get the clip to be used as image map
def getClip():
	match = path.lower()
	for c in xrange(lx.eval('query layerservice clip.N ? all')):
		if lx.eval('query layerservice clip.file ? %s' %c).lower() == match:
			return lx.eval('query layerservice clip.name ? %s' %c)


# Typical checks
layer = lx.eval('query layerservice layer.index ? main')
scene = lx.eval('query sceneservice scene.index ? main')


#----------------------------------------------------------------------------------------------------------------
# This script will create a bunch of checkgrids, storing them inside a GroupMask located just below the Base Shader.
# The first thing we need is to know the position of an item named 'Base Shader' in our shader tree
# And be sure also that this item is a direct child of Render Item (not masked)
#----------------------------------------------------------------------------------------------------------------

# Attempts to get the ID of a defaultShader named 'Base Shader'. If it doesn't exist, a silent error will occurs:
try:
	baseShad = lx.eval('query sceneservice defaultShader.id ? {Base Shader}')

# If the silent error occurs, our 'Base Shader' doesn't exist. Give advice and abort script:
except:
	fn_dialogAdvice()

# Query a list with all children of Render Item to check if our Base Shader is really there
# (to avoid cases where the user could place the BS inside a Mask Group)
rendChild = lx.evalN('query sceneservice polyRender.children ? 0')

# If our Base Shader is NOT in that 'direct children' list, then it's masked. Show message and exit:
if baseShad not in rendChild:
	fn_dialogAdvice()

# If we arrived here, we have a proper Base Shader that is a direct child of Render Item
# Lets query the exact position in Shader Tree
BSpos = rendChild.index(baseShad)


#----------------------------------------------------------------------------------------------------------------
# Determine the correct full path for out stored checkgrid image map (thanks to Mark Rossi for this snippet)
#----------------------------------------------------------------------------------------------------------------

# The short path referred to Kit directory
path = normpath('kit_eterea_uvtools:/scripts/checkgrids/%s.png' % myarg)

# Calculate the full path referred to the user directory
root, path = path.split(':')
path = ''.join((lx.eval('query platformservice path.path ? %s' %root), path)) if root in lx.evalN('query platformservice paths ?') else \
	   ''.join((lx.eval('query platformservice alias ? {%s:}' %root), path)) if root[:4] == 'kit_' else \
	   ':'.join((root, path))


#----------------------------------------------------------------------------------------------------------------
# Check if a global container GroupMask named 'ETEREA_UV_CHECKGRIDS' exists (to create, if not)
#----------------------------------------------------------------------------------------------------------------

# Attempts to get the ID of a GroupMask named 'ETEREA_UV_CHECKGRIDS'. If it doesn't exist, a silent error will occurs:
try:
	lx.eval('query sceneservice mask.ID ? {ETEREA_UV_CHECKGRIDS}') # Exists. No need to create it again ;-)

# If the silent error occurs, the GroupMask 'ETEREA_UV_CHECKGRIDS' doesn't exist. Create it just below our Base Shader:
except:
	renderitem = lx.eval('query sceneservice render.id ? 0')
	lx.eval('shader.create mask')
	lx.eval('item.name "ETEREA_UV_CHECKGRIDS" mask')
	lx.eval('texture.parent %s %s' % (renderitem, BSpos))

# Store the ID for our global container for further use
globalMaskID = lx.eval('query sceneservice mask.ID ? {ETEREA_UV_CHECKGRIDS}')


#----------------------------------------------------------------------------------------------------------------
# Check if an ImageMap named as our argument exists (to create, if not)
#----------------------------------------------------------------------------------------------------------------

# Attempts to get the ID of a ImageMap named as our argument. If it doesn't exist, a silent error will occurs:
try:
	ID = lx.eval('query sceneservice textureLayer.ID ? {%s (Image)}' % myarg) #Exists, then overpass the exception

# If the silent error occurs, the ImageMap named as our argument doesn't exist. Lets create it
except:
	# First we create a 'constant', convert to ImageMap and make first child of global container
	lx.eval('select.item Render set')
	lx.eval('shader.create constant')
	lx.eval('item.setType imageMap textureLayer')
	lx.eval('texture.parent %s -1' % globalMaskID)

	# Load our file as clip and apply as image map
	lx.eval('clip.addStill {%s}' %path)
	clip = getClip()
	lx.eval('texture.setImap {%s}' %clip)

	# Define a UV projection named 'Texture'
	lx.eval('texture.setProj uv')
	lx.eval('texture.setUV {Texture}')

	# Stores the ID for this image map
	ID = lx.eval('query sceneservice textureLayer.ID ? {%s (Image)}' % myarg)


# Force our already existing image map to be a first child of our global container
lx.eval('select.subItem %s set textureLayer' % ID)
lx.eval('texture.parent %s -1' % globalMaskID)


#----------------------------------------------------------------------------------------------------------------
# Finish with proper shading and selection mode
#----------------------------------------------------------------------------------------------------------------

# Apply the Default shading (advgl) in all 3D viewports
for w in xrange(lx.eval('query view3dservice view.N ?')):
	if lx.eval('query view3dservice view.type ? %s' %w) == 'MO3D':
		lx.eval('select.viewport set frame:%s viewport:%s' % lx.evalN('query view3dservice view.frame ? %s' %w))
		lx.eval('view3d.shadingStyle advgl')


# Return to original Selection Mode
lx.eval('select.typeFrom %s' % mySelMode)
