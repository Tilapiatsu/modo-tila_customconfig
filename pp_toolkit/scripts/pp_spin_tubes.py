#python
#-------------------------------------------------------------------------------
# Name:pp_spin_tubes
# Version: 1.0
# Purpose: This script is designed to allow you to spin tubes/pipes along 
# their length 
#
# Author:      William Vaughan, pushingpoints.com
#
#
# Created:     01/24/2014
# Copyright:   (c) William Vaughan 2014
#-------------------------------------------------------------------------------

lx.eval('select.type polygon') 

#Creates a variable named "layer" that = the current layer
layer = lx.eval('query layerservice layer.index ? main')
polysN = lx.eval('query layerservice poly.N ? selected') #poly count

if polysN <= 0:
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {PP Spin Tubes:}')
	lx.eval('dialog.msg {You must have one end cap polygon selected to run this script.}')
	lx.eval('dialog.open')
	sys.exit()
	
elif polysN > 1:
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {PP Spin Tubes:}')
	lx.eval('dialog.msg {You must have only one end cap polygon selected to run this script.}')
	lx.eval('dialog.open')
	sys.exit()
	
else:
	pass

#Create a user values.  
lx.eval("user.defNew degrees integer momentary")

#Set the label name for the popup we're going to call
lx.eval('user.def degrees dialogname "PP Spin Tubes"')

#Set the user names for the values that the users will see
lx.eval("user.def degrees username {Rotation Amount}")

#The '?' before the user.value call means we are calling a popup to have the user 
#set the value
try:
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {PP Spin Tubes:}')
	lx.eval('dialog.msg {Caution: you can not undo after this operation! }')
	lx.eval('dialog.open')
	lx.eval("?user.value degrees")
	userResponse = lx.eval("dialog.result ?")
	
except:
	userResponse = lx.eval("dialog.result ?")
	lx.out("Thank you for pressing %s." % userResponse)
	sys.exit()
	
#Now that the user set the values, we can just query it
user_input = lx.eval("user.value degrees ?")
lx.out('degrees', user_input)



#regardless of selection type convert it to Edges 
lx.eval('select.convert edge')

#store selected edges 
selected_edges = lx.eval('query layerservice edges ? selected')

lx.eval('select.drop edge')

#select just one edge in the loop

for edge in selected_edges:
	r_indicies = edge[1:-1]
	r_indicies = r_indicies.split(',')
	lx.eval("select.element %s edge add index:%s index2:%s" %(layer, r_indicies[0], r_indicies[1]))
	break
	
lx.eval('select.ring') 

#count selected edges
ring_edgesN = lx.eval('query layerservice edge.N ? selected')
lx.out('ringcount', ring_edgesN)

lx.eval('select.drop edge')

lx.eval('select.type polygon')
lx.eval('select.drop polygon')
lx.eval('select.type edge')

#re-select original edges
for Fedge in selected_edges:
	f_indicies = Fedge[1:-1]
	f_indicies = f_indicies.split(',')
	lx.eval("select.element %s edge add index:%s index2:%s" %(layer, f_indicies[0], f_indicies[1]))

steps = (ring_edgesN / 2)
lx.out('steps', steps)	
current_ring = 1
  
rot_amount = (user_input / steps)
newrot_amount = rot_amount

while current_ring != steps:
	lx.eval('select.loop next')
	lx.eval('poly.make auto')
	lx.eval('select.type polygon')
	
	poly = lx.eval('query layerservice polys ? selected')
	
	#Get position of selected poly
	posW = lx.eval("query layerservice poly.wpos ? %s" %poly) 
	posX = posW[0]
	posY = posW[1]
	posZ = posW[2]
	
	
	lx.eval('tool.set center.auto on')
	lx.eval('tool.set axis.local on')

	#rotate selection using Axis Rotate
	lx.eval('tool.set xfrm.rotate on')
	lx.eval('tool.reset xfrm.rotate')

	#adjust action center
	lx.eval ("tool.attr center.auto cenX %s" %posX) 
	lx.eval ("tool.attr center.auto cenY %s" %posY)
	lx.eval ("tool.attr center.auto cenZ %s" %posZ)
	
	#this line causes error if users undo
	#this is what makes script work tho
	lx.eval('!tool.activate xfrm.rotate')

	#rotate selection
	lx.eval('tool.setAttr xfrm.rotate angle %d' % newrot_amount)
	lx.eval('tool.doApply')
	
	lx.eval('tool.deactivate xfrm.rotate')
	lx.eval('tool.set xfrm.rotate off')
	lx.eval('tool.set center.auto off')
	lx.eval('tool.set axis.local off')

	lx.eval('select.delete')
	lx.eval('select.type edge')	
	newrot_amount += rot_amount
	#lx.out('newrot_amount', newrot_amount)
	current_ring += 1


lx.eval('select.drop edge')
lx.eval('app.clearUndos')