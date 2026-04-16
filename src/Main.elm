module Main exposing (main)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Data.Route.Parser as RouteParser
import Html exposing (..)
import Json.Decode as Decode
import Component
import Type exposing (Model, Msg(..))
import Update
import Url exposing (Url)


type alias Flags =
    { token : Maybe String
    }


flagsDecoder : Decode.Decoder Flags
flagsDecoder =
    Decode.map Flags
        (Decode.field "token" (Decode.nullable Decode.string))


init : Decode.Value -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flagsValue url key =
    let
        flags =
            Decode.decodeValue flagsDecoder flagsValue
                |> Result.withDefault { token = Nothing }
    in
    Update.init flags url key


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    Update.update msg model


view : Model -> Browser.Document Msg
view model =
    { title = "Conduit"
    , body = [ Component.view model ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Decode.Value Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = UrlChange
        , onUrlRequest =
            \urlRequest ->
                case urlRequest of
                    Browser.Internal url ->
                        ChangeRoute (RouteParser.parseAppRoute url)

                    Browser.External href ->
                        None
        }
