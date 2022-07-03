function setItem() {
	console.log("Stored an object successfully.");
}

function onRemoved() {
	console.log("Removed an object successfully.");
}

function onError(error) {
	alert(`Error: ${error}`);
}

function onCleared() {
	console.log("Successfully cleared local storage.");
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

function clearLocalStorage()
{
	var clearStorage = browser.storage.local.clear();
	clearStorage.then(onCleared, onError);
}

//=================================Start here=================================

if (window.location.href.match(/\?AnotherInstance/)) {
	SetFinishedFlag(0);
	SetErrorFlag(0);
}

if (window.location.href.match(/\?AutodramaIsFinished/)) {
	// Clear the local storage when the session ends
	clearLocalStorage()

	SetFinishedFlag(1);
	// window.close() only works if dom.allow_scripts_to_close_windows is set to true
    window.close();
}

if (window.location.href.match(/\?AutodramaFatalError/)) {
	// Clear the local storage when there is an error
	clearLocalStorage()

	SetErrorFlag(1);
	// window.close() only works if dom.allow_scripts_to_close_windows is set to true
    window.close();
}

// Check for helperCanClose flag every 3 seconds
setInterval(checkFinishedFlag, 3000)