module Api.Handler.Article exposing (..)

import Api.Handler.Common exposing (apiUrl, authHeader)
import Api.Type.Article as Article exposing (ArticleResponse, ArticlesResponse)
import Http
import Url.Builder as Builder


type alias ArticleParams =
    { tag : Maybe String
    , author : Maybe String
    , favorited : Maybe String
    , offset : Maybe Int
    , limit : Maybe Int
    }


defaultParams : ArticleParams
defaultParams =
    { tag = Nothing
    , author = Nothing
    , favorited = Nothing
    , offset = Nothing
    , limit = Nothing
    }


getArticles : Maybe String -> ArticleParams -> (Result Http.Error ArticlesResponse -> msg) -> Cmd msg
getArticles maybeToken params toMsg =
    let
        queryParams =
            [ params.tag |> Maybe.map (Builder.string "tag")
            , params.author |> Maybe.map (Builder.string "author")
            , params.favorited |> Maybe.map (Builder.string "favorited")
            , params.offset |> Maybe.map (Builder.int "offset")
            , params.limit |> Maybe.map (Builder.int "limit")
            ]
                |> List.filterMap identity
    in
    Http.request
        { method = "GET"
        , headers = authHeader maybeToken
        , url = apiUrl (Builder.relative [ "articles" ] queryParams)
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg Article.articlesResponseDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


getArticlesFeed : String -> { offset : Maybe Int, limit : Maybe Int } -> (Result Http.Error ArticlesResponse -> msg) -> Cmd msg
getArticlesFeed token { offset, limit } toMsg =
    let
        queryParams =
            [ offset |> Maybe.map (Builder.int "offset")
            , limit |> Maybe.map (Builder.int "limit")
            ]
                |> List.filterMap identity
    in
    Http.request
        { method = "GET"
        , headers = authHeader (Just token)
        , url = apiUrl (Builder.relative [ "articles", "feed" ] queryParams)
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg Article.articlesResponseDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


getArticle : Maybe String -> String -> (Result Http.Error ArticleResponse -> msg) -> Cmd msg
getArticle maybeToken slug toMsg =
    Http.request
        { method = "GET"
        , headers = authHeader maybeToken
        , url = apiUrl ("/articles/" ++ slug)
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg Article.responseDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


favoriteArticle : String -> String -> (Result Http.Error ArticleResponse -> msg) -> Cmd msg
favoriteArticle token slug toMsg =
    Http.request
        { method = "POST"
        , headers = authHeader (Just token)
        , url = apiUrl ("/articles/" ++ slug ++ "/favorite")
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg Article.responseDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


unfavoriteArticle : String -> String -> (Result Http.Error ArticleResponse -> msg) -> Cmd msg
unfavoriteArticle token slug toMsg =
    Http.request
        { method = "DELETE"
        , headers = authHeader (Just token)
        , url = apiUrl ("/articles/" ++ slug ++ "/favorite")
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg Article.responseDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


deleteArticle : String -> String -> (Result Http.Error () -> msg) -> Cmd msg
deleteArticle token slug toMsg =
    Http.request
        { method = "DELETE"
        , headers = authHeader (Just token)
        , url = apiUrl ("/articles/" ++ slug)
        , body = Http.emptyBody
        , expect = Http.expectWhatever toMsg
        , timeout = Nothing
        , tracker = Nothing
        }
