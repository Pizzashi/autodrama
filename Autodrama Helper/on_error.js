// This script monitors if the main application signalled a fatal error
// such as one of the download links are not up.
// The error flag is modified in "onfinish.js" at SetErrorFlag()

function checkErrorFlag()
{
	browser.storage.local.get("fatalError").then((res) => {
		if (res.fatalError)
			window.close();
	});
}

// Check for fatalError flag every 3 seconds
setInterval(checkErrorFlag, 3000)