module Api.Handler.User exposing (..)

import Api.Handler.Common exposing (apiUrl, authHeader)
import Api.Type.User as User exposing (LoginRequest, RegisterRequest, UserResponse)
import Http


getCurrentUser : String -> (Result Http.Error UserResponse -> msg) -> Cmd msg
getCurrentUser token toMsg =
    Http.request
        { method = "GET"
        , headers = authHeader (Just token)
        , url = apiUrl "/user"
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg User.responseDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


login : LoginRequest -> (Result Http.Error UserResponse -> msg) -> Cmd msg
login request toMsg =
    Http.post
        { url = apiUrl "/users/login"
        , body = Http.jsonBody (User.encodeLoginRequest request)
        , expect = Http.expectJson toMsg User.responseDecoder
        }


register : RegisterRequest -> (Result Http.Error UserResponse -> msg) -> Cmd msg
register request toMsg =
    Http.post
        { url = apiUrl "/users"
        , body = Http.jsonBody (User.encodeRegisterRequest request)
        , expect = Http.expectJson toMsg User.responseDecoder
        }
