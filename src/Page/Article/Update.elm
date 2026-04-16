module Page.Article.Update exposing (..)

import Http
import Page.Article.Type exposing (Model, Msg(..))
import Util.RemoteData as RD


init : String -> Maybe String -> ( Model, Cmd Msg )
init slug maybeToken =
    ( { slug = slug
      , article = RD.Loading
      , comments = RD.Loading
      , commentInput = ""
      }
    , Cmd.none
    )


update : Maybe String -> Msg -> Model -> ( Model, Cmd Msg )
update maybeToken msg model =
    ( model, Cmd.none )
