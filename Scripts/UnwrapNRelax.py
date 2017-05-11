# python

import lx


lx.eval('tool.set uv.unwrap on')
lx.eval('tool.setAttr uv.unwrap iter 100')
lx.eval('tool.doApply')
if lx.eval('select.typeFrom polygon;edge;vertex;item;pivot;center;ptag ?') != False:
	lx.eval('select.typeFrom polygon;edge;vertex;item;pivot;center;ptag true')
lx.eval('tool.set uv.relax on')
lx.eval('tool.attr uv.relax mode lscm')
lx.eval('tool.setAttr uv.relax iter 700')
lx.eval('tool.doApply')
lx.eval('tool.noChange')
lx.eval('tool.doApply')
lx.eval('tool.setAttr uv.relax iter 700')
lx.eval('tool.doApply')
lx.eval('select.nextMode')
lx.eval('tool.set uv.relax on')
lx.eval('tool.attr uv.relax mode adaptive')
lx.eval('tool.setAttr uv.relax iter 200')
lx.eval('tool.noChange')
lx.eval('tool.doApply')
lx.eval('select.nextMode')
lx.eval('uv.pack true true true horizontal 0.2 false false nearest 1001 0.0 0.0 2.0 2.0 1 1')
