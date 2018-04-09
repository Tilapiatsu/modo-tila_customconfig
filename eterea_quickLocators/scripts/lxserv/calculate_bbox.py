#!/usr/bin/env python

# ----------------------------------------------------------------------------------------------------------------
# NAME: calculate_bbox.py
# VERS: 1.0
# DATE: November 7, 2014
#
# MADE: James O'Hare aka Farfarer - Shared here: http://community.foundry.com/discuss/topic/93824
#
# USES: If you save this as a .py file in your lxserv directory, you can query it to get the bbox of selection
#       for the primary layer.
#       The BBOX is returned as a 6 length tuple with the max x/y/z then min x/y/z;
#       bbox = (+X, +Y, +Z, -X, -Y, -Z)
# ---------------------------------------------------------------------------------------------------------------


import lx
import lxifc
import lxu.command
import lxu.select

import traceback

minFloat = float('-inf')
maxFloat = float('inf')

class BBOXVerts(lxifc.Visitor):
    def __init__(self, point):
        self.point = point
        # BBOX = Max X Y Z, Min X Y Z
        self.points = []

    def get_points(self):
        return set (self.points)

    def vis_Evaluate(self):
        self.points.append (self.point.Pos ())

class BBOXEdges(lxifc.Visitor):
    def __init__(self, edge, point):
        self.edge = edge
        self.point = point
        # BBOX = Max X Y Z, Min X Y Z
        self.points = []

    def get_points(self):
        return set (self.points)

    def vis_Evaluate(self):
        try:
            p1, p2 = self.edge.Endpoints ()

            self.point.Select (p1)
            self.points.append (self.point.Pos ())

            self.point.Select (p2)
            self.points.append (self.point.Pos ())
        except:
            lx.out(traceback.format_exc())

class BBOXPolys(lxifc.Visitor):
    def __init__(self, polygon, point):
        self.polygon = polygon
        self.point = point
        self.points = []

    def get_points(self):
        return set (self.points)

    def vis_Evaluate(self):
        numPoints = self.polygon.VertexCount ()
        for pp in xrange(numPoints):
            self.point.Select (self.polygon.VertexByIndex(pp))
            self.points.append (self.point.Pos ())


class GetBBOX_Cmd(lxu.command.BasicCommand):
    def __init__(self):
        lxu.command.BasicCommand.__init__ (self)

        self.dyna_Add ('bbox', lx.symbol.sTYPE_FLOAT)
        self.basic_SetFlags (0, lx.symbol.fCMDARG_OPTIONAL | lx.symbol.fCMDARG_QUERY)

        self.dyna_Add ('space', lx.symbol.sTYPE_STRING)
        self.basic_SetFlags (1, lx.symbol.fCMDARG_OPTIONAL)

    def cmd_Query(self,index,vaQuery):
        va = lx.object.ValueArray()
        va.set(vaQuery)

        if index == 0:
            space = 'local'
            if self.dyna_IsSet (1):
                if self.dyna_String(1) == 'world':
                    space = 'world'

            bbox = self.getBBOX (space)
            for b in bbox:
                va.AddFloat (b)
        return lx.result.OK

    def cmd_Interact(self):
        # Stop modo complaining.
        pass

    def cmd_UserName(self):
        return 'BBox of Selection'

    def cmd_Desc(self):
        return 'Gives bounding box for selection.'

    def cmd_Tooltip(self):
        return 'Gives bounding box for selection.'

    def basic_ButtonName(self):
        return 'BBox of Selection'

    def cmd_Flags(self):
        return lx.symbol.fCMD_UI

    def basic_Enable(self, msg):
        return True


    def basic_Execute(self, msg, flags):
        space = 'local'
        if self.dyna_IsSet (1):
            if self.dyna_String(1) == 'world':
                space = 'world'
        print (self.getBBOX(space))

    def getBBOX (self, space):

        # Default to return until we get good values.
        bbox = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

        # Only deal with visible and unlocked verts.
        mesh_svc = lx.service.Mesh ()
        mode = mesh_svc.ModeCompose ('select', 'hide lock')
        mode_selected_unhideunlock = mesh_svc.ModeCompose ('select', 'hide lock')

        # Grab the primary layer.
        layer_svc = lx.service.Layer ()
        layer_scan = lx.object.LayerScan (layer_svc.ScanAllocate (lx.symbol.f_LAYERSCAN_PRIMARY | lx.symbol.f_LAYERSCAN_MARKALL))
        if not layer_scan.test ():
            return bbox

        # Early out if there are no active layers.
        layer_count = layer_scan.Count ()
        if layer_count == 0:
            return bbox

        # Get selection type.
        selType = lx.eval1('query layerservice selmode ?')

        # Grab the mesh.
        mesh = lx.object.Mesh (layer_scan.MeshBase (0))
        if not mesh.test ():
            return bbox

        # Early out if there are no points in the active layer.
        point_count = mesh.PointCount ()
        if point_count == 0:
            return bbox

        # Grab accessors.
        point = lx.object.Point (mesh.PointAccessor ())
        edge = lx.object.Edge (mesh.EdgeAccessor ())
        polygon = lx.object.Polygon (mesh.PolygonAccessor ())
        if not point.test () or not edge.test () or not polygon.test ():
            return bbox

        # Find the BBOX of selected verts.
        if selType == 'vertex':
            visitor = BBOXVerts (point)
            point.Enumerate (mode, visitor, 0)

        # Find the BBOX of selected edges.
        elif selType == 'edge':
            visitor = BBOXEdges (edge, point)
            edge.Enumerate (mode, visitor, 0)

        # Find the BBOX of selected polygons.
        elif selType == 'polygon':
            visitor = BBOXPolys (polygon, point)
            polygon.Enumerate (mode, visitor, 0)

        else:
            return

        # Make bbox.
        bbox = [minFloat, minFloat, minFloat, maxFloat, maxFloat, maxFloat]
        if space == 'world':
            item = lx.object.Item (layer_scan.MeshItem (0))
            lx.out('%s' % item.UniqueName ())
            current_scene = item.Context ()
            sel_svc = lx.service.Selection()
            chan_read = lx.object.ChannelRead (current_scene.Channels (None, sel_svc.GetTime()))
            matrix = lx.object.Matrix (chan_read.ValueObj (item, item.ChannelLookup (lx.symbol.sICHAN_XFRMCORE_WORLDMATRIX)))

            for pointPos in visitor.points:
                worldPos = matrix.MultiplyVector (pointPos)

                bbox[0] = max (bbox[0], worldPos[0])
                bbox[1] = max (bbox[1], worldPos[1])
                bbox[2] = max (bbox[2], worldPos[2])
                bbox[3] = min (bbox[3], worldPos[0])
                bbox[4] = min (bbox[4], worldPos[1])
                bbox[5] = min (bbox[5], worldPos[2])
        else:
            for pointPos in visitor.points:
                bbox[0] = max (bbox[0], pointPos[0])
                bbox[1] = max (bbox[1], pointPos[1])
                bbox[2] = max (bbox[2], pointPos[2])
                bbox[3] = min (bbox[3], pointPos[0])
                bbox[4] = min (bbox[4], pointPos[1])
                bbox[5] = min (bbox[5], pointPos[2])

        layer_scan.Apply()

        return bbox

lx.bless(GetBBOX_Cmd, 'ffr.getBBOX')