module Component.DebugPanel.Type exposing (..)


type alias Model =
    { isCollapse : Bool
    }


type Msg
    = ToggleCollapse
    | ClearCacheAndReload


init : Model
init =
    { isCollapse = True }
