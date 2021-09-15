module Api.AppSearchRequest exposing (AppSearchRequest, encodedAppSearchRequest)

import Json.Decode
import Json.Encode



-- Encoder / Decoder gen'ed by: https://korban.net/elm/json2elm/
-- Required packages:
-- * elm/json


type alias AppSearchRequest =
    { filters : RootFilters
    , page : RootPage
    , query : String
    }


type alias RootFilters =
    { presidentName : List String
    }


type alias RootPage =
    { current : Int
    , size : Int
    }


rootDecoder : Json.Decode.Decoder AppSearchRequest
rootDecoder =
    Json.Decode.map3 AppSearchRequest
        (Json.Decode.field "filters" rootFiltersDecoder)
        (Json.Decode.field "page" rootPageDecoder)
        (Json.Decode.field "query" Json.Decode.string)


rootFiltersDecoder : Json.Decode.Decoder RootFilters
rootFiltersDecoder =
    Json.Decode.map RootFilters
        (Json.Decode.field "president_name" <| Json.Decode.list Json.Decode.string)


rootPageDecoder : Json.Decode.Decoder RootPage
rootPageDecoder =
    Json.Decode.map2 RootPage
        (Json.Decode.field "current" Json.Decode.int)
        (Json.Decode.field "size" Json.Decode.int)


encodedAppSearchRequest : AppSearchRequest -> Json.Encode.Value
encodedAppSearchRequest root =
    Json.Encode.object
        [ ( "filters", encodedRootFilters root.filters )
        , ( "page", encodedRootPage root.page )
        , ( "query", Json.Encode.string root.query )
        ]


encodedRootFilters : RootFilters -> Json.Encode.Value
encodedRootFilters rootFilters =
    Json.Encode.object
        [ ( "president_name", Json.Encode.list Json.Encode.string rootFilters.presidentName )
        ]


encodedRootPage : RootPage -> Json.Encode.Value
encodedRootPage rootPage =
    Json.Encode.object
        [ ( "current", Json.Encode.int rootPage.current )
        , ( "size", Json.Encode.int rootPage.size )
        ]
