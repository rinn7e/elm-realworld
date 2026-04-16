module Page.Profile.View exposing (view)

import Api.Type.Article exposing (Article)
import Api.Type.Profile exposing (ProfileResponse)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Page.Profile.Type exposing (Model, Msg(..))
import Package.Prelude exposing (cn)
import Util.Http exposing (httpErrorToString)
import Util.RemoteData as RD
import VitePluginHelper


view : Model -> Html Msg
view model =
    let
        isCurrentUser =
            -- Simplified current user check for now
            -- In a real app we'd compare model.username with model.shared.user.username
            False 
    in
    div [ class "flex min-h-full flex-col" ]
        [ case model.profile of
            RD.NotAsked ->
                div [ class "py-[24px] text-center text-sm text-gray-500" ] [ text "Loading profile..." ]

            RD.Loading ->
                div [ class "py-[24px] text-center text-sm text-gray-500" ] [ text "Loading profile..." ]

            RD.Failure err ->
                div [ class "py-[24px] text-center text-sm text-red-500" ] [ text ("Error loading profile: " ++ httpErrorToString err) ]

            RD.Success data ->
                let
                    profile = data.profile
                in
                div []
                    [ -- Header Banner
                      div [ class "border-b border-gray-200 bg-gray-50 py-[12px] text-center shadow-inner lg:py-[40px]" ]
                        [ div [ class "mx-auto flex max-w-[1152px] flex-col items-center gap-[12px] px-[16px]" ]
                            [ img
                                [ src (Maybe.withDefault (VitePluginHelper.asset "/src/assets/default-avatar.svg") profile.image)
                                , class "h-[96px] w-[96px] rounded-full border-[4px] border-white object-cover shadow-sm"
                                , alt ""
                                ]
                                []
                            , div [ class "flex flex-col gap-[4px]" ]
                                [ h4 [ class "text-2xl font-bold text-gray-900" ] [ text profile.username ]
                                , case profile.bio of
                                    Just bio ->
                                        p [ class "max-w-[600px] text-sm text-gray-500" ] [ text bio ]
                                    Nothing ->
                                        text ""
                                ]
                            , div [ class "pt-[4px]" ]
                                [ if isCurrentUser then
                                    a
                                        [ class "inline-flex items-center gap-[6px] rounded border border-gray-400 px-[12px] py-[6px] text-sm text-gray-600 transition-colors hover:border-gray-600"
                                        , href "/settings"
                                        ]
                                        [ text "Edit Profile Settings" ]

                                  else
                                    button
                                        [ type_ "button"
                                        , class "inline-flex items-center gap-[6px] rounded border border-gray-400 px-[12px] py-[6px] text-sm text-gray-600 transition-colors hover:border-gray-600"
                                        , onClick (if profile.following then Unfollow else Follow)
                                        ]
                                        [ text (if profile.following then "Unfollow " ++ profile.username else "Follow " ++ profile.username) ]
                                ]
                            ]
                        ]
                    , -- Main Content
                      div [ class "mx-auto flex w-full max-w-[1152px] flex-col gap-[24px] px-[16px] py-[24px]" ]
                        [ div [ class "flex border-b border-gray-200" ]
                            [ button
                                [ type_ "button"
                                , cn 
                                    [ "border-b-2 px-[16px] py-[8px] text-sm font-medium transition-colors"
                                    , if not model.showFavorites then "border-green-600 text-green-600" else "border-transparent text-gray-500 hover:text-gray-700"
                                    ]
                                , onClick (ToggleFavorites False)
                                ]
                                [ text "My Articles" ]
                            , button
                                [ type_ "button"
                                , cn 
                                    [ "border-b-2 px-[16px] py-[8px] text-sm font-medium transition-colors"
                                    , if model.showFavorites then "border-green-600 text-green-600" else "border-transparent text-gray-500 hover:text-gray-700"
                                    ]
                                , onClick (ToggleFavorites True)
                                ]
                                [ text "Favorited Articles" ]
                            ]
                        , div [ class "flex flex-col" ]
                            [ case model.articles of
                                RD.NotAsked -> text ""
                                RD.Loading -> div [ class "py-[24px] text-sm text-gray-500" ] [ text "Loading articles..." ]
                                RD.Failure err -> div [ class "py-[24px] text-sm text-red-500" ] [ text ("Error loading articles: " ++ httpErrorToString err) ]
                                RD.Success response ->
                                    if List.isEmpty response.articles then
                                        div [ class "py-[24px] text-sm text-gray-500" ] [ text "No articles are here... yet." ]
                                    else
                                        div [ class "flex flex-col" ] (List.map viewArticle response.articles)
                            ]
                        ]
                    ]
        ]


viewArticle : Article -> Html Msg
viewArticle article =
    div [ class "flex flex-col gap-[12px] border-b border-gray-200 py-[24px]" ]
        [ div [ class "flex items-center justify-between" ]
            [ div [ class "flex items-center gap-[12px]" ]
                [ a [ href ("/profile/" ++ article.author.username) ]
                    [ img 
                        [ src (Maybe.withDefault (VitePluginHelper.asset "/src/assets/default-avatar.svg") article.author.image)
                        , class "h-[32px] w-[32px] rounded-full object-cover" 
                        ] [] 
                    ]
                , div [ class "flex flex-col" ]
                    [ a [ href ("/profile/" ++ article.author.username), class "block text-sm font-medium text-green-600 hover:underline" ] [ text article.author.username ]
                    , span [ class "text-xs text-gray-400" ] [ text article.createdAt ]
                    ]
                ]
            , button 
                [ class "flex items-center gap-[4px] rounded border border-green-500 px-[8px] py-[4px] text-xs text-green-600 hover:bg-green-50"
                , onClick (if article.favorited then UnfavoriteArticle article.slug else FavoriteArticle article.slug) 
                ]
                [ text (String.fromInt article.favoritesCount) ]
            ]
        , a [ href ("/article/" ++ article.slug), class "flex flex-col gap-[12px]" ]
            [ div [ class "flex flex-col gap-[4px]" ]
                [ h1 [ class "line-clamp-2 text-xl font-bold text-gray-900" ] [ text article.title ]
                , p [ class "line-clamp-3 text-sm text-gray-500" ] [ text article.description ]
                ]
            , div [ class "flex items-center justify-between" ]
                [ span [ class "text-xs text-gray-400" ] [ text "Read more..." ]
                , ul [ class "flex flex-wrap gap-[4px]" ]
                    (List.map (\tag -> li [ class "rounded-full border border-gray-300 px-[8px] py-[2px] text-xs text-gray-400" ] [ text tag ]) article.tagList)
                ]
            ]
        ]
