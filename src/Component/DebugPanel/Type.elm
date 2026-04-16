module Component.DebugPanel.Type exposing (..)


type alias Model =
    { isCollapse : Bool
    }


type Msg
    = ToggleCollapse


init : Model
init =
    { isCollapse = True }
