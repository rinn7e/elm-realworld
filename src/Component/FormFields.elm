module Component.FormFields exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onBlur, onFocus, onInput)
import Package.ElmForm as Form


standardInputUi : Bool -> Bool -> Form.TextUiArgs pmsg -> Html pmsg
standardInputUi isTextarea isLarge args =
    let
        isError =
            case args.validationResult of
                Err _ ->
                    args.showValidation

                Ok _ ->
                    False

        sizeClass =
            if isLarge then
                "py-[12px] text-base"

            else
                "py-[8px] text-sm"

        validationClass =
            if isError then
                "border-red-500"

            else
                "border-gray-300"

        inputClass =
            "w-full rounded border px-[12px] bg-white outline-none focus:border-green-500 focus:ring-1 focus:ring-green-500 transition-colors "
                ++ validationClass
                ++ " "
                ++ sizeClass

        inputValue =
            args.currentValue

        inputAttrs =
            [ class inputClass
            , placeholder args.placeholder
            , value inputValue
            , onInput (\val -> args.mkPmsg (Form.UpdateForm args.key val))
            , onFocus (args.mkPmsg (Form.HandleFocus args.key True))
            , onBlur (args.mkPmsg (Form.HandleFocus args.key False))
            ]

        content =
            if isTextarea then
                textarea (rows 8 :: inputAttrs) []

            else
                let
                    inputType =
                        case args.isPassword of
                            Just p ->
                                if p.revealPassword then
                                    "text"

                                else
                                    "password"

                            Nothing ->
                                "text"
                in
                input (type_ inputType :: inputAttrs) []
    in
    div [ class "flex flex-col gap-[4px] pb-[16px]" ]
        [ content
        , if args.showValidation then
            case args.validationResult of
                Err err ->
                    div [ class "px-[4px] text-xs text-red-600" ] [ text err ]

                Ok _ ->
                    text ""

          else
            text ""
        ]
