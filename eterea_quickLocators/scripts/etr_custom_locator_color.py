#python

# ----------------------------------------------------------------------------------------------------------------
# NAME: etr_custom_locator_color.py
# VERS: 2.1
# DATE: November 26, 2017
#
# MADE: Cristobal Vila, etereaestudios.com
#
# USES: To apply fill or wire color to selected Locators in 3D Viewport and/or Item List, depending on args
# ---------------------------------------------------------------------------------------------------------------


# Storing arguments
locatorcolor = lx.args()[0]	# This is the exact name for color (using same than color tags in Item List)
mode1 = lx.args()[1]		# Can be 'fill_default', 'fill_dark', 'fill_light', 'fill_custom' or 'wire'
mode2 = lx.args()[2]		# Can be '?' (pass) or 'ilist' (for 'itemlist')

lx.out('Mode2:', mode2)

# Define a dictionary with color assignements using same names as color tags in Item List
# NOTE: these colors are defined using the inner 'RGB Linear (HDR)' values (not the raw visible 'RGB')
# Update these values in case that Modo modify or updates these tags in the future
colors_dict = {
	'red':			'{0.90 0.38 0.31}',
	'magenta':		'{0.77 0.46 0.64}',
	'pink':			'{0.80 0.58 0.58}',
	'brown':		'{0.66 0.50 0.29}',
	'orange':		'{0.93 0.70 0.31}',
	'yellow':		'{0.88 0.82 0.35}',
	'green':		'{0.38 0.72 0.38}',
	'lightgreen':	'{0.65 0.86 0.65}',
	'cyan':			'{0.40 0.80 0.74}',
	'blue':			'{0.42 0.68 0.82}',
	'lightblue':	'{0.62 0.78 0.88}',
	'ultramarine':	'{0.35 0.52 0.90}',
	'purple':		'{0.62 0.52 0.82}',
	'lightpurple':	'{0.82 0.74 0.93}',
	'darkgrey':		'{0.52 0.52 0.52}',
	'grey':			'{0.72 0.72 0.72}',
	'white':		'{0.93 0.93 0.93}',
}


# Assign Draw Options
# Pass this step in case the locator has Draw Options already assigned
# Necessary to avoid an script error
try:
   lx.eval('!!item.draw add locator')
except:
   pass

# Enable draw options (just in case it could be disabled)    
lx.eval('item.channel locator$enable true')


# For LOCATOR FILL color
if 'fill' in mode1:
	# Make solid (just in case it would be only wired)    
	# Silently pass this step in case the locator has no Shape Options assigned
	# Necessary to avoid an script error
	try:
		lx.eval('!!item.channel locator$isSolid true')
	except:
		pass

	if mode1 == 'fill_default':
		lx.eval('item.channel locator$fillOptions default')

	elif mode1 == 'fill_dark':
		lx.eval('item.channel locator$fillOptions bgminus')

	elif mode1 == 'fill_light':
		lx.eval('item.channel locator$fillOptions bgplus')

	else:
		# Assign our custom color
		lx.eval('item.channel locator$fillOptions user')
		lx.eval('item.channel locator$fillColor %s' % colors_dict[locatorcolor])


# For LOCATOR WIRE color
elif mode1 == 'wire_default':
	lx.eval('item.channel locator$wireOptions default')

elif mode1 == 'wire_dark':
	lx.eval('item.channel locator$wireOptions bgminus')

elif mode1 == 'wire_light':
	lx.eval('item.channel locator$wireOptions bgplus')

elif mode1 == 'wire_custom':
	# Assign our custom color
	lx.eval('item.channel locator$wireOptions user')
	lx.eval('item.channel locator$wireColor %s' % colors_dict[locatorcolor])


# For LOCATOR ITEM LIST color
if mode2 == 'ilist':
	lx.out('he pasado por aqui')
	# Assign our custom Item List color
	lx.eval('item.editorColor %s' % locatorcolor)
