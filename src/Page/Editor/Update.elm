module Page.Editor.Update exposing (..)

import Http
import Package.ElmForm as Form
import Page.Editor.Type exposing (Model, Msg(..))


init : Maybe String -> Maybe String -> ( Model, Cmd Msg )
init slug maybeToken =
    let
        form =
            Form.init
                |> Form.addField "title" (Form.initText "Title" "Article Title" (Form.nonEmptyValidator "Title"))
                |> Form.addField "description" (Form.initText "Description" "What's this article about?" (Form.nonEmptyValidator "Description"))
                |> Form.addField "body" (Form.toTextarea (Form.initText "Body" "Write your article (in markdown)" (Form.nonEmptyValidator "Body")))
                |> Form.addField "tagInput" (Form.initText "Tags" "Enter tags" Ok)
    in
    ( { slug = slug
      , form = form
      , tagList = []
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
