function BeforeCompleteGetResults()
{
    var eTooManyReqs = $('h1:contains("429 Too Many Requests")').length;
    if (eTooManyReqs) {
        location.reload();
        return
    }
}

function GetResults()
{
    var eNoDownload = $('button:contains("Sorry, no download available")').length;
    var eServiceUnavail = $('h1:contains("503 Service Temporarily Unavailable")').length;
    
    if (eNoDownload || eServiceUnavail) {
        location.reload();
        return
    }

    var href360 = $("a:contains('360')").attr('href');
    var href480 = $("a:contains('480')").attr('href');
    var href720 = $("a:contains('720')").attr('href');
    var href1080 = $("a:contains('1080')").attr('href');
    directDownloadLink = href360 || href480 || href720 || href1080 || "no_download_link";
    
    SaveResults(directDownloadLink);
}

function SaveResults(ddl)
{
    // Some sort of error handling; in this case it's when the internet is slow
    // and the website has not finished building the download links yet
    if (ddl == "no_download_link")
    {
        if ($(".is-success")[0]) {
            // If there is an is-success class, it means a download link is present
            // Therefore, we should try scanning the page again after two seconds
            setTimeout(GetResults, 2000);
            return
        }
    }

    // Retrieve local storage
    var pageHref = window.location.href;
    var gettingItem = browser.storage.local.get(pageHref);
    gettingItem.then((res) => {
        whatEpisode = res[pageHref];
        SaveToDisk(whatEpisode + "|" + ddl, whatEpisode + ".autodramatext", 1);
    });
}

function ClickDownload()
{
    $("#download").trigger('click');
}

// Detect errors that appear immediately on page load
BeforeCompleteGetResults()

// Waits for $(document).ready()
// Wait 3 seconds before clicking
setTimeout(ClickDownload, 3000)

// Wait for at least 15 seconds to check for errors
// Error message/download link should appear by 10 seconds after clicking
setTimeout(GetResults, 15000)