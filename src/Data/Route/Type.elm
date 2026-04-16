module Data.Route.Type exposing (..)


type AppPage
    = HomePage
    | LoginPage
    | RegisterPage
    | SettingsPage
    | EditorPage (Maybe String)
    | ArticlePage String
    | ProfilePage { username : String, favorites : Bool }
    | NotFoundPage


type alias AppRoute =
    { page : AppPage
    }


defaultAppRoute : AppRoute
defaultAppRoute =
    { page = HomePage }
