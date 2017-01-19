#python
#-------------------------------------------------------------------------------
# Name:pp_poly_collapse
# Version: 1.0
# Purpose: This script is designed to collapse the selected polys without affecting
#the surrounding geometry. 
#
# Author:      William Vaughan, pushingpoints.com
#
# Created:     01/21/2014
# Copyright:   (c) William Vaughan 2014
#-------------------------------------------------------------------------------

#Creates a new edge loop to protect the surrounding geo
lx.eval('tool.set poly.bevel on')
lx.eval('tool.reset poly.bevel')
lx.eval('tool.doApply')
lx.eval('tool.set poly.bevel off')

#Collapses the original poly selection
lx.eval('poly.collapse')








