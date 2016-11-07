#python

import lx

lx.eval("pref.value application.defaultSubdivs psubdiv")
lx.eval("cmds.mapKey top5 @MP_itemSelectMM.pl .global (stateless) .anywhere (contextless)")
lx.eval("cmds.mapKey tab @MP_psubdivKeepsel.pl .global (stateless) .anywhere (contextless)")
lx.eval("cmds.mapKey ctrl-lmb @MP_mayaLooptemp.pl view3DNavigate (stateless) .anywhere (contextless)")
lx.eval("cmds.mapKey ctrl-rmb @MP_selremDirectional.pl view3DNavigate (stateless) .anywhere (contextless)")
lx.eval("cmds.mapKey shift-rmb @MP_selremDirectional.pl view3DNavigate (stateless) .anywhere (contextless)")
lx.eval("cmds.mapKey shift-lmb-dblclick @MP_selLoopDouble.pl view3DNavigate (stateless) .anywhere (contextless)")
lx.eval("cmds.mapKey ctrl-lmb-dblclick @MP_remLoopDouble.pl view3DNavigate (stateless) .anywhere (contextless)")
lx.eval("cmds.mapKey ctrl-shift-lmb @MP_selremBetween.pl view3DNavigate (stateless) .anywhere (contextless)")
# lx.eval("inmap.bindEvent view3DSelect (stateless) selCon lmb-dblclick (contextless)")
# lx.eval("inmap.bindEvent view3DSelect (stateless) addCon ctrl-shift-lmb-dblclick (contextless)")
lx.eval("cmds.mapKey ctrl-shift-lmb-dblclick @MP_selremConnect.pl view3DNavigate (stateless) .anywhere (contextless)")

lx.eval("cmds.mapKey shift-space @MP_itemSelect.pl .global (stateless) .anywhere (contextless)")

# lx.eval("inmap.unbindEvent view3DNavigate (stateless) navRoll ctrl-shift-mmb (contextless)")
# lx.eval("inmap.unbindEvent view3DSelect (stateless) selCon lmb-dblclick (contextless)")