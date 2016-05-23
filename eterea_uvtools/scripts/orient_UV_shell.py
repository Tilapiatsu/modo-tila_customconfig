#!/usr/bin/env python

####                                      ####
##   orient_UV_shell.py V1.1       ##
##                                          ##
##   Author: Mario Baldi                    ##
##   website: www.mariobaldi.com            ##
##   email:  info@mariobaldi.com            ##
##                                          ##
####                                      ####
##
##   v1.1 - Added orient feature by selecting pair of vertices
##   v1.0 - Select one edge in the uv view and orient the uv island/shell

import math
from time import clock,time
import lx

def parse_modo_pairs_results(modo_pairs):
    # This function parses modo results which contains pairs of values, in the form of:
    ### '(n1,n2)'  - for single pairs, where n1 and n2 are two int values
    ### ( '(n1,n2)', ... , '(N1,N2)' ) - for multiple pairs, where the container of the string defining pairs is a tuple
    # Great for edges, or uvs
    if modo_pairs==None:
        #lx.out('No edge selected')
        return []
    if type(modo_pairs)==str:
        #lx.out('One edge selected')
        verts = modo_pairs.split('(')[1].split(')')[0].split(',')
        return [[int(verts[0]), int(verts[1])]]
    elif type(modo_pairs)==tuple or type(modo_pairs)==list:
        #lx.out('More than one edge selected')
        pairs = []
        for pair in modo_pairs:
            verts = pair.split('(')[1].split(')')[0].split(',')
            pairs.append([int(verts[0]), int(verts[1])])
        return pairs

def selectedEdges(mode='selected'):
    # This function parses the modo result when wuerying selected vertices,
    # and return a list of pairs of vertices
    # 'mode' if for later expanding functionalities purposes
    if mode=='selected':
        sel_edge = lx.eval('query layerservice edges ? selected')
        # the above query returns string of two vertices if only one edge is selected (to be parsed),
        # or a list of strings, where every string encloses a list with a pair of two vertices (to be parsed).
        
        #lx.out(sel_edge)
        #lx.out(type(sel_edge))

        result = parse_modo_pairs_results(sel_edge)
        return result
            
def selectPolyList (polyList, layerId, mode):
	if mode=='set':
		lx.eval('select.drop polygon')
	for x in polyList:
		lx.eval('select.element %s polygon add %s 0 0' % (layerId,x) )
		

def orient_uv_shell_from_vertex_pair():
    # This is the main functions which rotates the uv_shell
    # It requires a selection of two vertices to work
    sel_uvs = lx.eval('query layerservice uvs ? selected')
    lx.out(sel_uvs)
    lx.out(type(sel_uvs))

    uvs = parse_modo_pairs_results(sel_uvs)
    lx.out(uvs)

    # In modo every UV is actually sconnected from the other,
    # so overlaied uvs (i.e they share the same position) move together while they are actually sconnected.
    # In modo every uv is expressed in the form ('polyID,vertID')
    # I will cycle trough every pair of values, and see where the vertID matches.
    # Usually this is not enough to see if the uvs are overlapping (as I should see if their position matches),
    # but in this case I am using uvs converted from a single edge, so I am sure that the result is taking into account
    # only overlapping uvs.

    uv1 = uvs[0]
    uv2 = None
    current_uv_vert = uvs[0][1]
    pos_start = lx.eval('query layerservice uv.pos ? (%s,%s)' % (uv1[0],uv1[1]) )
    pos_end = None
    #lx.out('uv1: %s' % uv1)
    #lx.out('uv2: %s' % uv2)
    #lx.out('uv1: %s' % uv1)
    #lx.out('current_uv_vert: %s' % current_uv_vert)
    # With this loop I check that, if there are two vertices selected,
    # only the first couple of uvs with different vertex_id wil be taken into account
    # It is important to note that selecting a couple of vertices in the 3d view, doesn't always mean selecting only 2 uvs:
    # basically 2 vertices = 2 or more uvs (if the model have been UVed, but can be even 1 or 0)
    # With this script we are safe enough, as usually we will fire it when we'll select a couple of vertices
    # from the uv view (so 2 vertices = 2+ uvs)
    # IMPORTANT: I need to take into account the existence of discontinuos uvs.
    #            This function can be called only with AT least ONE vert selected, and no more than TWO.
    #            Then I look for uvs that lie in the same position: duplicated uvs (uvs with same vertex ID and uvpos), can
    #            be discarded. If after this filtering there will be only a couple of uvs remaining, even if there is only one
    #            vertex selected in 3Dspace, than that means that the two uvs are discontinuos, and we're now safe to orient the shell(s)

    counter=0
    for uv in uvs:
        #lx.out(uv)
        c_pos = lx.eval('query layerservice uv.pos ? (%s,%s)' % (uv[0],uv[1]))
        #lx.out('c_pos')
        #lx.out(c_pos)
        if c_pos != pos_start:
            uv2 = uvs[counter]
            pos_end = c_pos
            break
        counter += 1
    #lx.out('uv1: %s' % uv1)
    #lx.out('uv2: %s' % uv2)

    if pos_end:
        #pos_start = lx.eval('query layerservice uv.pos ? (%s,%s)' % (uv1[0], uv1[1]) )
        #pos_end = lx.eval('query layerservice uv.pos ? (%s,%s)' % (uv2[0], uv2[1]) )

        lx.out(pos_start)
        lx.out(pos_end)
        
        deltaX = pos_end[0] - pos_start[0]
        deltaY =  pos_end[1] - pos_start[1]
        angleInDegrees = math.atan2(deltaY, deltaX) * 180 / math.pi

        lx.out(angleInDegrees)

        pivotX = (pos_end[0] + pos_start[0]) / 2
        pivotY = (pos_end[1] + pos_start[1]) / 2
        
        lx.eval('select.vertexConnect uv')
        lx.eval('tool.set center.auto on') # I add an 'auto' action center
        lx.eval('tool.attr center.auto cenU %s'  % pivotX)
        lx.eval('tool.attr center.auto cenV %s' % pivotY)
        lx.eval('tool.set xfrm.rotate on')
        lx.eval('tool.setAttr xfrm.rotate angle %s' % (-angleInDegrees)) # I apply the rotation
        lx.eval('tool.apply')
        lx.eval('tool.set xfrm.rotate off')
        lx.eval('select.drop vertex')
    return uv1, uv2


