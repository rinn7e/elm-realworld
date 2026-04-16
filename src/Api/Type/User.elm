module Api.Type.User exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode


type alias User =
    { email : String
    , token : String
    , username : String
    , bio : Maybe String
    , image : Maybe String
    }


decoder : Decoder User
decoder =
    Decode.succeed User
        |> required "email" Decode.string
        |> required "token" Decode.string
        |> required "username" Decode.string
        |> required "bio" (Decode.nullable Decode.string)
        |> required "image" (Decode.nullable Decode.string)


type alias UserResponse =
    { user : User
    }


responseDecoder : Decoder UserResponse
responseDecoder =
    Decode.succeed UserResponse
        |> required "user" decoder


type alias LoginRequest =
    { email : String
    , password : String
    }


encodeLoginRequest : LoginRequest -> Encode.Value
encodeLoginRequest request =
    Encode.object
        [ ( "user"
          , Encode.object
                [ ( "email", Encode.string request.email )
                , ( "password", Encode.string request.password )
                ]
          )
        ]


type alias RegisterRequest =
    { username : String
    , email : String
    , password : String
    }


encodeRegisterRequest : RegisterRequest -> Encode.Value
encodeRegisterRequest request =
    Encode.object
        [ ( "user"
          , Encode.object
                [ ( "username", Encode.string request.username )
                , ( "email", Encode.string request.email )
                , ( "password", Encode.string request.password )
                ]
          )
        ]
type alias UpdateUserRequest =
    { email : String
    , username : String
    , bio : Maybe String
    , image : Maybe String
    , password : Maybe String
    }


encodeUpdateUserRequest : UpdateUserRequest -> Encode.Value
encodeUpdateUserRequest request =
    Encode.object
        [ ( "user"
          , Encode.object
                ([ ( "email", Encode.string request.email )
                 , ( "username", Encode.string request.username )
                 , ( "bio", request.bio |> Maybe.map Encode.string |> Maybe.withDefault Encode.null )
                 , ( "image", request.image |> Maybe.map Encode.string |> Maybe.withDefault Encode.null )
                 ]
                    ++ (case request.password of
                            Just p ->
                                [ ( "password", Encode.string p ) ]

                            Nothing ->
                                []
                       )
                )
          )
        ]
