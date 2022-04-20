function setItem() {
	console.log("Stored an object successfully.");
}

function onRemoved() {
	console.log("Removed an object successfully.");
}

function onError(error) {
	console.log(`Error: ${error}`);
}

function FillOutCredentials()
{
	document.getElementById('username').value="Baconfry";
	document.getElementById('password').value="*t#du0#P#4MbUO*nVMp8u42zVxiwwFxWMiV&n$zum0ahWVdsnf";
	document.getElementById("btnSubmit").click();

	// Set flag for the next reload
	let setFlag = browser.storage.local.set({
		hadLoggedIn: 1
	});
	setFlag.then(setItem, onError);
}

function LoginChecker()
{
	var gettingItem = browser.storage.local.get("hadLoggedIn");

	gettingItem.then((res) => {
		if (res.hadLoggedIn)
		{
			// CredentialsReady() will not work if CredentialSignalSent is not declared for some reason
			browser.storage.local.set({
				CredentialSignalSent: 0
			}).then(setItem, onError);

			CredentialsReady("check");

			let removeFlag = browser.storage.local.remove("hadLoggedIn");
			removeFlag.then(onRemoved, onError);	
		}
	});
}

// "pass" will send CredentialsReady signal to the main app without questions
// "check" will check for hadLoggedIn
function CredentialsReady(mode)
{
	if (mode == "pass")
	{
		SaveToDisk("CredentialsReady", "status.autodramatext")
		return
	}
	
	if (mode == "check")
	{
		browser.storage.local.get("CredentialSignalSent").then((res) => {
			if (res.CredentialSignalSent == 0) {
				SaveToDisk("CredentialsReady", "status.autodramatext")
				browser.storage.local.set({
					CredentialSignalSent: 1
				}).then(setItem, onError);
			}
		});
		return
	}
}

//=================================Start here=================================

const LAUNCHED_BY_AUTODRAMA = (window.location.href == "https://kissasian.li/?LaunchedByAutodrama" || window.location.href == "https://kissasian.li/Login?LaunchedByAutodrama")

// Check if just logged in
if (window.location.pathname == "/") {
	LoginChecker();
}

// Login when needed (i.e., Autodrama requested the page AND
// if id="topHolderBox" contains "Please [login or register]")
if (LAUNCHED_BY_AUTODRAMA)
{
	let userNotLoggedIn = $("#topHolderBox:contains('Please')").length;
	let loginLink = $("a:contains('login')");

	if (userNotLoggedIn) {
		if (window.location.pathname == "/Login") {
			FillOutCredentials();
		} else {
			window.location.href = loginLink[0].href + "?LaunchedByAutodrama";
		}
	}
	else {
		CredentialsReady("pass");
	}
}