OpenDownloadFolder:
    Run, % MOVIE_DOWNLOAD_PATH
return

LaunchAdvancedSettings:
    if (advSettingsClicks < 3) {
        advSettingsClicks++
        return
    } else if (advSettingsClicks < 4) {
        advSettingsClicks++
        Remark.Update("Press me one more time to launch the advanced settings!"
                    , "Make sure Baconfry-senpai has instructed you to do so before doing this."
                    , "Teal")
        return
    }

    AdvancedSettings.Launch()

    Remark.Update("Successfully launched the advanced settings."
                    , "Please do proceed with caution."
                    , "Green")
return

ResumeDownloads:
    SetTimer, UpdateStatus, 1000
    if (aria2.unpauseAll().result = "OK") {
        Window.downloadControls("Enable", "Disable", "Enable")
        Log.Add("ResumeDownloads: Successfully resumed Aria2c downloads.")
        Remark.Update("Successfully resumed downloads."
                    , "Your downloads were paused with no problems."
                    , "Green")
    }
    else {
        Log.Add("ERROR: ResumeDownloads: Error in resuming Aria2c downloads.")
        Remark.Update("There's an error in resuming your downloads!"
                    , "Your downloads could not be resumed successfully. Please close the app and try again."
                    , "Red"
                    , 1)
    }
    Gosub, UpdateStatus ; Start updating GUI immediately
return

PauseDownloads:
    SetTimer, UpdateStatus, Off
    if (aria2.pauseAll().result = "OK") {
        Window.downloadControls("Disable", "Enable", "Enable")
        Log.Add("PauseDownloads: Successfully paused Aria2c downloads.")
        Remark.Update("Successfully paused downloads."
                    , "Your downloads were paused with no problems."
                    , "Green")
    }
    else {
        Log.Add("ERROR: PauseDownloads: Error in pausing Aria2c downloads.")
        Remark.Update("An error occured while pausing your downloads!"
                    , "Your downloads could not be paused successfully. Please close the app and try again."
                    , "Red"
                    , 1)
    }    
return

CancelDownloads:
    SetTimer, UpdateStatus, Off

    Log.Add("CancelDownloads: Attempting to shutdown aria2c.")
    if (aria2.shutdown().result = "OK") {
		Window.resetAll()
        Remark.Update("Successfully cancelled downloads."
                    , "Your downloads have been successfully cancelled. You may try searching another drama again."
                    , "Green")
    }
    else {
        Log.Add("ERROR: CancelDownloads: Error in shutting down aria.")
        Remark.Update("There was an error in cancelling your downloads."
                    , "Your downloads could not be cancelled. Close and restart the app instead."
                    , "Red"
                    , 1)
    }
return

SearchDrama:
    if !(ENABLE_SEARCH_DRAMA)
        return

    Gui, Main:Submit, NoHide
    
    ClearObjects() ; Reset objects

    ; Check for invalid input
    if (!RegExMatch(DramaLink, "(https|http):\/\/kissasian\.(\w+)\/(Drama|Movie)\/.*") || RegExMatch(DramaLink, "(https|http):\/\/kissasian\.(\w+).+(https|http):\/\/kissasian\.(\w+)"))
    {
        Remark.Update("Houston, we have a problem."
                    , "Badet, you are one so very useless egg. Your drama link is invalid, check if it is correct."
                    , "Red"
                    , 1)
        Log.Add("ERROR: Badet placed invalid DramaLink: " DramaLink)
        return
    }

    Window.disableInput()
    Window.disableDownload()
    Remark.Update("Working..."
                , "Getting the drama info, please wait..."
                , "Blue")
    Log.Add("SearchDrama: Searching for drama...")

    oDramaInfo := Drama.getPageInfo(DramaLink)
    if (oDramaInfo = "networkError") {
        Remark.Update("Error! Error! Error!"
                    , "The application cannot download the drama information due to network problems, please try again."
                    , "Red"
                    , 1)
        Window.disableDownload()
        Window.enableInput()
        return
    }
    else if (oDramaInfo = "pageNotFound") {
        Remark.Update("Error! The requested link was not found on the server!"
                    , "It looks like the drama link you entered is incorrect, or does not exist on the server. Try copying the entire link again."
                    , "Red"
                    , 1)
        Log.Add("ERROR: Badet has input an invalid drama link. DramaLink: " . DramaLink)
        Window.disableDownload()
        Window.enableInput()
        return
    }

    oDownloadLinks := oDramaInfo[7]
    if !(Drama.allLinksUp(oDownloadLinks)) {
        Remark.Update("One of the episode links cannot be reached."
                    , "Looks like not all episodes have valid links. Please try searching for the drama again."
                    , "808000")
        Window.disableDownload()
        Window.enableInput()
        return   
    }

    eBuildError := Drama.buildDramaInfoGUI(oDramaInfo)
    if (eBuildError) {
        Remark.Update("Got the drama information, but..."
                    , "The Drama image could not be downloaded successfully. Please try searching again."
                    , "808000")
        Window.disableDownload()
        Window.enableInput()
        return
    }
    
    ; Everything looks good!
    Remark.Update("Got the drama information!"
                , "Look at the drama details. If this is the drama that you intend to download, then modify the Options and hit download!"
                , "Green")
    Log.Add("SearchDrama: Successfully processed drama information and download links.")
    ComboBox.updateHistory(DramaLink) ; Record the last link to history
    Window.enableInput()
    Window.enableDownload()
    Window.showDownloadOptions()
