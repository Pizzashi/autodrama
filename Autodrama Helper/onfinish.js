function setItem() {
	console.log("Stored an object successfully.");
}

function onRemoved() {
	console.log("Removed an object successfully.");
}

function onError(error) {
	console.log(`Error: ${error}`);
}

// Set mode to 1 if finished, otherwise set to 0 to remove the finished flag
function SetFinishedFlag(mode)
{
	let setFinishFlag = browser.storage.local.set({
		helperCanClose: mode
	});
	setFinishFlag.then(setItem, onError);
}

function SetErrorFlag(mode)
{
	let setFinishFlag = browser.storage.local.set({
		fatalError: mode
	});
	setFinishFlag.then(setItem, onError);
}

function checkFinishedFlag()
{
	var gettingItem = browser.storage.local.get("helperCanClose");

	gettingItem.then((res) => {
		if (res.helperCanClose && window.location.pathname == "/")
		{	
			SetFinishedFlag(0);
			// window.close() only works if dom.allow_scripts_to_close_windows is set to true
			window.close();
		}
	});
}

//=================================Start here=================================

if (window.location.href.match(/\?AnotherInstance/)) {
	SetFinishedFlag(0);
	SetErrorFlag(0);
}

if (window.location.href.match(/\?AutodramaIsFinished/)) {
	SetFinishedFlag(1);
	// window.close() only works if dom.allow_scripts_to_close_windows is set to true
    window.close();
}

if (window.location.href.match(/\?AutodramaFatalError/)) {
	SetErrorFlag(1);
	// window.close() only works if dom.allow_scripts_to_close_windows is set to true
    window.close();
}

// Check for helperCanClose flag every 3 seconds
setInterval(checkFinishedFlag, 3000)