
//depends on jquery , moment.js and lodash

// dispatch input events when date changes
function defaultDettings(pickerId){

	// var now = moment()
	// var minDate = 0 
	// var minTime 
	//  if(now.hour() >= 22) minDate = now.add(1,'day').toDate()
	//  else minTime = now.add(1, 'hour').toDate()
	 

	return ({
		onChangeDateTime:function(dp, $input){
			document.getElementById(pickerId).dispatchEvent(new Event('input'));
		}//,
		// minDate: minDate,
		// minTime: minTime
	})	
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
// 		}
	
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
	var settingObects = command.settings

	
	var settingsParts = _.map(
		settingObects,
		function(settings){
			
			// if(settings.type == "limitRange"){
				// return timeRangeSettings(parse(settings.start), parse(settings.end))
			// }
			
			if (settings.type == "dateBoundary"){
				var minOrMax
				var obj = {}

				if(settings.boundaryType = "Upper") minOrMax =  "min"
				else if (settings.boundaryType = "Lower") 	minOrMax = "max"
				else throw "unknown boundary type" + settings.boundaryType

				function adoptTimeLimit(tlStr){
					var s = tlStr.split(":")
					if(s.size == 0) throw "time limit format unexpected:"+tlStr
					console.log(s)	
					return moment().set('hour',s[0]).set('minute',s[1]).toDate()
					
				}	

				obj[minOrMax + 'Date'] = settings.dateLimit
				obj[minOrMax + 'Time'] = adoptTimeLimit(settings.timeLimit)
				return obj
			}
			//TODO: other settrings go here:
			else throw("uknnown setting type "+ settings.type)

		}
	)

	var settings = _.reduce(settingsParts, function(agg, next){return $.extend(agg, next)}, defaultDettings(pickerId))

	whenAvailable(pickerId, 10, 5, () => {$('#'+pickerId).datetimepicker(settings)}) 
}

