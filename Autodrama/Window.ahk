class Window
{
    resetAll()
    {
        Global

        GuiControl, Main:-g, RemarkText
        this.enableOptions()
        this.disableDownload()
        this.enableInput()
        
        gidList :=
        oAriaDownloadLinks :=
    }
    
    downloadControls(pauseState, resumeState)
    {
        Global
        
        pauseState := 1 ? "Enable" : 0 ? "Disable" : pauseState
        , resumeState := 1 ? "Enable" : 0 ? "Disable" : resumeState

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
        ; SearchIcon GoSub is gSearchDrama
        ; Use GuiControl, Main:+gSearchDrama, SearchIcon
        GuiControl, Main:-g, SearchIcon
        GuiControl, Main:Disable, DramaLink
        this.disableOptions()
    }

    enableInput()
    {
        Global
        GuiControl, Main:+g, SearchIcon, SearchDrama
        GuiControl, Main:Enable, DramaLink
        this.enableOptions()
    }

    updateComboBox()
    {
        Global
    }
}