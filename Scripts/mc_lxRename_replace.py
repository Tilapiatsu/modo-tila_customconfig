#python

# File: mc_lxRename_replace.py
# Author: Matt Cox
# Description: Bulk renames a selection of items, replacing all instances of the search string with the replace string.

import lx
import re

lxRSearchText = lx.eval( "user.value mcRename.search ?" )
lxRRenameText = lx.eval( "user.value mcRename.replace ?" )
lxRRenameIgnoreCase = lx.eval( "user.value mcRename.searchIgnoreCase ?" )

if len(lxRSearchText) != 0:
    try:
        lxRSelectedItems = lx.evalN('query sceneservice selection ? all')
        
        for x in lxRSelectedItems:
            lx.eval('select.Item %s' %str(x))
            lxRMeshNameM = lx.eval('query sceneservice item.name ? %s' %str(x))
            try:
                if lxRRenameIgnoreCase == 0:
                    replaceCompile = re.compile(re.escape(lxRSearchText), re.IGNORECASE)
                    lxRNewNameM = replaceCompile.sub(lxRRenameText, lxRMeshNameM)
                    lx.eval('item.name "%s"'%(lxRNewNameM))
                else:
                    lxRNewNameM = lxRMeshNameM.replace(lxRSearchText, lxRRenameText)
                    lx.eval('item.name "%s"'%(lxRNewNameM))
        
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