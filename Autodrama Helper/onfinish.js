function setItem() {
	console.log("Stored an object successfully.");
}

function onRemoved() {
	console.log("Removed an object successfully.");
}

function onError(error) {
	console.log(`Error: ${error}`);
}

function setFinishedFlag()
{
	let setFinishFlag = browser.storage.local.set({
		helperCanClose: 1
	});
	setFinishFlag.then(setItem, onError);

    window.close(); // Only works if dom.allow_scripts_to_close_windows is set to true
}

function unsetFinishedFlag()
{
	let removeFlag = browser.storage.local.remove("helperCanClose");
	removeFlag.then(onRemoved, onError);
}

function checkFinishedFlag()
{
	var gettingItem = browser.storage.local.get("helperCanClose");

	gettingItem.then((res) => {
		if (res.helperCanClose && window.location.href == "https://kissasian.li/")
		{
			let setFinishFlag = browser.storage.local.set({
				helperCanClose: 0
			});
			setFinishFlag.then(setItem, onError);
			window.close(); // Only works if dom.allow_scripts_to_close_windows is set to true
		}
	});
}

if (window.location.href.match(/\?AnotherInstance/))
	unsetFinishedFlag();

if (window.location.href.match(/\?AutodramaIsFinished/))
    setFinishedFlag();

// Check for helperCanClose flag every 3 seconds
setInterval(checkFinishedFlag, 3000)