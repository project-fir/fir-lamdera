module Api.Catalog exposing (CatalogIndices, catalogIndicesDecoder)

import Json.Decode
import Json.Encode



-- Required packages:
-- * elm/json


type alias CatalogIndices =
    { docsU46count : String
    , docsU46deleted : String
    , health : String
    , index : String
    , pri : String
    , priU46storeU46size : String
    , rep : String
    , status : String
    , storeU46size : String
    , uuid : String
    }


catalogIndicesDecoder : Json.Decode.Decoder (List CatalogIndices)
catalogIndicesDecoder =
    Json.Decode.list rootObjectDecoder


rootObjectDecoder : Json.Decode.Decoder CatalogIndices
rootObjectDecoder =
    let
        fieldSet0 =
            Json.Decode.map8 CatalogIndices
                (Json.Decode.field "docs.count" Json.Decode.string)
                (Json.Decode.field "docs.deleted" Json.Decode.string)
                (Json.Decode.field "health" Json.Decode.string)
                (Json.Decode.field "index" Json.Decode.string)
                (Json.Decode.field "pri" Json.Decode.string)
                (Json.Decode.field "pri.store.size" Json.Decode.string)
                (Json.Decode.field "rep" Json.Decode.string)
                (Json.Decode.field "status" Json.Decode.string)
    in
    Json.Decode.map3 (<|)
        fieldSet0
        (Json.Decode.field "store.size" Json.Decode.string)
        (Json.Decode.field "uuid" Json.Decode.string)


encodedRoot : List CatalogIndices -> Json.Encode.Value
encodedRoot root =
    Json.Encode.list encodedRootObject root


encodedRootObject : CatalogIndices -> Json.Encode.Value
encodedRootObject rootObject =
    Json.Encode.object
        [ ( "docs.count", Json.Encode.string rootObject.docsU46count )
        , ( "docs.deleted", Json.Encode.string rootObject.docsU46deleted )
        , ( "health", Json.Encode.string rootObject.health )
        , ( "index", Json.Encode.string rootObject.index )
        , ( "pri", Json.Encode.string rootObject.pri )
        , ( "pri.store.size", Json.Encode.string rootObject.priU46storeU46size )
        , ( "rep", Json.Encode.string rootObject.rep )
        , ( "status", Json.Encode.string rootObject.status )
        , ( "store.size", Json.Encode.string rootObject.storeU46size )
        , ( "uuid", Json.Encode.string rootObject.uuid )
        ]
