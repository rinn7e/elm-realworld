module Package.ElmForm exposing (..)

import Dict exposing (Dict)
import Html exposing (Html)


type alias Password =
    { revealPassword : Bool
    , disableAutocomplete : Bool
    }


type alias TextUiArgs pmsg =
    { key : String
    , label : String
    , isFocus : Bool
    , placeholder : String
    , currentValue : String
    , showValidation : Bool
    , mkPmsg : Msg -> pmsg
    , validationResult : Result String String
    , isPassword : Maybe Password
    , isTextarea : Bool
    }


type alias CheckboxChoice =
    ( String, Bool )


type alias CheckboxUiArgs pmsg =
    { mkPmsg : Msg -> pmsg
    , fieldKey : String
    , checkboxChoice : CheckboxChoice
    , isMarkdown : Bool
    }


type alias RadioChoice =
    { key : String
    , label : String
    , desc : String
    }


type alias RadioUiArgs pmsg =
    { mkPmsg : Msg -> pmsg
    , fieldKey : String
    , radioChoice : RadioChoice
    , isActive : Bool
    }


type alias DropdownUiArgs pmsg =
    { mkPmsg : Msg -> pmsg
    , label : String
    , currentValue : Maybe String
    , placeholder : String
    , fieldKey : String
    , isFocus : Bool
    , choices : List String
    , validationResult : Result String (Maybe String)
    , showValidation : Bool
    }


type alias TextConfig pmsg =
    { placeholder : String
    , label : String
    , currentValue : String
    , validation : String -> Result String String
    , linkValidations : List { linkKey : String, validation : String -> String -> Result String String }
    , showValidation : Bool
    , isTextarea : Bool
    , isPassword : Maybe Password
    , isFocus : Bool
    , ui : TextUiArgs pmsg -> Html pmsg
    }


type alias CheckboxConfig pmsg =
    { currentValues : List CheckboxChoice
    , validation : List CheckboxChoice -> Result String (List CheckboxChoice)
    , isMarkdown : Bool
    , ui : CheckboxUiArgs pmsg -> Html pmsg
    }


type alias RadioConfig pmsg =
    { choices : List RadioChoice
    , currentValue : Maybe String
    , isMarkdown : Bool
    , ui : RadioUiArgs pmsg -> Html pmsg
    }


type alias DropdownConfig pmsg =
    { label : String
    , placeholder : String
    , choices : List String
    , currentValue : Maybe String
    , validation : Maybe String -> Result String (Maybe String)
    , showValidation : Bool
    , isFocus : Bool
    , ui : DropdownUiArgs pmsg -> Html pmsg
    }


type FieldType pmsg
    = TextType (TextConfig pmsg)
    | CheckboxType (CheckboxConfig pmsg)
    | RadioType (RadioConfig pmsg)
    | DropdownType (DropdownConfig pmsg)


type alias Model pmsg =
    { forms : Dict String (FieldType pmsg)
    , isDrag : Bool
    }


type Msg
    = UpdateForm String String
    | UpdateFormManual String String
    | UpdateDropdownType String String
    | ToggleCheckbox String String Bool
    | UpdateRadio String String Bool
    | HandleFocus String Bool
    | RevealPassword String Bool
    | HideValidation String
    | SetIsDrag Bool
    | RemoveFormItem String


init : Dict String (FieldType pmsg) -> Model pmsg
init forms =
    { forms = forms
    , isDrag = False
    }


update : Msg -> Model pmsg -> Model pmsg
update msg model =
    case msg of
        UpdateForm key val ->
            { model | forms = updateField key (updateValueTextType val) model.forms }

        UpdateFormManual key val ->
            { model | forms = updateField key (updateValueTextType val) model.forms }

        UpdateDropdownType key val ->
            { model | forms = updateField key (updateDropdownValue val) model.forms }

        ToggleCheckbox key checkboxKey val ->
            { model | forms = updateField key (toggleCheckboxValue checkboxKey val) model.forms }

        UpdateRadio key radioKey _ ->
            { model | forms = updateField key (updateRadioValue radioKey) model.forms }

        HandleFocus key isFocus ->
            { model | forms = updateField key (updateFocus isFocus) model.forms }

        RevealPassword key revealed ->
            { model | forms = updateField key (updateRevealPassword revealed) model.forms }

        HideValidation key ->
            { model | forms = updateField key updateHideValidation model.forms }

        SetIsDrag status ->
            { model | isDrag = status }

        RemoveFormItem key ->
            { model | forms = Dict.remove key model.forms }


updateField : String -> (FieldType pmsg -> FieldType pmsg) -> Dict String (FieldType pmsg) -> Dict String (FieldType pmsg)
updateField key fn forms =
    Dict.update key (Maybe.map fn) forms


