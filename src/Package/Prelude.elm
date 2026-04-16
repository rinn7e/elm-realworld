module Package.Prelude exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (class)
import Process
import Task


{-| Similar to tea-cup-prelude's delayCmd
-}
delayCmd : Float -> msg -> Cmd msg
delayCmd ms msg =
    Process.sleep ms
        |> Task.perform (\_ -> msg)


{-| Similar to tea-cup-prelude's updateAndCmd
-}
updateAndCmd : (model -> ( model, Cmd msg )) -> ( model, Cmd msg ) -> ( model, Cmd msg )
updateAndCmd func ( model, cmd ) =
    let
        ( newModel, newCmd ) =
            func model
    in
    ( newModel, Cmd.batch [ cmd, newCmd ] )


{-| Similar to tea-cup-prelude's extraCmd
-}
extraCmd : (model -> Cmd msg) -> ( model, Cmd msg ) -> ( model, Cmd msg )
extraCmd mkNewCmd ( model, cmd ) =
    ( model, Cmd.batch [ cmd, mkNewCmd model ] )


{-| Similar to tea-cup-prelude's cn (classname helper)
-}
cn : List String -> Attribute msg
cn classes =
    class (String.join " " (List.filter (not << String.isEmpty) classes))


{-| IfElse helper seen in kampu-law template
-}
ifElse : Bool -> a -> a -> a
ifElse condition whenTrue whenFalse =
    if condition then
        whenTrue

    else
        whenFalse
