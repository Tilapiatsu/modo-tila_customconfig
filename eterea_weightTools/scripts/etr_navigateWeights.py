#python

# ------------------------------------------------------------------------------------------------
# NAME: etr_navigateWeights.py
# VERS: 1.1
# DATE: October 29, 2017
#
# MADE: Cristobal Vila, etereaestudios.com
#
# USES:	to navigate through all weights in our scene (previous, next, first and last)
# ------------------------------------------------------------------------------------------------

mode = lx.arg()

# --------------------------------------------------------------------------------------------------
# Checks to know how many standard weights are in scene and which ones (if any) are selected
# --------------------------------------------------------------------------------------------------

# Store standard weight maps on scene (not the subd one aka edge weight, which is unique and always present)
weights_ID_list = lx.evalN('query layerservice vmaps ? weight')

# Define an empty list to fill later with selected weights
sel_weights_list = []

# Define an empty list to fill later with the names of all weights
weight_names_list = []


# CASE 1: there is no weights. Do nothing and exit
if len(weights_ID_list) == 0:
	sys.exit()

# CASE 2: there is only an unique weight. Select it, no matter it's already selected or not
elif len(weights_ID_list) == 1:
	weight_name = lx.eval('query layerservice vmap.name ? %s' % weights_ID_list[0])
	lx.eval('select.vertexMap {%s} wght replace' % weight_name)
	sys.exit()

# CASE 3: there is more than 1 weight. Lets check how many and which ones are already selected, if any
else:

	weights_N = len(weights_ID_list) # Total number of weights

	for weight_ID in weights_ID_list:

		# Query the weight names and store all in a list
		# We need to know the NAME of a weight to select it in the weight list (AFAIK)
		weight_name = lx.eval('query layerservice vmap.name ? %s' % weight_ID)
		weight_names_list.append(weight_name)

		# Query if each one of these weights are selected or not. Drop in a list if so
		weight_selState = lx.eval('query layerservice vmap.selected ? %s' % weight_ID)
		if weight_selState == 1:
			sel_weights_list.append(weight_name)

# --------------------------------------------------------------------------------------------------
# Now we have two lists: one with all the weight names and other which those already selected
# --------------------------------------------------------------------------------------------------

# For the 'first' button, just catch the first one of all weights in scene and exit
if mode == 'first':
	lx.eval('select.vertexMap {%s} wght replace' % weight_names_list[0])
	sys.exit()

# For the 'last' button, just catch the last one of all weights in scene and exit
elif mode == 'last':
	lx.eval('select.vertexMap {%s} wght replace' % weight_names_list[-1])
	sys.exit()

# For 'prev' and 'next' buttons, lets define various scenarios
else:

	# If no weigh is already selected, catch the first one, no matter we press 'prev' or 'next', and exit
	if len(sel_weights_list) == 0:
		lx.eval('select.vertexMap {%s} wght replace' % weight_names_list[0])
		sys.exit()

	# If more than 1 weight is selected, catch the second one of those selected, and exit
	elif len(sel_weights_list) > 1:
		lx.eval('select.vertexMap {%s} wght replace' % sel_weights_list[1])
		sys.exit()

	# If just 1 weigth is selected, lets define which is the next and the previous ones
	else:

		# Query the position of selected weight in the all-weights-list, to define next and previous, later
		sel_weight_pos = weight_names_list.index(sel_weights_list[0])

		next_weight = sel_weight_pos + 1
		prev_weight = sel_weight_pos - 1

		# Special cases for previous and next for those first and last ones (to cycle navigation)
		if sel_weight_pos == weights_N-1:
			next_weight = 0

		if sel_weight_pos == 0:
			prev_weight = weights_N-1

		# Catch the weight for each case
		if mode == 'prev':
			lx.eval('select.vertexMap {%s} wght replace' % weight_names_list[prev_weight])

		elif mode == 'next':
			lx.eval('select.vertexMap {%s} wght replace' % weight_names_list[next_weight])
