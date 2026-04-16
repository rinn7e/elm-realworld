module Util.View exposing (userImage)

import VitePluginHelper


userImage : Maybe String -> String
userImage maybeUrl =
    case maybeUrl of
        Nothing ->
            VitePluginHelper.asset "/src/assets/default-avatar.svg"

        Just url ->
            if String.isEmpty (String.trim url) || url == "/default-avatar.svg" || url == "https://static.productionready.io/images/smiley-cyrus.jpg" then
                VitePluginHelper.asset "/src/assets/default-avatar.svg"

            else
                url
