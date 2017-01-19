#python

# resize_selected_locators.py
#
# Version 1.2 - By Cristobal Vila, 2013 - With the help of other members from Luxology Forums :-)
# Special thanks to MonkeybrotherJR
#
# To give a custom size to all channels in a selected Locators,
# no matter the kind of Locators and if there are some channels greyed
#
# www.etereaestudios.com

import lx

try:

    scene_svc = lx.Service("sceneservice")

    # Define my argument:
    mysize = float(lx.args()[0])

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

        # get item type
        itemType = scene_svc.query("item.type")

        if itemType == 'locator':

            locators.append(item)

            # Ask if our locator has a default or custom shape:
            lx.eval('item.channel locator$drawShape ?')

            # This gives a result (default / custom)
            # Save that result into a variable:
            locatorShape = lx.eval1('item.channel locator$drawShape ?')

            if locatorShape == 'default':
                # Change size for standard default locator:
                lx.eval("item.channel locator$size " +str(mysize))

            elif locatorShape == 'custom':
                # Ask which is actual shape:
                lx.eval("item.channel locator$isShape ?")

                # This gives a result (box, pyramid, plane…)
                # Save that result into a variable:
                originalShape = lx.eval("item.channel locator$isShape ?")

                # Change size for standard default locator:
                lx.eval("item.channel locator$size " +str(mysize))

                # Set shape to Box:
                lx.eval("item.channel locator$isShape box")

                # Change properties for XYZ channels, since now all are available:
                lx.eval("item.channel locator$isSize.X " +str(mysize))
                lx.eval("item.channel locator$isSize.Y " +str(mysize))
                lx.eval("item.channel locator$isSize.Z " +str(mysize))

                # Set shape to Circle:
                lx.eval("item.channel locator$isShape circle")

                # Change properties for Radius, since now this is available:
                lx.eval("item.channel locator$isRadius " +str(mysize * 0.5))

                # Change shape back to the one saved inside our first variable:
                lx.eval("item.channel locator$isShape %s" % originalShape)

    # re-select the user selected layers
    for item in selected_layers:
        lx.eval('select.item {%s} add' % item)

except:
    lx.out('Exception "%s" on line: %d' % (sys.exc_value, sys.exc_traceback.tb_lineno))