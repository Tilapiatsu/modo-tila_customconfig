#python
import lx

if lx.eval('select.typeFrom edge false'):
	lx.eval('select.convert edge')

lx.eval('tool.set ffr.uvAlign on')

lx.eval('tool.attr ffr.uvAlign axis endpoints')
lx.eval('tool.attr ffr.uvAlign align average')
lx.eval('tool.attr ffr.uvAlign spacing relative3d')
lx.eval('tool.attr ffr.uvAlign length unchanged')
lx.eval('tool.doApply')
lx.eval('select.nextMode') 