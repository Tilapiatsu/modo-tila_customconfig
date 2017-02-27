#python
#------------------------------------------------------#
# bm_stitching by Bernd Möller - mail@berndcmoeller.de #
# 2014-05-15 v0.1                                      #
#------------------------------------------------------#

import bm_stitching_funcs as sf
import traceback

args = lx.args()
try:
    if 'polys' in args:
        sf.polys()
    if 'curves' in args:
        sf.curves()
except:
    lx.out(traceback.format_exc())
