port module DatePickers exposing (end, start, from, to ,initModel,initCmd,update,Msg, Model)
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

--TODO how to import 2 different date extra packeges ie import Date.Extra as Date1 import date.Extra as Date2

port datePickerCtrl : String -> Cmd msg

dpFromId = "dpFrom"
dpToId = "dpTo"


type Msg = SetStartDate (Result String Date) | SetEndDate (Result String Date) | StartDateSet Date |EndDateSet Date |InitPickers Date --SetStartTime Date |SetEndTime Date 

type DateBoundary = Upper | Lower
type alias Settings = List (String, Encode.Value) 
type alias Model = 
    {startDt : Maybe Date    
     ,endDt : Maybe Date    
    }

start = .startDt
end = .endDt    

dateFormat = Date.toFormattedString "yyyy/MM/dd" 
timeFormat = Date.toFormattedString "HH:mm"
dateTimeFormat = Date.toFormattedString "yyyy/MM/dd HH:mm"

initModel = Model Nothing Nothing  
initCmd =  Cmd.map InitPickers unsafeNow
    

from  = input [id dpFromId, name "start date", type' "text", onInput(Date.fromString >> SetStartDate )] []
to = input [id dpToId, name "end date", type' "text", onInput (Date.fromString >> SetEndDate)] []

unsafeNow = Task.perform (\s-> (Debug.crash("could not get now"))) (identity) Date.now 

encodeCmd : String -> Settings -> Cmd Msg
encodeCmd id settings =              
        [("id", Encode.string id), ("settings", Encode.object settings)] 
        |> Encode.object
        |> Encode.encode 0
        |> datePickerCtrl


nextDay = Date.add Date.Day 1 >> Date.floor Date.Day 


dateBoundarySettings: DateBoundary -> Date -> Settings
dateBoundarySettings boundaryType date = 
    let prefix = if(boundaryType == Upper) then "min" else "max"
        dateStr = dateFormat date
        timeStr = timeFormat date
    in
        [(prefix ++ "Date", Encode.string dateStr)
        ,(prefix ++ "Time", Encode.string timeStr)
        ]



setTime hour minute =  Date.floor Date.Day >> Date.add Date.Hour hour >> Date.add Date.Minute minute 

timeInMinutes date = Debug.log "timeinmin "((Date.hour date * 60) + Date.minute date )



fromUpLimit now = if (Date.hour now) >= 22 then nextDay now else  now |> Date.add Date.Hour 1

setupPickersOnFromIsSet : Date -> Date -> (Settings, Settings)
setupPickersOnFromIsSet now from =
    
    let (h, m) =     
        if isSameDay from now  && (timeInMinutes now >  (13 * 60)) then  ((Date.hour now) + 1 , Date.minute now)
        else (13, 0) 

        devaultFromValueSetting =("value", from |> setTime h m |> dateTimeFormat |> Encode.string )
        fromUpLimit' = if isSameDay from now then fromUpLimit now else (fromUpLimit now) |> Date.floor Date.Day
                        
    in  
        (fromUpLimit' |> dateBoundarySettings Upper|> (::) devaultFromValueSetting 
        ,nextDay from |> Date.floor Date.Day  |> dateBoundarySettings Upper 
        )
        
        
        

filter : (a -> Bool) -> Maybe a -> Maybe a 
filter f m =   Maybe.andThen m (\a-> if f a then Just a else Nothing) 

isSameDay date1 date2 = (Date.floor Date.Day date1) == (Date.floor Date.Day date2)



timeOrDate model isStart dt =
    let 
        modelDt = if isStart then model.startDt else model.endDt 
        tag = if isStart then StartDateSet else EndDateSet
        (date, cmd) = 
            modelDt |>
            filter (isSameDay dt) |> 
            --setting time
            Maybe.map (\_ -> (dt, Cmd.none)) |> 
            Maybe.withDefault (Date.floor Date.Day dt, Cmd.map tag unsafeNow )
        model' = if isStart then ({model | startDt = Just date}) else ({model | endDt = Just date})   
    in
        (model', cmd)        


unsafeGet lbl m =  
    case m of
        Just v -> v
        Nothing ->  Debug.crash(lbl ++ ": trying to get value from empty maybe")
    

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of 
        InitPickers now -> (model, fromUpLimit now |> dateBoundarySettings Upper |> encodeCmd dpFromId)
          
        StartDateSet now ->  
                let (fromSettings, toSettings) = setupPickersOnFromIsSet now (unsafeGet "StartDateSet getting startDt" model.startDt)
                in (model, Cmd.batch [encodeCmd dpFromId fromSettings, encodeCmd dpToId toSettings])
               

        EndDateSet now ->  
                    let 
                        end = unsafeGet "endDateSet: getting endDt" model.endDt
                        start = unsafeGet "endDateSet: getting startDt" model.startDt
                        (fromSettings, toSettings) = setupPickersOnFromIsSet now start
                        updFromSettings = (end |> Date.floor Date.Day |>  Date.add Date.Day -1 |> dateBoundarySettings Lower) ++ fromSettings 
                        updToSettings =  ("value",  end |> setTime 12 0 |> dateTimeFormat |> Encode.string) :: toSettings
                       
                    in    
                        (model, Cmd.batch[encodeCmd dpFromId updFromSettings, encodeCmd dpToId updToSettings])
                
            
            
        SetStartDate dt ->
            case dt of 
                Result.Err e -> Debug.log ("error parsing date:" ++ e) (model, Cmd.none)
                Result.Ok dt -> Debug.log "SetStartDate setting date" (timeOrDate model  True dt)
                    
                    
        --if there willbe some   setupPickersOnToIsSet  need to call both  setups on from and on to (using data from model)        
        SetEndDate dt ->
            case dt of 
                Result.Err e -> Debug.log ("error parsing date:" ++ e) (model, Cmd.none)
                Result.Ok dt -> timeOrDate model False dt
         
