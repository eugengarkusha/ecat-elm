module Messages exposing(..)
import Date exposing (Date)
import Json.Encode exposing(Value)

type Msg = SetStartDateTime Date | SetEndDateTime Date | SubmitDates