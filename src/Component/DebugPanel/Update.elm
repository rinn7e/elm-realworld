module Component.DebugPanel.Update exposing (..)

import Component.DebugPanel.Type exposing (Model, Msg(..))


update : Msg -> Model -> Model
update msg model =
    case msg of
        ToggleCollapse ->
            { model | isCollapse = not model.isCollapse }
