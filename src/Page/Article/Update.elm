module Page.Article.Update exposing (..)

import Api.Handler.Article as ArticleApi
import Api.Handler.Comment as CommentApi
import Api.Handler.Profile as ProfileApi
import Http
import Page.Article.Type exposing (Model, Msg(..))
import Util.RemoteData as RD


init : String -> Maybe String -> ( Model, Cmd Msg )
init slug maybeToken =
    ( { slug = slug
      , article = RD.Loading
      , comments = RD.Loading
      , commentInput = ""
      }
    , Cmd.batch
        [ ArticleApi.getArticle maybeToken slug GetArticleResponse
        , CommentApi.getComments maybeToken slug GetCommentsResponse
        ]
    )


reInit : Maybe String -> Model -> ( Model, Cmd Msg )
reInit maybeToken model =
    ( { model | article = RD.Loading, comments = RD.Loading }
    , Cmd.batch
        [ ArticleApi.getArticle maybeToken model.slug GetArticleResponse
        , CommentApi.getComments maybeToken model.slug GetCommentsResponse
        ]
    )


update : Maybe String -> Msg -> Model -> ( Model, Cmd Msg )
update maybeToken msg model =
    case msg of
        GetArticleResponse res ->
            ( { model | article = RD.fromResult res }, Cmd.none )

        GetCommentsResponse res ->
            ( { model | comments = RD.fromResult res }, Cmd.none )

        FavoriteArticle ->
            case maybeToken of
                Just token ->
                    ( model, ArticleApi.favoriteArticle token model.slug FavoriteArticleResponse )

                Nothing ->
                    ( model, Cmd.none )

        UnfavoriteArticle ->
            case maybeToken of
                Just token ->
                    ( model, ArticleApi.unfavoriteArticle token model.slug FavoriteArticleResponse )

                Nothing ->
                    ( model, Cmd.none )

        FavoriteArticleResponse res ->
            ( { model | article = RD.fromResult res }, Cmd.none )

        FollowAuthor username ->
            case maybeToken of
                Just token ->
                    ( model, ProfileApi.followUser token username FollowAuthorResponse )

                Nothing ->
                    ( model, Cmd.none )

        UnfollowAuthor username ->
            case maybeToken of
                Just token ->
                    ( model, ProfileApi.unfollowUser token username UnfollowAuthorResponse )

                Nothing ->
                    ( model, Cmd.none )

        FollowAuthorResponse (Ok _) ->
            ( model, ArticleApi.getArticle maybeToken model.slug GetArticleResponse )

        FollowAuthorResponse (Err _) ->
            ( model, Cmd.none )

        UnfollowAuthorResponse (Ok _) ->
            ( model, ArticleApi.getArticle maybeToken model.slug GetArticleResponse )

        UnfollowAuthorResponse (Err _) ->
            ( model, Cmd.none )

        DeleteArticle ->
            case maybeToken of
                Just token ->
                    ( model, ArticleApi.deleteArticle token model.slug DeleteArticleResponse )

                Nothing ->
                    ( model, Cmd.none )

        DeleteArticleResponse _ ->
            ( model, Cmd.none )

        SetCommentInput val ->
            ( { model | commentInput = val }, Cmd.none )

        SubmitComment ->
            case maybeToken of
                Just token ->
                    if String.isEmpty (String.trim model.commentInput) then
                        ( model, Cmd.none )

                    else
                        ( model, CommentApi.createComment token model.slug model.commentInput SubmitCommentResponse )

                Nothing ->
                    ( model, Cmd.none )

        SubmitCommentResponse (Ok _) ->
            ( { model | commentInput = "" }, CommentApi.getComments maybeToken model.slug GetCommentsResponse )

        SubmitCommentResponse (Err _) ->
            ( model, Cmd.none )

        DeleteComment id ->
            case maybeToken of
                Just token ->
                    ( model, CommentApi.deleteComment token model.slug id (DeleteCommentResponse id) )

                Nothing ->
                    ( model, Cmd.none )

        DeleteCommentResponse _ (Ok _) ->
            ( model, CommentApi.getComments maybeToken model.slug GetCommentsResponse )

        DeleteCommentResponse _ (Err _) ->
            ( model, Cmd.none )

        None ->
            ( model, Cmd.none )
