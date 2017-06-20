; hifi_light.nsi
; A light installer for High Fidelity, an open-source platform for virtual reality and beyond.
;
; 1. If needed, install High Fidelity Interface
; 2. If needed, add custom, pre-defined content to user's filesystem
; 3. Launch Interface with command-line arguments
;
; Compilation Requirements:
;   - http://nsis.sourceforge.net/NsProcess_plugin
;
; -------------------------------------------------------------------------------------------------


;--------------------------------
; START Includes
;--------------------------------
    !include "MUI2.nsh" ; Modern UI
    !include "nsProcess.nsh"
    !include "LogicLib.nsh"
;--------------------------------
; END Includes
;--------------------------------

;--------------------------------
; START Macros
;--------------------------------
    ;--------------------------------
    ; START String Replace Macro
    ; Taken from http://nsis.sourceforge.net/StrRep
    ;--------------------------------
    !define StrRep "!insertmacro StrRep"
    !macro StrRep output string old new
        Push `${string}`
        Push `${old}`
        Push `${new}`
        !ifdef __UNINSTALL__
            Call un.StrRep
        !else
            Call StrRep
        !endif
        Pop ${output}
    !macroend
     
    !macro Func_StrRep un
        Function ${un}StrRep
            Exch $R2 ;new
            Exch 1
            Exch $R1 ;old
            Exch 2
            Exch $R0 ;string
            Push $R3
            Push $R4
            Push $R5
            Push $R6
            Push $R7
            Push $R8
            Push $R9
     
            StrCpy $R3 0
            StrLen $R4 $R1
            StrLen $R6 $R0
            StrLen $R9 $R2
            loop:
                StrCpy $R5 $R0 $R4 $R3
                StrCmp $R5 $R1 found
                StrCmp $R3 $R6 done
                IntOp $R3 $R3 + 1 ;move offset by 1 to check the next character
                Goto loop
            found:
                StrCpy $R5 $R0 $R3
                IntOp $R8 $R3 + $R4
                StrCpy $R7 $R0 "" $R8
                StrCpy $R0 $R5$R2$R7
                StrLen $R6 $R0
                IntOp $R3 $R3 + $R9 ;move offset by length of the replacement string
                Goto loop
            done:
     
            Pop $R9
            Pop $R8
            Pop $R7
            Pop $R6
            Pop $R5
            Pop $R4
            Pop $R3
            Push $R0
            Push $R1
            Pop $R0
            Pop $R1
            Pop $R0
            Pop $R2
            Exch $R1
        FunctionEnd
    !macroend
    !insertmacro Func_StrRep ""
    !insertmacro Func_StrRep "un."
    ;--------------------------------
    ; END String Replace Macro
    ;--------------------------------
    
    ;--------------------------------
    ; START String Contains Macro
    ; Taken from http://nsis.sourceforge.net/StrContains
    ;--------------------------------
    ; StrContains
    ; This function does a case sensitive searches for an occurrence of a substring in a string. 
    ; It returns the substring if it is found. 
    ; Otherwise it returns null(""). 
    ; Written by kenglish_hi
    ; Adapted from StrReplace written by dandaman32
     
     
    Var STR_HAYSTACK
    Var STR_NEEDLE
    Var STR_CONTAINS_VAR_1
    Var STR_CONTAINS_VAR_2
    Var STR_CONTAINS_VAR_3
    Var STR_CONTAINS_VAR_4
    Var STR_RETURN_VAR
     
    Function StrContains
      Exch $STR_NEEDLE
      Exch 1
      Exch $STR_HAYSTACK
      ; Uncomment to debug
      ;MessageBox MB_OK 'STR_NEEDLE = $STR_NEEDLE STR_HAYSTACK = $STR_HAYSTACK '
        StrCpy $STR_RETURN_VAR ""
        StrCpy $STR_CONTAINS_VAR_1 -1
        StrLen $STR_CONTAINS_VAR_2 $STR_NEEDLE
        StrLen $STR_CONTAINS_VAR_4 $STR_HAYSTACK
        loop:
          IntOp $STR_CONTAINS_VAR_1 $STR_CONTAINS_VAR_1 + 1
          StrCpy $STR_CONTAINS_VAR_3 $STR_HAYSTACK $STR_CONTAINS_VAR_2 $STR_CONTAINS_VAR_1
          StrCmp $STR_CONTAINS_VAR_3 $STR_NEEDLE found
          StrCmp $STR_CONTAINS_VAR_1 $STR_CONTAINS_VAR_4 done
          Goto loop
        found:
          StrCpy $STR_RETURN_VAR $STR_NEEDLE
          Goto done
        done:
       Pop $STR_NEEDLE ;Prevent "invalid opcode" errors and keep the
       Exch $STR_RETURN_VAR  
    FunctionEnd
     
    !macro _StrContainsConstructor OUT NEEDLE HAYSTACK
      Push `${HAYSTACK}`
      Push `${NEEDLE}`
      Call StrContains
      Pop `${OUT}`
    !macroend
     
    !define StrContains '!insertmacro "_StrContainsConstructor"'
    ;--------------------------------
    ; END String Contains Macro
    ;--------------------------------

    ;--------------------------------
    ; START Prompt to Kill Running Application Macro
    ; Taken from High Fidelity's NSIS.template.in
    ;--------------------------------
    !macro PromptForRunningApplication applicationName displayName
      !define UniqueID ${__LINE__}

      Prompt_${UniqueID}:

        ${nsProcess::FindProcess} ${applicationName} $R0

        ${If} $R0 == 0

            ; the process is running, ask the user to close it
            MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION \
            "The installation process cannot continue while ${displayName} is running.$\r$\nPress Retry to automatically end the process and continue." \
            /SD IDCANCEL IDRETRY +1 IDCANCEL 0
            
            Abort ; If the user decided to cancel, stop the current installer/uninstaller
            
            ${nsProcess::KillProcess} ${applicationName} $R1
            
            ${If} $R1 == 0
                Goto Prompt_${UniqueID}
            ${Else}
                MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION \
                "${displayName} couldn't be automatically closed.$\r$\nPlease close it manually, then press Retry to continue." \
                /SD IDCANCEL IDRETRY Prompt_${UniqueID} IDCANCEL 0
                
                Abort  ; If the user decided to cancel, stop the current installer/uninstaller
            ${EndIf}
            
        ${Else}
            ;MessageBox MB_OK "${displayName} is not running."
        ${EndIf}

      !undef UniqueID
    !macroend
    ;--------------------------------
    ; END Prompt to Kill Running Application Macro
    ;--------------------------------

    ;--------------------------------
    ; START Check for Running Applications Macro
    ; Taken from High Fidelity's NSIS.template.in
    ;--------------------------------
    !macro CheckForRunningApplications
      !insertmacro PromptForRunningApplication "interface.exe" "Interface"
      !insertmacro PromptForRunningApplication "server-console.exe" "High Fidelity Server Console"
      !insertmacro PromptForRunningApplication "domain-server.exe" "High Fidelity Domain Server"
      !insertmacro PromptForRunningApplication "assignment-client.exe" "High Fidelity Assignment Client"
    !macroend
    ;--------------------------------
    ; END Check for Running Applications Macro
    ;--------------------------------

