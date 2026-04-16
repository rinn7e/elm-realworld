module Api.Type.Comment exposing (..)

import Api.Type.Profile as Profile exposing (Profile)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


type alias Comment =
    { id : Int
    , createdAt : String
    , updatedAt : String
    , body : String
    , author : Profile
    }


decoder : Decoder Comment
decoder =
    Decode.succeed Comment
        |> required "id" Decode.int
        |> required "createdAt" Decode.string
        |> required "updatedAt" Decode.string
        |> required "body" Decode.string
        |> required "author" Profile.decoder


type alias CommentResponse =
    { comment : Comment
    }


responseDecoder : Decoder CommentResponse
responseDecoder =
    Decode.succeed CommentResponse
        |> required "comment" decoder


type alias CommentsResponse =
    { comments : List Comment
    }


commentsResponseDecoder : Decoder CommentsResponse
commentsResponseDecoder =
    Decode.succeed CommentsResponse
        |> required "comments" (Decode.list decoder)
