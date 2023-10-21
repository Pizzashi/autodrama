#Requires AutoHotkey v1.1.36.02

;====================Compiler directives====================;
;@Ahk2Exe-SetName Autodrama
;@Ahk2Exe-SetDescription Autodrama
;@Ahk2Exe-SetMainIcon Main.ico
;@Ahk2Exe-SetCopyright Copyright © 2022 Pizzashi
;@Ahk2Exe-SetCompanyName Pizzashi
;@Ahk2Exe-SetVersion 0.4.3.2
; Alter the UPX compressed .exe so that it can't be de-compressed with UPX -d
;@Ahk2Exe-PostExec "BinMod.exe" "%A_WorkFileName%"
;@Ahk2Exe-Cont  "11.UPX." "1.UPX!.", 2
;===========================================================;
global AUTODRAMA_VERSION := "0.4.3.2"

#NoEnv
SetWorkingDir %A_ScriptDir%
#SingleInstance, force
; This code appears only in the compiled script
/*@Ahk2Exe-Keep
#NoTrayIcon
ListLines Off
#KeyHistory 0
*/

#Include aria2\aria2.ahk
#Include aria2\httpPost.ahk
#Include Lib\Jxon.ahk
#Include Cleanup.ahk
#Include Config.ahk
#Include Download.ahk
#Include Drama.ahk
#Include ErrorHandling.ahk
#Include ExitFunction.ahk
#Include FileCheck.ahk
#Include Generate.ahk
#Include GetDownloadFolders.ahk
#Include Helper.ahk
#Include Log.ahk
#Include Ntfy.ahk
#Include MainWindow.ahk
#Include Pastebin.ahk
#Include PlaySound.ahk
#Include ClearObjects.ahk
#Include SelectFolderEx.ahk
#Include UrlEncode.ahk

Process, Exist                                                   ; Retrieve the script's PID
global AUTODRAMA_PID          := ErrorLevel                      ; The script's PID is stored in ErrorLevel
     , SCRT_TOKEN             := Generate.randomString(64)       ; For use with Aria
     , FIREFOX_DOWNLOAD_PATH  := GetFirefoxDownloadFolder()
     , USER_DOWNLOAD_PATH     := GetUserDownloadFolder()
     , COMBO_BOX_HISTORY      := ""                              ; Used in ComboBoxHistory.ahk
     , REMARK_TEXT_ONCLICK    := ""                              ; Used as a flag for determining what action is done when the remark text is clicked
     , ENABLE_SEARCH_DRAMA    := 1                               ; Used as a way to disable the search button
     , LOG_FILEDIR            := A_ScriptDir . "\"               ; The file directory of the log file for the current script instance (i.e. the latest log file)
                              . "Autodrama" "_" A_MMM "_" A_DD "_" A_YYYY ".log"
     ; The variables below are set in advanced settings
     ; If StrLen(var) returns false, it means the setting is not set
     , DWNLD_SPEED_LIM        := StrLen(dwnlSpdLim := Config.Read("AppData", "SpeedLimit"))
                              ? dwnlSpdLim : Config.Write("AppData", "SpeedLimit", 0)
     , MOVIE_DOWNLOAD_PATH    := StrLen(movieDwnlPath := Config.Read("AppData", "DownloadPath"))
                              ? movieDwnlPath : Config.Write("AppData", "DownloadPath", USER_DOWNLOAD_PATH . "\Video\")
     , MAX_CONCURRENT_DWNL    := StrLen(maxConcDwnl := Config.Read("AppData", "MaxDownloads"))
                              ? maxConcDwnl : Config.Write("AppData", "MaxDownloads", 2)
     , DLEND_NOTIFY_WHO       := StrLen(notifyWho := Config.Read("AppData", "NotificationRecipient"))
                              ? notifyWho : Config.Write("AppData", "NotificationRecipient", "Daisy")
     , POP_UP_ONFINISH        := StrLen(popUpOnFinish := Config.Read("AppData", "PopUpOnFinish"))
                              ? popUpOnFinish : Config.Write("AppData", "PopUpOnFinish", "On")
     , DRAMA_HOSTNAME         := StrLen(SiteHostname := Config.Read("AppData", "SiteHostname"))
                              ? SiteHostname : Config.Write("AppData", "SiteHostname", "kissasian.lu")
     , MAX_RETRIES_FOR_LINKS  := StrLen(maxRetries := Config.Read("AppData", "MaxRetriesForUnavailableLinks"))
                              ? maxRetries : Config.Write("AppData", "MaxRetriesForUnavailableLinks", 3)
     , CUSTOM_ARIA_OPTIONS    := Trim(StrReplace((StrLen(customAriaOptns := Config.Read("AppData", "AriaOptions")) 
                              ? customAriaOptns
                              : Config.Write("AppData", "AriaOptions", "max-connection-per-server=16|split=16|min-split-size=5M|allow-overwrite=true|auto-file-renaming=false"))
                              , "|", "`r`n"), "`r`n")
                              
FileCheck("resources.dll, aria2c.exe")                           ; Check the existence of the required files
Config.Init()                                                    ; Set up configuration.ini
Log.Init()                                                       ; Initialize logging
Cleanup()                                                        ; Deletes all unnecessary files from last session
ComboBox.readPrevHistory()                                       ; Read previous search history for DramaLink
MainWindow.Launch()                                              ; Fire up the main window
OnExit("ExitFunction")                                           ; Set ExitFunction() to fire when the app is closed properly

return

#Include AdvancedSettingsLabels.ahk
#Include DownloadLabels.ahk
#Include HelperLabels.ahk
#Include MainWindowLabels.ahk