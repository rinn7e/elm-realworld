module Page.Auth.Update exposing (..)

import Api.Handler.User as UserApi
import Api.Type.User exposing (UserResponse)
import Http
import Package.ElmForm as Form
import Page.Auth.Type exposing (Model, Msg(..))


init : Bool -> ( Model, Cmd Msg )
init isRegister =
    let
        loginForm =
            Form.init
                |> Form.updateValue "email" ""
                |> Form.updateValue "password" ""

        signupForm =
            Form.init
                |> Form.updateValue "username" ""
                |> Form.updateValue "email" ""
                |> Form.updateValue "password" ""
    in
    ( { isRegister = isRegister
      , loginForm = loginForm
      , signupForm = signupForm
      , errors = Nothing
      , submitting = False
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FormMsg key value ->
            if model.isRegister then
                ( { model | signupForm = Form.updateValue key value model.signupForm }, Cmd.none )

            else
                ( { model | loginForm = Form.updateValue key value model.loginForm }, Cmd.none )

        Submit ->
            if model.isRegister then
                let
                    username =
                        Form.getTextValue "username" model.signupForm

                    email =
                        Form.getTextValue "email" model.signupForm

                    password =
                        Form.getTextValue "password" model.signupForm
                in
                ( { model | submitting = True }
                , UserApi.register { username = username, email = email, password = password } SubmitResponse
                )

            else
                let
                    email =
                        Form.getTextValue "email" model.loginForm

                    password =
                        Form.getTextValue "password" model.loginForm
                in
                ( { model | submitting = True }
                , UserApi.login { email = email, password = password } SubmitResponse
                )

        SubmitResponse (Ok _) ->
            ( { model | submitting = False, errors = Nothing }, Cmd.none )

        SubmitResponse (Err _) ->
            ( { model | submitting = False, errors = Just "Invalid credentials" }, Cmd.none )
