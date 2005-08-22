;NSIS Watir Installer for watir version 1.4.1
;Uses Modern UI
;Written by Kingsley Hendrickse @ thoughtworks.com
; 20/08/2005

;--------------------------------
;Include Modern UI

  !include "MUI.nsh"

;--------------------------------
;General

  ;Name and file
  Name "Watir 1.4.1"
  OutFile "watir_installer.exe"
  !define MUI_PRODUCT "Watir 1.4.1"

  ;Default installation folder
  InstallDir "$PROGRAMFILES\Watir"
  
  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\Watir" ""

; TrimNewlines
 ; input, top of stack  (e.g. whatever$\r$\n)
 ; output, top of stack (replaces, with e.g. whatever)
 ; modifies no other variables.

 Function un.TrimNewlines
   Exch $R0
   Push $R1
   Push $R2
   StrCpy $R1 0
 
 loop:
   IntOp $R1 $R1 - 1
   StrCpy $R2 $R0 1 $R1
   StrCmp $R2 "$\r" loop
   StrCmp $R2 "$\n" loop
   IntOp $R1 $R1 + 1
   IntCmp $R1 0 no_trim_needed
   StrCpy $R0 $R0 $R1
 
 no_trim_needed:
   Pop $R2
   Pop $R1
   Exch $R0
 FunctionEnd

;--------------------------------
;Interface Configuration

  !define MUI_WELCOMEFINISHPAGE_BITMAP "welcome.bmp"
  !define MUI_WELCOMEPAGE_TITLE "Welcome to the ${MUI_PRODUCT} Install Wizard"
  !define MUI_WELCOMEPAGE_TEXT "This wizard will guide you through the installation of ${MUI_PRODUCT} \n\n It is recommended that you close all other applications before running Setup. This will make it possible to update relevant system files without having to reboot your computer.\n\nClick Next to continue"
  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP "watir.bmp" 
  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "License.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  
;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Installer Sections

Section "${MUI_PRODUCT}" SecWatir
SectionIn RO
 ;Register AutoIt DLL
 Exec 'regsvr32.exe /s "..\watir\AutoItX3.dll"'
 
ReadEnvStr "$1" "TEMP"

; complicated line that creates a ruby_env.txt file in Temp
ExecWait 'rubyw -e "File.open(\"#{ENV[\"Temp\"]}/ruby_env.txt\", \"w\"){|f| f.puts Config::CONFIG[\"sitelibdir\"].gsub(%{/}, %{\\}) }"'
FileOpen $R0 "$1\ruby_env.txt" "r"
FileRead $R0 $0
FileClose $R0  

; delete file from temp dir
Delete "$1\ruby_env.txt"

 ;Write location to detail window
 DetailPrint "Library installation path $0"

 ;Install watir libraries
   SetOutPath "$0"
  File "..\watir.rb"
  SetOutPath "$0\watir"
  File "..\watir\*"

;Create uninstaller
 
 SetOutPath "$INSTDIR"
 
 ;Store installation folder
  WriteRegStr HKCU "Software\Watir" "" $INSTDIR
  
  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  
SectionEnd

SectionGroup "Documentation" 

 Section "Watir Documentation" SecDocumentation
  ;Documentation files
  SetOutPath "$INSTDIR\doc"
  File "..\doc\*"
  File /r "..\doc\rdoc"
  SetOutPath "$INSTDIR\doc\images"
  File "..\doc\images\*"
  SectionEnd
  
  Section "Desktop shortcuts" SecDocDeskShortcuts
  ;create desktop shortcut
  SetOutPath "$INSTDIR\doc"
  CreateShortCut "$DESKTOP\Watir Documentation.lnk" "$INSTDIR\doc\index.html" ""
  CreateShortCut "$DESKTOP\Watir User Guide.lnk" "$INSTDIR\doc\watir_user_guide.html" ""
  SetOutPath "$INSTDIR\doc\rdoc"
  CreateShortCut "$DESKTOP\Watir API Reference.lnk" "$INSTDIR\doc\rdoc\index.html" ""
  SectionEnd
  
  Section "Menu shortcuts" SecDocMenuShortcuts
  ;create menu shortcuts
  CreateDirectory "$SMPROGRAMS\Watir"
  SetOutPath "$INSTDIR\doc"
  CreateShortCut "$SMPROGRAMS\Watir\Watir Documentation.lnk" "$INSTDIR\doc\index.html" 0
  CreateShortCut "$SMPROGRAMS\Watir\Watir User Guide.lnk" "$INSTDIR\doc\watir_user_guide.html" 0
  SetOutPath "$INSTDIR\doc\rdoc"
  CreateShortCut "$SMPROGRAMS\Watir\Watir API Reference.lnk" "$INSTDIR\doc\rdoc\index.html" 0
  SetOutPath "$INSTDIR"
  CreateShortCut "$SMPROGRAMS\Watir\Uninstall.lnk" "$INSTDIR\Uninstall.exe" "" "$INSTDIR\Uninstall.exe" 0
 SectionEnd
 
 
 
SectionGroupEnd

SectionGroup "Examples" 

