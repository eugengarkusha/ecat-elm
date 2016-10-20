module Messages exposing(..)
import Date exposing (Date)
import Json.Encode exposing(Value)
import DatePickers exposing(Msg)

type Msg =  SubmitDates | DPMSG DatePickers.Msg 