return

DownloadDrama:
    Gui, Main:Submit, NoHide
    Gui, MainO:Submit, NoHide
    Gui, MainO2:Submit, NoHide
    
    if (DownloadType = "Download chosen episodes") {
        /**
         * Infer DownloadEnd if it is empty.
         *
         * If DownloadEnd is empty, it means the user only wants to download one episode,
         * that is, DownloadStart.
         */
        if (!DownloadEnd) {
            DownloadEnd := DownloadStart
            GuiControl, MainO2:, DownloadEnd, % DownloadEnd
        }
        
        /**
         * Check for invalid input. The tracked invalid inputs are:
         * - DownloadStart is greater than DownloadEnd
         * - DownloadStart is empty
         * - DownloadStart is less than 1
         * - DownloadEnd is greater than the last episode
         */
        if ( (DownloadStart > DownloadEnd)
          || (!DownloadStart)
          || (DownloadStart < 1)
          || (DownloadEnd > oDownloadLinks.Length()) ) {
            Remark.Update("There's an error on the chosen download range."
                        , "You useless badet. Recheck your chosen download episodes. Dapat mas gamay ang ""from"" kaysa ""to"". Take note nga dili pwede apilon ang mga raw kay dili kabalo mag Korean si mather you useless egg."
                        , "Red"
                        , 1)
            Log.Add("ERROR: Badet has screwed up on choosing the download episodes."
                    . "`nDownloadStart: " DownloadStart
                    . "`nDownloadEnd: " DownloadEnd
                    . "`nMaximum episode: " oDownloadLinks.Length())
            return
        }
    }

    Log.Add("DownloadDrama: Downloading the selected drama...")
    Window.disableInput()
    Window.disableDownload()
    Window.disableOptions()

    ; Modify oDownloadLinks if user chose to download chosen episodes
    ; Do not append this code to the previous if-statement, this is not checking for invalid input
    if (DownloadType = "Download chosen episodes") {
        beginLen := (DownloadStart - 1)
        oDownloadLinks.RemoveAt(1, beginLen)

        endStart := (DownloadEnd - DownloadStart + 2)
        endLen := (oDownloadLinks.Length() - endStart + 1)
        oDownloadLinks.RemoveAt(endStart, endLen)
    }

    global DRAMA_FOLDER := MOVIE_DOWNLOAD_PATH . Download.makeWinFriendly(oDramaInfo[1] . " (" . oDramaInfo[2] . ")")
    ; From this point, the Remarks.Update code will be written in the Helper and Download classes
    ; Check if Aria can be started
    if !Download.startAria()
        return
    ; Start download process
    Helper.readyCredentials()
return

ChangeDownloadType:
    Gui, MainO:Submit, NoHide
    if (DownloadType = "Download chosen episodes") {
        Gui, MainO2:Show
    } else {
        Gui, MainO2:Hide
    }
return

MainGuiClose:
ExitApp