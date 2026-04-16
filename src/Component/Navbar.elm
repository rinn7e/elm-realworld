module Component.Navbar exposing (view)

import Api.Type.User exposing (User)
import Data.Route.Parser as RouteParser
import Data.Route.Type exposing (AppPage(..), AppRoute)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Package.Prelude exposing (cn)
import Type exposing (Animate, AnimateState(..), Model, Msg(..), PageModel(..))
import Util.View as ViewUtil
import VitePluginHelper


view : Model -> Html Msg
view model =
    let
        user =
            model.shared.user

        pageTag =
            model.page

        isHome =
            case pageTag of
                Home _ ->
                    True

                _ ->
                    False

        isEditor =
            case pageTag of
                Editor _ ->
                    True

                _ ->
                    False

        isSettings =
            case pageTag of
                Settings _ ->
                    True

                _ ->
                    False

        isProfile =
            case pageTag of
                Profile subModel ->
                    case user of
                        Just u ->
                            subModel.username == u.username

                        Nothing ->
                            False

                _ ->
                    False

        activeCls =
            "font-semibold text-green-600"

        inactiveCls =
            "text-gray-500 hover:text-gray-900"

        links isSidebar =
            [ li []
                [ a
                    [ cn
                        [ "block rounded px-[12px] py-[6px] text-sm"
                        , if isHome then
                            activeCls

                          else
                            inactiveCls
                        ]
                    , href "/"
                    ]
                    [ text "Home" ]
                ]
            ]
                ++ (case user of
                        Just u ->
                            [ li []
                                [ a
                                    [ cn
                                        [ "flex items-center gap-[4px] rounded px-[12px] py-[6px] text-sm"
                                        , if isEditor then
                                            activeCls

                                          else
                                            inactiveCls
                                        ]
                                    , href "/editor"
                                    ]
                                    [ text "New Article" ]
                                ]
                            , li []
                                [ a
                                    [ cn
                                        [ "flex items-center gap-[4px] rounded px-[12px] py-[6px] text-sm"
                                        , if isSettings then
                                            activeCls

                                          else
                                            inactiveCls
                                        ]
                                    , href "/settings"
                                    ]
                                    [ text "Settings" ]
                                ]
                            , li []
                                [ a
                                    [ cn
                                        [ "flex items-center gap-[8px] rounded px-[12px] py-[6px] text-sm"
                                        , if isProfile then
                                            activeCls

                                          else
                                            inactiveCls
                                        ]
                                    , href ("/profile/" ++ u.username)
                                    ]
                                    [ img
                                        [ src (ViewUtil.userImage u.image)
                                        , class "h-[28px] w-[28px] rounded-full object-cover"
                                        ]
                                        []
                                    , text u.username
                                    ]
                                ]
                            ]

                        Nothing ->
                            [ li []
                                [ a [ cn [ "rounded px-[12px] py-[6px] text-sm", inactiveCls ], href "/login" ] [ text "Sign in" ]
                                ]
                            , li []
                                [ a [ cn [ "rounded px-[12px] py-[6px] text-sm", inactiveCls ], href "/register" ] [ text "Sign up" ]
                                ]
                            ]
                   )

        animate =
            model.navbarMobileOpen

        isVisible =
            animate.state /= Invisible

        backdropCls =
            cn
                [ "absolute inset-0 bg-black/50"
                , if animate.state == AnimateIn then
                    "animate-fade-in"

                  else if animate.state == AnimateOut then
                    "animate-fade-out"

                  else
                    ""
                ]

        sidebarCls =
            cn
                [ "relative flex flex-col w-[280px] h-full bg-white shadow-xl p-[16px] overflow-y-auto"
                , if animate.state == AnimateIn then
                    "animate-slide-in"

                  else if animate.state == AnimateOut then
                    "animate-slide-out"

                  else
                    ""
                ]
    in
    nav [ class "sticky top-0 z-20 border-b border-gray-100 bg-white shadow-sm" ]
        [ div [ class "mx-auto max-w-[1152px] px-[16px]" ]
            [ div [ class "flex h-[56px] items-center justify-between" ]
                [ a [ class "text-xl font-bold tracking-tight text-green-600", href "/" ] [ text "conduit" ]
                , button
                    [ type_ "button"
                    , class "p-[8px] text-gray-500 hover:text-gray-900 focus:outline-none lg:hidden"
                    , onClick (ToggleNavbarMobile True)
                    ]
                    [ text "Menu" ]
                , ul [ class "hidden lg:flex lg:items-center lg:gap-[4px]" ] (links False)
                ]
            ]
        , if isVisible then
            div [ class "fixed inset-0 z-[100] flex justify-end overflow-hidden" ]
                [ div [ backdropCls, onClick (ToggleNavbarMobile False) ] []
                , div [ sidebarCls ]
                    [ div [ class "flex flex-col gap-[16px]" ]
                        [ div [ class "flex items-center justify-between" ]
                            [ span [ class "text-xl font-bold text-green-600" ] [ text "conduit" ]
                            , button
                                [ type_ "button"
                                , class "p-[8px] text-gray-500 hover:text-gray-900 focus:outline-none"
                                , onClick (ToggleNavbarMobile False)
                                ]
                                [ text "X" ]
                            ]
                        , ul [ class "flex flex-col gap-[8px]" ] (links True)
                        ]
                    ]
                ]

          else
            text ""
        ]
