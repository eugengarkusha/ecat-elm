port module DatePickers exposing (..)
import Date exposing(..)
import Debug exposing(..)
import Date.Extra as Date
import Json.Encode as Encode
import Maybe exposing(..)
import Task exposing(..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time exposing(..)
import String exposing(..)

--TODO do not close picker on date pick

port datePickerCtrl : String -> Cmd msg

dpFromId = "dpFrom"
dpToId = "dpTo"


type Msg =  InitPickers Date --SetStartTime Date |SetEndTime Date 
            |SetStartDate Date 
            |SetEndDate Date
            |SetStartTime Date
            |SetEndTime Date
            |StartDateSet Date Date
            |StartTimeSet Date Date
            |EndDateSet Date Date
            |EndTimeSet Date Date
            |UpdateFromUpLimit Date
            |DateInputError Picker String String
            |EmptyInput Picker
            

type alias Time = {
    h : Int,
    m : Int
}

type Picker = From | To

toLoStr = toString >> toLower

type alias Settings = List (String, Encode.Value) 
type alias Model = 
    {startDt : Maybe Date    
     ,endDt : Maybe Date
     ,endTimeSet : Bool
     ,startTimeSet : Bool
     ,fromTimePicker : Bool
     ,toTimePicker : Bool
     ,fromUpDateLimit: Date
     ,fromUpTimeLimit: Time
     ,fromLoLimit: Maybe Date
     ,toUpLimit: Date
    }

toCmd: Model -> Cmd Msg
toCmd model =
    let 
        dateFormat = Date.toFormattedString "yyyy/MM/dd" 
        disableTimeSettings = [("minTime", Encode.string "0:0"), ("maxTime", Encode.string "0:0")]
        unlimitMaxTimeSetting = ("maxTime", Encode.string "23:59")    
        fromDateLimitSettings = 
            ("minDate", model.fromUpDateLimit |> dateFormat |> Encode.string) :: 
            (model.fromLoLimit |> fold [] (\d -> [("maxDate", d |> dateFormat |> Encode.string)]))

        toDateLimitSettings = [("minDate", model.toUpLimit |> dateFormat |> Encode.string)]

        fromTimeLimitSettings  = 
            if not model.fromTimePicker then disableTimeSettings
            else [unlimitMaxTimeSetting, ("minTime", Encode.string ((toString model.fromUpTimeLimit.h) ++ ":" ++ (toString model.fromUpTimeLimit.m)))]

        toTimeLimitSettings  =
            if not model.toTimePicker then disableTimeSettings         
            else   [unlimitMaxTimeSetting,("minTime", Encode.string "0:0")]

        encodeCmd id settings =              
            [("id", Encode.string id), ("settings", Encode.object settings)] 
            |> Encode.object
            |> Encode.encode 0
            |> datePickerCtrl

        fromSettings = fromDateLimitSettings ++ fromTimeLimitSettings
        toSettings = toDateLimitSettings ++ toTimeLimitSettings 
    in
        Cmd.batch[encodeCmd dpFromId fromSettings, encodeCmd dpToId toSettings]



start = .startDt
end = .endDt    


--used where detes are not optional and are set during initialization

initModel = 
    let dummyDate = Date.fromCalendarDate 2000 Jan 1
    in Model Nothing Nothing False False False False dummyDate (Time 0 0) Nothing dummyDate
initCmd =  Cmd.map InitPickers unsafeNow
    
--todo put ops to separate module
--optionOps    
isDefined m = 
  case m of
    Just _ -> True
    Nothing -> False

fold: x -> (a -> x) -> Maybe a -> x
fold default f m = m |> Maybe.map f |> Maybe.withDefault default 
exists: (a -> Bool)-> Maybe a -> Bool
exists f m = m |> Maybe.map f |> Maybe.withDefault False 
--filter f m =   Maybe.andThen m (\a-> if f a then Just a else Nothing) 
--unsafeGet lbl m =  
    --case m of
    --    Just v -> v
    --    Nothing ->  Debug.crash(lbl ++ ": trying to get value from empty maybe")

--dateOps
setTime t d =  
    let floored = Date.floor Date.Day d
        res = floored |> Date.add Date.Hour t.h |> Date.add Date.Minute t.m
        offsetDif = Date.offsetFromUtc floored -  Date.offsetFromUtc res
    in    
        res |> Date.add Date.Minute offsetDif

minutesToTime m = Time (m // 60) (m % 60)         

timeToMinutes t = t.h * 60 + t.m

ceil interval number = 
    let fullIntervals = number // interval
        noAdditionalInterval = (number % interval) == 0
    in  interval * (fullIntervals + if  noAdditionalInterval then 0 else 1)

getTime d = Time (Date.hour d) (Date.minute d)

--TODO:this method look shitty
ceilDateTo hours d = 
    let time = getTime d
    in  setTime (time |> timeToMinutes |> ceil (60 * hours) |> minutesToTime) d

isSameDay date1 date2 = (Date.floor Date.Day date1) == (Date.floor Date.Day date2)
nextDay = Date.add Date.Day 1 >> Date.floor Date.Day 
prevDay = Date.add Date.Day -1 >> Date.floor Date.Day 
unsafeNow = Task.perform (\s-> (Debug.crash("could not get now"))) (identity) Date.now 


dateOrTime picker dateTag timeTag prevDateOpt inpDateStr =
    case Date.fromString inpDateStr of
        Ok inpDate -> if prevDateOpt |> exists (isSameDay inpDate) then timeTag inpDate else dateTag inpDate
        Err e -> if inpDateStr == "" then EmptyInput picker else DateInputError picker inpDateStr e


dateTimeFormat = Date.toFormattedString "yyyy/MM/dd HH:mm"

from model = input
    [id dpFromId
    ,name "start date"
    ,type' "text"
    ,value (model.startDt |> fold "" dateTimeFormat)
    ,onInput(dateOrTime From SetStartDate SetStartTime model.startDt) 
    ] []

to model = input 
    [id dpToId
    ,name "end date"
    ,type' "text"
    ,value (model.endDt |> fold "" dateTimeFormat)
    ,disabled (model.startDt |> not << isDefined )
    ,onInput(dateOrTime To SetEndDate SetEndTime model.endDt)
    ] []


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =

    let 
        fromUpDateLimit now = if (Date.hour now) >= 22 then  now |> nextDay else now 
        fromUpTimeLimit now from  = if isSameDay now from then  now |>  Date.add Date.Hour 1 |> getTime  else Time 0 0
        process date tag = (model, Cmd.map (tag date) unsafeNow)
    in         

        case msg of 
            InitPickers now -> 
                let fromUpDateLim = fromUpDateLimit now 
                    model'= 
                        ({model | 
                          fromUpDateLimit = fromUpDateLim
                         ,fromUpTimeLimit = fromUpTimeLimit now now
                         ,toUpLimit = nextDay fromUpDateLim
                         })
                in (model', toCmd model')
                                      
            --alert and reset if limit crosses the chosen date
            UpdateFromUpLimit now -> 
                let model': Model
                    model' = ({model |
                                fromUpDateLimit = fromUpDateLimit now
                               ,fromUpTimeLimit = model.startDt |> fold model.fromUpTimeLimit (fromUpTimeLimit now)
                              })
                in (model', toCmd model')

            StartDateSet start now ->  
                let 
                    checkinTime = setTime (Time 13 0) start
                    timeLimit = Date.add Date.Hour 1 now
                    correctedDate = 
                        if isSameDay start now then 
                            if model.startTimeSet && (Date.compare start timeLimit  == GT) then start
                            else if Date.compare checkinTime timeLimit  == GT  then checkinTime
                            else timeLimit    
                        else if model.startTimeSet then start else checkinTime 
                    model': Model
                    model'= 
                        ({model |
                         startDt = correctedDate |> ceilDateTo 1 |> Just
                         ,fromTimePicker = True
                         ,toUpLimit =  nextDay start
                         ,fromUpTimeLimit = fromUpTimeLimit now start 
                         })
                in 
                    (model', toCmd model')


            StartTimeSet start now -> 
                let model'= ({model| startTimeSet = True, startDt = Just start})
                in (model', toCmd model')
                

            EndDateSet end now ->  
                let 
                    correctedDate = if model.endTimeSet then  end else  end |> setTime (Time 12 0) 
                    model': Model
                    model' =
                    ({model |
                     fromLoLimit = Just (prevDay end)
                    ,toTimePicker = True
                    ,endDt = Just correctedDate 
                    })
                in 
                    (model', toCmd model')    

            EndTimeSet end now ->  
                let model': Model
                    model'= ({model| endTimeSet = True, endDt = Just end})
                in (model', toCmd model')

            DateInputError picker input error -> 
                let notUsed = Debug.log("picker=" ++ (toString picker) ++ " input=" ++ input ++ "error="++ error)
                in (model, Cmd.none)    

            EmptyInput picker -> (model, Cmd.none)    
                
            SetStartDate dt -> process dt StartDateSet 
            SetStartTime dt -> process dt StartTimeSet 
            SetEndDate dt   -> process dt EndDateSet                
            SetEndTime dt   -> process dt EndTimeSet


sub : Sub Msg
sub  = Time.every Time.minute (Date.fromTime >> UpdateFromUpLimit)