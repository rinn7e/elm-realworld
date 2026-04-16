module Package.ElmForm exposing (..)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onBlur, onFocus, onInput)


type FieldType
    = TextType TextConfig


type alias TextConfig =
    { placeholder : String
    , label : String
    , currentValue : String
    , validation : String -> Result String String
    , showValidation : Bool
    , isPassword : Bool
    , isTextarea : Bool
    , isFocus : Bool
    }


type alias Model =
    { forms : Dict String FieldType
    }


init : Model
init =
    { forms = Dict.empty }


addField : String -> FieldType -> Model -> Model
addField key field model =
    { model | forms = Dict.insert key field model.forms }


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
        , isPassword = False
        , isTextarea = False
        , isFocus = False
        }


toPassword : FieldType -> FieldType
toPassword field =
    case field of
        TextType config ->
            TextType { config | isPassword = True }


toTextarea : FieldType -> FieldType
toTextarea field =
    case field of
        TextType config ->
            TextType { config | isTextarea = True }


withValue : String -> FieldType -> FieldType
withValue val field =
    case field of
        TextType config ->
            TextType { config | currentValue = val }


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


setFocus : String -> Bool -> Model -> Model
setFocus key focus model =
    let
        newForms =
            Dict.update key
                (\maybeField ->
                    case maybeField of
                        Just (TextType config) ->
                            Just (TextType { config | isFocus = focus })

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


-- View


viewItem : String -> Model -> (String -> String -> msg) -> (String -> Bool -> msg) -> Html msg
viewItem key model onInputMsg onFocusMsg =
    case Dict.get key model.forms of
        Just (TextType config) ->
            let
                validationResult =
                    config.validation config.currentValue

                isError =
                    case validationResult of
                        Err _ ->
                            config.showValidation

                        Ok _ ->
                            False

                borderStyle =
                    if isError then
                        "border-red-600 focus-within:border-red-600"

                    else
                        "border-gray-200 focus-within:border-gray-700"

                labelColor =
                    if isError then
                        "text-red-600"

                    else
                        "text-gray-900"

                labelMoved =
                    config.isFocus || (not <| String.isEmpty config.currentValue)

                labelClasses =
                    labelColor
                        ++ " pointer-events-none absolute z-10 px-3 transition-all "
                        ++ (if labelMoved then
                                " pt-1.5 text-xs opacity-100"

                            else
                                " pt-3.5 text-base opacity-50"
                           )

                inputAttrs =
                    [ class "w-full px-3 outline-none"
                    , style "padding-bottom" "6px"
                    , style "padding-top" "22px"
                    , value config.currentValue
                    , onInput (onInputMsg key)
                    , onFocus (onFocusMsg key True)
                    , onBlur (onFocusMsg key False)
                    , name config.label
                    , placeholder (if config.isFocus then config.placeholder else "")
                    ]
            in
            div [ class "flex w-full flex-col" ]
                [ if isError then
                    case validationResult of
                        Err err ->
                            div [ class "relative" ]
                                [ div [ class "absolute bottom-full left-0 z-20 mb-1 w-full" ]
                                    [ div [ class "inline-block rounded bg-red-600 px-2 py-1 text-xs text-white shadow-lg" ] [ text err ]
                                    ]
                                ]

                        Ok _ ->
                            text ""

                  else
                    text ""
                , div [ class ("flex flex-col border " ++ borderStyle) ]
                    [ div [ class "relative" ]
                        [ p [ class labelClasses ] [ text config.label ]
                        ]
                    , if config.isTextarea then
                        Html.textarea (rows 6 :: inputAttrs) []

                      else
                        input (type_ (if config.isPassword then "password" else "text") :: inputAttrs) []
                    ]
                ]

        Nothing ->
            div [] [ text ("Internal error: field " ++ key ++ " not found") ]


-- Validations


nonEmptyValidator : String -> String -> Result String String
nonEmptyValidator fieldName input =
    if String.isEmpty (String.trim input) then
        Err (fieldName ++ " can't be blank")

    else
        Ok input


emailValidator : String -> Result String String
emailValidator input =
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
