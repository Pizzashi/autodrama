class ComboBox
{
    readPrevHistory()
    {
        COMBO_BOX_HISTORY := Config.Read("UserData", "SearchHistory")
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
        GuiControl, Main:, DramaLink, % "|" COMBO_BOX_HISTORY
        Config.Write("UserData", "SearchHistory", COMBO_BOX_HISTORY)
    }
}