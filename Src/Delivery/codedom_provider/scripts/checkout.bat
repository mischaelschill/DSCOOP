@ECHO OFF
REM *********************************************
REM Eiffel Codedom Provider delivery build script
REM *********************************************

ECHO Checking out source files...
TITLE Checking out source files...
CD checkout
REM in checkout
ECHO Exporting eclop (HEAD) in checkout...
TITLE Exporting eclop (HEAD) in checkout...
MKDIR free_add_ons
svn export %SVN_ORIGO_URL%/trunk/free_add_ons/eclop free_add_ons/eclop
ECHO Exporting Eiffel (%CODEDOM_RELEASE%) in checkout...
TITLE Exporting Eiffel (%CODEDOM_RELEASE%) in checkout...
svn co %SVN_ORIGO_URL%/%CODEDOM_RELEASE%/Src/Eiffel Eiffel
ECHO Exporting runtime (%RELEASE%) in checkout...
TITLE Exporting runtime (%RELEASE%) in checkout...
svn export %SVN_ORIGO_URL%/%RELEASE%/Src/C C
ECHO Exporting studio (%RELEASE%) in checkout...
TITLE Exporting studio (%RELEASE%) in checkout...
svn export %SVN_ORIGO_URL%/%RELEASE%/Delivery/studio compiler_delivery 
ECHO Exporting eifinit (%RELEASE%) in checkout...
TITLE Exporting eifinit (%RELEASE%) in checkout...
svn export %SVN_ORIGO_URL%/%RELEASE%/Delivery/eifinit eifinit_delivery 

MKDIR tools
CD tools
REM in checkout\tools
ECHO Exporting silent_launcher (%CODEDOM_RELEASE%) in checkout\tools...
TITLE Exporting silent_launcher (%CODEDOM_RELEASE%) in checkout\tools...
svn export %SVN_URL%/%CODEDOM_RELEASE%/Src/tools/silent_launcher silent_launcher 
ECHO Exporting compliance_checker (%RELEASE%) in checkout\tools...
TITLE Exporting compliance_checker (%RELEASE%) in checkout\tools...
svn export %SVN_ORIGO_URL%/%COMPILER_RELEASE%/Src/tools/compliance_checker compliance_checker
ECHO Exporting doc_builder (%RELEASE%) in checkout\tools...
TITLE Exporting doc_builder (%RELEASE%) in checkout\tools...
svn export %SVN_ORIGO_URL%/%RELEASE%/Src/tools/doc_builder doc_builder
ECHO Exporting partial_classes_merger (%RELEASE%) in checkout\tools...
TITLE Exporting partial_classes_merger (%RELEASE%) in checkout\tools...
svn export %SVN_ORIGO_URL%/%RELEASE%/Src/tools/partial_classes_merger partial_classes_merger
CD ..
REM in checkout

MKDIR C_library
CD C_library
REM in checkout\C_library
ECHO Exporting libpng (%RELEASE%) in checkout\C_library...
TITLE Exporting libpng (%RELEASE%) in checkout\C_library...
svn export %SVN_ORIGO_URL%/%RELEASE%/Src/C_library/libpng libpng
ECHO Exporting zlib (%RELEASE%) in checkout\C_library...
TITLE Exporting zlib (%RELEASE%) in checkout\C_library...
svn export %SVN_ORIGO_URL%/%RELEASE%/Src/C_library/zlib zlib 

CD ..\
REM in checkout
ECHO Exporting framework (%RELEASE%) in checkout...
TITLE Exporting framework (%RELEASE%) in checkout...
svn export %SVN_ORIGO_URL%/%RELEASE%/Src/framework framework 

