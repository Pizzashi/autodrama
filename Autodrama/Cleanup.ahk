Cleanup()
{
    Global

    ; Delete old .autodramatext files
    FileDelete, %FIREFOX_DOWNLOAD_PATH%\*.autodramatext
    ; Delete the app's old images folder
    FileRemoveDir, %A_ScriptDir%\DownloadedImages, 1
}