Section "Examples" SecExamples

  SetOutPath "$INSTDIR\examples"
  
  ;Examples Files
   File "..\examples\*"
   SetOutPath "$INSTDIR\examples\logging"
   File "..\examples\logging\*"
 
SectionEnd

Section "Desktop shortcuts" SecExDeskShortcuts
  ;create desktop shortcut
  SetOutPath "$INSTDIR\examples"
  CreateShortCut "$DESKTOP\Watir Examples.lnk" "$INSTDIR\examples" "" "$WINDIR\System32\SHELL32.dll" 3
  SectionEnd
  
  Section "Menu shortcuts" SecExMenuShortcuts
  ;create menu shortcuts
  CreateDirectory "$SMPROGRAMS\Watir"  
  SetOutPath "$INSTDIR\examples"
  CreateShortCut "$SMPROGRAMS\Watir\Watir Examples.lnk" "$INSTDIR\examples" "" "$WINDIR\System32\SHELL32.dll" 3
  SetOutPath "$INSTDIR"
  CreateShortCut "$SMPROGRAMS\Watir\Uninstall.lnk" "$INSTDIR\Uninstall.exe" "" "$INSTDIR\Uninstall.exe" 0
 SectionEnd

SectionGroupEnd

Section "UnitTests" SecUnitTests

  SetOutPath "$INSTDIR\unittests"
  
  ;UnitTests Files
   File "..\unittests\*"
   SetOutPath "$INSTDIR\unittests\html"
   File "..\unittests\html\*"
 
SectionEnd

;--------------------------------
;Descriptions

  ;Language strings
  LangString DESC_SecWatir ${LANG_ENGLISH} "${MUI_PRODUCT} is required and it installs the watir library files into your local ruby installation"
  LangString DESC_SecDocumentation ${LANG_ENGLISH} "This installs the documentation for ${MUI_PRODUCT} into your chosen location"
  LangString DESC_SecExamples ${LANG_ENGLISH} "This installs the examples for ${MUI_PRODUCT} into you chosen location"
  LangString DESC_SecUnitTests ${LANG_ENGLISH} "This installs the unit tests for ${MUI_PRODUCT} into your chosen location"
  LangString DESC_SecDocDeskShortcuts ${LANG_ENGLISH} "This installs desktop shortcuts for ${MUI_PRODUCT} documentation"
  LangString DESC_SecDocMenuShortcuts ${LANG_ENGLISH} "This installs Start menu shortcuts for ${MUI_PRODUCT} documentation"
  LangString DESC_SecExDeskShortcuts ${LANG_ENGLISH} "This installs desktop shortcuts for ${MUI_PRODUCT} examples"
  LangString DESC_SecExMenuShortcuts ${LANG_ENGLISH} "This installs Start menu shortcuts for ${MUI_PRODUCT} examples"
  
  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecWatir} $(DESC_SecWatir)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDocumentation} $(DESC_SecDocumentation)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDocDeskShortcuts} $(DESC_SecDocDeskShortcuts)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDocMenuShortcuts} $(DESC_SecDocMenuShortcuts)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecExDeskShortcuts} $(DESC_SecExDeskShortcuts)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecExMenuShortcuts} $(DESC_SecExMenuShortcuts)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecExamples} $(DESC_SecExamples)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecUnitTests} $(DESC_SecUnitTests)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END
 
;--------------------------------
;Uninstaller Section

Section "Uninstall"

   ;Delete Files 
  RMDir /r "$INSTDIR\*.*"  
  
;Remove the installation directory
  RMDir "$INSTDIR"
  
;Delete Desktop and Start Menu Shortcuts
Delete "$DESKTOP\Watir Documentation.lnk"
Delete "$DESKTOP\Watir User Guide.lnk"
Delete "$DESKTOP\Watir API Reference.lnk"
Delete "$DESKTOP\Watir Examples.lnk"
Delete "$SMPROGRAMS\Watir\*.*"
RmDir "$SMPROGRAMS\Watir"
 
  ;Unregister AutoIt DLL
   Exec 'regsvr32.exe /s /u "..\watir\AutoItX3.dll"'

  Delete "$INSTDIR\Uninstall.exe"

  RMDir "$INSTDIR"
  
  ReadEnvStr "$1" "TEMP"

; complicated line that creates a ruby_env.txt file in Temp
ExecWait 'rubyw -e "File.open(\"#{ENV[\"Temp\"]}/ruby_env.txt\", \"w\"){|f| f.puts Config::CONFIG[\"sitelibdir\"].gsub(%{/}, %{\\}) }"'
FileOpen $R0 "$1\ruby_env.txt" "r"
FileRead $R0 $0
FileClose $R0  

; delete file from temp dir
Delete "$1\ruby_env.txt"

; trim the filepath so it can be used to delete the watir libs
  Push $0
    Call un.TrimNewLines
   Pop $0

 ;Write location to detail window
 DetailPrint "Library deletion path $0"

Delete "$0\watir.rb"
RMDir /r "$0\watir\*.*" 
  
 DeleteRegKey /ifempty HKCU "Software\Watir"

SectionEnd