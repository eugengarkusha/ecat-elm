
//depends on jquery , moment.js and lodash

// dispatch input events when date changes
function defaultDettings(pickerId) {
	return {
		onChangeDateTime : function(dp, $input){document.getElementById(pickerId).dispatchEvent(new Event('input'));},
		defautlTime : moment().set('hour', 21).set('minute', 21)

	}
}


//moment js times
// function timeRangeSettings(start, end) {

// 	function genTimeList(start, end){
// 		if(start > end)throw("start>end")

// 		function round(time){return time.set('m', (time.minute() == 0 || time.minute() > 30) ?  0 :  30 )}	

// 		var agg =[]		

// 		function gen(start, end){
// 			agg.push(start)
// 			if(!start.isSame(end)) gen(start.clone().add('m', 30), end)
// 		}s
	
// 		gen(round(start), round(end), [])
// 		return agg
// 	}

// 	{
// 	    allowTimes : _.map(genTimeList(start, end), function(time){return time.format("hh:mm")})
// 	}

// }

function configurePicker(cmd){
	
	function parse(time){return moment(time, "hh:mm")}

	var command = JSON.parse(cmd)
	console.log("got cmd " +  JSON.stringify(command, null, 2))

	
	var pickerId = command.id
	var pickerSettings = command.settings
	

	
	Object.keys(pickerSettings).forEach(function(key){

		//adopting time format(datepicker does not take default format "hh:mm" due to a bug)	
		if(key.includes("Time")) {
			console.log("key="+key)
			var hhmm = pickerSettings[key].split(":")

			if(hhmm.length != 2) throw "time limit format unexpected:" + pickerSettings[key]
			pickerSettings[key] = moment().set('hour', hhmm[0]).set('minute', hhmm[1]).toDate()
		}
	})


	whenAvailable(pickerId, 10, 5, () => {$('#'+pickerId).datetimepicker($.extend(pickerSettings, defaultDettings(pickerId)))}) 
}

