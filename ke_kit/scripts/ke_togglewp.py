#python

# ToggleWP Kjell Emanuelsson 2017 
# Simple toggle script that works well for my typical flow (and saves one hotkey) : 
# - Fits Workplane OR resets Workplane (if already active)

if lx.eval('workPlane.state ?') : lx.eval('workPlane.reset')
else : lx.eval('workPlane.fitSelect')