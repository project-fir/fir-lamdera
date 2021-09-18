module Api.AppSearchResponse exposing (AppSearchResponse, appSearchResponseDecoder)

import Json.Decode
import Json.Encode



-- Encoder / Decoder gen'ed by: https://korban.net/elm/json2elm/


type alias AppSearchResponse =
    { meta : RootMeta
    , results : List RootResultsObject
    }


type alias RootMeta =
    { alerts : List ()
    , engine : RootMetaEngine
    , page : RootMetaPage
    , precision : Int
    , requestId : String
    , warnings : List ()
    }


type alias RootMetaEngine =
    { name : String
    , type_ : String
    }


type alias RootMetaPage =
    { current : Int
    , size : Int
    , totalPages : Int
    , totalResults : Int
    }


type alias RootResultsObject =
    { approving : RootResultsObjectApproving
    , disapproving : RootResultsObjectDisapproving
    , endDate : RootResultsObjectEndDate
    , id : RootResultsObjectId
    , meta : RootResultsObjectMeta
    , presidentName : RootResultsObjectPresidentName
    , startDate : RootResultsObjectStartDate
    , unsureNoData : RootResultsObjectUnsureNoData
    }


type alias RootResultsObjectApproving =
    { raw : Int
    }


type alias RootResultsObjectDisapproving =
    { raw : Int
    }


type alias RootResultsObjectEndDate =
    { raw : String
    }


type alias RootResultsObjectId =
    { raw : String
    }


type alias RootResultsObjectMeta =
    { engine : String
    , id : String
    , score : Int
    }


type alias RootResultsObjectPresidentName =
    { raw : String
    }


type alias RootResultsObjectStartDate =
    { raw : String
    }


type alias RootResultsObjectUnsureNoData =
    { raw : Int
    }


appSearchResponseDecoder : Json.Decode.Decoder AppSearchResponse
appSearchResponseDecoder =
    Json.Decode.map2 AppSearchResponse
        (Json.Decode.field "meta" rootMetaDecoder)
        (Json.Decode.field "results" <| Json.Decode.list rootResultsObjectDecoder)


rootMetaDecoder : Json.Decode.Decoder RootMeta
rootMetaDecoder =
    Json.Decode.map6 RootMeta
        (Json.Decode.field "alerts" <| Json.Decode.list <| Json.Decode.succeed ())
        (Json.Decode.field "engine" rootMetaEngineDecoder)
        (Json.Decode.field "page" rootMetaPageDecoder)
        (Json.Decode.field "precision" Json.Decode.int)
        (Json.Decode.field "request_id" Json.Decode.string)
        (Json.Decode.field "warnings" <| Json.Decode.list <| Json.Decode.succeed ())


rootMetaEngineDecoder : Json.Decode.Decoder RootMetaEngine
rootMetaEngineDecoder =
    Json.Decode.map2 RootMetaEngine
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "type" Json.Decode.string)


rootMetaPageDecoder : Json.Decode.Decoder RootMetaPage
rootMetaPageDecoder =
    Json.Decode.map4 RootMetaPage
        (Json.Decode.field "current" Json.Decode.int)
        (Json.Decode.field "size" Json.Decode.int)
        (Json.Decode.field "total_pages" Json.Decode.int)
        (Json.Decode.field "total_results" Json.Decode.int)


rootResultsObjectDecoder : Json.Decode.Decoder RootResultsObject
rootResultsObjectDecoder =
    Json.Decode.map8 RootResultsObject
        (Json.Decode.field "approving" rootResultsObjectApprovingDecoder)
        (Json.Decode.field "disapproving" rootResultsObjectDisapprovingDecoder)
        (Json.Decode.field "end_date" rootResultsObjectEndDateDecoder)
        (Json.Decode.field "id" rootResultsObjectIdDecoder)
        (Json.Decode.field "_meta" rootResultsObjectMetaDecoder)
        (Json.Decode.field "president_name" rootResultsObjectPresidentNameDecoder)
        (Json.Decode.field "start_date" rootResultsObjectStartDateDecoder)
        (Json.Decode.field "unsure_no_data" rootResultsObjectUnsureNoDataDecoder)


rootResultsObjectApprovingDecoder : Json.Decode.Decoder RootResultsObjectApproving
rootResultsObjectApprovingDecoder =
    Json.Decode.map RootResultsObjectApproving
        (Json.Decode.field "raw" Json.Decode.int)


rootResultsObjectDisapprovingDecoder : Json.Decode.Decoder RootResultsObjectDisapproving
rootResultsObjectDisapprovingDecoder =
    Json.Decode.map RootResultsObjectDisapproving
        (Json.Decode.field "raw" Json.Decode.int)


rootResultsObjectEndDateDecoder : Json.Decode.Decoder RootResultsObjectEndDate
rootResultsObjectEndDateDecoder =
    Json.Decode.map RootResultsObjectEndDate
        (Json.Decode.field "raw" Json.Decode.string)


rootResultsObjectIdDecoder : Json.Decode.Decoder RootResultsObjectId
rootResultsObjectIdDecoder =
    Json.Decode.map RootResultsObjectId
        (Json.Decode.field "raw" Json.Decode.string)


rootResultsObjectMetaDecoder : Json.Decode.Decoder RootResultsObjectMeta
rootResultsObjectMetaDecoder =
    Json.Decode.map3 RootResultsObjectMeta
        (Json.Decode.field "engine" Json.Decode.string)
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "score" Json.Decode.int)


rootResultsObjectPresidentNameDecoder : Json.Decode.Decoder RootResultsObjectPresidentName
rootResultsObjectPresidentNameDecoder =
    Json.Decode.map RootResultsObjectPresidentName
        (Json.Decode.field "raw" Json.Decode.string)


rootResultsObjectStartDateDecoder : Json.Decode.Decoder RootResultsObjectStartDate
rootResultsObjectStartDateDecoder =
    Json.Decode.map RootResultsObjectStartDate
        (Json.Decode.field "raw" Json.Decode.string)


rootResultsObjectUnsureNoDataDecoder : Json.Decode.Decoder RootResultsObjectUnsureNoData
rootResultsObjectUnsureNoDataDecoder =
    Json.Decode.map RootResultsObjectUnsureNoData
        (Json.Decode.field "raw" Json.Decode.int)
