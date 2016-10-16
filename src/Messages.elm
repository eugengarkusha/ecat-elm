module Messages exposing(..)

import Json.Encode exposing(Value)
type Msg = SetStartDateTime String | SetEndDateTime String | SubmitDates