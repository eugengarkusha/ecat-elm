function sleep (time) {return new Promise((resolve) => setTimeout(resolve, time));}

function whenAvailable(id, pollInterval, nTries,  func) {
				
	if(nTries == 0 ) throw "element with id '" + id + "' was not eventually available on the page"
	console.log("in whenAvailable")
	if(document.getElementById(id) != null) func();
	else sleep(pollInterval).then(() => { whenAvailable(id, pollInterval, nTries -1, func);})
}	