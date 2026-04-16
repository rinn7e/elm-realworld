module Api.Type.Article exposing (..)

import Api.Type.Profile as Profile exposing (Profile)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)


type alias Article =
    { slug : String
    , title : String
    , description : String
    , body : Maybe String
    , tagList : List String
    , createdAt : String
    , updatedAt : String
    , favorited : Bool
    , favoritesCount : Int
    , author : Profile
    }


decoder : Decoder Article
decoder =
    Decode.succeed Article
        |> required "slug" Decode.string
        |> required "title" Decode.string
        |> required "description" Decode.string
        |> optional "body" (Decode.map Just Decode.string) Nothing
        |> required "tagList" (Decode.list Decode.string)
        |> required "createdAt" Decode.string
        |> required "updatedAt" Decode.string
        |> required "favorited" Decode.bool
        |> required "favoritesCount" Decode.int
        |> required "author" Profile.decoder


type alias ArticleResponse =
    { article : Article
    }


responseDecoder : Decoder ArticleResponse
responseDecoder =
    Decode.succeed ArticleResponse
        |> required "article" decoder


type alias ArticlesResponse =
    { articles : List Article
    , articlesCount : Int
    }


articlesResponseDecoder : Decoder ArticlesResponse
articlesResponseDecoder =
    Decode.succeed ArticlesResponse
        |> required "articles" (Decode.list decoder)
        |> required "articlesCount" Decode.int
