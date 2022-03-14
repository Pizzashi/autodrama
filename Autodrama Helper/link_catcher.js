function GetResults()
{
    var eNoDownload = $('button:contains("Sorry, no download available")').length;
    var eTooManyReqs = $('h1:contains("429 Too Many Requests")').length;
    var eServiceUnavail = $('h1:contains("503 Service Temporarily Unavailable")').length;
    
    if (eNoDownload || eTooManyReqs || eServiceUnavail) {
        location.reload();
    }

    var href360 = $("a:contains('360')").attr('href');
    var href480 = $("a:contains('480')").attr('href');
    var href720 = $("a:contains('720')").attr('href');
    var href1080 = $("a:contains('1080')").attr('href');
    directDownloadLink = href360 || href480 || href720 || href1080 || "no_download_link";

    // Retrieve local storage
    var pageHref = window.location.href;
    var gettingItem = browser.storage.local.get(pageHref);
    gettingItem.then((res) => {
      whatEpisode = res[pageHref];
      SaveToDisk(whatEpisode + "|" + directDownloadLink, whatEpisode + ".autodramatext", 1);
    });
}

// Waits for $(document).ready()
$("#download").trigger('click');
// Wait for at least 12 seconds to check for errors
// Error message/download link should appear by 10 seconds after clicking
setTimeout(GetResults, 12000)