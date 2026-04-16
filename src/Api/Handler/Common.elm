module Api.Handler.Common exposing (..)

import Http


apiUrl : String -> String
apiUrl path =
    let
        normalizedPath =
            if String.startsWith "/" path then
                path

            else
                "/" ++ path
    in
    "http://localhost:3000/api" ++ normalizedPath


authHeader : Maybe String -> List Http.Header
authHeader maybeToken =
    case maybeToken of
        Just token ->
            [ Http.header "Authorization" ("Token " ++ token) ]

        Nothing ->
            []
