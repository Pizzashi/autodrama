function CheckPageState() {
    // These QualityUrl variables means matching _n/_h/_x at the end of the url
    // They would match "https://kswplayer.info/f/o0eqiwskqc2r_n" for example
    let sdQualityUrl = window.location.href.match(/_n/)
    let hdQualityUrl = window.location.href.match(/_h/)
    let uhdQualityUrl = window.location.href.match(/_x/)
    let versionNotAvail = $("div:contains('This version is not available for this video')").length;
    let noSuchFile = $("div:contains('No such file!!')").length;
    let fileNotAvailable = $("div:contains('File not available!')").length;
    let finalDownloadTextPresent = $("h3:contains('YOUR DOWNLOAD LINK')").length;
    let downloadBtn = $("button.g-recaptcha");

    if (noSuchFile) {
        // Throw an error, we don't have a download link for an episode
        SaveToDisk("downloadNotAvailable", "err.autodramatext", 1);
    }
    else if (sdQualityUrl || hdQualityUrl || uhdQualityUrl) {    
        if (finalDownloadTextPresent) {
            ddl = $("a:contains('Download Video')").attr('href');
            landingPage = window.location.href.replace(/_\w$/, ".html")
            
            // Retrieve episode/movie name using landingPage
            var gettingItem = browser.storage.local.get(landingPage);
            gettingItem.then((res) => {
                whatEpisode = res[landingPage];
                SaveToDisk(whatEpisode + "|" + ddl, whatEpisode + ".autodramatext", 1);
            });         
        }
        else if (downloadBtn.length) {
            ClickFirstDownloadLink(downloadBtn)
        }
        else if (versionNotAvail || fileNotAvailable) {
            // Throw an error, we don't have a download link for an episode
            SaveToDisk("downloadNotAvailable", "err.autodramatext", 1);
        }
    }
    else {
        downloadLink480 = $("div.col-auto.flex-grow-1.flex-shrink-1:contains('Normal quality')");
        downloadLink720 = $("div.col-auto.flex-grow-1.flex-shrink-1:contains('HD quality')");
        downloadLink1080 = $("div.col-auto.flex-grow-1.flex-shrink-1:contains('UHD quality')");
        currentUrl = window.location.href

        if (downloadLink480.length) {
            window.location.href = currentUrl.replace(".html", "_n")
        }
        else if (downloadLink720.length) {
            window.location.href = currentUrl.replace(".html", "_h")
        }
        else if (downloadLink1080.length) {
            window.location.href = currentUrl.replace(".html", "_x")
        }
    }
}

// Avoid securityerror1
function ClickFirstDownloadLink(downloadBtn) {
    setTimeout(function() {
        downloadBtn.trigger("click")
    }, Math.floor(Math.random() * (2500 - 1000) + 1000)); // Generates a number between 1000 and 2500
}

// Code starts here
jQuery(document).ready(CheckPageState());