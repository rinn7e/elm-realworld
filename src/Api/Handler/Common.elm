module Api.Handler.Common exposing (..)

import Http


apiBaseUrl : String
apiBaseUrl =
    "https://rinn7e-haskell-realworld-api.fly.dev/api"


apiUrl : String -> String
apiUrl path =
    let
        normalizedPath =
            if String.startsWith "/" path then
                path

            else
                "/" ++ path
    in
    apiBaseUrl ++ normalizedPath


authHeader : Maybe String -> List Http.Header
authHeader maybeToken =
    case maybeToken of
        Just token ->
            [ Http.header "Authorization" ("Token " ++ token) ]

        Nothing ->
            []
