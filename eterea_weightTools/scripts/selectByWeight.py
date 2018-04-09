#python

"""  
	Select By Weight script 1.0  by Richard Rodriguez (gm770)
	Small changes on varible-names and comments added by Cristobal Vila
	
	How to use:
	- Run with no Edges selected, it will select all weighted edges
	- Run with Edges selected, it will select all edges that have 
	the same weight as any of the selected edges
"""

import lx


main=lx.eval("query layerservice layers ? main")

# Count the total number of edges in our active mesh
edge_cnt = lx.eval("query layerservice edge.N ? all")

# Create empty list to fill later with Edges and Edge Weights
if edge_cnt != 0:
	edge_list = []
	edgW_list = []

	# For each edge in our scene, query the Edge Weight and if is selected or not
	for edgeNum in range(edge_cnt):
		edgeWgt = lx.eval("query layerservice edge.creaseWeight ? %s" % edgeNum) # Get Edge Weight of a given Edge
		selStat = lx.eval("query layerservice edge.selected ? %s" % edgeNum) # Get Selection State of a given Edge (1 = Selected)

		if selStat == 1 and edgeWgt not in edgW_list:
			edgW_list.append(edgeWgt)

		edgA,edgB = lx.eval("query layerservice edge.vertList ? %s" % edgeNum) # Get vert pair indices for a given Edge

		edge_dict = {"edgeNum":edgeNum, "edgeWgt":edgeWgt, "edgA":edgA, "edgB":edgB} # Special description (dictionary?) for edges 

		edge_list.append(edge_dict)

	edgW_list_cnt = len(edgW_list)

	lx.eval("select.drop edge")

	if edgW_list_cnt != 0:
		for edge_dict in edge_list: 
			if edge_dict['edgeWgt'] in edgW_list:
				lx.eval("select.element %s edge add %s %s" % (main, edge_dict['edgA'], edge_dict['edgB']) )

	else:
		for edge_dict in edge_list:
			if edge_dict['edgeWgt'] != 0:
				lx.eval("select.element %s edge add %s %s" % (main, edge_dict['edgA'], edge_dict['edgB']) )	