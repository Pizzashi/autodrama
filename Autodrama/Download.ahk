class Download
{
    makeWinFriendly(text)
    {
        return RegexReplace(text, "[\/:\*\?""<>\|]")
    }

    Commence()
    {
        Global

        Gui, Main:Submit, NoHide
        Gui, MainO:Submit, NoHide
        Gui, MainO2:Submit, NoHide
        ; Note at this point, +AlwaysOnTop is still on.
        ; The flag was triggered at Helper.readyCredentials()
        Remark.Update("Gathering the download links..."
                    , "Please wait as the app gathers the download links for the episodes. This may take a while, so feel free to make some milk or take a poop."
                    , "Blue")
        Log.Add("Download.Commence(): Gathering the download links for " DramaLink
              . "`nDownload type is: " DownloadType
              . "`nDownload start (empty if DownloadType is not 'Download chosen episodes'): " DownloadStart
              . "`nDownload end: " DownloadEnd
              . "`nFirst download link: " oDownloadLinks[1]
              . "`nOn download finish: " OnFinish)

        SetTimer, CheckFiles, 1000

        launchedEpisodeNumber := 1
        SetTimer, RunDownloadLinks, 2000
    }

    onFinish(downloadSucess := 1)
    {
        Global

        Drama.infoImageToGrayScale()
		Window.resetAll()
        
        if (POP_UP_ONFINISH = "On")
            WinActivate, ahk_id %hMainGui%

		GuiControlGet, OnFinish, MainO:, OnFinish
        if (downloadFailed) {
            failedDownload := (OnFinish = "THE KING")
                            ? TheKing() : InStr(OnFinish, "Notify")
                            ? Join.Notify(DLEND_NOTIFY_WHO, "There was an error in downloading " . """" oDramaInfo[1] """" . ".") ; oDramaInfo[1] is the drama title    
        } else {
            finishedDownload := (OnFinish = "THE KING")
                            ? TheKing()
					        : InStr(OnFinish, "Notify")
                            ? Join.Notify(DLEND_NOTIFY_WHO, """" oDramaInfo[1] """" . " has finished downloading.") ; oDramaInfo[1] is the drama title
        }
    }

    startAria()
    {
        Global
        
        ; Check if Aria is already started
        if (aria2.getVersion().result.version)
            return 1
        
        Remark.Update("Starting Aria2c..."
            , "Please wait as the app tries to start the downloader."
            , "Blue")

        local SCRT_TOKEN := "xRyEkIylIPAxgw9Yo6NNnpvajNvAHRZPqvS1lwgrOXX9K6pNlSdBQt4w4y73pYfL"
            , global_options := "max-concurrent-downloads=" MAX_CONCURRENT_DWNL     . "`r`n"
                              . "max-overall-download-limit=" DWNLD_SPEED_LIM "K"   . "`r`n"
                              . CUSTOM_ARIA_OPTIONS
        ;, global_options := "max-concurrent-downloads=2"
            , oGlobalOptions := this.Options2obj(global_options)

        try Run, %ComSpec% /c aria2c.exe --enable-rpc --rpc-listen-all --rpc-secret=%SCRT_TOKEN% --stop-with-process=%AUTODRAMA_PID% -c,, Hide UseErrorLevel, pidAria
        catch
        {
            Log.Add("ERROR: Download.startAria(): Aria2c could not be started.")
            Remark.Update("Error! Error! Error!"
                        , "Aria2c could not be started for some reason. Try closing the app and trying again."
                        , "Red"
                        , 1)
            return 0
        }

        if (aria2.changeGlobalOption(oGlobalOptions).result != "OK") {
            Log.Add("ERROR: Download.startAria(): Aria2c global settings could not be set. Global options: " global_options)
            Remark.Update("Error!"
                        , "Aria2c options could not be modified. Please close the app and try again."
                        , "Red"
                        , 1)
            return 0
        }
        
        Log.Add("Download.startAria(): Successfully started Aria2c and modified global options.")
        
        return 1
    }

    pushToAria(oAriaDownloadLinks)
    {
        Global

        Run, % "https://" . DRAMA_HOSTNAME . "/?AutodramaIsFinished" ; This will close the main window

        if !IsObject(gidList)
            gidList := []
      
        TOTAL_DOWNLOADS := oAriaDownloadLinks.Count()
        COMPLETED_DOWNLOADS := 0
        FAILED_DOWNLOADS := 0

        Log.Add("Download.pushToAria(): Attempting to download " TOTAL_DOWNLOADS " file(s).")

        for key, value in oAriaDownloadLinks
        {
            ; Set file name and download directory
            local addUriOptions := "dir=" . DRAMA_FOLDER . "`n"
                                 . "out=" . this.makeWinFriendly(value.fileName)
            ;local addUriOptions := "out=.\" this.makeWinFriendly(DRAMA_FOLDER) . "\" . this.makeWinFriendly(value.fileName)
            local oAddUriOptions := this.Options2obj(addUriOptions)

            ; Add url to aria2
            local gid := aria2.addUri( [value.downloadLink], oAddUriOptions ).result
            ; Record download info
            gidList.Push( {gid: gid, fileName: value.fileName} )
        }
        
        Window.downloadControls("Enable", "Disable", "Enable")
        SetTimer, UpdateStatus, 1000
    }

    FormatByteSize(Bytes){ ; by HotKeyIt, http://ahkscript.org/boards/viewtopic.php?p=18338#p18338
        static size:="bytes,KB,MB,GB,TB,PB,EB,ZB,YB"
        Loop,Parse,size,`,
            If (bytes>999)
            bytes:=bytes/1024
            else {
            bytes:=Trim(SubStr(bytes,1,4),".") " " A_LoopField
            break
            }
        return bytes
    }

    FormatSeconds(NumberOfSeconds)  ; Convert the specified number of seconds to hh:mm:ss format.
    {
        time = 19990101  ; *Midnight* of an arbitrary date.
        time += %NumberOfSeconds%, seconds
        FormatTime, mmss, %time%, mm:ss
        return NumberOfSeconds//3600 ":" mmss  ; This method is used to support more than 24 hours worth of sections.
    }

    Options2obj(options) {
        obj := {}

        options := Trim(options, " `t`r`n")
        options := RegExReplace(options, "im`a)^\s*-+")
        StringReplace, options, options, ",, All

        Loop, Parse, options, `n, `r
            If ( pos := InStr(A_LoopField, "=") )
                obj[ SubStr(A_LoopField, 1, pos-1) ] := SubStr(A_LoopField, pos+1)

        Return obj
    }
}