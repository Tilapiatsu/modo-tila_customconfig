#python

#This Script Create a weight map based on the length of a curve

import lx, lxu.select, lxu.object

#Get selected Mesh Item
meshItem = lxu.select.ItemSelection().current()[0]

#Get the current scene and create a channel read object
scene = meshItem.Context()
chanRead = scene.Channels(None, 0)

#Lookup the 'crvGroup' channel of the mesh item, create a value object from it
crvChan = meshItem.ChannelLookup('crvGroup')
crvValObj = chanRead.ValueObj(meshItem, crvChan)

#Create a Value Reference object out of the Value object from our curve
valRef = lxu.object.ValueReference(crvValObj)

#Generate an unknown object using the Value Reference
vrObj = valRef.GetObject()

#Cast the unknown object as a curve group (since we know that's what it actually is)
curveGroup = lxu.object.CurveGroup(vrObj)

#Get the first curve of the mesh from the curve group object
for c in xrange(curveGroup.Count()):
	curve = curveGroup.ByIndex(c)

	#print the curve's Length() to the event log
	lx.out(curve.Length())