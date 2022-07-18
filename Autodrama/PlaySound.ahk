TheKing(playMusic := 1)
{
    ; Because +OwnDialogs is unique for each thread, this must be declared here
    Gui, Main:+OwnDialogs
    ; The actual music length is 136.463687 seconds (value retrieved using sox)
    static MUSIC_LENGTH := 136

    if !(playMusic) {
        Log.Add("TheKing(): Successfully stopped the song (User called with 0 parameter).")
        PlaySound(0) ; Stop the song
        return
    }

    Dll.Read(Sound, "resources.dll", "Audio", "HoundDog.wav")
    sucessfulPlay := PlaySoundAsync(Sound)
    if (sucessfulPlay) {
        Log.Add("TheKing(): Successfully played the song.")

        /**
         * DO NOT set a Task Modal flag in the MsgBox,
         * this will cause the app to freeze when MsgBox times out.
         * Use Gui, Main:+OwnDialogs instead (see above)
         */
        MsgBox, 0, % " Your download is complete!"
                    , % "To stop playing THE KING, simply click OK or close this message box."
                    , % MUSIC_LENGTH
        PlaySound(0) ; Stop the song

        Log.Add("TheKing(): Successfully stopped the song.")
        return
    }
}

/*  Use PlaySound(0) or any nonexistent variable to stop the playing sound (this will return 0)
 *
 *  Do not set the error checking within the functions!
 *  To stop an audio from playing, PlaySound() or PlaySoundAsync() are called with null parameters (or 0)
 *  This means that if you terminate the current audio, the functions will return 0
 *  So it would look like there's an error
 */
PlaySound( ByRef Sound ) {
    Return DllCall( "winmm.dll\PlaySound" ( A_IsUnicode ? "W" : "A" ), UInt,&Sound, UInt,0
               , UInt, 0x6 ) ; SND_MEMORY := 0x4 | SND_NODEFAULT := 0x2
}
PlaySoundAsync( ByRef Sound ) {
    Return DllCall( "winmm.dll\PlaySound" ( A_IsUnicode ? "W" : "A" ), UInt,&Sound, UInt,0, UInt, 0x7 )
}