class Window
{
    resetAll()
    {
        Global

        Cleanup()
        
        this.enableInput()
        this.hideDownloadOptions()
        this.enableOptions()
        this.disableDownload()
        this.downloadControls("Disable", "Disable", "Disable")

        ; Clear the "from" and "to" episodes in "Download chosen episodes"
        GuiControl, MainO2:, DownloadStart
        GuiControl, MainO2:, DownloadEnd
        gidList := ""
        oAriaDownloadLinks := ""
    }

    hideDownloadOptions()
    {
        Global
        Gui, MainO:Hide
        GuiControl, Main:Show, StartGuide
    }

    showDownloadOptions()
    {
        Global
        GuiControl, Main:Hide, StartGuide
        Gui, MainO:Show
    }

    downloadControls(pauseState, resumeState, cancelState)
    {
        Global
        
        if (pauseState ~= "Enable|Disable")
            GuiControl, MainO:%pauseState%, PauseDownloadBtn
        if (resumeState ~= "Enable|Disable")
            GuiControl, MainO:%resumeState%, ResumeDownloadBtn
        if (cancelState ~= "Enable|Disable")
            GuiControl, MainO:%cancelState%, CancelDownloadBtn
    }

    disableOptions()
    {
        Global
        GuiControl, MainO:Disable, DownloadType
        GuiControl, MainO2:Disable, DownloadStart
        GuiControl, MainO2:Disable, DownloadEnd
    }
    
    enableOptions()
    {
        Global
        GuiControl, MainO:Enable, DownloadType
        GuiControl, MainO2:Enable, DownloadStart
        GuiControl, MainO2:Enable, DownloadEnd
    }
    
    disableDownload()
    {
        Global
        GuiControl, MainO:Disable, DownloadBtn
    }

    enableDownload()
    {
        Global
        GuiControl, MainO:Enable, DownloadBtn
    }

    disableInput()
    {
        Global
        ENABLE_SEARCH_DRAMA := 0 ; Disable search button
        GuiControl, Main:Disable, DramaLink
        this.disableOptions()
    }

    enableInput()
    {
        Global
        ENABLE_SEARCH_DRAMA := 1 ; Enable search button
        GuiControl, Main:Enable, DramaLink
        this.enableOptions()
    }
}