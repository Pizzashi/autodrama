AdvSetGuiClose:
    Gui, Main:-Disabled
    Gui, AdvSet:Destroy
return

BrowseNewDlDir:
    newDownloadFolder := SelectFolderEx("::{20d04fe0-3aea-1069-a2d8-08002b30309d}", "Select new download folder", hAdvSettings)
    if (newDownloadFolder = "") ; User picked nothing
		return
    GuiControl, AdvSet:, DlDir, % newDownloadFolder
return

SaveDownloadOptions:
    Gui, AdvSet:Submit, NoHide
    GuiControl, AdvSet:, SaveDlOptionsBtn, % "Saving settings..."

    Config.Write("AppData", "SpeedLimit", DlSpdLim)
    Config.Write("AppData", "MaxDownloads", MaxConcDl)
    Config.Write("AppData", "AriaOptions", CustDlOptns)
    Config.Write("AppData", "DownloadPath", DlDir)

    ; If this returns anything, it means Aria is active and must be restarted
    if (aria2.getVersion().result.version)
    {
        ; If this is the case, the application needs to be restarted
        if (CustDlOptns != CUSTOM_ARIA_OPTIONS || DlDir != MOVIE_DOWNLOAD_PATH)
            Msgbox, 0, % " Notice", % "The custom download options and download directory modifications will be reflected when you restart the app."

        newOptions := "max-concurrent-downloads=" MaxConcDl "`r`n"
                    . "max-overall-download-limit=" DlSpdLim "K"
        oNewOptions := Download.Options2obj(newOptions)
        if !(aria2.changeGlobalOption(oNewOptions).result)
        {
            Msgbox, 0, % " Error", % "The maximum concurrent downloads and speed limit could not be saved to Aria. Please restart the application for the changes to take effect."
        }

    }
    else
    {
        CUSTOM_ARIA_OPTIONS     := CustDlOptns
        , MOVIE_DOWNLOAD_PATH   := DlDir
        , MAX_CONCURRENT_DWNL   := MaxConcDl
        , DWNLD_SPEED_LIM       := DlSpdLim
    }

    GuiControl, AdvSet:, SaveDlOptionsBtn, % "Options saved!"
    Sleep, 1500
    GuiControl, AdvSet:, SaveDlOptionsBtn, % "Save download options"
return

ChangePopUpNotif:
    Gui, AdvSet:Submit, NoHide
    if (POP_NOTIF_ONFINISH != PopUpOnFin)
    {
        POP_NOTIF_ONFINISH := PopUpOnFin
        Config.Write("AppData", "PopUpOnFinish", PopUpOnFin)
    }
return

ClearSearchHistory:
    GuiControlGet, DramaLink, Main:
    ; The pipe (|) at the start is necessary for the DDL options to be replaced
    ; otherwise, they will be appended at the other options
    GuiControl, Main:, DramaLink, % "|" . DramaLink . "||"
    Config.Write("UserData", "SearchHistory", DramaLink . "||") ; We don't need the starting pipe

    GuiControl, AdvSet:, ClrSearchBtn, % "Cleared!"
    Sleep, 1500
    GuiControl, AdvSet:, ClrSearchBtn, % "Clear"
return

ClearPrevLogs:
    SplitPath, LOG_FILEDIR, latestLog

    try Loop, Files, *.*
    {
        if (A_LoopFileExt != "log" && A_LoopFileExt != "old")
            continue
        
        if (A_LoopFileName != latestLog)
            FileDelete, % A_LoopFileLongPath
    }
    catch
        Msgbox, 0, % " Error", % "The application cannot successfully delete the old log files, please try again."

    GuiControl, AdvSet:, SelectedLogToUpload, % AdvancedSettings.buildLogList(1)

    GuiControl, AdvSet:, ClrPrevLogsBtn, % "Cleared!"
    Sleep, 1500
    GuiControl, AdvSet:, ClrPrevLogsBtn, % "Clear"
return

UploadLogFile:
    GuiControlGet, SelectedLogToUpload, AdvSet:
    GuiControl, AdvSet:, UpLogFileBtn, % "Uploading..."

    if Pastebin.Upload(SelectedLogToUpload)
    {
        GuiControl, AdvSet:, UpLogFileBtn, % "Uploaded!"
        Sleep, 1500
        GuiControl, AdvSet:, UpLogFileBtn, % "Upload"
    }
    else
        GuiControl, AdvSet:, UpLogFileBtn, % "Upload"   
return