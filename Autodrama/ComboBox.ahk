class ComboBox
{
    readPrevHistory()
    {
        if !FileExist("configuration.ini") {
            FileAppend,, configuration.ini
            return
        }

        IniRead, prevHistory, configuration.ini, UserData, SearchHistory, %A_Space%
        COMBO_BOX_HISTORY := prevHistory

        return
    }

    updateHistory(currentDramaLink)
    {
        Global

        local comboBoxList := ""

        Gui, Main:Submit, NoHide
        ControlGet, comboBoxList, List,,, ahk_id %hDramaLink%

        ; This parse loop tests if the first index of the history is DramaLink
        ; If it is, then there is no need to update history
        Loop, Parse, comboBoxList, `n, `r
        {
            if (DramaLink = A_LoopField)
                return ; Stops the function
            
            break ; Only A_Index = 1 is needed (latest link)
        }

        COMBO_BOX_HISTORY := DramaLink . "|" ; Make DramaLink the starting entry
        if !(comboBoxList) ; if comboBoxList is empty, the loop below won't proc, and DramaLink won't be set as the default entry
            COMBO_BOX_HISTORY .= "|"
            
        Loop, Parse, comboBoxList, `n, `r
        {
            if (A_Index > 4)
                break

            if (A_LoopField != DramaLink)
                COMBO_BOX_HISTORY .= "|" . A_LoopField
        }

        ; The pipe (|) at the start is necessary for the DDL options to be replaced
        ; otherwise, they will be appended at the other options
        try GuiControl, Main:, DramaLink, % "|" COMBO_BOX_HISTORY
        catch
            Log.Add("ERROR: ComboBox.updateHistory(): The app could not edit the DDL for the ComboBox (vDramaLink).")
        
        try IniWrite, %COMBO_BOX_HISTORY%, configuration.ini, UserData, SearchHistory
        catch
            Log.Add("ERROR: ComboBox.updateHistory(): The app could not write COMBO_BOX_HISTORY into SearchHistory in configuration.ini")
    }
}