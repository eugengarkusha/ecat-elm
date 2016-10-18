
//depends on jquery , moment.js and lodash

// dispatch input events when date changes
function defaultDettings(pickerId){
	return ({
		onChangeDateTime:function(dp, $input){
			document.getElementById(pickerId).dispatchEvent(new Event('input'));
		}
	})	
} 

//moment js times
function timeRangeSettings(start, end) {

	function genTimeList(start, end){
		if(start > end)throw("start>end")

		function round(time){return time.set('m', (time.minute() == 0 || time.minute() > 30) ?  0 :  30 )}	

		var agg =[]		

		function gen(start, end){
			agg.push(start)
			if(!start.isSame(end)) gen(start.clone().add('m', 30), end)
		}
	
		gen(round(start), round(end), [])
		return agg
	}

	{
	    allowTimes : _.map(genTimeList(start, end), function(time){return time.format("hh:mm")})
	}

}

function appendPicker(cmd){
	
	function parse(time){return moment(time, "hh:mm")}

	var parts = cmd.split(":")
	var pickerId = parts[0]
	var settingControlObects = parts[1].split(",")

	
	var settingsParts = settingControlObects == "" ? [{}] : _.map(
		settingObects,
		function(settingObj){
			var setting = JSON.parse(settingObj)
			var t = setting.type
			if(t == "limitTimes"){
				return timeRangeSettings(parse(t.start), parse(t.end))
			}
			//TODO: other settrings go here:
			else throw("uknnown setting type "+ t)

		}
	)

	var settings = _.reduce(settingsParts, function(agg, next){return $.extend(agg, next)}, defaultDettings(pickerId))

	whenAvailable(pickerId, 10, 5, () => {$('#'+pickerId).datetimepicker(settings)}) 
}

