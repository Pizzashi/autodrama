﻿class aria2_base
{
	__call(method, params*)
	{
		If method not in % this.methods
			Return "error: invalid method."

		data := { "jsonrpc": "2.0"
		        , "id": "1"
		        , "method": "aria2." method
		        , "params": ["token:" SCRT_TOKEN, params*] }
		data := Jxon_Dump(data)

		httpPost( this.url, data, "utf-8" )

		Return Jxon_Load(data)
	}
}

class aria2 extends aria2_base
{
	static url := "http://127.0.0.1:6800/jsonrpc"

	; http://aria2.sourceforge.net/manual/en/html/aria2c.html#rpc-interface
	static methods := "addUri,addMetalink,remove,forceRemove"
	                . ",pause,pauseAll,forcePause,forcePauseAll,unpause"
	                . ",unpauseAll,tellStatus,getUris,getFiles,getPeers"
	                . ",getServers,tellActive,tellWaiting,tellStopped"
	                . ",changePosition,changeUri,getOption,changeOption"
	                . ",getGlobalOption,changeGlobalOption,getGlobalStat"
	                . ",purgeDownloadResult,removeDownloadResult,getVersion"
	                . ",getSessionInfo,shutdown,forceShutdown,saveSession,multicall"
}