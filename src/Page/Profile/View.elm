module Page.Profile.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Page.Profile.Type exposing (Model)


view : Model -> Html msg
view model =
    div [ class "mx-auto w-full max-w-[1152px] px-[16px] py-[24px]" ]
        [ h1 [ class "text-2xl font-bold" ] [ text ("Profile: " ++ model.username) ]
        , p [] [ text "This is the profile page skeleton." ]
        ]
