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
         * "https://DRAMA_HOSTNAME/?LaunchedByAutodrama?AnotherInstance"
         * "https://DRAMA_HOSTNAME/Login?LaunchedByAutodrama
         * The hostname is stored in the global variable DRAMA_HOSTNAME
         */
        Run, % homePage

        Gui, MainO:Submit, NoHide
        Gui, MainO2:Submit, NoHide
        SetTimer, CheckFiles, 1500
    }

    ; Don't add a return statement in the middle of this function
    ; if you want CheckFiles to be queued again.
    processSignal(filePath)
    {
        Global
        
        if !IsObject(oAriaDownloadLinks) {
            oAriaDownloadLinks := Object() ; oAriaDownloadLinks is a linear array of associative arrays (nice)
        }
        static currentRetriesForUnavailableLinks := 1, processedLinksCount := 0
            , validEpisodes := [], linksUnfinished := 0
        local helperSignal, episodeName, fileName, downloadLink, skipLinkProcess := 0

        SetTimer, CheckFiles, Off
        FileRead, helperSignal, % filePath
        FileDelete, % filePath

        ; Don't count the credentials signal as a download link
        if (helperSignal = "CredentialsReady") {
            Log.Add("Helper.processSignal(): Successful login.")
            Download.Commence(linksUnfinished)
            return
        }

        ; Counting for processed links starts here!
        processedLinksCount++

        if (helperSignal = "downloadNotAvailable") {
            skipLinkProcess := 1
            skipLinkError := "downloadNotAvailable"
        }

        ; This be the fileName-downloadLink pair object
        ; oAriaDownloadLinks is declared in the start of the script
        Loop, Parse, helperSignal, |
        {
            episodeName := (A_Index = 1) ? A_LoopField : episodeName
            fileName := (A_Index = 1) ? episodeName . ".mp4" : fileName
            downloadLink := (A_Index = 2) ? A_LoopField : downloadLink
        }

        if (!fileName || !downloadLink) {
            skipLinkProcess := 1
            skipLinkError := "fileNameOrDownloadLinkEmpty"
        }

        if (episodeName = "undefined") {
            skipLinkProcess := 1
            skipLinkError := "episodeNameUndefined"
        }

        if (downloadLink = "no_download_link") {
            skipLinkProcess := 1
            skipLinkError := "noDownloadLink"
        }

        for existingFileName, _ in oAriaDownloadLinks {
            if (existingFileName = fileName) {
                skipLinkProcess := 1
                skipLinkError := "duplicateDownloadLink"
                break
            }
        }

        if (!skipLinkProcess) {
            static posRegex := "\d+", movieRegex := "\bMovie\b$"

            if RegexMatch(episodeName, movieRegex) {
                ; No need to sort if the drama type is movie
                oAriaDownloadLinks[fileName] := downloadLink
                validEpisodes.Push(1)   ; Episode 1
            }
            else {
                ; Only register the link to oAriaDownloadLinks if RegexMatch succeeds.
                ; If RegexMatch fails, ignore that download link so that it can be
                ; redownloaded later with the proper file name.
                if RegExMatch(episodeName, posRegex, episodeNum) {
                    oAriaDownloadLinks[fileName] := downloadLink
                    validEpisodes.Push(episodeNum)
                }
            }
        }

        if (skipLinkProcess) {
            Log.Add("Helper.processSignal(): A download link is invalid. The error is: " skipLinkError)
        }
        else {
            Remark.Update("Gathering the download links... " . processedLinksCount . " out of " . oDownloadLinks.Count()
                , "Please wait as the app gathers the download links for the episodes. This may take a while, so feel free to make some milk or take a poop."
                , "Blue")
            Log.Add("Helper.processSignal(): Processing download links, " . processedLinksCount . " out of " . oDownloadLinks.Count())
        }

        ; Got everything
        if (processedLinksCount >= oDownloadLinks.Count())
        {
            SetTimer, CheckFiles, Off
            processedLinksCount := 0
            linksUnfinished := 1

            totalEpisodes := (DownloadType = "Download all episodes") ? DRAMA_TOTAL_EPISODES : (DownloadEnd - DownloadStart + 1)
            ; Check if we got all the download episodes
            if (oAriaDownloadLinks.Count() = totalEpisodes) {  ; All good
                linksUnfinished := 0
                , currentRetriesForUnavailableLinks := 1
                , validEpisodes := []

                Gui, Main:-AlwaysOnTop

                Log.Add("Helper.processSignal(): Got all download links. Proceeding to push links to Aria...")
                downloadLinksLog := "Gathered download links are:`n"
                for fileName, downloadLink in oAriaDownloadLinks {
                    downloadLinksLog .= "`t" fileName . " : " . downloadLink . "`n"
                }
                Log.Add("Helper.processSignal(): " RTrim(downloadLinksLog, "`n"))
                
                ; Sort and linearize the download link array
                linearAriaDownloadLinks := []
                Loop % DRAMA_TOTAL_EPISODES {
                    newFileName := "Episode " . A_Index ".mp4"
                    if oAriaDownloadLinks.hasKey(newFileName) {
                        newDownloadLink := oAriaDownloadLinks[newFileName]
                        linearAriaDownloadLinks.Push( {fileName: newFileName, downloadLink: newDownloadLink} )
                    }
                }
                Download.pushToAria(linearAriaDownloadLinks)
            }
            ; If not, we'll have to redownload the episodes with no valid links,
            ; provided the number of retries is below or equal to MAX_RETRIES_FOR_LINKS
            else if (currentRetriesForUnavailableLinks <= MAX_RETRIES_FOR_LINKS) {
                Log.Add("Helper.processSignal(): There are episodes that have no valid download links, retrying... " currentRetriesForUnavailableLinks " out of " MAX_RETRIES_FOR_LINKS)

                ; Remove the episodes with valid download links
                for index, episodeNumber in validEpisodes {
                    if oDownloadLinks.hasKey(episodeNumber) {
                        oDownloadLinks.Delete(episodeNumber)
                    }
                }

                ; Log the episode numbers with no valid download links
                invalidEpisodeList := ""
                for episodeNumber, downloadLink in oDownloadLinks {
                    invalidEpisodeList .= episodeNumber . ","
                }
                Log.Add("Helper.processSignal(): Episodes with no valid download links are: " RTrim(invalidEpisodeList, ","))

                currentRetriesForUnavailableLinks++
                validEpisodes := []
                ; Retry gathering for download links
                Helper.readyCredentials()
            }
            else {
                linksUnfinished := 0
                , currentRetriesForUnavailableLinks := 1
                Gui, Main:-AlwaysOnTop

                ; Log the episode numbers with no valid download links
                invalidEpisodeList := ""
                for episodeNumber, downloadLink in oDownloadLinks {
                    invalidEpisodeList .= episodeNumber . ","
                }
                Log.Add("Helper.processSignal(): Not retrying anymore. Episodes with no valid download links are: " RTrim(invalidEpisodeList, ","))

                if InStr(OnFinish, "Notify") {
                    Ntfy.sendMessage(DLEND_NOTIFY_WHO
                                    , "Autodrama needs your input!"
                                    , "There are episodes with no valid download links and I need your help to decide!")
                }
                Msgbox, % (4 + 8192), % "Notice", % "Autodrama cannot download some episodes even after retrying " MAX_RETRIES_FOR_LINKS " times.`n"
                                    . "Do you still want to proceed downloading?"
                IfMsgBox, Yes
                {
                    ; Log the gathered download links
                    downloadLinksLog := "Gathered download links are:`n"
                    for fileName, downloadLink in oAriaDownloadLinks {
                        downloadLinksLog .= "`t" fileName . " : " . downloadLink . "`n"
                    }
                    Log.Add("Helper.processSignal(): " RTrim(downloadLinksLog, "`n"))

                    ; Sort and linearize the download link array
                    linearAriaDownloadLinks := []
                    Loop % DRAMA_TOTAL_EPISODES {
                        newFileName := "Episode " . A_Index ".mp4"
                        if oAriaDownloadLinks.hasKey(newFileName) {
                            newDownloadLink := oAriaDownloadLinks[newFileName]
                            linearAriaDownloadLinks.Push( {fileName: newFileName, downloadLink: newDownloadLink} )
                        }
                    }

                    Download.pushToAria(linearAriaDownloadLinks)
                    Log.Add("Helper.processSignal(): User chose to download despite incomplete episodes.")
                }
                else
                {
                    Window.resetAll()
                    Remark.Update("Cancelled download.", "You have cancelled the download. Try again, if you like!", "Green")
                    Log.Add("Helper.processSignal(): User chose not proceed with download due to incomplete episodes.")
                }
            }
        }
        else {
            SetTimer, CheckFiles, 1000
        }
    }

    closeTabs()
    {
        ; This will close Autodrama tabs in the browser
        Run, % "https://" . DRAMA_HOSTNAME . "/?LaunchedByAutodrama?AutodramaIsFinished"
    }
}