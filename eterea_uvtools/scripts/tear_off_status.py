#python
#
# tear_off_status
#
# Author: Cristobal Vila, based on toggleUVImage script by Mark Rossi (aka Onim).
# Packaged by Cristobal Vila [http://www.etereaestudios.com] to form part of the Eterea UV Tools, distributed free.
# Version: .3
# Compatibility: Modo 501/601
# Purpose: To enable Move tool and check Tear Off Status in UV, no matter you select your geo both in 3D or UV viewport.

for w in range(lx.eval("query view3dservice view.N ?")):
    if lx.eval("query view3dservice view.type ? %s" %w) == "UV2D":
        frame = lx.evalN("query view3dservice view.frame ? %s" %w)
        lx.eval("select.viewport set viewport:%s frame:%s" %(frame[1], frame[0]))
        lx.eval("tool.set TransformMove on")