#python

# convert_locators_to_shape.py
#
# Version 1.1 - By Cristobal Vila, 2013 - With the help of other members from Luxology Forums :-)
# Special thanks to MonkeybrotherJR
#
# To convert selected locators on scene to a new shape
#
# www.etereaestudios.com

import lx

# Enable Locators visibility, just in case it was disable
lx.eval("view3d.showLocators true")

try:

    scene_svc = lx.Service("sceneservice")

    # Defining arguments
    myform = lx.args()[0] # box, plane, circle, etc
    myshap = lx.args()[1] # shape default or custom

    # get selected layers
    selected_layers = lx.evalN("query sceneservice selection ? all")
    
    # drop selection so that we can work on one item at a time
    lx.eval("select.drop item")
    
    # create empty list to put locators in
    locators = []
    
    for item in selected_layers:
        
        # select layer
        scene_svc.select("item",str(item))
        lx.eval('select.item {%s} set' % item)

        #get item type
        itemType = scene_svc.query("item.type")

        if itemType == 'locator':
        
            locators.append(item)

            # Ask which is actual shape in our locator:
            lx.eval('item.channel locator$drawShape ?')

            # This gives a result (default / custom)

            # Save that result into a variable:
            locatorShape = lx.eval1('item.channel locator$drawShape ?')

            if locatorShape == 'default':
                # Change to custom
                lx.eval('item.channel locator$drawShape custom')
                # Apply form shape
                lx.eval("item.channel locator$isShape " + myform )
                # Decide between default or custom shape
                lx.eval("item.channel locator$drawShape " + myshap )

            elif locatorShape == 'custom':
                # Apply form shape
                lx.eval("item.channel locator$isShape " + myform )
                # Decide between default or custom shape
                lx.eval("item.channel locator$drawShape " + myshap )
                    
    # re-select the user selected layers
    for item in selected_layers:
        lx.eval('select.item {%s} add' % item)
        
except:
    lx.out('Exception "%s" on line: %d' % (sys.exc_value, sys.exc_traceback.tb_lineno))