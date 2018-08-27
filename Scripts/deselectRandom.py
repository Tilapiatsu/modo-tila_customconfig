import modo, random
 
def DeselectPolysRandom(percentage):
        scn = modo.Scene()                                          # Get the current Modo Scene
        selectedMeshItem = scn.selectedByType('mesh')[0]            # Get a list of selected meshes, grab the first one and ignore the rest.
        sPolys = list(selectedMeshItem.geometry.polygons.selected)  # Create a list of the currently selected polygons using the mesh item from the previous line.
                                                                    # We surround it with list() beause Modo will give back a tuple which is a list, but cannot be modified.
                                                                    # Since we randomize this list later in the script, we ensure we have a list.
 
        num_polys = len(sPolys)                                     # Count how many selected polygons we have
 
        if num_polys < 2:                                           # If we have less than two polygons selected, exit the code
                return                                              # return is very useful because it will end the script when its encountered.
                                                                    # This alleviates the need for something like ' if num_polys < 2...     else... '
 
        random.shuffle(sPolys)                                      # Using the list of selected polygons, randomize their order
        lsHalf = sPolys[:int(num_polys * (1.0-percentage))]         # Using the provided percentage, cut the list in two, giving us a shortened list
                                                                    # containing only the polygons that happened to be inside that particular range.
 
        for index, poly in enumerate(lsHalf):                       # enumerate() allows us to loop through a list but keep track of how many times we have gone around the loop
                                                                    # the first time through, index will be 0, then 1, then 2, etc...  And poly will simply hold the polygon, just like a typical for loop.
 
                poly.select(replace=index==0)                       # The select command available allows us to add the polygon to our current selection of polygons, or if we us poly.select(replace=True),
                                                                    # it will drop our current selection of polygons and we end up with only that one particular polygon selected.
                                                                    # We want to end up with a percentage of polygons left selected, so the first time around the loop, replace will be True which will drop our selection,
                                                                    # all remaining loops through, replace will be False, and we will add that polygon to our selection.  the replace=index==0 is compressed logic that's basically saying
                                                                    # if index == 0 : Do this     else: Do this instead
 
        selectedMeshItem.geometry.setMeshEdits()                    # Any time you change geo, geo selections, etc, you have to alert modo that you are all finished, and then modo will update the change
                                                                    # This way, modo isn't constantly updating the scene while we're spinning through tons of items and polygons.

if __name__ == '__main__':
    DeselectPolysRandom(0.5)