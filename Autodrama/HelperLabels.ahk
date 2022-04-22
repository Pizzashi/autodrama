CheckFiles:
    Loop, Files, %FIREFOX_DOWNLOAD_PATH%\*.autodramatext, R
    {
        Helper.processSignal(A_LoopFileFullPath)
        break
    }
return