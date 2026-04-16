module Page.Editor.Type exposing (..)

import Api.Type.Article exposing (ArticleResponse)
import Http
import Package.ElmForm as Form


type alias Model =
    { slug : Maybe String
    , form : Form.Model
    , tagList : List String
    , errors : Maybe String
    , submitting : Bool
    }


type Msg
    = FormMsg String String -- Key Value
    | FormFocus String Bool
    | Submit
    | SubmitResponse (Result Http.Error ArticleResponse)
    | GetArticleResponse (Result Http.Error ArticleResponse)
    | AddTag
    | RemoveTag String
