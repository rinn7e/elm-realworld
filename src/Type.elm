module Type exposing (..)

import Api.Type.User exposing (User)
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Component.DebugPanel.Type as DebugPanel
import Data.Route.Type exposing (AppRoute)
import Page.Article.Type as Article
import Page.Auth.Type as Auth
import Page.Editor.Type as Editor
import Page.Home.Type as Home
import Page.Profile.Type as Profile
import Page.Settings.Type as Settings
import Url exposing (Url)


type alias Route =
    AppRoute


type alias Shared =
    { user : Maybe User
    , token : Maybe String
    }


type PageModel
    = Home Home.Model
    | Article Article.Model
    | Auth Auth.Model
    | Settings Settings.Model
    | Profile Profile.Model
    | Editor Editor.Model
    | NotFound
    | Loading


type AnimateState
    = AnimateIn
    | Visible
    | AnimateOut
    | Invisible


type alias Animate a =
    { internal : a
    , state : AnimateState
    }


type alias Model =
    { route : Route
    , shared : Shared
    , page : PageModel
    , isInternal : Bool
    , debugPanel : DebugPanel.Model
    , navbarMobileOpen : Animate ()
    , navKey : Nav.Key
    }


type Msg
    = UrlChange Url -- Handle URL changes from browser
    | LinkClick UrlRequest
    | ChangeRoute Route -- Programmatic route change
    | SetUser (Maybe User)
    | HomeMsg Home.Msg
    | ArticleMsg Article.Msg
    | AuthMsg Auth.Msg
    | SettingsMsg Settings.Msg
    | ProfileMsg Profile.Msg
    | EditorMsg Editor.Msg
    | DebugPanelMsg DebugPanel.Msg
    | ToggleNavbarMobile Bool
    | SetNavbarMobileState AnimateState
    | Logout
    | None
