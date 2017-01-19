#python
#-------------------------------------------------------------------------------
# Name:pp_locsctor_drop
# Version: 1.1
# Purpose: This script is designed to create new locators with custom settings 
# at the location of selected verts by using the custom command: pp_locdrop_cmd.py
#
# Author:      William Vaughan, pushingpoints.com
#
# Created:     01/12/2014
# Copyright:   (c) William Vaughan 2013
#-------------------------------------------------------------------------------

####NOTE: pp_locdrop_cmd.py MUST BE PLACED IN THE lxserv FOLDER FOR THIS SCRIPT TO WORK###


#The command will be enabled if at least 1 vert is selected.
vertcount = lx.eval('select.count vertex ?')
lx.out('vertcount', vertcount)
		
#If no verts are selected display this dialog and exit command
if vertcount <= 0:
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {PP Locator Drop:}')
	lx.eval('dialog.msg {You must have at least one vertex selected to run this script.}')
	lx.eval('+dialog.open')
	sys.exit()
	
else:
	lx.eval('pp.LocatorDrop')