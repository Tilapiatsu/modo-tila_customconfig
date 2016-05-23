#python

# Kindly created and shared by MonkeyBrotherJr on the Lux forums

import lx
from lx import eval, eval1, evalN, out, Monitor, args

arguments = args()

eval("tool.viewType uv")
eval("tool.set xfrm.transform on")
eval("tool.reset")
eval("tool.setAttr xfrm.transform U %s" %arguments[0])
eval("tool.setAttr xfrm.transform V %s" %arguments[1])
eval("tool.doApply")
eval("tool.set xfrm.transform off")