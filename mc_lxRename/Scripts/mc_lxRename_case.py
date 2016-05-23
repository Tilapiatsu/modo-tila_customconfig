#python

# File: mc_lxRename_case.py
# Author: Matt Cox
# Description: Bulk renames a selection of items, converting the entire name to another case.

import lx
import re

lxRArgs = lx.args()
lxRArg_case = lxRArgs[0].lower()

if (lxRArg_case != "upper") and (lxRArg_case != "lower"):
    lxRArg_case = "upper"

try:
    lxRSelectedItems = lx.evalN('query sceneservice selection ? all')
    
    lxRCurrentCount = 1
    for x in lxRSelectedItems:
        lx.eval('select.Item %s' %str(x))
        lxRMeshNameM = lx.eval('query sceneservice item.name ? %s' %str(x))
        try:
            if lxRArg_case == "upper":
                lxRNewNameM = lxRMeshNameM.upper()
            else:
                lxRNewNameM = lxRMeshNameM.lower()
            lx.eval('item.name "%s"'%(lxRNewNameM))
            lxRCurrentCount = lxRCurrentCount + 1
    
        except:
            lx.eval('dialog.setup error')
            lx.eval('dialog.title {Error}')
            lx.eval('dialog.msg {Unable to rename items.}')
            lx.eval('dialog.open')  
    
    lx.eval('select.drop item')
    for x in lxRSelectedItems:
        lx.eval('select.Item %s add' %str(x))
except:
    lx.out('Exception "%s" on line: %d' % (sys.exc_value, sys.exc_traceback.tb_lineno))