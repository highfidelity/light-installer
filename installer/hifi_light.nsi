; hifi_light.nsi
; A light installer for High Fidelity, an open-source platform for virtual reality and beyond.
;
; 1. If needed, install High Fidelity Interface
; 2. If needed, add custom, pre-defined content to user's filesystem
; 3. Launch Interface with command-line arguments
;
; Compilation Requirements:
;   - http://nsis.sourceforge.net/NsProcess_plugin
;   - http://nsis.sourceforge.net/ThreadTimer_plug-in
;
; -------------------------------------------------------------------------------------------------


;--------------------------------
; START Includes
;--------------------------------
    !include "MUI2.nsh" ; Modern UI
    !include "nsProcess.nsh"
    !include "LogicLib.nsh"
    !include "nsDialogs.nsh"
    !include "WinMessages.nsh"
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
        Call StrRep
        Pop ${output}
    !macroend
     
    !macro Func_StrRep
        Function StrRep
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
    !insertmacro Func_StrRep
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
            /SD IDCANCEL IDRETRY +2 IDCANCEL 0
            Abort ; If the user decided to cancel, stop the current installer
            
            ${nsProcess::KillProcess} ${applicationName} $R1
            Sleep 1000
            
            ${If} $R1 == 0
                Goto Prompt_${UniqueID}
            ${Else}
                MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION \
                "${displayName} couldn't be automatically closed.$\r$\nPlease close it manually, then press Retry to continue." \
                /SD IDCANCEL IDRETRY Prompt_${UniqueID} IDCANCEL 0
                
                Abort  ; If the user decided to cancel, stop the current installer
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
    Name "High Fidelity Jaws Event"

    ; Installer filename
    OutFile "High_Fidelity_Jaws_Event.exe"

    !define MUI_ICON "icons\interface.ico"
    !define MUI_HEADERIMAGE
    !define MUI_HEADERIMAGE_BITMAP "icons\installer-header.bmp"
    !define HIFI_PROTOCOL_VERSION "wZvQKLWfxkPibrBrFztVYA=="
    ;;!define HIFI_MAIN_INSTALLER_URL "http://builds.highfidelity.com/HighFidelity-Beta-6765.exe"
    ;;!define HIFI_MAIN_INSTALLER_URL "https://deployment.highfidelity.com/jobs/pr-build/label%3Dwindows/1042/HighFidelity-Beta-PR10794-e5666fbb2f9e0e7fa403cb3eafc74a386e253597.exe"
    ; Small test exe for testing.
    !define HIFI_MAIN_INSTALLER_URL "https://s3-us-west-1.amazonaws.com/hifi-content/zfox/Personal/test.exe"
    ;; If the above is any release or dev-download build, the following should be an empty string.
    ;; However, if you need to use a PR build during development:
    ;;  1. let this be "High Fidleity - PRxxxxx" (with whatever actual number), and
    ;;  2. make sure that some older NON-PR build is already installed (such as an older release). This puts an entry in the registry so we don't fail when checking.
    ;;  3. If steam is the latest, or if the old installation has a non-default install pathname, you're screwed.
    !define PR_BUILD_DIRECTORY ""
    !define EVENT_LOCATION "hifi://dev-playa/event"

    ; Request Administrator privileges for Windows Vista and higher
    RequestExecutionLevel admin
;--------------------------------
; END General
;--------------------------------

;--------------------------------
; START Installer Pages
;--------------------------------
!insertmacro MUI_PAGE_INSTFILES
Page custom HiFiInstallingPage
!define MUI_PAGE_CUSTOMFUNCTION_PRE LaunchInterface
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "English"
;--------------------------------
; END Installer Sections
;--------------------------------

;--------------------------------
; START Installer Sections
;--------------------------------    
    Section "Interface" Interface
        Call SetupVars
        Call MakeSureHiFiInstalled
    SectionEnd
;--------------------------------
; END Installer Sections
;--------------------------------
  
