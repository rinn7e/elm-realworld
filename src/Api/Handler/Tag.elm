module Api.Handler.Tag exposing (..)

import Api.Handler.Common exposing (apiUrl, authHeader)
import Api.Type.Tag as Tag exposing (TagsResponse)
import Http


getTags : Maybe String -> (Result Http.Error TagsResponse -> msg) -> Cmd msg
getTags maybeToken toMsg =
    Http.request
        { method = "GET"
        , headers = authHeader maybeToken
        , url = apiUrl "/tags"
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg Tag.responseDecoder
        , timeout = Nothing
        , tracker = Nothing
        }
