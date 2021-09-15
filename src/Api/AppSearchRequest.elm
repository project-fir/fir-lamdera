module Api.AppSearchRequest exposing (AppSearchRequest, encodedAppSearchRequest)

import Json.Decode
import Json.Encode



-- Encoder / Decoder gen'ed by: https://korban.net/elm/json2elm/


type alias AppSearchRequest =
    { filters : AppSearchRequestFilters
    , query : String
    }


type alias AppSearchRequestFilters =
    { presidentName : List String
    }


appSearchRequestDecoder : Json.Decode.Decoder AppSearchRequest
appSearchRequestDecoder =
    Json.Decode.map2 AppSearchRequest
        (Json.Decode.field "filters" rootFiltersDecoder)
        (Json.Decode.field "query" Json.Decode.string)


rootFiltersDecoder : Json.Decode.Decoder AppSearchRequestFilters
rootFiltersDecoder =
    Json.Decode.map AppSearchRequestFilters
        (Json.Decode.field "president_name" <| Json.Decode.list Json.Decode.string)


encodedAppSearchRequest : AppSearchRequest -> Json.Encode.Value
encodedAppSearchRequest root =
    Json.Encode.object
        [ ( "filters", encodedRootFilters root.filters )
        , ( "query", Json.Encode.string root.query )
        ]


encodedRootFilters : AppSearchRequestFilters -> Json.Encode.Value
encodedRootFilters rootFilters =
    Json.Encode.object
        [ ( "president_name", Json.Encode.list Json.Encode.string rootFilters.presidentName )
        ]
