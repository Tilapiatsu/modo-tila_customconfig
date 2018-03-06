# python
import lx, lxu, modo
import os, sys

scn = modo.Scene()

def init_message(type, title, message):
    return_result = type == 'okCancel' \
                    or type == 'yesNo' \
                    or type == 'yesNoCancel' \
                    or type == 'yesNoAll' \
                    or type == 'yesNoToAll' \
                    or type == 'saveOK' \
                    or type == 'fileOpen' \
                    or type == 'fileOpenMulti' \
                    or type == 'fileSave' \
                    or type == 'dir'
    try:
        lx.eval('dialog.setup {%s}' % type)
        lx.eval('dialog.title {%s}' % title)
        lx.eval('dialog.msg {%s}' % message)
        lx.eval('dialog.open')

        if return_result:
            return lx.eval('dialog.result ?')

    except:
        if return_result:
            return lx.eval('dialog.result ?')

# http://modo.sdk.thefoundry.co.uk/wiki/Dialog_Commands
def init_custom_dialog(type, title, format, uname, ext, save_ext=None, path=None, init_dialog=False):
    ''' Custom file dialog wrapper function

        type  :   Type of dialog, string value, options are 'fileOpen' or 'fileSave'
        title :   Dialog title, string value.
        format:   file format, tuple of string values
        uname :   internal name
        ext   :   tuple of file extension filter strings
        save_ext: output file extension for fileSave dialog
        path  :   optional default loacation to open dialog

    '''
    lx.eval("dialog.setup %s" % type)
    lx.eval("dialog.title {%s}" % title)
    lx.eval("dialog.fileTypeCustom {%s} {%s} {%s} {%s}" % (format, uname, ext, save_ext))
    if type == 'fileSave' and save_ext != None:
        lx.eval("dialog.fileSaveFormat %s extension" % save_ext)
    if path is not None:
        lx.eval('dialog.result {%s}' % path)

    if init_dialog:
        try:
            lx.eval("dialog.open")
            return lx.eval("dialog.result ?")
        except:
            return None

def init_dialog(dialog_type, currPath, format=None):
    if dialog_type == "input":
        # Get the directory to export to.
        lx.eval('dialog.setup fileOpenMulti')
        lx.eval('dialog.fileType scene')
        lx.eval('dialog.title "Mesh Path"')
        lx.eval('dialog.msg "Select the meshes you want to process."')
        lx.eval('dialog.result "%s"' % currPath)

    if dialog_type == "input_path":
        # Get the directory to Open.
        lx.eval('dialog.setup dir')
        lx.eval('dialog.title "Open Path"')
        lx.eval('dialog.msg "Select path to process."')
        lx.eval('dialog.result "%s"' % currPath)

    if dialog_type == "output":
        # Get the directory to export to.
        lx.eval('dialog.setup dir')
        lx.eval('dialog.title "Export Path"')
        lx.eval('dialog.msg "Select path to export to."')
        lx.eval('dialog.result "%s"' % currPath)

    if dialog_type == 'filesave':
        if format is None:
            print 'Unspecified format'
            sys.exit()
        else:
            init_custom_dialog('fileSave', 'SaveFile', format[0], format[1], format[2], format[3], currPath)

    if dialog_type == "cancel":
        #init_message('error', 'Canceled', 'Operation aborded')
        sys.exit()

def print_log(message):
    lx.out("IMPORT_AS_MORPH : " + message)

def transform():
	curr_pos = lx.eval('transform.channel pos.Y ?')
	lx.eval('transform.channel pos.Y {}'.format(curr_pos+1.0))

def filter_arr_of_type(arr, type):
	return [item for item in arr if  item.type == type]

def get_name_of_arr(arr):
	return [item.name for item in arr]

def get_child_of_type(arr, type):
	return [item for item in modo.Item.children(arr, True) if item.type == type]

def construct_item_dict(arr):
	result = {}
	for item in arr:
		result[item.name] = item

	return result

