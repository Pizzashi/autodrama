class AdvancedSettings
{
    Launch()
    {
        Global

        Gui, Main:+Disabled
        Gui, AdvSet:New, +OwnerMain +HwndhAdvSettings, % "Autodrama v" . AUTODRAMA_VERSION . " Settings"
        Gui, AdvSet:Margin, 10, 10 
        Gui, AdvSet:Add, Tab3, x10 y10 w410 h280, Download|Application|Log
        ;===================Download Settings===================;
        Gui, Tab, 1 ; Download tab
        
        Gui, AdvSet:Add, Text,, % "Speed limit"
        Gui, AdvSet:Add, Edit, x150 yp-2 w100 number vDlSpdLim, % DWNLD_SPEED_LIM
        Gui, AdvSet:Add, Text, x+5 yp+2, % "kB/s"

        Gui, AdvSet:Add, Text, x22 y+10, % "Maximum downloads"
        Gui, AdvSet:Add, DDL, x150 yp-2 w100 vMaxConcDl, % (MAX_CONCURRENT_DWNL = 2) ? "1|2||" : "1||2"

        Gui, AdvSet:Add, Text, x22 y+10, % "Download directory"
        Gui, AdvSet:Add, Edit, x150 yp-2 w200 h21 ReadOnly vDlDir, % MOVIE_DOWNLOAD_PATH
        Gui, AdvSet:Add, Button, x+5 yp+0 gBrowseNewDlDir, % "Browse"

        Gui, AdvSet:Add, Text, x22 y+10, % "Custom options (one option per line)"
        Gui, AdvSet:Add, Edit, x22 y+5 w379 h100 vCustDlOptns, % CUSTOM_ARIA_OPTIONS
        Gui, AdvSet:Add, Button, x115 y+10 w200 vSaveDlOptionsBtn gSaveDownloadOptions, % "Save download options"
        ;===================Application Settings===================;
        Gui, Tab, 2 ; Application tab

        Gui, AdvSet:Add, Text, x22 y+10, % "Clear search history"
        Gui, AdvSet:Add, Button, x200 yp-2 w100 vClrSearchBtn gClearSearchHistory, % "Clear"

        ;===================Application Settings===================;
        Gui, Tab, 3 ; Log tab

        Gui, AdvSet:Add, Text, x22 y+10, % "Clear logs (except latest)"
        Gui, AdvSet:Add, Button, x200 yp-2 w100 gClearPrevLogs vClrPrevLogsBtn, % "Clear"

        Gui, AdvSet:Add, Text, x22 y+10, % "Upload log to Baconfry-sama"
        Gui, AdvSet:Add, DDL, x200 yp-2 w200 vSelectedLogToUpload, % AdvancedSettings.buildLogList()
        Gui, AdvSet:Add, Button, x200 y+5 w100 gUploadLogFile vUpLogFileBtn, % "Upload"

        Gui, AdvSet:Show, w430 h300
    }

    buildLogList(rebuild := 0)
    {
        OLogsList := []
        Loop, Files, *.*
        {
            if (A_LoopFileExt != "log")
                continue
            
            OLogsList.Push(A_LoopFileName)
        }
        Loop, % OLogsList.Length()
        {
            if (A_Index = 1)
            {
                logsList := OLogsList[OLogsList.Length()] . "||"
                if (OLogsList.Length() = 1)
                    return rebuild ? "|" . logsList : logsList  ; No need to RTrim if there's only one entry
            }
            if (A_Index >= 10)
                break
            logsList := logsList . OLogsList[OLogsList.Length() - A_Index] "|"
        }
        return rebuild ? "|" . RTrim(logsList, "|") : RTrim(logsList, "|")
    }
}