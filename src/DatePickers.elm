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
--TODO how to import 2 different date extra packeges ie import Date.Extra as Date1 import date.Extra as Date2

port datePickerCtrl : String -> Cmd msg

dpFromId = "dpFrom"
dpToId = "dpTo"

type Msg = SetStartDate (Result String Date) | SetEndDate (Result String Date) | StartDateSet Date | InitPickers Date

type DateBoundary = Upper | Lower
type alias Settings = List (String, String) 
type alias Model = 
    {startDt : Maybe Date    
     ,endDt : Maybe Date    
    }

start = .startDt
end = .endDt    

initModel = Model Nothing Nothing  
initCmd = Cmd.map InitPickers (unsafeNow)
    

--onInput : (Date -> Msg) -> Attribute Msg
--onInput tagger =  
--  on "input" (Json.customDecoder targetValue (Date.fromString >> (Result.map tagger)) )

from  = input [id dpFromId, name "start date", type' "text", onInput(Date.fromString >> SetStartDate )] []
to = input [id dpToId, name "end date", type' "text", onInput (Date.fromString >> SetEndDate)] []


unsafeNow = Task.perform (\s-> (Debug.crash("could not get now"))) (identity) Date.now 
--now toMsg = Task.perform (always (toMsg Nothing)) (Just >> toMsg) Date.now

   
dateBoundarySettings: DateBoundary -> Date -> Settings
dateBoundarySettings boundaryType date =
    [("type", "dateBoundary")
    ,("boundaryType", toString(boundaryType))
    ,("dateLimit", Date.toFormattedString "yyyy/MM/dd" date)
    ,("timeLimit", Date.toFormattedString "HH:mm" date)
    ]


encodeCmd : String -> List Settings -> String
encodeCmd id settings =
    let encode: Settings -> Encode.Value
        encode l = l |> List.map (\t -> (fst t, Encode.string (snd t)))
                     |> Encode.object
    in                 
        [("id", Encode.string id), ("settings", settings|> List.map encode |> Encode.list)] 
        |> Encode.object
        |> Encode.encode 0


nextDay = Date.add Date.Day 1 >> Date.floor Date.Day 



--initPickers : Date -> Cmd Msg
--initPickers now = 
--    let fromDate = 
--            if (hour now) > 22 then nextDay now
--            else  now |> Date.add Date.Hour 1

--        toDate =  nextDay fromDate 
--    in   
--        [encodeCmd dpFromId [dateBoundarySettings Upper fromDate]
--        ,encodeCmd dpToId   [dateBoundarySettings Upper toDate]
--        ] 
--        |> List.map datePickerCtrl
--        |> Cmd.batch



setupPickersOnFromIsSet now from =
    let 
        processTo  =  nextDay >> (Date.floor Date.Day)
        (fromDate, toDate) =  
            if(isSameDay now from) then
                let td = if (hour now) > 22 then nextDay now else  now |> Date.add Date.Hour 1
                in (td, processTo td)    
            else
                let td = Date.floor Date.Day now    
                in  (td, processTo from)
        
    in   
        [encodeCmd dpFromId [dateBoundarySettings Upper fromDate]
        ,encodeCmd dpToId   [dateBoundarySettings Upper toDate]
        ] 
        |> List.map datePickerCtrl
        |> Cmd.batch


isSameDay date1 date2 = (Date.floor Date.Day date1) == (Date.floor Date.Day date2)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of 
        InitPickers now ->(model, setupPickersOnFromIsSet now now) 

        StartDateSet now ->  
            case model.startDt of
                Just dt ->  (model, setupPickersOnFromIsSet now dt)
                Nothing -> (model, Cmd.none)
            
        SetStartDate dt ->
            case dt of 
                Result.Err e -> Debug.log ("error parsing date:" ++ e) (model, Cmd.none)
                Result.Ok dt -> ({model | startDt = Just dt}, Cmd.map StartDateSet unsafeNow )

        SetEndDate dt ->
            case dt of 
                Result.Err e -> Debug.log e (model, Cmd.none)
                Result.Ok dt -> ({model | endDt = Just dt}, Cmd.none)
         