;--------------------------------
; END Macros
;--------------------------------

;--------------------------------
; START General
;--------------------------------
    ; Installer application name
    Name "High Fidelity Express"

    ; Installer filename
    OutFile "HiFi_Express.exe"

    ; Default installation folder
    InstallDir "$PROGRAMFILES64\High Fidelity"

    ; Request Administrator privileges for Windows Vista and higher
    RequestExecutionLevel admin
;--------------------------------
; END General
;--------------------------------

;--------------------------------
; START Installer Pages
;--------------------------------
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_INSTFILES
;--------------------------------
; END Installer Sections
;--------------------------------

;--------------------------------
; START Installer Sections
;--------------------------------    
    Section "Interface" Interface
        Call MakeSureHiFiInstalled
    SectionEnd
    
    Section "Custom Content" CustomContent
            Call EventSpecificContent
    SectionEnd
;--------------------------------
; END Installer Sections
;--------------------------------
  
;--------------------------------
; START Step 1:
; If needed, install High Fidelity Interface
;--------------------------------
    Function MakeSureHiFiInstalled
        ; Try getting the location of Interface.exe by checking
        ;     the path associated with 'hifi://' URLs
        ReadRegStr $0 HKCR "hifi\DefaultIcon" ""
        ${StrRep} '$0' '$0' ',1' ''
        ${If} $0 != ""
            ; Make sure the file actually exists in the filesystem
            IfFileExists $0 interface_found interface_not_found
            
            interface_found: ; We might not need to (download and install) High Fidelity Interface
                ;MessageBox MB_OK "High Fidelity .exe was found at: $0"
                ; 1: Make sure that no High Fidelity application is already running
                !insertmacro CheckForRunningApplications
                ; 2: Run Interface.exe with --protocolVersion argument.
                ExecWait '"$0" --version $TEMP\version.txt'
                FileOpen $4 "$TEMP\version.txt" r
                FileRead $4 $1 ; Read the Interface version from the file into $1
                FileClose $4
                ${If} $1 == "PR10758"
                    ;MessageBox MB_OK "$0 Interface Version $1 is correct!"
                ${Else}
                    ${StrContains} $3 "steamapps" $0 ; Double-check Interface.exe isn't a Steam version by checking the EXE path
                    StrCmp $3 "" not_installed_from_steam
                        Goto installed_from_steam
                        not_installed_from_steam:
                            ;MessageBox MB_OK "$0 Installation Portal is NOT STEAM. Interface Version $1 is incorrect."
                                Goto interface_not_found
                    installed_from_steam:
                        ;MessageBox MB_OK "$0 Installation Portal is STEAM. Steam will update High Fidelity the next time it starts."
                ${EndIf}
        ${Else}
            interface_not_found: ; We need to (download and install) High Fidelity Interface
                MessageBox MB_OKCANCEL "High Fidelity needs to be downloaded and installed." IDOK continue_download IDABORT abort_download
                abort_download:
                    ;MessageBox MB_OK "Aborting download."
                    Goto finish
                continue_download:
                    StrCpy $4 "$TEMP\hifi_installer.exe"
                    NSISdl::download https://deployment.highfidelity.com/jobs/pr-build/label%3Dwindows/919/HighFidelity-Beta-PR10758-41003bd3079d1309b17134950f6c94922c8b4520.exe $4
                    Pop $R0 ; Get the download process return value
                    StrCmp $R0 "success" +3
                        MessageBox MB_OK "Download failed with status: $R0"
                        Goto finish
                    ExecWait '"$4"'
        ${EndIf}
        finish: 
            ${nsProcess::Unload}
    FunctionEnd
;--------------------------------
; END Step 1
;--------------------------------
  
;--------------------------------
; START Step 2:
; If needed, add custom, pre-defined content to user's filesystem
;--------------------------------
    Function EventSpecificContent
        StrCpy $0 "CONTENT_ID_GOES_HERE"
        IfFileExists "$AppData\Local\High Fidelity\$0\*.*" content_found content_not_found
        content_found:
            ;MessageBox MB_OK "Custom content found!"
            Goto EventSpecificContent_finish
        content_not_found:
            ;MessageBox MB_OK "Custom content NOT found!"
            Goto EventSpecificContent_finish
        EventSpecificContent_finish:
            Call LaunchInterface
    FunctionEnd
;--------------------------------
; END Step 2
;--------------------------------
  
;--------------------------------
; START Step 3:
; Launch Interface with command-line arguments
;--------------------------------
    Function LaunchInterface
        ReadRegStr $0 HKCR "hifi\DefaultIcon" ""
        ${StrRep} '$0' '$0' ',1' ''
        Exec '"$0" --url hifi://zaru'
        Quit
    FunctionEnd
;--------------------------------
; END Step 3
;--------------------------------
