#python
#-------------------------------------------------------------------------------
# Name:pp_fixsymm_oo
# Version: 1.0
# Purpose: This script is designed to restore symmetry on a mesh. Simply select 
# half of your mesh and run the script. Works even when your mesh is not at 
# the origin
#
# Author:      William Vaughan, pushingpoints.com
#
# Created:     26/12/2013
# Copyright:   (c) William Vaughan 2013
#-------------------------------------------------------------------------------

#Makes sure all selected geo is dropped
lx.eval('select.drop vertex')
lx.eval('select.drop edge')

# Switches to polygon component mode
lx.eval('select.typeFrom polygon')
lx.eval('select.editSet half_temp add')
lx.eval('select.all')
lx.eval('copy')

#Solves for open edges
lx.eval('tool.set poly.bevel on')
lx.eval('tool.attr poly.bevel group true')
lx.eval('tool.setAttr poly.bevel inset 0.0')
lx.eval('tool.setAttr poly.bevel shift 0.05')
lx.eval('tool.doApply')

#Creates a new temp selection set
lx.eval('select.all')
lx.eval('select.editSet keep_temp add')
lx.eval('select.paste')
lx.eval('select.drop polygon')

#lx.eval('!vert.merge auto false 0.001 false true')
lx.eval('tool.set vert.merge on')
lx.eval('tool.attr vert.merge dist 0.0005')
lx.eval('tool.apply')

#lx.eval('select.polygon add material face temp')
lx.eval('select.useSet half_temp select')

#Selects polygon selection Boundary
lx.eval('select.boundary')

#Aligns workplane to the selected edges
lx.eval('select.drop polygon')
lx.eval('select.type edge')
lx.eval('poly.make auto')
lx.eval('select.type polygon')
lx.eval('workPlane.fitSelect')
lx.eval('delete')

#Activates Scale tool and sets parameters, flattens geo and deletes it
lx.eval('select.useSet half_temp select')
lx.eval('tool.set TransformScale on')
lx.eval('tool.setAttr xfrm.transform SY 0')

# Make sure centerline is at zero
lx.eval('vert.set y 0.0 true false')

# Switches to polygon component mode
lx.eval('select.typeFrom polygon')
lx.eval('select.drop polygon')

#lx.eval('select.polygon add material face temp')
lx.eval('select.useSet half_temp select')

# Changes action center to origin
lx.eval('tool.set actr.origin on')

#Activates Scale tool and sets parameters, flattens geo and deletes it
lx.eval('tool.set TransformScale on')
lx.eval('tool.attr xfrm.transform negScale true')
lx.eval('tool.setAttr xfrm.transform SY 0')
lx.eval('select.delete')

#Selects the good and makes a copy of it
lx.eval('select.all')
lx.eval('select.copy')
lx.eval('select.paste')

# Mirrors good geo
lx.eval('tool.set TransformScale on')
lx.eval('tool.attr xfrm.transform negScale true')
lx.eval('tool.setAttr xfrm.transform SY -1.0')
lx.eval('tool.doApply')
lx.eval('tool.set TransformScale flush 0')
lx.eval('poly.flip')

#Merges the verts on the center line
lx.eval('select.type vertex')
lx.eval('select.drop vertex')
#lx.eval('!vert.merge auto false 0.001 false true')
lx.eval('tool.set vert.merge on')
lx.eval('tool.attr vert.merge dist 0.0005')
lx.eval('tool.apply')

# Changes action center default and resets Workplane
lx.eval('tool.set actr.origin off')
lx.eval('workPlane.reset')
lx.eval('workPlane.reset')

# Switches to polygon component mode
lx.eval('select.typeFrom polygon')
lx.eval('select.drop polygon')
lx.eval('select.useSet keep_temp select')
lx.eval('delete')

#Makes sure all selected geo is dropped
lx.eval('select.drop vertex')
lx.eval('select.drop edge')
lx.eval('select.drop polygon')