updateValueTextType : String -> FieldType pmsg -> FieldType pmsg
updateValueTextType val field =
    case field of
        TextType config ->
            TextType { config | currentValue = val }

        _ ->
            field


updateDropdownValue : String -> FieldType pmsg -> FieldType pmsg
updateDropdownValue val field =
    case field of
        DropdownType config ->
            DropdownType { config | currentValue = Just val, isFocus = False }

        _ ->
            field


toggleCheckboxValue : String -> Bool -> FieldType pmsg -> FieldType pmsg
toggleCheckboxValue checkboxKey val field =
    case field of
        CheckboxType config ->
            let
                newValues =
                    List.map
                        (\( k, v ) ->
                            if k == checkboxKey then
                                ( k, val )

                            else
                                ( k, v )
                        )
                        config.currentValues
            in
            CheckboxType { config | currentValues = newValues }

        _ ->
            field


updateRadioValue : String -> FieldType pmsg -> FieldType pmsg
updateRadioValue radioKey field =
    case field of
        RadioType config ->
            RadioType { config | currentValue = Just radioKey }

        _ ->
            field


updateFocus : Bool -> FieldType pmsg -> FieldType pmsg
updateFocus isFocus field =
    case field of
        TextType config ->
            TextType { config | isFocus = isFocus, showValidation = if not isFocus then True else config.showValidation }

        DropdownType config ->
            DropdownType { config | isFocus = isFocus, showValidation = if not isFocus then True else config.showValidation }

        _ ->
            field


updateRevealPassword : Bool -> FieldType pmsg -> FieldType pmsg
updateRevealPassword revealed field =
    case field of
        TextType config ->
            case config.isPassword of
                Just p ->
                    TextType { config | isPassword = Just { p | revealPassword = revealed } }

                Nothing ->
                    field

        _ ->
            field


updateHideValidation : FieldType pmsg -> FieldType pmsg
updateHideValidation field =
    case field of
        TextType config ->
            TextType { config | showValidation = False }

        DropdownType config ->
            DropdownType { config | showValidation = False }

        _ ->
            field


viewItem : String -> Model pmsg -> (Msg -> pmsg) -> Html pmsg
viewItem key model mkPmsg =
    case Dict.get key model.forms of
        Just field ->
            case field of
                TextType config ->
                    let
                        validationResult =
                            runValidationAndLink config model.forms
                    in
                    config.ui
                        { key = key
                        , label = config.label
                        , isFocus = config.isFocus
                        , placeholder = config.placeholder
                        , currentValue = config.currentValue
                        , showValidation = config.showValidation
                        , mkPmsg = mkPmsg
                        , validationResult = validationResult
                        , isPassword = config.isPassword
                        , isTextarea = config.isTextarea
                        }

                CheckboxType config ->
                    Html.div []
                        (List.map
                            (\choice ->
                                config.ui
                                    { mkPmsg = mkPmsg
                                    , fieldKey = key
                                    , checkboxChoice = choice
                                    , isMarkdown = config.isMarkdown
                                    }
                            )
                            config.currentValues
                        )

                RadioType config ->
                    Html.div []
                        (List.map
                            (\choice ->
                                config.ui
                                    { mkPmsg = mkPmsg
                                    , fieldKey = key
                                    , radioChoice = choice
                                    , isActive = config.currentValue == Just choice.key
                                    }
                            )
                            config.choices
                        )

                DropdownType config ->
                    let
                        validationResult =
                            config.validation config.currentValue
                    in
                    config.ui
                        { mkPmsg = mkPmsg
                        , label = config.label
                        , currentValue = config.currentValue
                        , placeholder = config.placeholder
                        , fieldKey = key
                        , isFocus = config.isFocus
                        , choices = config.choices
                        , validationResult = validationResult
                        , showValidation = config.showValidation
                        }

        Nothing ->
            Html.text ("Internal error: field " ++ key ++ " not found")


runValidationAndLink : TextConfig pmsg -> Dict String (FieldType pmsg) -> Result String String
runValidationAndLink config forms =
    case config.validation config.currentValue of
        Ok val ->
            List.foldl
                (\link acc ->
                    case acc of
                        Ok currentVal ->
                            case Dict.get link.linkKey forms of
                                Just (TextType linkedConfig) ->
                                    link.validation currentVal linkedConfig.currentValue

                                _ ->
                                    acc

                        Err _ ->
                            acc
                )
                (Ok val)
                config.linkValidations

        Err err ->
            Err err


-- Helpers to get values


getTextValue : String -> Model pmsg -> String
getTextValue key model =
    case Dict.get key model.forms of
        Just (TextType config) ->
            config.currentValue

        _ ->
            ""


-- Validators


nonEmptyValidator : String -> String -> Result String String
nonEmptyValidator input fieldName =
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
