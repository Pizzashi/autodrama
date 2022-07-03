;====================Compiler directives====================;
;@Ahk2Exe-SetName Autodrama
;@Ahk2Exe-SetMainIcon Main.ico
;@Ahk2Exe-SetCopyright Copyright © 2022 Baconfry
;@Ahk2Exe-SetCompanyName Furaico
;@Ahk2Exe-SetVersion 0.4.2
;===========================================================;
global AUTODRAMA_VERSION := "0.4.2"

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
#Include aria2\Jxon.ahk
#Include Cleanup.ahk
#Include Config.ahk
#Include Download.ahk
#Include Drama.ahk
#Include ErrorHandling.ahk
#Include ExitFunction.ahk
#Include FileCheck.ahk
#Include GetDownloadFolders.ahk
#Include Helper.ahk
#Include Log.ahk
#Include Join.ahk
#Include MainWindow.ahk
#Include Pastebin.ahk
#Include PlaySound.ahk
#Include SelectFolderEx.ahk
#Include UrlEncode.ahk

Process, Exist                                                   ; Retrieve the script's PID
global AUTODRAMA_PID          := ErrorLevel                      ; The script's PID is in ErrorLevel
     , FIREFOX_DOWNLOAD_PATH  := GetFirefoxDownloadFolder()
     , USER_DOWNLOAD_PATH     := GetUserDownloadFolder()
     , COMBO_BOX_HISTORY      := ""                              ; Used in ComboBoxHistory.ahk
     , REMARK_TEXT_ONCLICK    := ""                              ; Used as a flag for determining what action is done when the remark text is clicked
     , ENABLE_SEARCH_DRAMA    := 1                               ; Used as a way to disable the search button
     , LOG_FILEDIR            := A_ScriptDir . "\"               ; The file directory of the log file for the current script instance (i.e. the latest log file)
                              . "Autodrama" "_" A_MMM "_" A_DD "_" A_YYYY ".log"
     ; The settings below this are set in advanced settings
     , DWNLD_SPEED_LIM        := (dwnlSpdLim := Config.Read("AppData", "SpeedLimit"))
                              ? dwnlSpdLim : 0
     , MOVIE_DOWNLOAD_PATH    := (movieDwnlPath := Config.Read("AppData", "DownloadPath"))
                              ? movieDwnlPath : USER_DOWNLOAD_PATH . "\Video\"
     , MAX_CONCURRENT_DWNL    := (maxConcDwnl := Config.Read("AppData", "MaxDownloads")) 
                              ? maxConcDwnl : 2
     , CUSTOM_ARIA_OPTIONS    := Config.Read("AppData", "AriaOptions")
     , DLEND_NOTIFY_WHO       := (notifyWho := Config.Read("AppData", "NotificationRecipient"))
                              ? notifyWho : "Daisy"
     , POP_UP_ONFINISH        := (popUpOnFinish := Config.Read("AppData", "PopUpOnFinish"))
                              ? popUpOnFinish : "On"

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