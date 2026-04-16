module Page.Auth.Update exposing (..)

import Api.Handler.User as UserApi
import Component.FormFields exposing (standardInputUi)
import Dict
import Package.ElmForm as Form
import Page.Auth.Type exposing (Model, Msg(..))


emailField : ( String, Form.FieldType Msg )
emailField =
    ( "email"
    , Form.TextType
        { placeholder = "Email"
        , label = "Email"
        , currentValue = ""
        , validation = Form.emailValidator
        , linkValidations = []
        , showValidation = False
        , isTextarea = False
        , isPassword = Nothing
        , isFocus = False
        , ui = standardInputUi False True
        }
    )


passwordField : ( String, Form.FieldType Msg )
passwordField =
    ( "password"
    , Form.TextType
        { placeholder = "Password"
        , label = "Password"
        , currentValue = ""
        , validation = Form.minLengthValidator "Password" 8
        , linkValidations = []
        , showValidation = False
        , isTextarea = False
        , isPassword = Just { revealPassword = False, disableAutocomplete = False }
        , isFocus = False
        , ui = standardInputUi False True
        }
    )


usernameField : ( String, Form.FieldType Msg )
usernameField =
    ( "username"
    , Form.TextType
        { placeholder = "Username"
        , label = "Username"
        , currentValue = ""
        , validation = \s -> Form.nonEmptyValidator s "Username"
        , linkValidations = []
        , showValidation = False
        , isTextarea = False
        , isPassword = Nothing
        , isFocus = False
        , ui = standardInputUi False True
        }
    )


loginFormConfig : List ( String, Form.FieldType Msg )
loginFormConfig =
    [ emailField, passwordField ]


signupFormConfig : List ( String, Form.FieldType Msg )
signupFormConfig =
    [ usernameField, emailField, passwordField ]


init : Bool -> ( Model, Cmd Msg )
init isRegister =
    ( { isRegister = isRegister
      , loginForm = Form.init (Dict.fromList loginFormConfig)
      , signupForm = Form.init (Dict.fromList signupFormConfig)
      , errors = Nothing
      , submitting = False
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FormMsg subMsg ->
            if model.isRegister then
                ( { model | signupForm = Form.update subMsg model.signupForm }, Cmd.none )

            else
                ( { model | loginForm = Form.update subMsg model.loginForm }, Cmd.none )

        Submit ->
            let
                currentForm =
                    if model.isRegister then
                        model.signupForm

                    else
                        model.loginForm

                email =
                    Form.getTextValue "email" currentForm

                password =
                    Form.getTextValue "password" currentForm
            in
            if model.isRegister then
                let
                    username =
                        Form.getTextValue "username" currentForm
                in
                ( { model | submitting = True }
                , UserApi.register { username = username, email = email, password = password } SubmitResponse
                )

            else
                ( { model | submitting = True }
                , UserApi.login { email = email, password = password } SubmitResponse
                )

        SubmitResponse (Ok _) ->
            ( { model | submitting = False, errors = Nothing }, Cmd.none )

        SubmitResponse (Err _) ->
            ( { model | submitting = False, errors = Just "Invalid credentials" }, Cmd.none )
