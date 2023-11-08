# set "SM_RUN_RESULT" and "SM_RUN_RESULT__TRYRUN_OUTPUT" to fix:
#   | CMake Error: TRY_RUN() invoked in cross-compiling mode, please set the following cache variables appropriately:
#   |  SM_RUN_RESULT (advanced)
#   |  SM_RUN_RESULT__TRYRUN_OUTPUT (advanced)
EXTRA_OECMAKE += "-DSM_RUN_RESULT=false -DSM_RUN_RESULT__TRYRUN_OUTPUT=false"