def get_matching_item(source_arr, imported_item, skipped_item_dict):
	for item in source_arr:
		item_name = item.name + '_' + imported_item.name.split('_')[-1:][0]
		if imported_item.name == item_name:
			print_log('Matching name = {}'.format(item_name))
			if item.type == 'mesh':
				print_log('Matching type = {}'.format(item.type))
				return item
			else:
				print_log('{} is type of {}. No Match'.format(item.name, item.type))
				return None
	else:
		skipped_item_dict[imported_item.name] = 'No item name matching for {}'.format(imported_item.name)
		print_log('No item name matching for {}'.format(imported_item.name))
		return None

def print_arr_name(arr, prefix):
	for o in arr:
		print prefix + o.name

if __name__ == '__main__':

	if len(scn.selected) == 0:
		item_to_proceed = scn.items()
	else:
		item_to_proceed = scn.selected

	skipped_item_dict = {}

	group_locator = filter_arr_of_type(item_to_proceed, 'groupLocator')
	group_locator_name = get_name_of_arr(group_locator)

	group_locator_dict = construct_item_dict(group_locator)
	path = r'C:\Users\lboucher\Documents\3dsMax\export\NewBodyPose'

	if len(group_locator): # at least one group locator item selected
		
		init_dialog("input", path, 'fbx')

		try:  # mesh to process dialog
			lx.eval('dialog.open')
		except: # if cancel button pressed
			init_dialog('cancel', path)
		else: # process selected mesh
			files = lx.evalN('dialog.result ?')

			for f in files:
				filename = os.path.splitext(os.path.basename(f))[0]
				if filename in group_locator_name: # the filename have a groupLocator selected with the same name
					lx.eval('!!scene.open "{}" import'.format(f))
					print_log('Importing {}'.format(filename))

					imported_scene_root = modo.Item(filename + '_2')
					imported_items = get_child_of_type(imported_scene_root, 'mesh')
					source_items = get_child_of_type(group_locator_dict[filename], 'mesh')

					for imported_item in imported_items:
						matching_source_item = get_matching_item(source_items, imported_item, skipped_item_dict)
						if matching_source_item is not None:
							
							matching_list = [matching_source_item, imported_item]

							scn.select(matching_list)

							lx.eval('hide.unsel')

							scn.select(matching_source_item)

							vertex_map_name = 'Conformed'

							matching_vertex_map_name = False
							for vmap in matching_source_item.geometry.vmaps.morphMaps:
								if vmap == vertex_map_name:
									matching_vertex_map_name = True
							if not matching_vertex_map_name:
								print_log('No matching morph map found! Creating a "{}" morph map'.format(vertex_map_name))
								lx.eval('!!vertMap.new {} morf'.format(vertex_map_name))

							lx.eval('select.vertexMap {} morf replace'.format(vertex_map_name))
							lx.eval('vertMap.bgMorph background')
							lx.eval('select.vertexMap {} morf 3'.format(vertex_map_name))
							lx.eval('vertMap.applyMorph {} 1.0'.format(vertex_map_name))
							lx.eval('select.vertexMap {} morf replace'.format(vertex_map_name))
							lx.eval('vertMap.clear morf')
							print_log('Updating {} morph map for {}'.format(vertex_map_name, matching_source_item.name))

							lx.eval('unhide')

					scn.select(imported_scene_root)
					lx.eval('!!item.delete')
					print_log('Delete imported scene : {}'.format(imported_scene_root.name))

					if len(skipped_item_dict) == 0 :
						print_log('Importing done with no error')
					else:
						print_log('Importing done with {} error'.format(len(skipped_item_dict)))
						for key in skipped_item_dict.keys():
							print_log('{} item has been skipped because : \n {}'.format(key, skipped_item_dict[key]))

				else:
					print_log('No groupLocator named {} found ! \n \n Skipping file !'.format(filename))
	else:
		init_message('error', 'No groupLocator selected', 'At leat one "groupLocator" item has to be selected')


	