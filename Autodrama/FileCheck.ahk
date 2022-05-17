FileCheck(ReqFiles)
{
    Loop, Parse, ReqFiles, `,
    {
        if !FileExist(Trim(A_LoopField))
            FatalError("""" A_LoopField """" . " was not found! Try redownloading the app.")
    }
}