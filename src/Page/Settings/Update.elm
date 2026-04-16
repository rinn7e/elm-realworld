module Page.Settings.Update exposing (..)

import Api.Type.User exposing (User)
import Http
import Package.ElmForm as Form
import Page.Settings.Type exposing (Model, Msg(..))


init : User -> ( Model, Cmd Msg )
init user =
    let
        form =
            Form.init
                |> Form.addField "image" (Form.initText "URL of profile picture" "URL of profile picture" (Form.nonEmptyValidator "URL of profile picture") |> Form.withValue (Maybe.withDefault "" user.image))
                |> Form.addField "username" (Form.initText "Username" "Username" (Form.nonEmptyValidator "Username") |> Form.withValue user.username)
                |> Form.addField "bio" (Form.toTextarea (Form.initText "Short bio about you" "Short bio about you" (Form.nonEmptyValidator "Short bio about you")) |> Form.withValue (Maybe.withDefault "" user.bio))
                |> Form.addField "email" (Form.initText "Email" "Email" Form.emailValidator |> Form.withValue user.email)
                |> Form.addField "password" (Form.toPassword (Form.initText "New Password" "New Password" (Form.minLengthValidator "Password" 8)))
    in
    ( { form = form
      , errors = Nothing
      , submitting = False
      }
    , Cmd.none
    )


update : String -> Msg -> Model -> ( Model, Cmd Msg )
update token msg model =
    case msg of
        FormMsg key val ->
            ( { model | form = Form.updateValue key val model.form }, Cmd.none )

        FormFocus key focus ->
            ( { model | form = Form.setFocus key focus model.form }, Cmd.none )

        _ ->
            ( model, Cmd.none )
