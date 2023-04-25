// We infer that there is captcha if the "YOUR DOWNLOAD LINK" message is not shown
// In addition, there is an error landing page that disappears upon reload.
function CheckPageState() {
    pageError = $("h1:contains('503 Service Temporarily Unavailable')").length;
    if (pageError) {
		location.reload()
	}

    captchaDone = $("h3:contains('YOUR DOWNLOAD LINK')").length;
    if (captchaDone == 0) {
        DealWithCaptcha()
    } else {
        SaveDownloadLink()
    }
}

// Captcha management
function DealWithCaptcha() {
    openSesame = $("button:contains('Download Video')");
    setTimeout(function() {
        openSesame.trigger("click")
    }, Math.floor(Math.random() * (2500 - 1000) + 1000)); // Generates a number between 1000 and 2500
}

// Actual download
function SaveDownloadLink() {
    ddl = $("a:contains('Download Video')").attr('href');
    urlParams = new URL(window.location.toLocaleString()).searchParams;
    sbId = urlParams.getAll('id')[0];
    landingPage = "https://wnews247.net/d/" + sbId + ".html";
    
    // Retrieve episode/movie name using landingPage
    var gettingItem = browser.storage.local.get(landingPage);
    gettingItem.then((res) => {
        whatEpisode = res[landingPage];
        SaveToDisk(whatEpisode + "|" + ddl, whatEpisode + ".autodramatext", 1);
    });
}

// Code starts here
jQuery(document).ready(CheckPageState());