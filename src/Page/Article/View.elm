module Page.Article.View exposing (view)

import Api.Type.Article exposing (ArticleResponse)
import Api.Type.Comment exposing (Comment, CommentsResponse)
import Api.Type.User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Package.Prelude exposing (cn)
import Page.Article.Type exposing (Model, Msg(..))
import Util.RemoteData as RD
import Util.View as ViewUtil
import VitePluginHelper


view : Maybe User -> Model -> Html Msg
view maybeUser model =
    div [ class "flex min-h-full flex-col" ]
        [ case model.article of
            RD.NotAsked ->
                text ""

            RD.Loading ->
                div [ class "py-[24px] text-center text-sm text-gray-500" ] [ text "Loading article..." ]

            RD.Failure _ ->
                div [ class "py-[24px] text-center text-sm text-red-500" ] [ text "Error loading article" ]

            RD.Success data ->
                renderArticle maybeUser model data
        ]


renderArticle : Maybe User -> Model -> ArticleResponse -> Html Msg
renderArticle maybeUser model data =
    let
        article =
            data.article

        author =
            article.author

        isLoggedIn =
            case maybeUser of
                Just _ ->
                    True

                Nothing ->
                    False

        isAuthor =
            case maybeUser of
                Just u ->
                    u.username == author.username

                Nothing ->
                    False
    in
    div [ class "flex flex-col" ]
        [ -- Article Header
          div [ class "bg-gray-900 py-[40px] text-white shadow-inner" ]
            [ div [ class "mx-auto flex max-w-[1152px] flex-col gap-[16px] px-[16px]" ]
                [ h1 [ class "text-3xl font-bold leading-tight lg:text-4xl" ] [ text article.title ]
                , articleMeta True isAuthor isLoggedIn article
                ]
            ]
        , -- Article Body
          div [ class "mx-auto flex w-full max-w-[1152px] flex-col gap-[32px] px-[16px] py-[32px]" ]
            [ div [ class "flex flex-col gap-[16px]" ]
                [ div [ class "whitespace-pre-wrap text-lg leading-relaxed text-gray-800" ]
                    [ text (Maybe.withDefault "" article.body) ]
                , ul [ class "flex flex-wrap gap-[4px]" ]
                    (List.map (\tag -> li [ class "rounded-full border border-gray-300 px-[8px] py-[2px] text-xs text-gray-400" ] [ text tag ]) article.tagList)
                ]
            , hr [ class "border-gray-200" ] []
            , div [ class "flex flex-col items-center gap-[32px]" ]
                [ articleMeta False isAuthor isLoggedIn article
                , renderCommentsSection maybeUser model
                ]
            ]
        ]


articleMeta : Bool -> Bool -> Bool -> Api.Type.Article.Article -> Html Msg
articleMeta isLight isAuthor isLoggedIn article =
    let
        author =
            article.author

        textColor =
            if isLight then
                "text-green-400"

            else
                "text-green-600"

        btnBase =
            "flex items-center gap-[4px] rounded border px-[12px] py-[4px] text-xs transition-colors"

        secondaryBtn =
            if isLight then
                "border-gray-400 text-gray-300 hover:border-white hover:text-white"

            else
                "border-gray-300 text-gray-600 hover:border-gray-500"

        primaryBtn =
            if isLight then
                "border-green-500 text-green-400 hover:bg-green-900"

            else
                "border-green-500 text-green-600 hover:bg-green-50"

        deleteBtn =
            if isLight then
                "border-red-500 text-red-400 hover:bg-red-900"

            else
                "border-red-500 text-red-600 hover:bg-red-50"
    in
    div [ class "flex flex-wrap items-center gap-[12px]" ]
        [ a [ href ("/profile/" ++ author.username) ]
            [ img
                [ src (ViewUtil.userImage author.image)
                , class "h-[36px] w-[36px] rounded-full object-cover"
                ]
                []
            ]
        , div [ class "flex flex-col" ]
            [ a [ href ("/profile/" ++ author.username), cn [ "block text-sm font-medium hover:underline", textColor ] ]
                [ text author.username ]
            , span [ class "text-xs text-gray-400" ] [ text article.createdAt ]
            ]
        , div [ class "flex flex-wrap items-center gap-[8px]" ]
            (if isAuthor then
                [ a [ href ("/editor/" ++ article.slug), cn [ btnBase, secondaryBtn ] ]
                    [ text "Edit Article" ]
                , button [ type_ "button", cn [ btnBase, deleteBtn ], onClick DeleteArticle ]
                    [ text "Delete Article" ]
                ]

             else
                [ if isLoggedIn then
                    if author.following then
                        button [ type_ "button", cn [ btnBase, secondaryBtn ], onClick (UnfollowAuthor author.username) ]
                            [ text ("Unfollow " ++ author.username) ]

                    else
                        button [ type_ "button", cn [ btnBase, secondaryBtn ], onClick (FollowAuthor author.username) ]
                            [ text ("Follow " ++ author.username) ]

                  else
                    text ""
                , button
                    [ type_ "button"
                    , cn [ btnBase, primaryBtn ]
                    , onClick
                        (if isLoggedIn then
                            if article.favorited then
                                UnfavoriteArticle

                            else
                                FavoriteArticle

                         else
                            None
                        )
                    ]
                    [ text
                        (if article.favorited then
                            "Unfavorite Post"

                         else
                            "Favorite Post"
                        )
                    , span [] [ text (" (" ++ String.fromInt article.favoritesCount ++ ")") ]
                    ]
                ]
            )
        ]


