module Page.Profile.Update exposing (..)

import Api.Type.User exposing (User)
import Http
import Page.Profile.Type exposing (Model, Msg(..))
import Util.RemoteData as RD


init : String -> Bool -> Maybe User -> ( Model, Cmd Msg )
init username favorites maybeUser =
    ( { username = username
      , profile = RD.Loading
      , articles = RD.Loading
      , showFavorites = favorites
      }
    , Cmd.none
    )


update : String -> Maybe String -> Msg -> Model -> ( Model, Cmd Msg )
update username maybeToken msg model =
    ( model, Cmd.none )
