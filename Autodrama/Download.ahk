class Download
{
    makeWinFriendly(text)
    {
        return RegexReplace(text, "[\/:\*\?""<>\|]")
    }

    Commence(linksUnfinished := 0)
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
        ; Avoid verbose logging when redownloading drama
        if !(linksUnfinished) {
            if (DownloadType = "Download chosen episodes") {
            Log.Add("Download.Commence(): Gathering the download links for " DramaLink
              . "`n`tDownload type is: " DownloadType
              . "`n`tDownload start: " DownloadStart
              . "`n`tDownload end: " DownloadEnd
              . "`n`tOn download finish: " OnFinish)
            }
            else {
            Log.Add("Download.Commence(): Gathering the download links for " DramaLink
              . "`n`tDownload type is: " DownloadType
              . "`n`tOn download finish: " OnFinish)
            }
        }

        ; Launch the download links
        SetTimer, CheckFiles, 1000
        runningLinks := 0
        linearDownloadLinks := []
        launchedEpisodeNumber := 1
        for episodeNumber, downloadLink in oDownloadLinks {
            linearDownloadLinks.Push(downloadLink)
        }
        SetTimer, RunDownloadLinks, 2000
    }

    onFinish(downloadSuccess := 1, completedDownloads := 0, failedDownloads := 0)
    {
        Global

        Drama.infoImageToGrayScale()
		Window.resetAll()
        
        if (POP_UP_ONFINISH = "On")
            WinActivate, ahk_id %hMainGui%

		GuiControlGet, OnFinish, MainO:, OnFinish
        if (OnFinish = "THE KING") {
            TheKing()
        }
        else if InStr(OnFinish, "Notify") {
            ; Alter the title depending if there are failed downloads present
            successTitle := !(failedDownloads) ? "Autodrama has great news!" : !(completedDownloads) ? "Autodrama has bad news...." : "Autodrama has good and bad news..." 
            ; oDramaInfo[1] is the drama title
            if (downloadSuccess) {
               Ntfy.sendMessage(DLEND_NOTIFY_WHO, successTitle, """" oDramaInfo[1] """" . " has finished downloading.`nCompleted: " . completedDownloads . ", Failed: " . failedDownloads)
            } else {
                Ntfy.sendMessage(DLEND_NOTIFY_WHO, "Autodrama encountered an error!", "There was an error in downloading " . """" oDramaInfo[1] """" . ".")
            }
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

        local global_options := "max-concurrent-downloads=" MAX_CONCURRENT_DWNL    . "`r`n"
                            . "max-overall-download-limit=" DWNLD_SPEED_LIM "K"   . "`r`n"
                            . CUSTOM_ARIA_OPTIONS
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
            Log.Add("ERROR: Download.startAria(): Aria2c global settings could not be set. Global options:`n" global_options)
            Remark.Update("Error!"
                        , "Aria2c options could not be modified. Please close the app and try again."
                        , "Red"
                        , 1)
            return 0
        }
        
        Log.Add("Download.startAria(): Successfully started Aria2c and modified global options.")
        
        return 1
    }

    ; Pass in a sorted (by episode number) linear array where the values are {fileName:downloadLink} pair
    pushToAria(pushedDownloadLinks)
    {
        Global

        Helper.closeTabs()

        if !IsObject(gidList)
            gidList := []
      
        TOTAL_DOWNLOADS := pushedDownloadLinks.Count()
        COMPLETED_DOWNLOADS := 0
        FAILED_DOWNLOADS := 0

        Log.Add("Download.pushToAria(): Attempting to download " TOTAL_DOWNLOADS " file(s).")

        for key, value in pushedDownloadLinks
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