module App exposing(..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String
import Task
import FrontPage 
import Messages exposing(..)
import Debug exposing(..)
import Date exposing (..)
import Date.Extra as Date
import DatePickers as DP




main = 
    App.program
    { init = (Model DP.initModel, Cmd.map DPMSG DP.initCmd)
    , view = view
    , update = update
    , subscriptions = subs
    }

    
type alias Model = 
    {dpModel : DP.Model
    }


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        --TODO: liimit times
        DPMSG m -> 
            let (updModel, cmd) = DP.update m model.dpModel
            in ({model | dpModel = updModel},  Cmd.map DPMSG cmd)
        SubmitDates  ->  
            case (DP.start model.dpModel, DP.end model.dpModel) of 
                --Where to do dated validation , probablyin dp module(disabling wrong values possibility)
                (Just start, Just end) -> (if Date.compare (end) (start) == GT then log "submit" else log "fail to is not after from") (model, Cmd.none)
                _ ->  log "will not submit, dates are not fully set" (model, Cmd.none)


subs : Model -> Sub Msg
subs model =  Sub.map DPMSG DP.sub
--Sub.none--dateTimeInput SetDateTime



view : Model -> Html Msg
--TODO: make submit button disabled untill dates are set
--TODO: default time - checkintime
view model = FrontPage.view model.dpModel
