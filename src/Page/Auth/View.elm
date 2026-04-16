module Page.Auth.View exposing (view)

import Html exposing (..)
import Page.Auth.Type exposing (Model)


view : Model -> Html msg
view model =
    div [] [ text (if model.isRegister then "Register" else "Login") ]
