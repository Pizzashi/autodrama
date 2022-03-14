function SaveToDisk(text, fileName = "general.autodramatext", closeWindow = 0)
{
	// https://stackoverflow.com/a/56616752
	var fileContent = text;
	var bb = new Blob([fileContent ], { type: 'text/plain' });
	var a = document.createElement('a');
	a.download = fileName;
	a.href = window.URL.createObjectURL(bb);
	a.click();

	// No choice but to use a dummy timer here
	// Make sure that dom.allow_scripts_to_close_windows is set to true in about:config
	if (closeWindow) {
		setTimeout(function() { window.close() }, 2000);
	}
}