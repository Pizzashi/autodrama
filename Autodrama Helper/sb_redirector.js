downloadLink360 = $("div.block.py-3.rounded-3.mb-3.text-reset.d-block:contains('360p')");
downloadLink480 = $("div.block.py-3.rounded-3.mb-3.text-reset.d-block:contains('480p')");
downloadLink720 = $("div.block.py-3.rounded-3.mb-3.text-reset.d-block:contains('720p')");
downloadLink1080 = $("div.block.py-3.rounded-3.mb-3.text-reset.d-block:contains('1080p')");

if (downloadLink360.length) {
	downloadLink = downloadLink360;
}
else if (downloadLink480.length) {
	downloadLink = downloadLink480;
}
else if (downloadLink720.length) {
	downloadLink = downloadLink720;
}
else if (downloadLink1080.length) {
	downloadLink = downloadLink1080;
}
else {
	downloadLink = "no_download_link";
}

if (downloadLink == "no_download_link") {
	// Throw an error, we don't have a download link for an episode
	SaveToDisk("eFeNotAvail", "err.autodramatext", 1);
}
else {
	downloadLink.trigger("onclick");
}