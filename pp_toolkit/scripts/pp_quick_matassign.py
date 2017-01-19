#python
#-------------------------------------------------------------------------------
# Name:pp_quick_matassign
# Version: 1.0
# Purpose: This command is designed to assign the selected material to your 
# current poly selection
#
# Author:      William Vaughan, pushingpoints.com
#
# Created:     01/14/2014
# Copyright:   (c) William Vaughan 2014
#-------------------------------------------------------------------------------

#Get the selected Material Mask name
selection = lx.eval1('query sceneservice selection ? mask')
name = lx.eval('query sceneservice mask.name ? %s' % selection)
lx.out(selection)
lx.out(name)

#Remove the extra portion of the name not needed
name = name.replace( " (Material)", "")

#Set the selected material to the selected polys
lx.eval('poly.setMaterial {%s}' % name )
lx.eval('select.drop polygon')