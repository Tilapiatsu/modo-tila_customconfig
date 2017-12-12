#!/usr/bin/env python
__author__ = 'Nicholas Stevenson'
__email__  = 'twistedsheep@gmail.com'

import lx
import lxu
import lxu.select
#import lxifc

class RenameSel(lxu.command.BasicCommand):
    def __init__(self):
        lxu.command.BasicCommand.__init__(self)

        # Store the currently selected item, or if nothing is selected, an empty list.
        # Wrap this is a try except, the initial launching of Modo will cause this function
        # to perform a shallow execution before the scene state is established.
        # The script will still continue to run, but it outputs a stack trace since it failed.
        # So to prevent console spew on launch when this plugin is loaded, we use the try/except.
        try:
            self.current_Selection = lxu.select.ItemSelection().current()
        except:
            self.current_Selection = []

        # If we do have something selected, put it in self.current_Selection
        # Using [-1] will grab the newest item that was added to your selection.
        if len(self.current_Selection) > 0:
            self.current_Selection = self.current_Selection[-1]
        else:
            self.current_Selection = None

        # Test the stored selection list, only if it it not empty, instantiate the variables.
        if self.current_Selection:
            self.dyna_Add('Name', lx.symbol.sTYPE_STRING)
            self.basic_SetFlags(0, lx.symbol.fCMDARG_QUERY)

    def basic_Execute(self, msg, flags):

        # Only proceed if self.current_Selection is not None
        if self.current_Selection is not None:
            # Prompt the user with a dialog containing the name of the currently selected item
            prompt_String = self.dyna_String(0)

            # Check if the user cleared the field and hit enter, resulting in a value of ''
            # If a proper name was entered, strip out all illegal characters and rename
            # the item to the new name.
            if prompt_String != '':
                prompt_String = self.returnSafeString(sVal=prompt_String)
                if prompt_String:
                    scn_svc = lx.service.Scene()
                    if scn_svc.ItemTypeName(self.current_Selection.Type()) == 'mask': # is selection is type : Material
                        lx.eval('material.reassign {} {}'.format(self.current_Selection.UniqueName().split('(')[0], prompt_String))
                    else:
                        self.current_Selection.SetName(prompt_String)

        else:
            return

    def cmd_Query(self, index, vaQuery):
        """
        Pulling from the self.current_Selection, put the name of the object
        in the rename dialog's text field.
        """
        va = lx.object.ValueArray()
        va.set(vaQuery)
        va.AddString(self.current_Selection.UniqueName())
        return lx.result.OK

    def cmd_Flags(self):
        return lx.symbol.fCMD_MODEL | lx.symbol.fCMD_UNDO

    def cmd_Interact(self):
        """
        This prevents bogus stack trace errors
        """
        pass

    def returnSafeString(self, sVal = None):
        """
        When this function is passed a string, it will attempt to strip most
        illegal characters and return a happy string
        """

        sVal = sVal.replace(' ', '_')

        illegalChars = ['^', '<', '>', '/', '\\', '{', '}', '[', ']',
                        '~', '`', '$', '.', '?', '%', '&', '@', '*',
                        '(', ')', '!', '+', '#', '\'', '\"', ':']

        if sVal:
            for i in illegalChars:
                if i in sVal:
                    sVal = sVal.replace(i, '_')

        # If you passed in only illegal characters, you have just ended up with an empty string
        if sVal:
            return sVal
        else:
            return None

lx.bless(RenameSel, "item.renameSel")
