module Api.Handler.Comment exposing (..)

import Api.Handler.Common exposing (apiUrl, authHeader)
import Api.Type.Comment as Comment exposing (CommentResponse, CommentsResponse)
import Http
import Json.Encode as Encode


getComments : Maybe String -> String -> (Result Http.Error CommentsResponse -> msg) -> Cmd msg
getComments maybeToken slug toMsg =
    Http.request
        { method = "GET"
        , headers = authHeader maybeToken
        , url = apiUrl ("/articles/" ++ slug ++ "/comments")
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg Comment.commentsResponseDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


createComment : String -> String -> String -> (Result Http.Error CommentResponse -> msg) -> Cmd msg
createComment token slug body toMsg =
    let
        jsonBody =
            Encode.object
                [ ( "comment"
                  , Encode.object [ ( "body", Encode.string body ) ]
                  )
                ]
    in
    Http.request
        { method = "POST"
        , headers = authHeader (Just token)
        , url = apiUrl ("/articles/" ++ slug ++ "/comments")
        , body = Http.jsonBody jsonBody
        , expect = Http.expectJson toMsg Comment.responseDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


deleteComment : String -> String -> Int -> (Result Http.Error () -> msg) -> Cmd msg
deleteComment token slug id toMsg =
    Http.request
        { method = "DELETE"
        , headers = authHeader (Just token)
        , url = apiUrl ("/articles/" ++ slug ++ "/comments/" ++ String.fromInt id)
        , body = Http.emptyBody
        , expect = Http.expectWhatever toMsg
        , timeout = Nothing
        , tracker = Nothing
        }
