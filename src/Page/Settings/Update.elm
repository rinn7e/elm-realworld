module Page.Settings.Update exposing (..)

import Api.Type.User exposing (User)
import Http
import Package.ElmForm as Form
import Page.Settings.Type exposing (Model, Msg(..))


init : User -> ( Model, Cmd Msg )
init user =
    ( { form = Form.init
      , errors = Nothing
      , submitting = False
      }
    , Cmd.none
    )


update : String -> Msg -> Model -> ( Model, Cmd Msg )
update token msg model =
    ( model, Cmd.none )
