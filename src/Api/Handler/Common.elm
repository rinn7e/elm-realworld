module Api.Handler.Common exposing (..)

import Http


apiUrl : String -> String
apiUrl path =
    "http://localhost:3000/api" ++ path


authHeader : Maybe String -> List Http.Header
authHeader maybeToken =
    case maybeToken of
        Just token ->
            [ Http.header "Authorization" ("Token " ++ token) ]

        Nothing ->
            []
