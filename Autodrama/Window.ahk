class Window
{
    disableDownload()
    {
        Global
        GuiControl, Main:Disable, DownloadButton
    }

    enableDownload()
    {
        Global
        GuiControl, Main:Enable, DownloadButton
    }

    disableInput()
    {
        Global
        ; SearchIcon GoSub is gSearchDrama
        ; Use GuiControl, Main:+gSearchDrama, SearchIcon
        GuiControl, Main:-g, SearchIcon
        GuiControl, Main:Disable, DramaLink
    }

    enableInput()
    {
        Global
        GuiControl, Main:+gSearchDrama, SearchIcon
        GuiControl, Main:Enable, DramaLink
    }

    updateComboBox()
    {
        Global
    }
}