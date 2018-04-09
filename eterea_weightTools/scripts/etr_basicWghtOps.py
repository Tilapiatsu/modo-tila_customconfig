#python

# ------------------------------------------------------------------------------------------------
# NAME: etr_basicWghtOps.py
# VERS: 1.0
# DATE: October 29, 2017
#
# MADE: Cristobal Vila, etereaestudios.com
#
# USES:	to perform basic operations with weights (rename, copy, paste, clear and delete)
#		All those ops could be done as a command, ie: 'vertMap.name' (without the need of a script)
#		But under certain circumstances a command fails (lost focus?). Not embraced in a script
#		Use these arguments:
#			name
#			copy
#			paste
#			clear
#			delete
# ------------------------------------------------------------------------------------------------

operation = lx.arg()

if operation == 'name':
	lx.eval('vertMap.name')

elif operation == 'delete':
	lx.eval('!vertMap.delete wght')

else:
	lx.eval('vertMap.%s wght' % operation)