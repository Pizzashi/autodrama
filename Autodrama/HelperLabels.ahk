CheckFiles:
    ListLines, Off  ; This thread does not need to be logged

    Loop, Files, %FIREFOX_DOWNLOAD_PATH%\*.autodramatext
    {
        Helper.processSignal(A_LoopFileFullPath)
        break
    }
return