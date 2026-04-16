module Api.Type.Article exposing (..)

import Api.Type.Profile as Profile exposing (Profile)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode


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
type alias ArticleRequest =
    { title : String
    , description : String
    , body : String
    , tagList : List String
    }


encodeArticleRequest : ArticleRequest -> Encode.Value
encodeArticleRequest request =
    Encode.object
        [ ( "article"
          , Encode.object
                [ ( "title", Encode.string request.title )
                , ( "description", Encode.string request.description )
                , ( "body", Encode.string request.body )
                , ( "tagList", Encode.list Encode.string request.tagList )
                ]
          )
        ]
