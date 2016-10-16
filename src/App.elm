module App exposing(..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String
import Task
import Ports exposing(appOut, dateTimeInput)
import FrontPage 
import Messages exposing(..)
import Debug exposing(..)
main = 
    App.program
    { init = (Model "" "", Cmd.batch <| List.map ((<|) appOut ) ["init:" ++ dpFrom,"init:" ++ dpTo] )
    , view = view
    , update = update
    , subscriptions = subs
    }

    


dpFrom = "dpFrom"
dpTo = "dpTo"

type alias Model = 
    { startdt : String    
     ,enddt : String    
    }


update : Msg -> Model -> (Model, Cmd msg)
update msg model =
    case msg of
        SetStartDateTime dt -> log "!!in upd start :" ({model | startdt = dt}, appOut (dt ++ " start !!"))
        SetEndDateTime dt -> log "!!in upd end :" ({model | enddt = dt}, appOut (dt ++ " end !!"))
        SubmitDates  -> log "submit" (model, Cmd.none)

subs : Model -> Sub Msg
subs model =  Sub.none--dateTimeInput SetDateTime



view : Model -> Html Msg
view model = FrontPage.view dpFrom
