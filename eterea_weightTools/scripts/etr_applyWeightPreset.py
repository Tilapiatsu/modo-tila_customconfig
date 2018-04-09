#python

#-------------------------------------------------------------------------------
# NAME: etr_applyWeightPreset.py
# VERS: 1.0
# DATE: February 24, 2014
#
# MADE: Cristobal Vila, etereaestudios.com
#
# USES: to apply predefined Weight amounts to selected components.
#-------------------------------------------------------------------------------

myWeight = lx.arg()

myCustomValue = (lx.eval("user.value etr_wgt_customWeight ?")) / 100


lx.eval('tool.set vertMap.setWeight on')
lx.eval('tool.attr vertMap.setWeight additive false')

if myWeight == 'userValue':
	lx.eval('tool.setAttr vertMap.setWeight weight %s' % myCustomValue)
else:
	lx.eval('tool.setAttr vertMap.setWeight weight %s' % myWeight)

lx.eval('tool.doApply')
lx.eval('tool.set vertMap.setWeight off 0')