## Get the main layer id
mainScene = lx.eval('query sceneservice scene.name ? current')
mainLayerID = lx.eval('query layerservice layer.index ? main')
lx.out (mainLayerID)

is_vert_sel_type = lx.eval('select.typeFrom typelist:"vertex;polygon;edge;item;ptag" ?')
is_edge_sel_type = lx.eval('select.typeFrom typelist:"edge;vertex;polygon;item" ?')
is_poly_sel_type = lx.eval('select.typeFrom typelist:"polygon;vertex;edge;item" ?')
if is_vert_sel_type:
    lx.out('current_sel_type: vert')
elif is_edge_sel_type:
    lx.out('current_sel_type: edge')
elif is_poly_sel_type:
    lx.out('current_sel_type: poly')    

if is_vert_sel_type:
    # Current selection is set to 'vertex'
    sel_verts = lx.eval('query layerservice verts ? selected') or []
    if type(sel_verts) ==str:
        sel_verts = [sel_verts]
        lx.out('sel_verts: %s' % sel_verts)
    else:
        lx.out('sel_verts: %s' % (', '.join(sel_verts)) )
    if len(sel_verts)==1 or len(sel_verts)==2:
        uv1, uv2 = orient_uv_shell_from_vertex_pair()
        # I found a way to select UVs !!!
        # YAY!
        # Example:
        # select.element 1 disco set 168 192 192  # 168 is the vertex ID, and 192 is the poly id (which must be repeated 2 times)
        lx.out(uv1, uv2)
        lx.eval('select.element %s disco set %s %s %s' % (mainLayerID, uv1[1], uv1[0], uv1[0]) )
        lx.eval('select.element %s disco add %s %s %s' % (mainLayerID, uv2[1], uv2[0], uv2[0]) )
elif is_edge_sel_type:
    # Current selection is set to 'edge'
    sel_edge = lx.eval('query layerservice edges ? selected')
    edges = selectedEdges()
    lx.out(edges)
    if len(edges)==1:
        pass
        #lx.out(sel_edge)
        #edge_verts = lx.eval('query layerservice edge.vertList ? selected')
        lx.eval('select.convert vertex')

        # Call the main orient function
        orient_uv_shell_from_vertex_pair()
        
        #lx.eval('select.edge %s % sel_edge)
        lx.eval('select.edge add bond 0')
        
    else:
        lx.out('Select one edge')
