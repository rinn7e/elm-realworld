module Page.Settings.Update exposing (..)

import Api.Handler.User as UserApi
import Api.Type.User exposing (User)
import Component.FormFields exposing (standardInputUi)
import Dict
import Package.ElmForm as Form
import Page.Settings.Type exposing (Model, Msg(..))


settingsFormConfig : User -> List ( String, Form.FieldType Msg )
settingsFormConfig user =
    [ ( "image"
      , Form.TextType
            { placeholder = "URL of profile picture"
            , label = "Profile picture"
            , currentValue = Maybe.withDefault "" user.image
            , validation = \s -> Form.nonEmptyValidator s "Image URL"
            , linkValidations = []
            , showValidation = False
            , isTextarea = False
            , isPassword = Nothing
            , isFocus = False
            , ui = standardInputUi False False
            }
      )
    , ( "username"
      , Form.TextType
            { placeholder = "Username"
            , label = "Username"
            , currentValue = user.username
            , validation = \s -> Form.nonEmptyValidator s "Username"
            , linkValidations = []
            , showValidation = False
            , isTextarea = False
            , isPassword = Nothing
            , isFocus = False
            , ui = standardInputUi False True
            }
      )
    , ( "bio"
      , Form.TextType
            { placeholder = "Short bio about you"
            , label = "Bio"
            , currentValue = Maybe.withDefault "" user.bio
            , validation = \s -> Form.nonEmptyValidator s "Bio"
            , linkValidations = []
            , showValidation = False
            , isTextarea = True
            , isPassword = Nothing
            , isFocus = False
            , ui = standardInputUi True True
            }
      )
    , ( "email"
      , Form.TextType
            { placeholder = "Email"
            , label = "Email"
            , currentValue = user.email
            , validation = Form.emailValidator
            , linkValidations = []
            , showValidation = False
            , isTextarea = False
            , isPassword = Nothing
            , isFocus = False
            , ui = standardInputUi False True
            }
      )
    , ( "password"
      , Form.TextType
            { placeholder = "New Password"
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
    ]


init : User -> ( Model, Cmd Msg )
init user =
    ( { form = Form.init (Dict.fromList (settingsFormConfig user))
      , errors = Nothing
      , submitting = False
      }
    , Cmd.none
    )


update : String -> Msg -> Model -> ( Model, Cmd Msg )
update token msg model =
    case msg of
        FormMsg subMsg ->
            ( { model | form = Form.update subMsg model.form }, Cmd.none )

        Logout ->
            ( model, Cmd.none )

        Submit ->
            let
                image =
                    Form.getTextValue "image" model.form

                username =
                    Form.getTextValue "username" model.form

                bio =
                    Form.getTextValue "bio" model.form

                email =
                    Form.getTextValue "email" model.form

                password =
                    Form.getTextValue "password" model.form

                userUpdate =
                    { email = email
                    , username = username
                    , bio = Just bio
                    , image = Just image
                    , password =
                        if String.isEmpty password then
                            Nothing

                        else
                            Just password
                    }
            in
            ( { model | submitting = True, errors = Nothing }
            , UserApi.updateUser token userUpdate SubmitResponse
            )

        SubmitResponse (Ok _) ->
            ( { model | submitting = False, errors = Nothing }, Cmd.none )

        SubmitResponse (Err _) ->
            ( { model | submitting = False, errors = Just "Could not update settings" }, Cmd.none )
