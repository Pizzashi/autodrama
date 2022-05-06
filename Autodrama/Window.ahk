class Window
{
    resetAll()
    {
        Global
        this.enableInput()
        this.enableOptions()
        this.disableDownload()
        this.downloadControls("Disable", "Disable")

        gidList :=
        oAriaDownloadLinks :=
    }

    downloadControls(pauseState, resumeState)
    {
        Global
        
        if (pauseState ~= "Enable|Disable")
            GuiControl, Main:%pauseState%, PauseDownloadBtn
        if (resumeState ~= "Enable|Disable")
            GuiControl, Main:%resumeState%, ResumeDownloadBtn
    }

    disableOptions()
    {
        Global
        GuiControl, Main:Disable, DownloadType
        GuiControl, Main:Disable, OnFinish
        GuiControl, Main2:Disable, DownloadStart
        GuiControl, Main2:Disable, DownloadEnd
    }
    
    enableOptions()
    {
        Global
        GuiControl, Main:Enable, DownloadType
        GuiControl, Main:Enable, OnFinish
        GuiControl, Main2:Enable, DownloadStart
        GuiControl, Main2:Enable, DownloadEnd
    }
    
    disableDownload()
    {
        Global
        GuiControl, Main:Disable, DownloadBtn
    }

    enableDownload()
    {
        Global
        GuiControl, Main:Enable, DownloadBtn
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