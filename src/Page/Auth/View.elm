module Page.Auth.View exposing (view)

import Data.Route.Parser as RouteParser
import Data.Route.Type exposing (AppPage(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onSubmit)
import Package.ElmForm as Form
import Page.Auth.Type exposing (Model, Msg(..))


view : Model -> Html Msg
view model =
    let
        title =
            if model.isRegister then
                "Sign up"

            else
                "Sign in"

        linkText =
            if model.isRegister then
                "Have an account?"

            else
                "Need an account?"

        route =
            if model.isRegister then
                LoginPage

            else
                RegisterPage

        currentForm =
            if model.isRegister then
                model.signupForm

            else
                model.loginForm
    in
    div [ class "flex min-h-full items-start justify-center px-[16px] pt-[64px] pb-[32px]" ]
        [ div [ class "flex w-full max-w-[448px] flex-col gap-[24px]" ]
            [ div [ class "flex flex-col gap-[8px]" ]
                [ h1 [ class "text-center text-3xl font-bold text-gray-900" ] [ text title ]
                , p [ class "text-center text-sm" ]
                    [ a [ class "text-green-600 hover:underline", href (RouteParser.toUrlString { page = route }) ] [ text linkText ]
                    ]
                ]
            , case model.errors of
                Just err ->
                    ul [ class "flex flex-col gap-[4px] rounded border border-red-200 bg-red-50 p-[12px] text-sm text-red-700" ]
                        [ li [] [ text err ] ]

                Nothing ->
                    text ""
            , Html.form [ class "flex flex-col gap-[24px]", onSubmit Submit ]
                [ fieldset [ class "flex flex-col gap-[0px]" ]
                    [ if model.isRegister then
                        Form.viewItem "username" model.signupForm FormMsg

                      else
                        text ""
                    , Form.viewItem "email" currentForm FormMsg
                    , Form.viewItem "password" currentForm FormMsg
                    , div [ class "pt-[16px]" ]
                        [ button
                            [ class "w-full rounded bg-green-600 px-[16px] py-[10px] text-sm font-semibold text-white transition-colors hover:bg-green-700 disabled:opacity-60"
                            , type_ "submit"
                            , disabled model.submitting
                            ]
                            [ text title ]
                        ]
                    ]
                ]
            ]
        ]
