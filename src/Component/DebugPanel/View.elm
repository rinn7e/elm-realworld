module Component.DebugPanel.View exposing (view)

import Component.DebugPanel.Type exposing (Model, Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


view : Model -> Html Msg
view model =
    let
        panelContent =
            div
                [ class ("fixed right-4 bottom-4 z-[9999] transition-all duration-300 ease-in-out " ++ (if model.isCollapse then "h-12 w-12" else "w-64")) ]
                [ if model.isCollapse then
                    button
                        [ type_ "button"
                        , onClick ToggleCollapse
                        , class "flex h-12 w-12 items-center justify-center rounded-full bg-gray-900 text-white shadow-xl transition-colors hover:bg-black"
                        , title "Open Debug Panel"
                        ]
                        [ text "⚙️" ]

                  else
                    div [ class "overflow-hidden rounded-2xl border border-gray-800 bg-gray-900 text-white shadow-2xl" ]
                        [ div [ class "flex items-center justify-between border-b border-gray-800 p-4" ]
                            [ h3 [ class "flex items-center gap-2 font-bold" ]
                                [ text "⚙️ Debug Panel" ]
                            , button
                                [ type_ "button"
                                , onClick ToggleCollapse
                                , class "text-gray-400 transition-colors hover:text-white"
                                ]
                                [ text "X" ]
                            ]
                        , div [ class "space-y-4 p-4" ]
                            [ div [ class "space-y-2" ]
                                [ p [ class "text-xs font-bold tracking-wider text-gray-500 uppercase" ] [ text "Shortcuts" ]
                                , button
                                    [ type_ "button"
                                    , class "group flex w-full items-center gap-3 rounded-xl bg-gray-800 p-3 text-left transition-all hover:bg-gray-700"
                                    ]
                                    [ div [ class "flex h-8 w-8 items-center justify-center rounded-lg bg-red-500/10 transition-colors group-hover:bg-red-500/20" ]
                                        [ text "🔄" ]
                                    , div []
                                        [ p [ class "text-sm font-medium" ] [ text "Clear & Reload" ]
                                        , p [ class "text-[10px] text-gray-400" ] [ text "Clears localStorage" ]
                                        ]
                                    ]
                                ]
                            ]
                        , div [ class "flex items-center justify-between bg-black/50 px-4 py-3 text-[10px] text-gray-600" ]
                            [ span [] [ text "TEA RealWorld Debug" ]
                            , span [ class "rounded bg-gray-800 px-1.5 py-0.5" ] [ text "v0.1.0" ]
                            ]
                        ]
                ]
    in
    panelContent