;--------------------------------
; START Step 1:
; If needed, install High Fidelity Interface
;--------------------------------
    Function InterfaceTimerExpired
        ${nsProcess::KillProcess} "interface.exe" $R0
    FunctionEnd

    Var InterfacePath
    Var InterfaceVersion
    Var FileHandle
    Var DownloadedFilePath
    Var DownloadedFileName
    Var StrContainsResult
    Var ShouldSkipInstallingPage
    Var HadToInstallInterface
    Var HiFiInstalled
    Function SetupVars
        StrCpy $ShouldSkipInstallingPage "true"
        StrCpy $HadToInstallInterface "false"
        StrCpy $HiFiInstalled "false"
    FunctionEnd
    Function GetInterfacePath
        ; Try getting the location of Interface.exe into InterfacePath by checking
        ;     the path associated with 'hifi://' URLs or its icon
        ReadRegStr $InterfacePath HKCR "hifi\DefaultIcon" ""
        ${StrRep} '$InterfacePath' '$InterfacePath' ',1' ''
        ${IfNot} "${PR_BUILD_DIRECTORY}" == ""
          ${StrRep} '$InterfacePath' '$InterfacePath' 'High Fidelity' "${PR_BUILD_DIRECTORY}"
        ${EndIf}
    FunctionEnd
    Function MakeSureHiFiInstalled
        Call GetInterfacePath
        ${If} $InterfacePath != ""
            ; Make sure the file actually exists in the filesystem
            IfFileExists $InterfacePath interface_found interface_not_found
            
            interface_found: ; We might not need to (download and install) High Fidelity Interface
                ;MessageBox MB_OK "High Fidelity .exe was found at: $InterfacePath"
                ; 1: Make sure that no High Fidelity application is already running
                !insertmacro CheckForRunningApplications
                ; 2: Run Interface.exe with --protocolVersion argument.
                GetFunctionAddress $R0 InterfaceTimerExpired
                ThreadTimer::Start 3000 1 $R0 ; Uses ThreadTimer plugin
                ExecWait '"$InterfacePath" --suppress-settings-reset --protocolVersion $TEMP\version.txt'
                ThreadTimer::Stop
                FileOpen $FileHandle "$TEMP\version.txt" r
                FileRead $FileHandle $InterfaceVersion ; Read the Interface version from the file into $InterfaceVersion
                FileClose $FileHandle
                ${If} $InterfaceVersion == "${HIFI_PROTOCOL_VERSION}"
                    ;MessageBox MB_OK "$InterfacePath Interface Version $InterfaceVersion is correct!"
                    StrCpy $HiFiInstalled "true"
                    ${If} $HadToInstallInterface == "false"
                        ${nsProcess::Unload}
                        Call EventSpecificContent
                    ${EndIf}
                ${Else}
                    ;MessageBox MB_OK "Found protocol $InterfaceVersion does not match expected ${HIFI_PROTOCOL_VERSION}"
                    ${StrContains} $StrContainsResult "steamapps" $InterfacePath ; Double-check Interface.exe isn't a Steam version by checking the EXE path
                    StrCmp $StrContainsResult "" not_installed_from_steam
                        Goto installed_from_steam
                        not_installed_from_steam:
                            ;MessageBox MB_OK "$InterfacePath Installation Portal is NOT STEAM. Interface Version $InterfaceVersion is incorrect."
                                Goto interface_not_found
                    installed_from_steam:
                        MessageBox MB_OK "$InterfacePath Installation Portal is STEAM. Steam will update High Fidelity the next time it starts."
                ${EndIf}
                Delete "$TEMP\version.txt"
        ${Else}
            interface_not_found: ; We need to (download and install) High Fidelity Interface
                ${If} $HadToInstallInterface == "false"
                    ;MessageBox MB_OK "High Fidelity needs to be downloaded and installed. Old path: $InterfacePath. Old protocol: $InterfaceVersion. Expected protocol: ${HIFI_PROTOCOL_VERSION}"
                    StrCpy $DownloadedFileName "hifi_installer.exe"
                    StrCpy $DownloadedFilePath "$TEMP\$DownloadedFileName"
                    NSISdl::download "${HIFI_MAIN_INSTALLER_URL}" $DownloadedFilePath
                    Pop $R0 ; Get the download process return value
                    StrCmp $R0 "success" +3
                        MessageBox MB_OK "Download failed with status: $R0. Press OK to quit this installer."
                        Quit
                    StrCpy $ShouldSkipInstallingPage "false"
                    StrCpy $HadToInstallInterface "true"
                    ;Exec '"$DownloadedFilePath" /nSandboxIfNew /S /forceNoLaunchClient /forceNoLaunchServer'
                    ; Modified command for use when testing with downloaded "test.exe"
                    Exec '"$DownloadedFilePath"'
                ${EndIf}
        ${EndIf}
    FunctionEnd
    
    Var InstallerProcessStatus
    Var Dialog
    Var Label
    Var ProgressBar
    !define PBS_MARQUEE 0x08
    Function CheckInstallComplete
        ${nsProcess::FindProcess} "$DownloadedFileName" $InstallerProcessStatus
        ${If} $InstallerProcessStatus != "0"
            ${NSD_KillTimer} CheckInstallComplete
            
            Call MakeSureHiFiInstalled
            
            ShowWindow $ProgressBar ${SW_HIDE}
            ${NSD_CreateProgressBar} 0 16 100% 10% ""
            Pop $ProgressBar
            ${If} $HiFiInstalled == "false"
                SendMessage $Label ${WM_SETTEXT} "" "STR:High Fidelity failed to install. Please rerun this installer."
                SendMessage $ProgressBar ${PBM_SETPOS} 100 0
                SendMessage $ProgressBar ${PBM_SETSTATE} ${PBST_ERROR} 0
            ${Else}
                SendMessage $Label ${WM_SETTEXT} "" "STR:Downloading content for Project Jaws..."
                Call EventSpecificContent
                SendMessage $ProgressBar ${PBM_SETPOS} 100 0
                SendMessage $Label ${WM_SETTEXT} "" "STR:High Fidelity has finished installing! Press Next to launch."
            ${EndIf}
        ${EndIf}
    FunctionEnd    
    Function HiFiInstallingPage
        ${If} $ShouldSkipInstallingPage == "true"
            Abort
        ${EndIf}
        
        nsDialogs::Create 1018
        Pop $Dialog

        ${If} $Dialog == error
            Abort
        ${EndIf}
        
        ${NSD_CreateLabel} 0 0 100% 14u "High Fidelity is installing in the background..."
        Pop $Label

        ${NSD_CreateProgressBar} 0 16 100% 10% ""
        Pop $ProgressBar
        ${NSD_AddStyle} $ProgressBar ${PBS_MARQUEE}
        SendMessage $ProgressBar ${PBM_SETMARQUEE} 1 50 ; start=1|stop=0 interval(ms)=+N
        
        ${NSD_CreateTimer} CheckInstallComplete 100
        
        nsDialogs::Show
    FunctionEnd
