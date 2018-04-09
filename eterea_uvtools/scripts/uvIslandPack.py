#python
#
# UVIslandPack
#
# Author: Mark Rossi (small update by Cristobal Vila for Modo 11.x)
# Version: .4
# Compatibility: Modo 11.x
#
# Purpose: To fit every UV island in the selected UV map to 0-1 range and then array them in a grid so that each island has its own
#          discrete range in UV space.
#
# Use: Select the mesh layer, select the UV map, and run the script. However, if you select any polygons, then the script will only run on
#      the islands that the polygon/s belong to. Moreover, the order in which you select the islands dictates the array order, provided that
#      you do NOT double-click on any of the polygons to select the entire island/s. The script takes two arguments, both numbers. The first 
#      specifies the number of islands per row, the second specifies the amount of UV space padding between islands. The default values are
#      5 and 0.001, respectively. If you specify one argument then you must specify both. 
#
#      For example: @uvIslandPack.py 3 0.01

args  = lx.args()
split = len(args) > 1 and float(args[0]) or 5.0
pad   = len(args) > 1 and float(args[1]) or 0.001
row   = 0.0
count = 0.0

layer  = lx.eval("query layerservice layer.index ? current")
polys  = [p.strip("()").split(",")[1] for p in lx.evalN("query layerservice selection ? poly")]
unproc = polys or lx.evalN("query layerservice polys ? visible")

lx.eval("escape")
lx.eval("tool.set actr.auto on")
while unproc:
	lx.eval("select.element %s polygon set %s" %(layer, unproc[0]))
	lx.eval("select.polygonConnect uv")
	lx.eval("uv.fit entire true") # October 2017: This changed. It previously was 'uv.fit false'
	lx.eval("tool.set TransformScale on")
	lx.eval("tool.viewType uv")
	lx.eval("tool.setAttr xfrm.transform SX %s" %(1.0 - pad))
	lx.eval("tool.setAttr xfrm.transform SY %s" %(1.0 - pad))
	lx.eval("tool.doApply")
	lx.eval("tool.set TransformScale off")
	lx.eval("tool.set TransformMove on")
	lx.eval("tool.viewType uv")
	lx.eval("tool.setAttr xfrm.transform U %s" %count)
	lx.eval("tool.setAttr xfrm.transform V %s" %row)
	lx.eval("tool.doApply")
	lx.eval("tool.set TransformMove off")
	island = set(lx.evalN("query layerservice polys ? selected"))
	unproc = [p for p in unproc if p not in island]
	count += 1.0
	if count == split:
		count = 0.0
		row  += 1.0
	
lx.eval("select.drop polygon")
lx.eval("tool.set TransformMove on")
lx.eval("tool.reset")
lx.eval("tool.viewType uv")
lx.eval("tool.setAttr xfrm.transform U %s" %(pad * .5))
lx.eval("tool.setAttr xfrm.transform V %s" %(pad * .5))
lx.eval("tool.doApply")
lx.eval("tool.set TransformMove off")
lx.eval("tool.set actr.auto off")