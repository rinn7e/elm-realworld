module Component.DebugPanel.Update exposing (..)

import Component.DebugPanel.Type exposing (Model, Msg(..))


import Ports


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        ToggleCollapse ->
            ( { model | isCollapse = not model.isCollapse }, Cmd.none )

        ClearCacheAndReload ->
            ( model, Cmd.batch [ Ports.removeToken (), Ports.reload () ] )
