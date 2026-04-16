module Page.Article.View exposing (view)

import Html exposing (..)
import Page.Article.Type exposing (Model)


view : Model -> Html msg
view model =
    div [] [ text ("Article: " ++ model.slug) ]
