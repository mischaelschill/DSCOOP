@echo off
echo

mkdir bin

echo *************************************
echo *    Generating `ISE.Reflection.Formatter.dll'     *
echo *************************************
echo
cd ISE.Reflection.Emitter
copy ..\..\..\tools\emitter\formatter.cs .
call make_formatter.bat
copy ISE.Reflection.Formatter.dll ..\bin
del formatter.cs
del ISE.Reflection.Formatter.dll
cd ..

echo **********************************************************
echo *    Generating Eiffel class corresponding to `ISE.Reflection.Formatter.dll'     *
echo ********************************************************** 
echo
..\..\tools\emitter\emitter.exe /t .\bin\ISE.Reflection.Formatter.dll /d .\generated\formatter_generated

set PATH=%PATH%;%ISE_EIFFEL%\bench\spec\windows\bin

echo ******************************************
echo *    Generating `ISE.Reflection.EiffelComponents.dll'     *
echo ******************************************
echo
cd ISE.Reflection.EiffelComponents
cd ace_file
ec -ace ace.ace -batch 
copy .\ISE.Reflection.EiffelComponents.dll ..\..\bin

cd ..
cd ..

echo ***************************************************************
echo *    Emitting Eiffel classes corresponding to `ISE.Reflection.EiffelComponents.dll'     *
echo ***************************************************************
echo
..\..\tools\emitter\emitter.exe /t .\bin\ISE.Reflection.EiffelComponents.dll /d .\generated\eiffel_components_generated
del .\generated\eiffel_components_generated\tuple.e

echo **************************************************
echo *    Generating `ISE.Reflection.EiffelAssemblyCacheNotifier.dll'     *
echo **************************************************
echo
cd ISE.Reflection.EiffelAssemblyCacheNotifier
cd ace_file
ec -ace ace.ace -batch 
copy .\ISE.Reflection.EiffelAssemblyCacheNotifier.dll ..\..\bin

cd ..
cd ..

echo **********************************************************************
echo *    Emitting Eiffel classes corresponding to `ISE.Reflection.EiffelAssemblyCacheNotifier.dll'    *
echo **********************************************************************
echo
copy .\bin\ISE.Reflection.EiffelComponents.dll ..\..\tools\emitter
..\..\tools\emitter\emitter.exe /t .\bin\ISE.Reflection.EiffelAssemblyCacheNotifier.dll /d .\generated\notifier_generated

echo **************************************************
echo *    Generating `ISE.Reflection.Support.dll'     *
echo **************************************************
echo
cd ISE.Reflection.Support
cd ace_file
ec -ace ace.ace -batch 
copy .\ISE.Reflection.Support.dll ..\..\bin

cd ..
cd ..

echo **********************************************************************
echo *    Emitting Eiffel classes corresponding to `ISE.Reflection.Support.dll'    *
echo **********************************************************************
echo
copy bin\ISE.Reflection.Formatter.dll ..\..\tools\emitter
..\..\tools\emitter\emitter.exe /t .\bin\ISE.Reflection.Support.dll /d .\generated\support_generated

echo **************************************************
echo *    Generating `ISE.Reflection.EiffelAssemblyCacheHandler.dll'     *
echo **************************************************
echo
cd ISE.Reflection.EiffelAssemblyCacheHandler
cd ace_file
ec -ace ace.ace -batch 
copy .\ISE.Reflection.EiffelAssemblyCacheHandler.dll ..\..\bin

cd ..
cd ..

echo **********************************************************************
echo *    Emitting Eiffel classes corresponding to `ISE.Reflection.EiffelAssemblyCacheHandler.dll'    *
echo **********************************************************************
echo
copy .\bin\ISE.Reflection.Support.dll ..\..\tools\emitter
copy .\bin\ISE.Reflection.EiffelAssemblyCacheNotifier.dll ..\..\tools\emitter
..\..\tools\emitter\emitter.exe /t .\bin\ISE.Reflection.EiffelAssemblyCacheHandler.dll /d .\generated\eiffel_assembly_cache_generated

echo **************************************************
echo *    Generating `ISE.Reflection.CodeGenerator.dll'     *
echo **************************************************
echo
cd ISE.Reflection.CodeGenerator
cd ace_file
ec -ace ace.ace -batch 
copy .\ISE.Reflection.CodeGenerator.dll ..\..\bin

cd ..
cd ..

echo **********************************************************************
echo *    Emitting Eiffel classes corresponding to `ISE.Reflection.CodeGenerator.dll'    *
echo **********************************************************************
echo
copy .\bin\ISE.Reflection.EiffelAssemblyCacheHandler.dll ..\..\tools\emitter
..\..\tools\emitter\emitter.exe /t .\bin\ISE.Reflection.CodeGenerator.dll /d .\generated\code_generator_generated

