module Page.Editor.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onSubmit)
import Page.Editor.Type exposing (Model, Msg(..))
import Package.ElmForm as Form


view : Model -> Html Msg
view model =
    div [ class "mx-auto flex w-full max-w-[768px] flex-col gap-[24px] px-[16px] py-[32px]" ]
        [ case model.errors of
            Just err ->
                ul [ class "flex flex-col gap-[4px] rounded border border-red-200 bg-red-50 p-[12px] text-sm text-red-700" ]
                    [ li [] [ text err ] ]

            Nothing ->
                text ""
        , Html.form [ onSubmit Submit ]
            [ fieldset [ class "flex flex-col gap-[24px]" ]
                [ Form.viewItem "title" model.form FormMsg FormFocus
                , Form.viewItem "description" model.form FormMsg FormFocus
                , Form.viewItem "body" model.form FormMsg FormFocus
                , div [ class "flex flex-col gap-[8px]" ]
                    [ Form.viewItem "tagInput" model.form FormMsg FormFocus
                    , div [ class "flex flex-wrap gap-[4px] px-[12px]" ]
                        (List.map viewTag model.tagList)
                    ]
                , div [ class "flex justify-end pt-[24px]" ]
                    [ button
                        [ class "rounded bg-green-600 px-[20px] py-[10px] text-sm font-semibold text-white transition-colors hover:bg-green-700 disabled:opacity-60"
                        , type_ "submit"
                        , disabled model.submitting
                        ]
                        [ text "Publish Article" ]
                    ]
                ]
            ]
        ]


viewTag : String -> Html Msg
viewTag tag =
    span [ class "inline-flex items-center gap-[4px] rounded-full bg-green-100 px-[8px] py-[2px] text-xs text-green-800" ]
        [ button
            [ type_ "button"
            , class "cursor-pointer hover:text-green-600 focus:outline-none"
            , onClick (RemoveTag tag)
            ]
            [ text "X" ]
        , text tag
        ]
