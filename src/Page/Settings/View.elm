module Page.Settings.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onSubmit)
import Page.Settings.Type exposing (Model, Msg(..))
import Package.ElmForm as Form


view : Model -> Html Msg
view model =
    div [ class "flex min-h-full items-start justify-center px-[16px] pb-[32px] pt-[64px]" ]
        [ div [ class "flex w-full max-w-[448px] flex-col gap-[24px]" ]
            [ h1 [ class "text-center text-3xl font-bold text-gray-900" ]
                [ text "Your Settings" ]
            , case model.errors of
                Just err ->
                    ul [ class "flex flex-col gap-[4px] rounded border border-red-200 bg-red-50 p-[12px] text-sm text-red-700" ]
                        [ li [] [ text err ] ]

                Nothing ->
                    text ""
            , Html.form
                [ class "flex flex-col gap-[24px]"
                , onSubmit Submit
                ]
                [ fieldset [ class "flex flex-col gap-[16px]" ]
                    [ Form.viewItem "image" model.form FormMsg FormFocus
                    , Form.viewItem "username" model.form FormMsg FormFocus
                    , Form.viewItem "bio" model.form FormMsg FormFocus
                    , Form.viewItem "email" model.form FormMsg FormFocus
                    , Form.viewItem "password" model.form FormMsg FormFocus
                    , div [ class "flex justify-end pt-[16px]" ]
                        [ button
                            [ class "rounded bg-green-600 px-[20px] py-[10px] text-sm font-semibold text-white transition-colors hover:bg-green-700 disabled:opacity-60"
                            , type_ "submit"
                            , disabled model.submitting
                            ]
                            [ text "Update Settings" ]
                        ]
                    ]
                ]
            , hr [ class "border-gray-200" ] []
            , div [ class "flex flex-col" ]
                [ button
                    [ type_ "button"
                    , class "self-start rounded border border-red-400 px-[16px] py-[8px] text-sm text-red-500 transition-colors hover:bg-red-50"
                    , onClick Logout
                    ]
                    [ text "Or click here to logout." ]
                ]
            ]
        ]
