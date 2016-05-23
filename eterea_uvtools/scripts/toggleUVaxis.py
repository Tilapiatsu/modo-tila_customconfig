#python
#
# ToggleUVgrid
#
# Author: minor changes added by Cristobal Vila over toggleUVImage script by Mark Rossi (aka Onim).
# Packaged by Cristobal Vila [http://www.etereaestudios.com] to form part of the Eterea UV Tools, distributed free.
# Version: .1
# Compatibility: Modo 501/601
# Purpose: To toggle the UV Grid display on all visible UV viewports.

for w in range(lx.eval("query view3dservice view.N ?")):
    if lx.eval("query view3dservice view.type ? %s" %w) == "UV2D":
        frame = lx.evalN("query view3dservice view.frame ? %s" %w)
        lx.eval("select.viewport set viewport:%s frame:%s" %(frame[1], frame[0]))
        lx.eval("viewuv.showInsideLabel ?+")
        lx.eval("viewuv.showAxis ?+")