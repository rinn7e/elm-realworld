module Api.Type.Tag exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


type alias TagsResponse =
    { tags : List String
    }


responseDecoder : Decoder TagsResponse
responseDecoder =
    Decode.succeed TagsResponse
        |> required "tags" (Decode.list Decode.string)
