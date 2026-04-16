module Page.Article.Type exposing (..)

import Api.Type.Article exposing (ArticleResponse, ArticlesResponse)
import Api.Type.Comment exposing (CommentResponse, CommentsResponse)
import Api.Type.Profile exposing (ProfileResponse)
import Http
import Util.RemoteData exposing (RemoteData)


type alias Model =
    { slug : String
    , article : RemoteData Http.Error ArticleResponse
    , comments : RemoteData Http.Error CommentsResponse
    , commentInput : String
    }


type Msg
    = GetArticleResponse (Result Http.Error ArticleResponse)
    | GetCommentsResponse (Result Http.Error CommentsResponse)
    | FavoriteArticle
    | UnfavoriteArticle
    | FavoriteArticleResponse (Result Http.Error ArticleResponse)
    | FollowAuthor String
    | UnfollowAuthor String
    | FollowAuthorResponse (Result Http.Error ProfileResponse)
    | UnfollowAuthorResponse (Result Http.Error ProfileResponse)
    | DeleteArticle
    | DeleteArticleResponse (Result Http.Error ())
    | SetCommentInput String
    | SubmitComment
    | SubmitCommentResponse (Result Http.Error CommentResponse)
    | DeleteComment Int
    | DeleteCommentResponse Int (Result Http.Error ())
    | None
