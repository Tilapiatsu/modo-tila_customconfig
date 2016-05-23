#python

# Title: mc_lxMirrorWeights.py
# Author: Matt Cox
# Description: Mirrors weights across weight maps.
# Version: 2.0 (601)

import lx

def errorBox(message):
    # Alert the user that something was incorrect.
    lx.eval('dialog.setup error')
    lx.eval('dialog.title {Error}')
    lx.eval('dialog.msg {%s}' % message)
    lx.eval('dialog.open')
    return

vertexMapsArray = []
weightMapCount = 0

#try:
lxArgs = lx.args()
axis = lxArgs[0].lower()

# Get the active symmetry state
symmetryState = lx.eval('select.symmetryState ? ')

try:
    if axis != "x" and axis != "y" and axis != "z":
        errorBox("Incorrect Arguments")
        sys.exit()
    else:
        # Now we check that two weight maps are selected as well as a selection of vertices.
        vertexMaps = lx.evalN("query layerservice vmaps ? selected")
        
        for vertexMap in vertexMaps:
            vertexMapType = lx.eval("query layerservice vmap.type ? {%s}" % vertexMap)
            if vertexMapType == "weight":
                vertexMapsArray.append(vertexMap)
                weightMapCount = weightMapCount + 1
        
    
        # Get the active layer.
        lx.eval("query layerservice layer.index ? selected")
        vertices = lx.evalN("query layerservice verts ? all")
        totalVertexCount = len(vertices)
        
        # Loop through all the vertices and check if they are selected.
        for vertex in range(totalVertexCount):
            isVertSelected = lx.eval('query layerservice vert.selected ? %s' % vertex)
            if isVertSelected == 1:
                # Turn on symmetry in the correct axis.
                lx.eval('select.symmetryState %s' % axis)
                # Get the id of corresponding symmetrical vertex
                symmetricVert = lx.eval('query layerservice vert.symmetric ? %s' % vertex)
                if symmetricVert != None:
                    # Turn off symmetry
                    lx.eval('select.symmetryState none')
                    # Get the weight value for both weight maps.
                    if weightMapCount == 2:
                        weightMapNameOne = lx.eval("query layerservice vmap.name ? {%s}" % vertexMapsArray[0])
                        weightValueOne = lx.eval("query layerservice vert.vmapValue ? {%s}" % vertex)
                        weightMapNameTwo = lx.eval("query layerservice vmap.name ? {%s}" % vertexMapsArray[1])
                        weightValueTwo = lx.eval("query layerservice vert.vmapValue ? {%s}" % vertex)
                        # Apply it to the symmetrical vertex for the other weight map.
                        lx.eval('vertMap.setVertex {%s} weight 0 %s %s' %(weightMapNameOne, symmetricVert, weightValueTwo))
                        lx.eval('vertMap.setVertex {%s} weight 0 %s %s' %(weightMapNameTwo, symmetricVert, weightValueOne))
                    elif weightMapCount == 1:
                        weightMapNameOne = lx.eval("query layerservice vmap.name ? {%s}" % vertexMapsArray[0])
                        weightValueOne = lx.eval("query layerservice vert.vmapValue ? {%s}" % vertex)
                        # Apply it to the symmetrical vertex for the other weight map.
                        lx.eval('vertMap.setVertex {%s} weight 0 %s %s' %(weightMapNameOne, symmetricVert, weightValueOne))
                    else:
                        errorBox("Incorrect Weight Map Selection")
                        sys.exit()
        # Return symmetry to its original state.
        lx.eval('select.symmetryState %s' % symmetryState)
except:
    errorBox("Unable to Mirror Weights")
    sys.exit()