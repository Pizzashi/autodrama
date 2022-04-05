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
	browser.storage.local.set({
		hadLoggedIn: 1
	}).then(setItem, onError);
}

function LoginChecker()
{
	var gettingItem = browser.storage.local.get("hadLoggedIn");
	gettingItem.then((res) => {
		if (res.hadLoggedIn) {
			CredentialsReady();
			let removeFlag = browser.storage.local.remove("hadLoggedIn");
			removeFlag.then(onRemoved, onError);	
		}
	});
}

function CredentialsReady()
{
	var gettingItem = browser.storage.local.get("CredentialSignalSent");
	gettingItem.then((res) => {
		if (!res.CredentialSignalSent) {
			SaveToDisk("CredentialsReady", "status.autodramatext")
			browser.storage.local.set({
				CredentialSignalSent: 1
			}).then(setItem, onError);
		}
	});
}


const LAUNCHED_BY_AUTODRAMA = window.location.href.match(/\?LaunchedByAutodrama/)

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
			window.location.href = loginLink[0].href;
		}
	}
	else {
		CredentialsReady();
	}
}