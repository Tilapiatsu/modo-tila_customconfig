#python
#
# toggleUVextents
#
# Author: minor changes added by Cristobal Vila over toggleUVImage script by Mark Rossi (aka Onim).
# Arguments introduced with the great help of Jeegrobot (THANKS!)
# Packaged by Cristobal Vila [http://www.etereaestudios.com] to form part of the Eterea UV Tools, distributed free.
# Version: .2
# Compatibility: Modo 501/601
# Purpose: To toggle various UV Image Extents features on all visible UV viewports.

MyArg1 = lx.args()[0]
MyArg2 = lx.args()[1]
MyArg3 = lx.args()[2]
MyArg4 = lx.args()[3]
for w in range(lx.eval("query view3dservice view.N ?")):
    if lx.eval("query view3dservice view.type ? %s" %w) == "UV2D":
        frame = lx.evalN("query view3dservice view.frame ? %s" %w)
        lx.eval("select.viewport set viewport:%s frame:%s" %(frame[1], frame[0]))
        lx.eval("viewuv.uMin "+MyArg1+"")
        lx.eval("viewuv.uMax "+MyArg2+"")
        lx.eval("viewuv.vMin "+MyArg3+"")
        lx.eval("viewuv.vMax "+MyArg4+"")