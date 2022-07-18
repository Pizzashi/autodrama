CheckFiles:
    ListLines, Off  ; This thread does not need to be logged
    /**
     *  The Gui, Submit is set because
     *  Helper.processSignal() needs the values of these portions
     *  Specifically: MainO:DownloadType, MainO2:DownloadStart, MainO2:DownloadEnd
     */
    Gui, MainO:Submit, NoHide
    Gui, MainO2:Submit, NoHide

    Loop, Files, %FIREFOX_DOWNLOAD_PATH%\*.autodramatext, R
    {
        Helper.processSignal(A_LoopFileFullPath)
        break
    }
return