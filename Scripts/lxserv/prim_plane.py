#!python
 
'''
 
    A simple tool plugin to demonstrate geometry creation. A plane is
    created on the active mesh layer, with the size controlled by hauling
    in the viewport.
 
    Tools are rather advanced and there is a lot of potential for taking
    this example further. For example, drawing tool handles, defining the
    origin of the geometry creation, support for falloffs, generating UVs...etc.
 
    Author: Matt Cox
 
'''
 
import lx
import lxifc
import lxu.attributes
 
class Plane_Tool(lxifc.Tool, lxifc.ToolModel, lxu.attributes.DynamicAttributes):
 
    def __init__(self):
        lxu.attributes.DynamicAttributes.__init__(self)
 
        '''
            Our tool is going to have a single value that controls how it
            operates. This value will control the size of the plane geometry
            that we create. So we create a new Dynamic Attribute, who's type
            is float and it's initial value is 1.0.
        '''        
        self.dyna_Add('size', lx.symbol.sTYPE_FLOAT)
        self.attr_SetFlt(0,1.0)
 
        '''
            Allocate a vector type. We're setting the mimimum required here,
            but we could add some packets to the vector stack, that would
            allow us to do things like work with symmetry or falloffs.
        '''
        pkt_svc = lx.service.Packet()
        self.vec_type = pkt_svc.CreateVectorType(lx.symbol.sCATEGORY_TOOL)
 
    def tool_Reset(self):
        '''
            This function is called to reset the tool back to it's default.
            In our case, we are simply setting the plane size attribute
            back to the default of 1m.
        '''
        self.attr_SetFlt(0,1.0)
 
    def tool_Evaluate(self,vts):
        '''
            This is where our tool is actually evaluated. We're going to get
            the current layers and loop through them, generating new vertices
            and polygons, defined by the size attribute.
        '''
 
        '''
            We'll be using the LayerService to interact with meshes in the
            scene. We also want to localize a LayerScan object using the
            ScanAllocate method. The symbol "f_LAYERSCAN_EDIT", tells modo
            that we want to scan active layers and edit the mesh. See the SDK
            wiki for the declaration of this symbol.
        '''
        layer_svc = lx.service.Layer()
        layer_scan = lx.object.LayerScan(layer_svc.ScanAllocate(lx.symbol.f_LAYERSCAN_EDIT))
 
        if layer_scan.test() == False:
            return
 
        '''
            We have a single attribute that defines the size of the plane. We
            read it's value using the index or the order the attributes were
            added in the constructor. As we only have a single attribute on
            this tool, it's clearly going to be 0.
        '''
        size_attr = self.attr_GetFlt(0)
 
        '''
            We're going to operate on all active layers, so we simply want
            to loop through the active layers and perform some operation.
        '''        
        for n in range(0,layer_scan.Count()):
            '''
                We want to grab the Edit Mesh on the current layer and
                localize it into a Mesh object, so that we can edit it.
            '''
            mesh_loc = lx.object.Mesh(layer_scan.MeshEdit(n))
 
            if mesh_loc.test() == False:
                continue
 
            '''
                As we are editing both Points and Polygons, we need to get
                some Point and Polygon interfaces from the mesh.
            '''
            point_loc = lx.object.Point(mesh_loc.PointAccessor())
            poly_loc = lx.object.Polygon(mesh_loc.PolygonAccessor())
 
            if poly_loc.test() == False or point_loc.test() == False:
                continue
 
            '''
                Now we are going to construct the plane geometry. To keep things
                simple, we're going to loop through a statement that creates 4
                new points. For each of the points, we'll store their ID in a
                list. Finally, we'll iterrate over the list and create the
                new polygon from the four points.
            '''
            points = ()            
            for point in range(0,4):
                '''
                    First we want to calculate a position for the new point.
                '''
                point_pos = list()
                if point == 0:
                    point_pos = ((-size_attr)/2,0.0,(-size_attr)/2)
                elif point == 1:
                    point_pos = ((-size_attr)/2,0.0,(size_attr)/2)
                elif point == 2:
                    point_pos = ((size_attr)/2,0.0,(size_attr)/2)
                elif point == 3:
                    point_pos = ((size_attr)/2,0.0,(-size_attr)/2)
 
                '''
                    Create a new point. This method takes a position and
                    return a PointID, so we pass it the position vector we
                    created.
                '''
                current_point = point_loc.New(point_pos)
 
                '''
                    We have to pass a list of points to the Polygon New()
                    method. So we add the current PointID to the Points tuple.
                '''
                points = points + (current_point,)
 
            '''
                The Polygon New() method requires the list of points to be
                passed as a Storage Buffer. So we create a storage buffer, set
                it's type to store pointers, set the size to be number of points
                we intend to store in it and then finally, write out Points
                tuple to it.
            '''
            points_storage = lx.object.storage()
            points_storage.setType('p')
            points_storage.setSize(4)
            points_storage.set(points)
 
            '''
                Now we have our point positions, we create a new polygon.
            '''
            poly_loc.New(lx.symbol.iPTYP_FACE,points_storage,4,0)
 
            '''
                Before we move on to the next layer, we tell modo that have
                edited this mesh layer.
            '''
            layer_scan.SetMeshChange(n, lx.symbol.f_MESHEDIT_GEOMETRY)
 
        '''
            Finally, we call the Apply function, which closes our LayerScan
            interface and applies all our changes to the mesh.
        '''
        layer_scan.Apply()
 
    def tool_VectorType(self):
        '''
            This function simply returns the tool VectorType that we created
            in the constructor.
        '''
        return self.vec_type
 
    def tool_Order(self):
        '''
            This sets the position of the tool in the toolpipe.
        '''
        return lx.symbol.s_ORD_ACTR
 
    def tool_Task(self):
        '''
            Simply defines the type of task performed by this tool. We set
            this to an Action tool, which basically means it will alter the
            state of modo.
        '''
        return lx.symbol.i_TASK_ACTR
 
    def tmod_Flags(self):
        '''
            This sets how we intend to interact with the tool. The symbol
            "fTMOD_I0_ATTRHAUL" basically says that we expect to haul an
            attribute when clicking and dragging with the left mouse button.
        '''
        return lx.symbol.fTMOD_I0_ATTRHAUL
 
    def tmod_Initialize(self,vts,adjust,flags):
        '''
            This is called when the tool is activated. We use it to simply
            set the attribute that we hauling back to the default.
        '''
        adj_tool = lx.object.AdjustTool(adjust)
        adj_tool.SetFlt(0, 1.0)
 
    def tmod_Haul(self,index):
        '''
            Hauling is dependent on the direction of the haul. So a vertical
            haul can drive a different parameter to a horizontal haul. The
            direction of the haul is represented by an index, with 0
            representing horizontal and 1 representing vertical. The function
            simply returns the name of the attribute to drive, given it's index.
            As we only have one attribute, we'll set horizontal hauling to
            control it and vertical hauling to do nothing.
        '''
        if index == 0:
            return "size"
        else:
            return 0
 
'''
    "Blessing" the class promotes it to a fist class server. This basically
    means that modo will now recognize this plugin script as a tool plugin.
'''
lx.bless(Plane_Tool, "prim.plane")