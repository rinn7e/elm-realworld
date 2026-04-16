module Page.Profile.Type exposing (..)

import Api.Type.Article exposing (ArticleResponse, ArticlesResponse)
import Api.Type.Profile exposing (ProfileResponse)
import Http
import Util.RemoteData exposing (RemoteData)


type alias Model =
    { profile : RemoteData Http.Error ProfileResponse
    , articles : RemoteData Http.Error ArticlesResponse
    , showFavorites : Bool
    }


type Msg
    = GetProfileResponse (Result Http.Error ProfileResponse)
    | GetArticlesResponse (Result Http.Error ArticlesResponse)
    | ToggleFavorites Bool
    | Follow
    | Unfollow
    | FavoriteArticle String
    | UnfavoriteArticle String
    | FavoriteArticleResponse (Result Http.Error ArticleResponse)
