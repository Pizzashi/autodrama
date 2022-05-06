FatalError(message)
{
    Log.Add("FATAL ERROR - Message: " . message)
    MsgBox, 48, Error, %message%
    ExitApp
}