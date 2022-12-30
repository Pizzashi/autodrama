class Helper
{
    readyCredentials()
    {
        Gui, Main:+AlwaysOnTop
        Remark.Update("Checking credentials..."
                    , "Please wait while the app is checking if you are signed in."
                    , "Blue")
        Log.Add("Helper.readyCredentials(): Checking for credentials...")

        homePage := "https://" . DRAMA_HOSTNAME . "/?LaunchedByAutodrama?AnotherInstance"
        /**
         * To prevent mishaps, the helper will check only these links to check for logins:
         * "https://DRAMA_HOSTNAME/?LaunchedByAutodrama"
         * "https://DRAMA_HOSTNAME/Login?LaunchedByAutodrama"
         * The hostname is stored in the global variable DRAMA_HOSTNAME
         */
        Run, % homePage
        SetTimer, CheckFiles, 1000
    }

    ; If you add a return statement here, CheckFiles won't be turned on again.
    processSignal(filePath)
    {
        Global
        
        local episodePos := 0, helperSignal, episodeName, fileName, downloadLink

        SetTimer, CheckFiles, Off
        FileRead, helperSignal, % filePath
        FileDelete, % filePath
            
        if (helperSignal = "eFeNotAvail") {
            Helper.FatalError()
            return
        }

        if (helperSignal = "CredentialsReady") {
            Log.Add("Helper.processSignal(): Successful login.")
            Download.Commence()
            return
        }

        ; This be the fileName-downloadLink pair object
        ; oAriaDownloadLinks is declared in the start of the script
        Loop, Parse, helperSignal, |
        {
            episodeName := (A_Index = 1) ? A_LoopField : episodeName
            fileName := (A_Index = 1) ? episodeName . ".mp4" : fileName
            downloadLink := (A_Index = 2) ? A_LoopField : downloadLink

            if (!fileName || !downloadLink)
                continue

            if (downloadLink = "no_download_link") {
                Helper.FatalError()
                return
            }     
        }

        if !IsObject(oAriaDownloadLinks)
            oAriaDownloadLinks := []
        
        ; Sort the download order of the episodes in an ascending manner
        static posRegex := "\d+", movieRegex := "\bMovie\b$"
        if RegexMatch(episodeName, movieRegex)
        {
            ; No need to sort if the drama type is movie
            oAriaDownloadLinks.Push( {fileName: fileName, downloadLink: downloadLink} )
        }
        else
        {
            if (DownloadType = "Download all episodes") {    
                RegExMatch(episodeName, posRegex, episodePos)
                
                ; If RegexMatch fails, push to the end of the array instead
                if !(episodePos)
                    oAriaDownloadLinks.Push({fileName: fileName, downloadLink: downloadLink})
                else
                    oAriaDownloadLinks.InsertAt(episodePos, {fileName: fileName, downloadLink: downloadLink})
            }
            if (DownloadType = "Download chosen episodes") {
                RegExMatch(episodeName, posRegex, episodePos)

                ; If RegexMatch fails, push to the end of the array instead
                if !(episodePos)
                    oAriaDownloadLinks.Push({fileName: fileName, downloadLink: downloadLink})
                else {
                    episodePos :=  (episodePos - DownloadStart + 1)
                    oAriaDownloadLinks.InsertAt(episodePos, {fileName: fileName, downloadLink: downloadLink})
                }
            }
        }

        Remark.Update("Gathering the download links... " . oAriaDownloadLinks.Count() . " out of " . oDownloadLinks.Count()
                    , "Please wait as the app gathers the download links for the episodes. This may take a while, so feel free to make some milk or take a poop."
                    , "Blue")
        Log.Add("Helper.processSignal(): Processing download links, " . oAriaDownloadLinks.Count() . " out of " . oDownloadLinks.Count())
        Log.Add("Helper.processSignal(): Added aria2 download link for " fileName "`n`t`tDownload link is: " downloadLink)      
        SetTimer, CheckFiles, 1000

        ; Got everything
        if (oAriaDownloadLinks.Count() >= oDownloadLinks.Count())
        {
            SetTimer, CheckFiles, Off
            Gui, Main:-AlwaysOnTop
            Download.pushToAria(oAriaDownloadLinks)
        }
    }

    FatalError()
    {
        SetTimer, RunDownloadLinks, Off
        Run, % "https://" DRAMA_HOSTNAME "/?AutodramaFatalError"  ; Signals the helper that we have a fatal error
        Window.resetAll()

        Remark.Update("One of the download links is down..."
                    , "One of episodes has no valid download link. Try again later. Igna si mama nga down ang server."
                    , "Red"
                    , 1)
        Log.Add("ERROR: Helper.processSignal(): One of the download links has no valid download link, terminating.")
    }
}