module Page.Editor.Update exposing (..)

import Api.Handler.Article as ArticleApi
import Component.FormFields exposing (standardInputUi)
import Dict
import Http
import Package.ElmForm as Form
import Page.Editor.Type exposing (Model, Msg(..))


editorFormConfig :
    { title : String
    , description : String
    , body : String
    , tagInput : String
    }
    -> List ( String, Form.FieldType Msg )
editorFormConfig values =
    [ ( "title"
      , Form.TextType
            { placeholder = "Article Title"
            , label = "Title"
            , currentValue = values.title
            , validation = \s -> Form.nonEmptyValidator s "Title"
            , linkValidations = []
            , showValidation = False
            , isTextarea = False
            , isPassword = Nothing
            , isFocus = False
            , ui = standardInputUi False True
            }
      )
    , ( "description"
      , Form.TextType
            { placeholder = "What's this article about?"
            , label = "Description"
            , currentValue = values.description
            , validation = \s -> Form.nonEmptyValidator s "Description"
            , linkValidations = []
            , showValidation = False
            , isTextarea = False
            , isPassword = Nothing
            , isFocus = False
            , ui = standardInputUi False False
            }
      )
    , ( "body"
      , Form.TextType
            { placeholder = "Write your article (in markdown)"
            , label = "Body"
            , currentValue = values.body
            , validation = \s -> Form.nonEmptyValidator s "Body"
            , linkValidations = []
            , showValidation = False
            , isTextarea = True
            , isPassword = Nothing
            , isFocus = False
            , ui = standardInputUi True False
            }
      )
    , ( "tagInput"
      , Form.TextType
            { placeholder = "Enter tags"
            , label = "Tags"
            , currentValue = values.tagInput
            , validation = Ok
            , linkValidations = []
            , showValidation = False
            , isTextarea = False
            , isPassword = Nothing
            , isFocus = False
            , ui = standardInputUi False False
            }
      )
    ]


init : Maybe String -> Maybe String -> ( Model, Cmd Msg )
init slug maybeToken =
    let
        emptyForm =
            Form.init (Dict.fromList (editorFormConfig { title = "", description = "", body = "", tagInput = "" }))
    in
    ( { slug = slug
      , form = emptyForm
      , tagList = []
      , errors = Nothing
      , submitting = False
      }
    , case slug of
        Just s ->
            ArticleApi.getArticle maybeToken s GetArticleResponse

        Nothing ->
            Cmd.none
    )


update : String -> Msg -> Model -> ( Model, Cmd Msg )
update token msg model =
    case msg of
        FormMsg subMsg ->
            let
                newForm =
                    Form.update subMsg model.form
            in
            ( { model | form = newForm }, Cmd.none )

        Submit ->
            let
                title =
                    Form.getTextValue "title" model.form

                description =
                    Form.getTextValue "description" model.form

                body =
                    Form.getTextValue "body" model.form

                request =
                    { title = title, description = description, body = body, tagList = model.tagList }
            in
            ( { model | submitting = True, errors = Nothing }
            , case model.slug of
                Just slug ->
                    ArticleApi.updateArticle token slug request SubmitResponse

                Nothing ->
                    ArticleApi.createArticle token request SubmitResponse
            )

        SubmitResponse (Ok _) ->
            ( { model | submitting = False, errors = Nothing }, Cmd.none )

        SubmitResponse (Err _) ->
            ( { model | submitting = False, errors = Just "Could not save article" }, Cmd.none )

        GetArticleResponse (Ok response) ->
            let
                a =
                    response.article

                newForm =
                    Form.init
                        (Dict.fromList
                            (editorFormConfig
                                { title = a.title
                                , description = a.description
                                , body = Maybe.withDefault "" a.body
                                , tagInput = ""
                                }
                            )
                        )
            in
            ( { model | form = newForm, tagList = a.tagList }, Cmd.none )

        GetArticleResponse (Err _) ->
            ( model, Cmd.none )

        AddTag ->
            let
                tagInput =
                    String.trim (Form.getTextValue "tagInput" model.form)
            in
            if not (String.isEmpty tagInput) && not (List.member tagInput model.tagList) then
                ( { model
                    | tagList = model.tagList ++ [ tagInput ]
                    , form = Form.update (Form.UpdateFormManual "tagInput" "") model.form
                  }
                , Cmd.none
                )

            else
                ( model, Cmd.none )

        RemoveTag tag ->
            ( { model | tagList = List.filter (\t -> t /= tag) model.tagList }, Cmd.none )
