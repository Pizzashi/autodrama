function setItem() {
	console.log("Stored an object successfully.");
}

function onCleared() {
	console.log("Successfully cleared local storage.");
}

function onError(error) {
	alert(`Error: ${error}`);
}

function CrawlPage() {
	const LAUNCHED_BY_AUTODRAMA = window.location.href.match(/\?LaunchedByAutodrama/)
	let oDownloadPage = $("a:contains('CLICK HERE TO DOWNLOAD')");
	let dramaName = $("a:contains('information')").text().match(/Drama\s+(.*?)\s+information/)[1];
	let pageTimeOut = $('body:contains("Gateway time-out")').length;
	
	let movieDramaType = window.location.href.includes("Movie?")

	if (!LAUNCHED_BY_AUTODRAMA)
		return

	// Page is dead
	if (pageTimeOut) {
		window.location.reload();
	}

	// Kissasian is using the beta server and not the FE server
	if (window.location.href.includes("&s=beta")) {
		SaveToDisk("eFeNotAvail", "err.autodramatext");
		// Only works if dom.allow_scripts_to_close_windows is set to true
		window.close();
	}

	// Download link exists
	if (oDownloadPage.length) {
		/*	
		 * 	for debugging
		 *  var clearStorage = browser.storage.local.clear();
		 *	clearStorage.then(onCleared, onError);
		 */

		let downloadPage = oDownloadPage.attr('href');
		let currentEpisode = {}

		if (movieDramaType) {
			currentEpisode[downloadPage] = dramaName + " Movie";	
		}
		else {
			let episodeName = $("#selectEpisode option:selected").text().trim();
			currentEpisode[downloadPage] = dramaName + " " + episodeName;
		}
		
		// First fix attempt to fix the wretched "undefined.autodramatext"
        if (whatEpisode.matches(/^undefined(\s\(\d+?\))?/)) {
			window.location.reload();
		}

		let saveCurrentEpisode = browser.storage.local.set(currentEpisode);
		saveCurrentEpisode.then(setItem, onError);
		window.location.href = downloadPage;
		
		/*
		 *	To add another entry to currentEpisode, the code is:
		 *		currentEpisode['episode3'] = "exmapl.vcom";
		 *		browser.storage.local.set(currentEpisode).then(setItem, onError);
		 *	
		 *  To retrive an entry from local storage, a sample code is:
		 *  	var gettingItem = browser.storage.local.get(downloadPage);
		 *		gettingItem.then((res) => {
		 *			whatEpisode = res[downloadPage];
		 *			alert(whatEpisode);
		 *		});
		 */
	}
}

// If the page is not responsive for 5 seconds, this portion will reload the page
setTimeout(function() {
	location.reload();
}, 5000)

// Crawl for information 1 second after the page is ready (to ensure full readiness of the webpage)
jQuery(document).ready(setTimeout(CrawlPage, 1000));