;--------------------------------
; END Step 1
;--------------------------------
  
;--------------------------------
; START Step 2:
; If needed, add custom, pre-defined content to user's filesystem
;--------------------------------
    Var ContentId
    Function EventSpecificContent
        StrCpy $ContentId "CONTENT_ID_GOES_HERE"
        IfFileExists "$AppData\Local\High Fidelity\$ContentId\*.*" content_found content_not_found
        content_found:
            ;MessageBox MB_OK "Custom content found!"
            Goto EventSpecificContent_finish
        content_not_found:
            ;MessageBox MB_OK "Custom content NOT found!"
            Goto EventSpecificContent_finish
        EventSpecificContent_finish:
            ${If} $HadToInstallInterface == "false"
                Call LaunchInterface
            ${EndIf}
    FunctionEnd
;--------------------------------
; END Step 2
;--------------------------------
  
;--------------------------------
; START Step 3:
; Launch Interface with command-line arguments
;--------------------------------
    Function LaunchInterface
        ${If} $HiFiInstalled == "true"
            ; Make sure that no High Fidelity application is already running
            !insertmacro CheckForRunningApplications
            Call GetInterfacePath ;; In case it changed during installation of a new version
            Exec '"$InterfacePath" --url "${EVENT_LOCATION}" --skipTutorial'
        ${EndIf}
        Quit
    FunctionEnd
;--------------------------------
; END Step 3
;--------------------------------
