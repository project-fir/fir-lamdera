module Pages.Search exposing (Model, Msg, page)

-- elm-package install --yes circuithub/elm-json-extra

import Api.Data exposing (..)
import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Color
import Components.Styling as S
import Date exposing (Date)
import Debug
import Dict as D
import Effect exposing (Effect)
import ElasticSearch as ES exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input
import Gen.Params.Search exposing (Params)
import Html as H
import Http
import Json.Decode
import Json.Encode
import Page
import Request
import Shared
import Url exposing (Protocol(..))
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init shared
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { searchText : String
    , chartData : Data (List PresidentialApprovalDatum)
    }


init : Shared.Model -> ( Model, Effect Msg )
init _ =
    ( { searchText = ""
      , chartData = NotAsked
      }
    , Effect.none
    )


defaultAppSearchRequest =
    { filters =
        { presidentName = [ "Barack Obama" ]
        }
    , query = ""
    }



-- UPDATE


type Msg
    = SearchTextChanged String
    | UserClickedSearch
    | UserClickedFetch
    | FetchResponded (Result Http.Error AppSearchResponse)


type alias PresidentialApprovalDatum =
    { presidentName : String
    , startDate : Date
    , disapproving : Float
    , approving : Float
    , unsureNoData : Float
    }


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SearchTextChanged newText ->
            ( { model
                | searchText = newText
              }
            , Effect.none
            )

        UserClickedSearch ->
            let
                searchRequest =
                    { query =
                        ES.Term
                            { name = "president_name"
                            , value = StringValue model.searchText
                            , boost = Nothing
                            , queryName = Nothing
                            }
                    , sort = []
                    }
            in
            ( model
            , Effect.none
              -- , Effect.fromCmd <| submitSearchRequest searchRequest
            )

        UserClickedFetch ->
            ( { model
                | chartData = Loading
              }
            , Effect.fromCmd <| submitAppSearchRequest defaultAppSearchRequest
            )

        FetchResponded result ->
            case result of
                Ok response ->
                    ( { model
                        | chartData = mapResponse response
                      }
                    , Effect.none
                    )

                Err errs ->
                    ( { model
                        | chartData = Failure <| [ Debug.toString errs ]
                      }
                    , Effect.none
                    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "elm-ui"
    , body =
        [ layout
            [ width fill
            , height fill
            ]
          <|
            viewElements model
        ]
    }


viewElements : Model -> Element Msg
viewElements model =
    Element.column
        [ paddingEach { left = 150, right = 20, top = 20, bottom = 20 }
        , spacing 50
        ]
        [ Element.text <| "This is a column!"
        , viewChartElement
            model
            rawData
            [ Border.color S.dimGrey
            , Border.width 2
            ]
            ( 400, 400 )
        , Input.button
            [ Background.color S.medGrey
            , Font.color S.black
            , Font.bold
            , Border.color S.dimGrey
            , Border.width 5

            -- , paddingXY 32 16
            -- , Border.rounded 10
            , Element.width fill

            -- , Element.height fill
            , centerX
            ]
            { onPress = Just UserClickedFetch
            , label = el [ centerX ] <| Element.text "Fetch:"
            }
        ]


rawData =
    [ { x = 1, y = 2, z = 3 }
    , { x = 5, y = 4, z = 1 }
    , { x = 10, y = 2, z = 4 }
    ]


