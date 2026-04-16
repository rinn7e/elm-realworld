module Page.Editor.Update exposing (..)

import Http
import Package.ElmForm as Form
import Page.Editor.Type exposing (Model, Msg(..))


init : Maybe String -> Maybe String -> ( Model, Cmd Msg )
init slug maybeToken =
    ( { slug = slug
      , form = Form.init
      , tagList = []
      , errors = Nothing
      , submitting = False
      }
    , Cmd.none
    )


update : String -> Msg -> Model -> ( Model, Cmd Msg )
update token msg model =
    ( model, Cmd.none )
