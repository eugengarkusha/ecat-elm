port module Ports exposing(..)

port appOut : String -> Cmd msg

port dateTimeInput: (String -> msg) -> Sub msg