#NoEnv
#Include Dll.ahk

Dll.Read(Sound, "resources.dll", "Audio", "HoundDog.wav")
Msgbox % PlaySoundAsync(Sound)
Sleep, 5000
Msgbox % PlaySound(0)
return

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