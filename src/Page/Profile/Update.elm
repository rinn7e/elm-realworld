module Page.Profile.Update exposing (..)

import Api.Handler.Article as ArticleApi
import Api.Handler.Profile as ProfileApi
import Http
import Page.Profile.Type exposing (Model, Msg(..))
import Util.RemoteData as RD


init : String -> Maybe String -> Bool -> ( Model, Cmd Msg )
init username maybeToken favorites =
    let

        params =
            ArticleApi.defaultParams
    in
    ( { username = username
      , profile = RD.Loading
      , articles = RD.Loading
      , showFavorites = favorites
      }
    , Cmd.batch
        [ ProfileApi.getProfile maybeToken username GetProfileResponse
        , ArticleApi.getArticles maybeToken
            (if favorites then
                { params | favorited = Just username }

             else
                { params | author = Just username }
            )
            GetArticlesResponse
        ]
    )


reInit : Maybe String -> Model -> ( Model, Cmd Msg )
reInit maybeToken model =
    init model.username maybeToken model.showFavorites


update : String -> Maybe String -> Msg -> Model -> ( Model, Cmd Msg )
update username maybeToken msg model =
    case msg of
        GetProfileResponse (Ok response) ->
            ( { model | profile = RD.Success response }, Cmd.none )

        GetProfileResponse (Err err) ->
            ( { model | profile = RD.Failure err }, Cmd.none )

        GetArticlesResponse (Ok response) ->
            ( { model | articles = RD.Success response }, Cmd.none )

        GetArticlesResponse (Err err) ->
            ( { model | articles = RD.Failure err }, Cmd.none )

        ToggleFavorites show ->
            let
                params =
                    ArticleApi.defaultParams
            in
            ( { model | showFavorites = show, articles = RD.Loading }
            , ArticleApi.getArticles maybeToken
                (if show then
                    { params | favorited = Just username }

                 else
                    { params | author = Just username }
                )
                GetArticlesResponse
            )

        Follow ->
            case maybeToken of
                Just token ->
                    ( model, ProfileApi.followUser token username GetProfileResponse )

                Nothing ->
                    ( model, Cmd.none )

        Unfollow ->
            case maybeToken of
                Just token ->
                    ( model, ProfileApi.unfollowUser token username GetProfileResponse )

                Nothing ->
                    ( model, Cmd.none )

        FavoriteArticle slug ->
            case maybeToken of
                Just token ->
                    ( model, ArticleApi.favoriteArticle token slug FavoriteArticleResponse )

                Nothing ->
                    ( model, Cmd.none )

        UnfavoriteArticle slug ->
            case maybeToken of
                Just token ->
                    ( model, ArticleApi.unfavoriteArticle token slug FavoriteArticleResponse )

                Nothing ->
                    ( model, Cmd.none )

        FavoriteArticleResponse (Ok response) ->
            case model.articles of
                RD.Success articlesResponse ->
                    let
                        updated =
                            response.article

                        newArticles =
                            List.map
                                (\a ->
                                    if a.slug == updated.slug then
                                        updated

                                    else
                                        a
                                )
                                articlesResponse.articles
                    in
                    ( { model | articles = RD.Success { articlesResponse | articles = newArticles } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )
