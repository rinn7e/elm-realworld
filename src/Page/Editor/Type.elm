module Page.Editor.Type exposing (..)

import Api.Type.Article exposing (ArticleResponse)
import Http
import Package.ElmForm as Form


type alias Model =
    { slug : Maybe String
    , form : Form.Model Msg
    , tagList : List String
    , errors : Maybe String
    , submitting : Bool
    }


type Msg
    = FormMsg Form.Msg
    | Submit
    | SubmitResponse (Result Http.Error ArticleResponse)
    | GetArticleResponse (Result Http.Error ArticleResponse)
    | AddTag
    | RemoveTag String
