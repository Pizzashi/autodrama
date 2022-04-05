class Remark
{
    Update(newTitle := "", newText := "", newColor := "", playErrorSound := 0)
    {
        Global

        if (newColor)
            GuiControl, Main:+c%newColor%, RemarkTitle
        if (newTitle)
            GuiControl, Main:, RemarkTitle, % newTitle
        if (newText)
            GuiControl, Main:, RemarkText, % newText

        if (playErrorSound)
            SoundPlay, *16, 1
    }

    updTitle(text, color := "", playErrorSound := 0)
    {
        Global
        if (playErrorSound)
            SoundPlay, *16, 1
        GuiControl, Main:, RemarkTitle, %text%
        GuiControl, Main:+c%color%, RemarkTitle
    }

    updText(text)
    {
        Global
        GuiControl, Main:, RemarkText, %text%
    }
}