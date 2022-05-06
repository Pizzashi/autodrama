Cleanup()
{
    Global

    ; Delete old .autodramatext files
    FileDelete, %FIREFOX_DOWNLOAD_PATH%\*.autodramatext
    ; Delete the app's old images folder
    FileRemoveDir, %A_ScriptDir%\DownloadedImages, 1

    if (ErrorLevel)
        Log.Add("ERROR: Cleanup(): There was a problem in cleaning unnecessary files.`nThis also triggers if DownloadedImages folder does not exist (i.e., this error may be a false alarm).")
    else
        Log.Add("Cleanup(): Successfully cleaned up unnecessary files.")
}