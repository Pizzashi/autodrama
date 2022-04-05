class Dll
{
	Read(ByRef Var, Filename, Section, Key) {    ; By SKAN | goo.gl/DjDxzW
		Local ResType, ResName, hMod, hRes, hData, pData, nBytes := 0
		ResName := ( Key+0 ? Key : &Key ), ResType := ( Section+0 ? Section : &Section )

		VarSetCapacity( Var,128 ), VarSetCapacity( Var,0 )
		If hMod  := DllCall( "LoadLibraryEx", "Str",Filename, "Ptr",0, "UInt",0x2, "Ptr" )
		If hRes  := DllCall( "FindResource", "Ptr",hMod, "Ptr",ResName, "Ptr",ResType, "Ptr" )
		If hData := DllCall( "LoadResource", "Ptr",hMod, "Ptr",hRes, "Ptr" )
		If pData := DllCall( "LockResource", "Ptr",hData, "Ptr" )
		If nBytes := DllCall( "SizeofResource", "Ptr",hMod, "Ptr",hRes )
			VarSetCapacity( Var,nBytes,1 )
		, DllCall( "RtlMoveMemory", "Ptr",&Var, "Ptr",pData, "Ptr",nBytes )
		DllCall( "FreeLibrary", "Ptr",hMod )
		Return nBytes
	}

	; DllEnum( Filename, Section, Prefix, Delimiter )
	; Imgs := DllEnum( "Images.dll", "MyImages", "", "`n" )
	Enum( P1, P2, P3, P4 ) {                       ; By SKAN | goo.gl/DjDxzW
		Local hMod, hGlobal
		Static Section  :=   L := Prefix := Delim := "" 
		If ( Section and ( L .= Prefix . StrGet(P3+0) . Delim ) )
			Return True
		Section := P2, Prefix := P3, Delim := P4 
		hMod := DllCall( "LoadLibrary", "Str", P1, "Ptr" )
		hGlobal := RegisterCallback( A_ThisFunc, "F" )
		DllCall( "EnumResourceNames", "Ptr",hMod, "Str",P2, "Ptr",hGlobal, "UInt",123 )
		DllCall( "GlobalFree", "Ptr",hGlobal, "Ptr")
		DllCall( "FreeLibrary", "Ptr",hMod )
		Return RTrim( L, Delim ) . ( Section := L := Prefix :=  Delim := "" )
	}
}