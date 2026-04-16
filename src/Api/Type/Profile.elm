module Api.Type.Profile exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)


type alias Profile =
    { username : String
    , bio : Maybe String
    , image : Maybe String
    , following : Bool
    }


decoder : Decoder Profile
decoder =
    Decode.succeed Profile
        |> required "username" Decode.string
        |> required "bio" (Decode.nullable Decode.string)
        |> required "image" (Decode.nullable Decode.string)
        |> required "following" Decode.bool


type alias ProfileResponse =
    { profile : Profile
    }


responseDecoder : Decoder ProfileResponse
responseDecoder =
    Decode.succeed ProfileResponse
        |> required "profile" decoder