renderCommentsSection : Maybe User -> Model -> Html Msg
renderCommentsSection maybeUser model =
    div [ class "flex w-full max-w-[700px] flex-col gap-[24px]" ]
        [ case maybeUser of
            Just _ ->
                Html.form [ class "flex flex-col overflow-hidden rounded border border-gray-200", onSubmit SubmitComment ]
                    [ textarea
                        [ class "min-h-[100px] w-full resize-none p-[12px] text-sm text-gray-800 outline-none"
                        , rows 3
                        , placeholder "Write a comment..."
                        , value model.commentInput
                        , onInput SetCommentInput
                        ]
                        []
                    , div [ class "flex justify-end border-t border-gray-100 bg-gray-50 px-[12px] py-[8px]" ]
                        [ button
                            [ type_ "submit"
                            , class "rounded bg-green-600 px-[12px] py-[4px] text-xs text-white transition-colors hover:bg-green-700"
                            ]
                            [ text "Post Comment" ]
                        ]
                    ]

            Nothing ->
                div [ class "text-center text-sm text-gray-500" ]
                    [ a [ href "/login", class "text-green-600 hover:underline" ] [ text "Sign in" ]
                    , text " or "
                    , a [ href "/register", class "text-green-600 hover:underline" ] [ text "sign up" ]
                    , text " to add comments on this article."
                    ]
        , case model.comments of
            RD.NotAsked ->
                text ""

            RD.Loading ->
                div [ class "py-[12px] text-sm text-gray-500 text-center" ] [ text "Loading comments..." ]

            RD.Failure _ ->
                div [ class "py-[12px] text-sm text-red-500 text-center" ] [ text "Error loading comments" ]

            RD.Success commentsData ->
                div [ class "flex flex-col gap-[16px]" ]
                    (List.map (renderComment maybeUser model.slug) commentsData.comments)
        ]


renderComment : Maybe User -> String -> Comment -> Html Msg
renderComment maybeUser slug comment =
    let
        author =
            comment.author

        isOwner =
            case maybeUser of
                Just u ->
                    u.username == author.username

                Nothing ->
                    False
    in
    div [ class "overflow-hidden rounded border border-gray-200" ]
        [ div [ class "p-[16px]" ]
            [ p [ class "whitespace-pre-wrap text-sm text-gray-800" ] [ text comment.body ] ]
        , div [ class "flex items-center gap-[8px] border-t border-gray-100 bg-gray-50 px-[16px] py-[8px] text-xs" ]
            [ a [ href ("/profile/" ++ author.username) ]
                [ img
                    [ src (ViewUtil.userImage author.image)
                    , class "h-[20px] w-[20px] rounded-full object-cover"
                    ]
                    []
                ]
            , a [ href ("/profile/" ++ author.username), class "font-medium text-green-600 hover:underline" ]
                [ text author.username ]
            , span [ class "text-gray-400" ] [ text comment.createdAt ]
            , if isOwner then
                button
                    [ type_ "button"
                    , class "ml-auto text-gray-400 transition-colors hover:text-red-500"
                    , onClick (DeleteComment comment.id)
                    ]
                    [ text "delete" ]

              else
                text ""
            ]
        ]