viewChartElement : Model -> List { x : Float, y : Float, z : Float } -> List (Attribute Msg) -> ( Int, Int ) -> Element Msg
viewChartElement model data attrs ( wpx, hpx ) =
    -- This is a bit weird, but I think the culprit is the containing `el` must have the same width / height as what is set in elm-charts height and width
    -- I'm not sure, but I think it may be related to this issue: https://github.com/mdgriffith/elm-ui/issues/146
    let
        viewLineChart : ( Float, Float ) -> H.Html Msg
        viewLineChart ( wpx_, hpx_ ) =
            C.chart
                [ CA.width wpx_
                , CA.height hpx_
                ]
                [ C.xLabels [ CA.withGrid ]
                , C.yLabels [ CA.withGrid ]
                , C.series .x
                    [ C.interpolated .y [ CA.monotone ] [ CA.circle ]
                    , C.interpolated .z [ CA.monotone ] [ CA.square ]
                    ]
                    data
                ]

        el_ =
            el
                ([ width <| px wpx
                 , height <| px hpx
                 , padding 25 -- Not sure what's up with this padding
                 ]
                    ++ attrs
                )

        elements =
            case model.chartData of
                NotAsked ->
                    Element.text "Not asked yet"

                Loading ->
                    Element.text "Loading.."

                Success data_ ->
                    Element.text "Success?"

                -- Element.html <|
                --     viewLineChart ( toFloat wpx, toFloat hpx )
                Failure errs ->
                    Element.column [] <| List.map (\e -> Element.text e) errs
    in
    el_ elements



-- viewElements : Model -> Element Msg
-- viewElements model =
--     Element.column
--         [ padding 20
--         , spacing 10
--         ]
--         [ Input.search [ width <| px 600 ]
--             { onChange = \text -> SearchTextChanged text
--             , text = model.searchText
--             , placeholder = Nothing
--             , label = Input.labelAbove [] <| Element.text "Search Fir:"
--             }
--         , Input.button
--             [ Background.color S.medGrey
--             , Font.color S.black
--             , Font.bold
--             , Border.color S.dimGrey
--             , Border.width 5
--             -- , paddingXY 32 16
--             -- , Border.rounded 10
--             , Element.width fill
--             -- , Element.height fill
--             , centerX
--             ]
--             { onPress = Just UserClickedSearch
--             , label = el [ centerX ] <| Element.text "Go:"
--             }
--         ]
-- HTTP
-- TODO: Does this belong in ElasticSearch.elm? How do I map Msgs to Pages then??


host =
    "https://fir-sandbox.ent.eastus2.azure.elastic-cloud.com"


documentsEndpoint =
    "/api/as/v1/engines/presidential-approval-ratings-dev/documents"


appSearchEndpoint =
    "/api/as/v1/engines/presidential-approval-ratings-dev/search"



-- submitSearchRequest : ES.SearchRequest -> Cmd Msg
-- submitSearchRequest searchRequest =
--     let
--         endcodedRequest =
--             ES.encodeSearchRequest searchRequest
--         url =
--             host ++ appSearchEndpoint
--     in
--     Http.request
--         { method = "POST"
--         , headers =
--             [ Http.header "Content-Type" "application/json"
--             , Http.header "Authorization" "Bearer TODO: Make this private!"
--             ]
--         , url = url
--         , body = Http.jsonBody endcodedRequest
--         , expect = Http.expectJson SearchResponded searchResponseDecoder
--         , timeout = Nothing
--         , tracker = Nothing
--         }


submitAppSearchRequest : AppSearchRequest -> Cmd Msg
submitAppSearchRequest req =
    let
        encReq =
            encodedAppSearchRequest req

        url =
            host ++ appSearchEndpoint
    in
    Http.request
        { method = "POST"
        , headers =
            [ Http.header "Content-Type" "application/json"
            , Http.header "Authorization" "Bearer private-CENSORED"
            ]
        , url = url
        , body = Http.jsonBody encReq
        , expect = Http.expectJson FetchResponded appSearchResponseDecoder
        , timeout = Nothing
        , tracker = Nothing
        }



-- Encoder / Decoder gen'ed by: https://korban.net/elm/json2elm/
-- NB: I have doubts json2elm will be my long-term solution, so granting myself some laziness here, only renaming the object that will be "actually used", for the rest
--     I'm sticking to the output of the tool


mapResponse : AppSearchResponse -> Data (List PresidentialApprovalDatum)
mapResponse res =
    let
        res_ : List PresidentialApprovalDatum
        res_ =
            []
    in
    Success res_



-- Required packages:
-- * elm/json


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



-- Encoding / Decoding for AppSearchRequest:


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
