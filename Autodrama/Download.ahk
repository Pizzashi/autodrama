class Download
{
    makeWinFriendly(text)
    {
        return RegexReplace(text, "[\/:\*\?""<>\|]")
    }

    Commence()
    {
        Global

        ; Note at this point, +AlwaysOnTop is still on.
        ; The flag was triggered at Helper.readyCredentials()

        Remark.Update("Gathering the download links..."
                    , "Please wait as the app gathers the download links for the episodes."
                    , "Blue")
        Log.Add("Download.Commence(): Gathering the download links for " DramaLink
              . "`nDownload type is: " DownloadType
              . "`nDownload start (empty if DownloadType is not 'Download chosen episodes'): " DownloadStart
              . "`nDownload end: " DownloadEnd
              . "`nFirst download link: " oDownloadLinks[1]
              . "`nOn download finish: " OnFinish)

        SetTimer, CheckFiles, 1000

        Loop % oDownloadLinks.Length()
        {
            Run, % oDownloadLinks[A_Index]
            Sleep, 2000
        }
    }

    startAria()
    {
        Global
        
        Remark.Update("Starting Aria2c..."
            , "Please wait as the app tries to start the downloader."
            , "Blue")

        local SCRT_TOKEN := "xRyEkIylIPAxgw9Yo6NNnpvajNvAHRZPqvS1lwgrOXX9K6pNlSdBQt4w4y73pYfL"
        /*
            global_options := "max-concurrent-downloads=2`n"
                            . "max-overall-download-limit=500K"
        */
        , global_options := "max-concurrent-downloads=2"
        , oGlobalOptions := this.Options2obj(global_options)

        Run, %ComSpec% /c aria2c.exe --enable-rpc --rpc-listen-all --rpc-secret=%SCRT_TOKEN% --stop-with-process=%AUTODRAMA_PID% -c,, UseErrorLevel, pidAria
        if (ErrorLevel) {
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

        Log.Add("Download.pushToAria(): Processing download links, " . oAriaDownloadLinks.Length() . " out of " . oDownloadLinks.Length())
        if (oAriaDownloadLinks.Length() < oDownloadLinks.Length()) {
            return
        }

        ; Got everything
        if !IsObject(gidList)
            gidList := []
        SetTimer, CheckFiles, Off
        Gui, Main:-AlwaysOnTop
        
        TOTAL_DOWNLOADS := oAriaDownloadLinks.Length()
        COMPLETED_DOWNLOADS := 0
        FAILED_DOWNLOADS := 0

        Log.Add("Download.pushAria(): Attempting to download " TOTAL_DOWNLOADS " file(s).")

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