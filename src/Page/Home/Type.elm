module Page.Home.Type exposing (..)

import Api.Type.Article exposing (ArticleResponse, ArticlesResponse)
import Api.Type.Tag exposing (TagsResponse)
import Http
import Util.RemoteData exposing (RemoteData)


type alias Model =
    { articles : RemoteData Http.Error ArticlesResponse
    , tags : RemoteData Http.Error TagsResponse
    }


type Msg
    = GetArticlesResponse (Result Http.Error ArticlesResponse)
    | GetTagsResponse (Result Http.Error TagsResponse)
    | FavoriteArticle String
    | UnfavoriteArticle String
    | FavoriteArticleResponse (Result Http.Error ArticleResponse)