echo **************************************************
echo *    Generating `ISE.Reflection.ReflectionInterface.dll'     *
echo **************************************************
echo
cd ISE.Reflection.ReflectionInterface
cd ace_file
ec -ace ace.ace -batch 
copy .\ISE.Reflection.ReflectionInterface.dll ..\..\bin

cd ..
cd ..

echo **********************************************************************
echo *    Emitting Eiffel classes corresponding to `ISE.Reflection.ReflectionInterface.dll'    *
echo **********************************************************************
echo
..\..\tools\emitter\emitter.exe /t .\bin\ISE.Reflection.ReflectionInterface.dll /d .\generated\reflection_interface_generated
del ..\..\tools\emitter\ISE.Reflection.EiffelComponents.dll
del ..\..\tools\emitter\ISE.Reflection.EiffelAssemblyCacheNotifier.dll
del ..\..\tools\emitter\ISE.Reflection.Support.dll
del ..\..\tools\emitter\ISE.Reflection.EiffelAssemblyCacheHandler.dll
del ..\..\tools\emitter\ISE.Reflection.Formatter.dll

echo **************************************************
echo *    Generating `ISE.AssemblyManager.WindowsDirectoryExtractor.dll'     *
echo **************************************************
echo
cd assembly_manager
cd gac_browser
call make.bat
copy ISE.AssemblyManager.WindowsDirectoryExtractor.dll ..\..\bin

echo **************************************************
echo *    Generating `FolderBrowser.dll' and `FolderDialog.dll'     *
echo **************************************************
echo
cd ..
cd folder_dialog
cd Core
call build.bat
copy FolderBrowser.dll ..\..\..\bin
copy FolderDialog.dll ..\..\..\bin

cd ..
cd Clib
call make_finalize.bat
cd ..

echo **************************************************
echo *    Generating `folder_browser.dll'     *
echo **************************************************
echo
ec -ace Ace.ace -batch -finalize
cd EIFGEN
cd F_code
finish_freezing
copy .\folder_browser.dll ..\..\..\..\bin

cd ..
cd ..
cd ..
cd ..

echo **************************************************
echo *    Generating `ISE.Reflection.Emitter.exe'     *
echo **************************************************
echo
cd ISE.Reflection.Emitter
copy ..\..\..\tools\emitter\argparser.cs .
copy ..\..\..\tools\emitter\eiffelclassfactory.cs .
copy ..\..\..\tools\emitter\eiffelcreationroutine.cs .
copy ..\..\..\tools\emitter\eiffelmethodfactory.cs .
copy ..\..\..\tools\emitter\formatter.cs .
copy ..\..\..\tools\emitter\globals.cs .
copy ..\..\..\tools\emitter\newemitter.cs .
copy ..\..\..\tools\emitter\newemittermain.cs .
copy ..\..\..\tools\emitter\redefineclauses.cs .
copy ..\..\..\tools\emitter\renameclauses.cs .
copy ..\..\..\tools\emitter\selectclauses.cs .
copy ..\..\..\tools\emitter\undefineclauses.cs .

call make.bat
copy ISE.Reflection.Emitter.exe ..\bin

del argparser.cs
del eiffelclassfactory.cs
del eiffelcreationroutine.cs
del eiffelmethodfactory.cs
del formatter.cs
del globals.cs
del newemitter.cs
del newemittermain.cs
del redefineclauses.cs
del renameclauses.cs
del selectclauses.cs
del undefineclauses.cs

cd ..

echo **************************************************
echo *    Generating `ISE.AssemblyManager.exe'     *
echo **************************************************
echo
cd assembly_manager
cd ace_file
ec -ace ace.ace -batch 
copy ISE.AssemblyManager.exe .\..\dotnet\reflection_interface\bin
copy ..\..\bin\ISE.Reflection.Formatter.dll .
copy ..\..\bin\ISE.Reflection.EiffelComponents.dll .
copy ..\..\bin\ISE.Reflection.EiffelAssemblyCacheNotifier.dll .
copy ..\..\bin\ISE.Reflection.Support.dll .
copy ..\..\bin\ISE.Reflection.EiffelAssemblyCacheHandler.dll .
copy ..\..\bin\ISE.Reflection.CodeGenerator.dll .
copy ..\..\bin\ISE.Reflection.ReflectionInterface.dll .
copy ..\..\bin\ISE.AssemblyManager.WindowsDirectoryExtractor.dll .
copy ..\..\bin\FolderBrowser.dll .
copy ..\..\bin\FolderDialog.dll .
copy ..\..\bin\folder_browser.dll .
copy ..\..\bin\ISE.Reflection.Emitter.exe .

regsvr32 folder_browser.dll