MKDIR library
CD library
REM in checkout\library
ECHO Copying GOBO
TITLE Copying GOBO
XCOPY /Q /S %GOBO_SRC% gobo\
ECHO Exporting base (%RELEASE%) in checkout\library...
TITLE Exporting base (%RELEASE%) in checkout\library...
svn export %SVN_ORIGO_URL%/%RELEASE%/Src/library/base base
ECHO Exporting wel (%RELEASE%) in checkout\library...
TITLE Exporting wel (%RELEASE%) in checkout\library...
svn export %SVN_ORIGO_URL%/%RELEASE%/Src/library/wel wel
ECHO Exporting vision2 (%RELEASE%) in checkout\library...
TITLE Exporting vision2 (%RELEASE%) in checkout\library...
svn export %SVN_ORIGO_URL%/%RELEASE%/Src/library/vision2 vision2
ECHO Exporting vision2_extension (%COMPILER_RELEASE%) in checkout\library...
TITLE Exporting vision2_extension (%COMPILER_RELEASE%) in checkout\library...
svn export %SVN_ORIGO_URL%/%RELEASE%/Src/library/vision2_extension vision2_extension 
ECHO Exporting thread (%RELEASE%) in checkout\library...
TITLE Exporting thread (%RELEASE%) in checkout\library...
svn export %SVN_ORIGO_URL%/%RELEASE%/Src/library/thread thread 
ECHO Exporting helpers (%RELEASE%) in checkout\library...
TITLE Exporting helpers (%RELEASE%) in checkout\library...
svn export %SVN_ORIGO_URL%/%RELEASE%/Src/library/helpers helpers
ECHO Exporting time (%RELEASE%) in checkout\library...
TITLE Exporting time (%RELEASE%) in checkout\library...
svn export %SVN_ORIGO_URL%/%RELEASE%/Src/library/time time
ECHO Exporting keygen (%RELEASE%) in checkout\library...
TITLE Exporting keygen (%RELEASE%) in checkout\library...
svn export %SVN_URL%/%RELEASE%/Src/library/keygen keygen
ECHO Exporting preferences (%RELEASE%) in checkout\library...
TITLE Exporting preferences (%RELEASE%) in checkout\library...
svn export %SVN_ORIGO_URL%/%RELEASE%/Src/library/preferences preferences
ECHO Exporting editor (%RELEASE%) in checkout\library...
TITLE Exporting editor (%RELEASE%) in checkout\library...
svn export %SVN_ORIGO_URL%/%RELEASE%/Src/library/editor editor
ECHO Exporting pattern (%RELEASE%) in checkout\library...
TITLE Exporting pattern (%RELEASE%) in checkout\library...
svn export %SVN_ORIGO_URL%/%RELEASE%/Src/library/patterns patterns
CD ..
REM in checkout

MKDIR dotnet
CD dotnet
REM in checkout\dotnet
ECHO Exporting consumer (%CODEDOM_RELEASE%) in checkout\dotnet...
TITLE Exporting consumer (%CODEDOM_RELEASE%) in checkout\dotnet...
svn export %SVN_ORIGO_URL%/%CODEDOM_RELEASE%/Src/dotnet/consumer consumer
ECHO Exporting helpers (%COMPILER_RELEASE%) in checkout\dotnet...
TITLE Exporting helpers (%COMPILER_RELEASE%) in checkout\dotnet...
svn export %SVN_ORIGO_URL%/%COMPILER_RELEASE%/Src/dotnet/helpers helpers
ECHO Exporting eac_browser (%RELEASE%) in checkout\dotnet...
TITLE Exporting eac_browser (%RELEASE%) in checkout\dotnet...
svn export %SVN_ORIGO_URL%/%RELEASE%/Src/dotnet/eac_browser eac_browser
ECHO Exporting codedom_provider (%CODEDOM_RELEASE%) in checkout\dotnet...
TITLE Exporting codedom_provider (%CODEDOM_RELEASE%) in checkout\dotnet...
svn export %SVN_ORIGO_URL%/%CODEDOM_RELEASE%/Src/dotnet/codedom_provider_2.0 codedom_provider_2.0

CD ..\
REM in checkout
MKDIR docs
CD docs
REM in checkout\docs
ECHO Exporting xmldoc (%CODEDOM_RELEASE%) in checkout\docs...
TITLE Exporting xmldoc (%CODEDOM_RELEASE%) in checkout\docs...
svn export %SVN_ORIGO_URL%/%RELEASE%/Delivery/xmldoc xmldoc

CD ..\..