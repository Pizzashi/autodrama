#NoEnv 
ResRead( Sound, "dog.wav" )
PlaySoundAsync( Sound )
Sleep, 3000
PlaySound(null)


Return ; // end of auto-execute section //
FileInstall, chimes.wav, chimes.wav
;never executed, so never extracted, this should be replaced with ahk2exe directives when applicable!

ResRead( ByRef Var, Key ) { 
  VarSetCapacity( Var, 128 ), VarSetCapacity( Var, 0 )
  If ! ( A_IsCompiled ) {
    FileGetSize, nSize, %Key%
    FileRead, Var, *c %Key%
    Return nSize
  }
 
  If hMod := DllCall( "GetModuleHandle", UInt,0 )
    If hRes := DllCall( "FindResource", UInt,hMod, Str,Key, UInt,10 )
      If hData := DllCall( "LoadResource", UInt,hMod, UInt,hRes )
        If pData := DllCall( "LockResource", UInt,hData )
  Return VarSetCapacity( Var, nSize := DllCall( "SizeofResource", UInt,hMod, UInt,hRes ) )
      ,  DllCall( "RtlMoveMemory", Str,Var, UInt,pData, UInt,nSize )
Return 0    
}

PlaySound( ByRef Sound ) {
 Return DllCall( "winmm.dll\PlaySound" ( A_IsUnicode ? "W" : "A" ), UInt,&Sound, UInt,0
               , UInt, 0x6 ) ; SND_MEMORY := 0x4 | SND_NODEFAULT := 0x2
}

PlaySoundAsync( ByRef Sound ) {
 Return DllCall( "winmm.dll\PlaySound" ( A_IsUnicode ? "W" : "A" ), UInt,&Sound, UInt,0, UInt, 0x7 )
}