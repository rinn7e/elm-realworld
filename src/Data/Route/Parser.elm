module Data.Route.Parser exposing (parseAppRoute, toUrlString)

import Data.Route.Type exposing (AppPage(..), AppRoute)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, map, oneOf, s, string)


parser : Parser (AppPage -> a) a
parser =
    oneOf
        [ map HomePage Parser.top
        , map LoginPage (s "login")
        , map RegisterPage (s "register")
        , map SettingsPage (s "settings")
        , map (EditorPage Nothing) (s "editor")
        , map (\slug -> EditorPage (Just slug)) (s "editor" </> string)
        , map ArticlePage (s "article" </> string)
        , map (\username -> ProfilePage { username = username, favorites = False }) (s "profile" </> string)
        , map (\username -> ProfilePage { username = username, favorites = True }) (s "profile" </> string </> s "favorites")
        ]


parseAppRoute : Url -> AppRoute
parseAppRoute url =
    { page = Maybe.withDefault NotFoundPage (Parser.parse parser url) }


toUrlString : AppRoute -> String
toUrlString { page } =
    case page of
        HomePage ->
            "/"

        LoginPage ->
            "/login"

        RegisterPage ->
            "/register"

        SettingsPage ->
            "/settings"

        EditorPage Nothing ->
            "/editor"

        EditorPage (Just slug) ->
            "/editor/" ++ slug

        ArticlePage slug ->
            "/article/" ++ slug

        ProfilePage { username, favorites } ->
            if favorites then
                "/profile/" ++ username ++ "/favorites"

            else
                "/profile/" ++ username

        NotFoundPage ->
            "/404"
