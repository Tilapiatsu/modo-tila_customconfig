#python
#-------------------------------------------------------------------------------
# Name:pp_scale_freeze
# Version: 1.0
# Purpose: This script is designed to scale all items by a user defined value
# freeze the items and save as an LWO.
#
# Author:      William Vaughan, pushingpoints.com
#
#
# Created:     01/22/2014
# Copyright:   (c) William Vaughan 2014
#-------------------------------------------------------------------------------

#Create a user values.  
lx.eval("user.defNew scale float momentary")

#Set the label name for the popup we're going to call
lx.eval('user.def scale dialogname "Scale Factor"')

#Set the user names for the values that the users will see
lx.eval("user.def scale username {Scale Factor}")

#The '?' before the user.value call means we are calling a popup to have the user 
#set the value
try:
	lx.eval("?user.value scale")
	userResponse = lx.eval("dialog.result ?")
	
except:
	userResponse = lx.eval("dialog.result ?")
	lx.out("Thank you for pressing %s." % userResponse)
	sys.exit()
	
#Now that the user set the values, we can just query it
user_input = lx.eval("user.value scale ?")
lx.out('scale', user_input)

#Select all items in the scene
lx.eval('select.type item') 
lx.eval('select.all')

#switch to poly component mode
lx.eval('select.type polygon')

#Scale by the user defined value
lx.eval('tool.set TransformScale on')
lx.eval('tool.attr xfrm.transform SX %f' %user_input)
lx.eval('tool.attr xfrm.transform SY %f'%user_input)
lx.eval('tool.attr xfrm.transform SZ %f'%user_input)
lx.eval('tool.doApply')
lx.eval('tool.set TransformScale off')

#freeze geo
lx.eval('!poly.freeze false false 2 true true true')

lx.eval('tool.set actr.origin off') 


#Save Dialog commands
lx.eval('dialog.setup fileSave')
lx.eval('dialog.title {Save LWO}')
lx.eval('dialog.fileTypeCustom format:[$NLWO2] username:[LightWave Object] loadPattern:[] saveExtension:[lwo]')
try:
    lx.eval('dialog.open')
    filename = lx.eval1('dialog.result ?')
    lx.eval('!!scene.saveAs {%s} $NLWO2 false' % filename) # The !! is to suppress the data loss warning dialog, remove it if you want that to show.
except:
    pass

lx.out('File: %s' % filename)
