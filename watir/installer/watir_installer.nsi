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
ExecWait 'ruby -e "File.open(\"#{ENV[\"Temp\"]}/ruby_env.txt\", \"w\"){|f| f.puts Config::CONFIG[\"sitelibdir\"].gsub(%{/}, %{\\}) }"'
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
  
  Section "Desktop shortcuts" SecDeskShortcuts
  ;create desktop shortcut
  CreateShortCut "$DESKTOP\Watir Documentation.lnk" "$INSTDIR\doc\index.html" ""
  CreateShortCut "$DESKTOP\Watir User Guide.lnk" "$INSTDIR\doc\watir_user_guide.html" ""
  CreateShortCut "$DESKTOP\Watir API Reference.lnk" "$INSTDIR\doc\rdoc\index.html" ""
  SectionEnd
  
  Section "Menu shortcuts" SecMenuShortcuts
  ;create menu shortcuts
  CreateDirectory "$SMPROGRAMS\Watir"
  CreateShortCut "$SMPROGRAMS\Watir\Watir Documentation.lnk" "$INSTDIR\doc\index.html" 0
  CreateShortCut "$SMPROGRAMS\Watir\Watir User Guide.lnk" "$INSTDIR\doc\watir_user_guide.html" 0
  CreateShortCut "$SMPROGRAMS\Watir\Watir API Reference.lnk" "$INSTDIR\doc\rdoc\index.html" 0
  CreateShortCut "$SMPROGRAMS\Watir\Uninstall.lnk" "$INSTDIR\Uninstall.exe" "" "$INSTDIR\Uninstall.exe" 0
 SectionEnd
 
 
 
SectionGroupEnd

;SectionGroup "some stuff"
;Section "a section"
;SectionEnd
;Section "another section"
;SectionEnd
;SectionGroupEnd

Section "Examples" SecExamples

  SetOutPath "$INSTDIR\examples"
  
  ;Examples Files
   File "..\examples\*"
   SetOutPath "$INSTDIR\examples\logging"
   File "..\examples\logging\*"
 
SectionEnd

Section "UnitTests" SecUnitTests

  SetOutPath "$INSTDIR\UnitTests"
  
  ;UnitTests Files
   File "..\unittests\*"
   SetOutPath "$INSTDIR\UnitTests\html"
   File "..\unittests\html\*"
 
SectionEnd

;--------------------------------
;Descriptions

  ;Language strings
  LangString DESC_SecWatir ${LANG_ENGLISH} "${MUI_PRODUCT} is required and it installs the watir library files into your local ruby installation"
  LangString DESC_SecDocumentation ${LANG_ENGLISH} "This installs the documentation for ${MUI_PRODUCT} into your chosen location"
  LangString DESC_SecExamples ${LANG_ENGLISH} "This installs the examples for ${MUI_PRODUCT} into you chosen location"
  LangString DESC_SecUnitTests ${LANG_ENGLISH} "This installs the unit tests for ${MUI_PRODUCT} into your chosen location"
  LangString DESC_SecDeskShortcuts ${LANG_ENGLISH} "This installs desktop shortcuts for ${MUI_PRODUCT}"
  LangString DESC_SecMenuShortcuts ${LANG_ENGLISH} "This installs Start menu shortcuts for ${MUI_PRODUCT}"
  
  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecWatir} $(DESC_SecWatir)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDocumentation} $(DESC_SecDocumentation)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDeskShortcuts} $(DESC_SecDeskShortcuts)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecMenuShortcuts} $(DESC_SecMenuShortcuts)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecExamples} $(DESC_SecExamples)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecUnitTests} $(DESC_SecUnitTests)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END
 
;--------------------------------
;Uninstaller Section

Section "Uninstall"

  ;ADD YOUR OWN FILES HERE...
  
  ;Delete Files 
  RMDir /r "$INSTDIR\*.*"    
 
;Remove the installation directory
  RMDir "$INSTDIR"
  
;Delete Desktop and Start Menu Shortcuts
Delete "$DESKTOP\Watir Documentation.lnk"
Delete "$DESKTOP\Watir User Guide.lnk"
Delete "$DESKTOP\Watir API Reference.lnk"
Delete "$SMPROGRAMS\Watir\*.*"
RmDir "$SMPROGRAMS\Watir"
 
  
  ;Unregister AutoIt DLL
   Exec 'regsvr32.exe /s /u "..\watir\AutoItX3.dll"'

  Delete "$INSTDIR\Uninstall.exe"

  RMDir "$INSTDIR"

  DeleteRegKey /ifempty HKCU "Software\Watir"

SectionEnd