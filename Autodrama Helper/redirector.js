function setItem() {
	console.log("Stored an object successfully.");
}

function onCleared() {
	console.log("Successfully cleared local storage.");
}

function onError(error) {
	console.log(`Error: ${error}`);
}

{
	let oDownloadPage = $("a:contains('CLICK HERE TO DOWNLOAD')");
	let dramaName = $("a:contains('information')").text().match(/Drama\s+(.*?)\s+information/)[1];
	let pageTimeOut = $('body:contains("Gateway time-out")').length;
	
	let movieDramaType = window.location.href.includes("Movie?") ? 1 : 0;

	// Page is dead
	if (pageTimeOut) {
		window.location.reload();
	}

	// Download link exists
	if (oDownloadPage.length) {
		// for debugging
		//var clearStorage = browser.storage.local.clear();
		//clearStorage.then(onCleared, onError);
		
		let downloadPage = oDownloadPage.attr('href');
		let currentEpisode = {}

		if (movieDramaType) {
			currentEpisode[downloadPage] = dramaName + " Movie";	
		}
		else {
			let episodeName = $("#selectEpisode option:selected").text().trim();
			currentEpisode[downloadPage] = dramaName + " " + episodeName;
		}

		let saveCurrentEpisode = browser.storage.local.set(currentEpisode);
		saveCurrentEpisode.then(setItem, onError);
		window.location.href = downloadPage;
		
		// to add another entry to currentEpisode, just do:
		//currentEpisode['episode3'] = "exmapl.vcom";
		//browser.storage.local.set(currentEpisode).then(setItem, onError);
		
		// GET CODE
		//var gettingItem = browser.storage.local.get(downloadPage);
		//gettingItem.then((res) => {
		//  whatEpisode = res[downloadPage];
		//  alert(whatEpisode);
		//});
	}

	// Kissasian is using the beta server and not the FE server
	if (window.location.href.includes("&s=beta")) {
		episodeName = !(episodeName) ? "undefined_episode_name" : episodeName;
		SaveToDisk(episodeName
				+ " can't be downloaded automatically. href of the window is: "
				+ window.location.href
				, "err.autodramatext");
		window.close(); // Only works if dom.allow_scripts_to_close_windows is set to true
	}
}