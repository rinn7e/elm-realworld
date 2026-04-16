module Page.Home.Update exposing (..)

import Api.Handler.Article as Article
import Api.Handler.Tag as Tag
import Api.Type.Article exposing (ArticlesResponse)
import Http
import Page.Home.Type exposing (Model, Msg(..))
import Util.RemoteData as RD


init : Maybe String -> ( Model, Cmd Msg )
init maybeToken =
    ( { articles = RD.Loading
      , tags = RD.Loading
      }
    , Cmd.batch
        [ Article.getArticles maybeToken Article.defaultParams GetArticlesResponse
        , Tag.getTags maybeToken GetTagsResponse
        ]
    )


update : Maybe String -> Msg -> Model -> ( Model, Cmd Msg )
update maybeToken msg model =
    case msg of
        GetArticlesResponse res ->
            ( { model | articles = resultToRD res }, Cmd.none )

        GetTagsResponse res ->
            ( { model | tags = resultToRD res }, Cmd.none )

        FavoriteArticle slug ->
            case maybeToken of
                Just token ->
                    ( model, Article.favoriteArticle token slug FavoriteArticleResponse )

                Nothing ->
                    ( model, Cmd.none )

        UnfavoriteArticle slug ->
            case maybeToken of
                Just token ->
                    ( model, Article.unfavoriteArticle token slug FavoriteArticleResponse )

                Nothing ->
                    ( model, Cmd.none )

        FavoriteArticleResponse res ->
            -- Handle favorite response (normally would update the article in the list)
            ( model, Cmd.none )


resultToRD : Result Http.Error a -> RD.RemoteData Http.Error a
resultToRD res =
    case res of
        Ok a ->
            RD.Success a

        Err e ->
            RD.Failure e
