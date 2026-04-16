module Component.Footer exposing (view)

import Data.Route.Type exposing (AppPage(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Package.Prelude exposing (cn)


view : Html msg
view =
    footer [ class "border-t border-gray-100 bg-gray-50 py-[24px]" ]
        [ div
            [ cn
                [ "mx-auto flex max-w-[1152px] flex-col items-center gap-[4px] px-[16px] text-center"
                , "lg:flex-row lg:justify-between lg:text-left"
                ]
            ]
            [ a
                [ href "/"
                , class "text-sm font-bold text-green-600"
                ]
                [ text "conduit" ]
            , span [ class "text-xs text-gray-400" ]
                [ text "An interactive learning project from "
                , a
                    [ href "https://thinkster.io"
                    , target "_blank"
                    , rel "noopener noreferrer"
                    , class "underline hover:text-gray-600"
                    ]
                    [ text "Thinkster" ]
                , text ". Code & design licensed under MIT."
                ]
            ]
        ]
