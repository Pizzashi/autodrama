;====================Compiler directives====================;
;@Ahk2Exe-SetName Autodrama
;@Ahk2Exe-SetMainIcon Main.ico
;@Ahk2Exe-SetCopyright Copyright © 2022 Baconfry
;@Ahk2Exe-SetCompanyName Furaico
;@Ahk2Exe-SetVersion 0.3.2
;===========================================================;
global AUTODRAMA_VERSION := "0.3.2"

#NoEnv
SetBatchLines, -1
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
#Include Download.ahk
#Include Drama.ahk
#Include ErrorHandling.ahk
#Include ExitFunction.ahk
#Include FileCheck.ahk
#Include GetDownloadFolders.ahk
#Include Helper.ahk
#Include Log.ahk
#Include MainWindow.ahk
#Include PlaySound.ahk

Process, Exist ; Retrieve the script's PID
global AUTODRAMA_PID := ErrorLevel                              ; The script's PID is in ErrorLevel
     , FIREFOX_DOWNLOAD_PATH := GetFirefoxDownloadFolder()
     , USER_DOWNLOAD_PATH    := GetUserDownloadFolder()
     , MOVIE_DOWNLOAD_PATH   := USER_DOWNLOAD_PATH . "\Video\"
     , COMBO_BOX_HISTORY     := ""                              ; Used in ComboBoxHistory.ahk
     , REMARK_TEXT_ONCLICK   := ""                              ; Used as a flag for determining what action is done when the remark text is clicked
     , ENABLE_SEARCH_DRAMA   := 1                               ; Used as a way to disable the search button

Log.Init()                                                      ; Initialize logging
Cleanup()                                                       ; Deletes all unnecessary files from last session
FileCheck("resources.dll, aria2c.exe")                          ; Check the existence of the required files
ComboBox.readPrevHistory()                                      ; Read previous search history for DramaLink
MainWindow.Launch()                                             ; Fire up the main window
OnExit("ExitFunction")                                          ; Set ExitFunction() to fire when the app is closed properly

return

#Include DownloadLabels.ahk
#Include HelperLabels.ahk
#Include MainWindowLabels.ahk

