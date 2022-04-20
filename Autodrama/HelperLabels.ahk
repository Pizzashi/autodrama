CheckFiles:
    Loop, Files, %FIREFOX_DOWNLOAD_PATH%\*.autodramatext, R
    {
        Helper.processSignal(A_LoopFileFullPath)
        break
    }
return
/*
ProcessHelperSignal:
    FileRead, fileContents, %foundSignal%
    FileDelete, %foundSignal%
    ; if fileContents = creds

    ; movieFolder

    movieFolder := """" . MOVIE_DOWNLOAD_PATH . "Twenty-Five Twenty-One (2022)" . """"

    Loop, Parse, tempContents, |
    {
        if (A_Index = 1)
            episodeName := """" . A_LoopField . ".mp4" . """"
        if (A_Index = 2)
            downloadLink := """" . A_LoopField . """"
    }

    ; TO-DO: Add a folder per series
    RunWait, %ComSpec% /c title Downloading %episodeName% && "C:\Users\bacon\Desktop\Temp\AHK\Autodrama\__res\aria2-1.36.0-win-32bit-build1\aria2c.exe" --console-log-level=warn -d %movieFolder% -o %episodeName% %downloadLink%, , Min

    if FileExist(movieFolder . "\" . episodeName)
        Msgbox, yaaay
return
*/
HelperTimeOut:

return