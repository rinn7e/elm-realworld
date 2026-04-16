module Api.Handler.Profile exposing (..)

import Api.Handler.Common exposing (apiUrl, authHeader)
import Api.Type.Profile as Profile exposing (ProfileResponse)
import Http


getProfile : Maybe String -> String -> (Result Http.Error ProfileResponse -> msg) -> Cmd msg
getProfile maybeToken username toMsg =
    Http.request
        { method = "GET"
        , headers = authHeader maybeToken
        , url = apiUrl ("/profiles/" ++ username)
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg Profile.responseDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


followUser : String -> String -> (Result Http.Error ProfileResponse -> msg) -> Cmd msg
followUser token username toMsg =
    Http.request
        { method = "POST"
        , headers = authHeader (Just token)
        , url = apiUrl ("/profiles/" ++ username ++ "/follow")
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg Profile.responseDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


unfollowUser : String -> String -> (Result Http.Error ProfileResponse -> msg) -> Cmd msg
unfollowUser token username toMsg =
    Http.request
        { method = "DELETE"
        , headers = authHeader (Just token)
        , url = apiUrl ("/profiles/" ++ username ++ "/follow")
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg Profile.responseDecoder
        , timeout = Nothing
        , tracker = Nothing
        }
