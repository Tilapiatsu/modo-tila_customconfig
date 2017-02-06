#python
import lx
lx.eval('select.convert edge')
lx.eval('tool.viewType uv')
lx.eval('tool.set xfrm.linearAlign on')
lx.eval('tool.setAttr xfrm.linearAlign weight 1.0 ')
lx.eval('tool.setAttr xfrm.linearAlign edgeLength 0.0')
lx.eval('tool.doApply') 


lx.eval('tool.attr xfrm.linearAlign uniform true')
lx.eval('tool.attr xfrm.linearAlign length false')
lx.eval('tool.doApply')
lx.eval('tool.set xfrm.linearAlign off')


lx.eval('tool.set ffr.uvAlign on')
lx.eval('tool.reset')

lx.eval('tool.attr ffr.uvAlign axis endpoints')
lx.eval('tool.attr ffr.uvAlign align average')
lx.eval('tool.attr ffr.uvAlign spacing relative3d')
lx.eval('tool.attr ffr.uvAlign length unchanged')
lx.eval('tool.doApply')
lx.eval('tool.set ffr.uvAlign off')
