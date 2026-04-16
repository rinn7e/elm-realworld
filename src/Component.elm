module Component exposing (view)

import Component.DebugPanel.Type as DebugPanel
import Component.DebugPanel.View as DebugPanel
import Component.Footer as Footer
import Component.Navbar as Navbar
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Article.View as Article
import Page.Auth.View as Auth
import Page.Editor.View as Editor
import Page.Home.View as Home
import Page.Profile.View as Profile
import Page.Settings.View as Settings
import Package.Prelude exposing (cn)
import Type exposing (AnimateState(..), Model, Msg(..), PageModel(..))


view : Model -> Html Msg
view model =
    let
        isNavOpen =
            model.navbarMobileOpen.state /= Invisible
    in
    div
        [ cn
            [ "flex min-h-dvh flex-col"
            , if isNavOpen then
                "h-dvh overflow-hidden"

              else
                ""
            ]
        ]
        [ Navbar.view model
        , main_ [ class "flex-grow" ] [ renderPage model ]
        , Footer.view
        , DebugPanel.view model.debugPanel |> Html.map DebugPanelMsg
        ]


renderPage : Model -> Html Msg
renderPage model =
    case model.page of
        Home subModel ->
            Home.view subModel |> Html.map HomeMsg

        Article subModel ->
            Article.view subModel |> Html.map ArticleMsg

        Auth subModel ->
            Auth.view subModel |> Html.map AuthMsg

        Editor subModel ->
            Editor.view subModel |> Html.map EditorMsg

        Profile subModel ->
            Profile.view subModel |> Html.map ProfileMsg

        Settings subModel ->
            Settings.view subModel |> Html.map SettingsMsg

        Loading ->
            div [ class "flex min-h-[400px] items-center justify-center" ] [ text "Loading..." ]

        NotFound ->
            div [ class "p-[16px]" ] [ text "404 - Not Found" ]
