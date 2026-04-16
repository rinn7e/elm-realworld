module Package.ElmForm exposing (..)

import Dict exposing (Dict)


type FieldType
    = TextType TextConfig


type alias TextConfig =
    { placeholder : String
    , label : String
    , currentValue : String
    , validation : String -> Result String String
    , showValidation : Bool
    }


type alias Model =
    { forms : Dict String FieldType
    }


init : Model
init =
    { forms = Dict.empty }


{-| Initialize a text field
-}
initText : String -> String -> (String -> Result String String) -> FieldType
initText label placeholder validation =
    TextType
        { label = label
        , placeholder = placeholder
        , currentValue = ""
        , validation = validation
        , showValidation = False
        }


{-| Get the current value of a text field
-}
getTextValue : String -> Model -> String
getTextValue key model =
    case Dict.get key model.forms of
        Just (TextType config) ->
            config.currentValue

        _ ->
            ""


{-| Update a field value
-}
updateValue : String -> String -> Model -> Model
updateValue key value model =
    let
        newForms =
            Dict.update key
                (\maybeField ->
                    case maybeField of
                        Just (TextType config) ->
                            Just (TextType { config | currentValue = value })

                        _ ->
                            maybeField
                )
                model.forms
    in
    { model | forms = newForms }


{-| Set showValidation to true for a field
-}
setShowValidation : String -> Bool -> Model -> Model
setShowValidation key show model =
    let
        newForms =
            Dict.update key
                (\maybeField ->
                    case maybeField of
                        Just (TextType config) ->
                            Just (TextType { config | showValidation = show })

                        _ ->
                            maybeField
                )
                model.forms
    in
    { model | forms = newForms }


{-| Set showValidation to true for all fields
-}
showAllValidations : Model -> Model
showAllValidations model =
    let
        newForms =
            Dict.map
                (\_ field ->
                    case field of
                        TextType config ->
                            TextType { config | showValidation = True }
                )
                model.forms
    in
    { model | forms = newForms }


{-| Validate all fields
-}
validateAll : Model -> Result String (Dict String String)
validateAll model =
    let
        results =
            Dict.toList model.forms
                |> List.map
                    (\( key, field ) ->
                        case field of
                            TextType config ->
                                config.validation config.currentValue
                                    |> Result.map (\val -> ( key, val ))
                    )

        folded =
            List.foldl
                (\res acc ->
                    case ( res, acc ) of
                        ( Err err, _ ) ->
                            Err err

                        ( _, Err err ) ->
                            Err err

                        ( Ok ( k, v ), Ok dict ) ->
                            Ok (Dict.insert k v dict)
                )
                (Ok Dict.empty)
                results
    in
    case folded of
        Ok dict ->
            Ok dict

        Err _ ->
            Err "Some fields are invalid."


-- Validations


nonEmptyValidator : String -> String -> Result String String
nonEmptyValidator fieldName input =
    if String.isEmpty (String.trim input) then
        Err (fieldName ++ " can't be blank")

    else
        Ok input


emailValidator : String -> Result String String
emailValidator input =
    -- Simple email regex check
    if String.contains "@" input && String.contains "." input then
        Ok input

    else
        Err "is invalid"


minLengthValidator : String -> Int -> String -> Result String String
minLengthValidator label minLength input =
    if String.length input < minLength then
        Err (label ++ " is too short (minimum is " ++ String.fromInt minLength ++ " characters)")

    else
        Ok input
