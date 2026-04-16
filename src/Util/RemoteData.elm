module Util.RemoteData exposing (..)


type RemoteData e a
    = NotAsked
    | Loading
    | Failure e
    | Success a


map : (a -> b) -> RemoteData e a -> RemoteData e b
map f rd =
    case rd of
        Success a ->
            Success (f a)

        NotAsked ->
            NotAsked

        Loading ->
            Loading

        Failure e ->
            Failure e


fromResult : Result e a -> RemoteData e a
fromResult res =
    case res of
        Ok a ->
            Success a

        Err e ->
            Failure e
