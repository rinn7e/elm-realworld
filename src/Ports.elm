port module Ports exposing (..)


port scrollToId : String -> Cmd msg


port saveToken : String -> Cmd msg


port removeToken : () -> Cmd msg
