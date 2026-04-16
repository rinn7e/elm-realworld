module Page.Home.View exposing (view)

import Api.Type.Article exposing (Article, ArticlesResponse)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Page.Home.Type exposing (Model, Msg(..))
import Util.Http exposing (httpErrorToString)
import Util.RemoteData as RD
import VitePluginHelper


view : Model -> Html Msg
view model =
    div [ class "flex min-h-full flex-col" ]
        [ -- Hero Section
          div [ class "bg-green-600 py-[48px] text-center text-white shadow-inner" ]
            [ div [ class "mx-auto flex max-w-[1152px] flex-col gap-[8px] px-[16px]" ]
                [ h1 [ class "text-4xl font-bold tracking-tight lg:text-5xl" ] [ text "conduit" ]
                , p [ class "text-base font-light opacity-90 lg:text-lg" ] [ text "A place to share your knowledge." ]
                ]
            ]
        , -- Main Content
          div [ class "mx-auto w-full max-w-[1152px] px-[16px] py-[24px]" ]
            [ div [ class "flex flex-col gap-[24px] lg:flex-row lg:gap-[48px]" ]
                [ -- Article List
                  div [ class "flex min-w-0 flex-1 flex-col" ]
                    [ div [ class "flex border-b border-gray-200" ]
                        [ a [ class "border-b-2 border-green-600 px-[16px] py-[8px] text-sm font-medium text-green-600", href "/" ] [ text "Global Feed" ]
                        ]
                    , div [ class "flex flex-col" ]
                        [ case model.articles of
                            RD.NotAsked ->
                                text ""

                            RD.Loading ->
                                div [ class "py-[24px] text-sm text-gray-500" ] [ text "Loading articles..." ]

                            RD.Failure err ->
                                div [ class "py-[24px] text-sm text-red-500" ] [ text ("Error loading articles: " ++ httpErrorToString err) ]

                            RD.Success response ->
                                if List.isEmpty response.articles then
                                    div [ class "py-[24px] text-sm text-gray-500" ] [ text "No articles are here... yet." ]

                                else
                                    div [ class "flex flex-col" ] (List.map viewArticle response.articles)
                        ]
                    ]
                , -- Popular Tags
                  div [ class "w-full shrink-0 lg:w-[224px]" ]
                    [ div [ class "flex flex-col gap-[12px] rounded-lg bg-gray-50 p-[16px]" ]
                        [ p [ class "text-sm font-semibold text-gray-700" ] [ text "Popular Tags" ]
                        , div [ class "flex flex-wrap gap-[4px]" ]
                            [ case model.tags of
                                RD.Success response ->
                                    div [] (List.map viewTag response.tags)

                                RD.Loading ->
                                    text "Loading tags..."

                                _ ->
                                    text ""
                            ]
                        ]
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
                    [ img [ src (Maybe.withDefault (VitePluginHelper.asset "/src/assets/default-avatar.svg") article.author.image), class "h-[32px] w-[32px] rounded-full object-cover" ] [] ]
                , div [ class "flex flex-col" ]
                    [ a [ href ("/profile/" ++ article.author.username), class "block text-sm font-medium text-green-600 hover:underline" ] [ text article.author.username ]
                    , span [ class "text-xs text-gray-400" ] [ text article.createdAt ]
                    ]
                ]
            , button [ class "flex items-center gap-[4px] rounded border border-green-500 px-[8px] py-[4px] text-xs text-green-600 hover:bg-green-50", onClick (FavoriteArticle article.slug) ]
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


viewTag : String -> Html Msg
viewTag tag =
    a [ href "#", class "inline-block rounded-full bg-gray-200 px-[8px] py-[2px] text-xs text-gray-700 hover:bg-gray-300" ] [ text tag ]
