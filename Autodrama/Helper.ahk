class Helper
{
    readyCredentials()
    {
        Gui, Main:+AlwaysOnTop
        Remark.Update("Checking credentials..."
                    , "Please wait while the app is checking if you are signed in."
                    , "Blue")
        Log.Add("Helper.readyCredentials(): Checking for credentials...")

        static homePage := "https://kissasian.li/?LaunchedByAutodrama"
        /* 
         * To prevent mishaps, the helper will check only these links to check for logins:
         * "https://kissasian.li/?LaunchedByAutodrama"
         * "https://kissasian.li/Login?LaunchedByAutodrama"
        */
        Run, % homePage
        SetTimer, CheckFiles, 1000
    }

    ; If you add a return statement here, CheckFiles won't be turned on again.
    processSignal(filePath)
    {
        SetTimer, CheckFiles, Off
        FileRead, helperSignal, % filePath
        FileDelete, % filePath

        if (helperSignal = "eFeNotAvail") {
            Remark.Update("One of the download links is down..."
                        , "One of episodes has no valid FE download link. Please try again later or tomorrow. Igna si mama nga down ang server."
                        , "Red"
                        , 1)
            Log.Add("ERROR: Helper.processSignal(): One of the download links has no valid FE server, terminating.")
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
            fileName := (A_Index = 1) ? A_LoopField . ".mp4" : fileName
            downloadLink := (A_Index = 2) ? A_LoopField : downloadLink
            if (downloadLink = "no_download_link") {
                Remark.Update("One of the download links is down..."
                        , "One of episodes has no valid download link. Please try again later or tomorrow. Igna si mama nga down ang server."
                        , "Red"
                        , 1)
                Log.Add("ERROR: Helper.processSignal(): One of the download links has no valid download link, terminating.")
                return
            }
        }

        oAriaDownloadLinks.Push( {fileName: fileName, downloadLink: downloadLink} )
        Log.Add("Helper.processSignal(): Added aria2 download link for " fileName)      
        SetTimer, CheckFiles, 1000

        Download.pushToAria(oAriaDownloadLinks)
    }
}