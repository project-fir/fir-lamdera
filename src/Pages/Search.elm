module Pages.Search exposing (Model, Msg, page)

import Api.Data exposing (..)
import Chart as C
import Chart.Attributes as CA
import Json.Encode
import Json.Decode exposing ((:=))
-- elm-package install --yes circuithub/elm-json-extra
import Json.Decode.Extra exposing ((|:))
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
    , chartData : Data (List PresidentialApproval)
    }


init : Shared.Model -> ( Model, Effect Msg )
init _ =
    ( { searchText = ""
      , chartData = NotAsked
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = SearchTextChanged String
    | UserClickedSearch
    | UserClickedFetch
    | FetchResponded (Result Http.Error (Data (List PresidentialApproval)))


type alias PresidentialApproval =
    { presidentName : String
    , startDate : Date
    , disapproving : Float
    , approving : Float
    , unsureNoData : Float
    }


type alias AppSearchResponse result =
    { results : List result
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
                        | chartData = response
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
                    Element.text "Error"

        -- Element.column [] <| List.map (\e -> Element.text e) errs
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
            encodeAppSearchRequest req

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


type alias SearchResponse =
    { someField : String
    }


searchResponseDecoder : JD.Decoder SearchResponse
searchResponseDecoder =
    JD.map SearchResponse
        (JD.at [ "someField" ] JD.string)


type alias AppSearchRequest =
    { query : String
    , filters : List String
    }


defaultAppSearchRequest =
    { query = ""
    , filters = [ "Barrack Obama", "George W. Bush" ] -- TODO: I want this formatting eventually: Dict[Dim, EnumeratedValues]
    }


encodeAppSearchRequest : AppSearchRequest -> JE.Value
encodeAppSearchRequest req =
    -- let
    --     encodeFilters : D.Dict String (List String)
    --     encodeFilters d =
    -- in
    JE.object <|
        [ ( "query", JE.string req.query )
        , ( "filters"
          , JE.object <|
                [ ( "president_name", JE.list JE.string req.filters ) ]
          )
        ]


appSearchResponseDecoder : JD.Decoder (Data (List PresidentialApproval))
appSearchResponseDecoder =
    Debug.todo "This!"


rowDecoder : JD.Decoder PresidentialApproval
rowDecoder =
    JD.map5 PresidentialApproval
        (JD.field "president_name")



type alias ComplexType =
    {

    }



type alias FetchResponse = { 
    meta : Meta
    , results : List ComplexType
    }

type alias MetaPage =
    { current : Int
    , total_pages : Int
    , total_results : Int
    , size : Int
    }

type alias MetaEngine =
    { name : String
    , type : String
    }

type alias Meta =
    { alerts : List ComplexType
    , warnings : List ComplexType
    , precision : Int
    , page : MetaPage
    , engine : MetaEngine
    , request_id : String
    }

decode : Json.Decode.Decoder 
decode =
    Json.Decode.succeed 
        |: ("" := decode)
        |: ("meta" := decodeMeta)
        |: ("results" := Json.Decode.list decodeComplexType)

decodeMetaPage : Json.Decode.Decoder MetaPage
decodeMetaPage =
    Json.Decode.succeed MetaPage
        |: ("current" := Json.Decode.int)
        |: ("total_pages" := Json.Decode.int)
        |: ("total_results" := Json.Decode.int)
        |: ("size" := Json.Decode.int)

decodeMetaEngine : Json.Decode.Decoder MetaEngine
decodeMetaEngine =
    Json.Decode.succeed MetaEngine
        |: ("name" := Json.Decode.string)
        |: ("type" := Json.Decode.string)

decodeMeta : Json.Decode.Decoder Meta
decodeMeta =
    Json.Decode.succeed Meta
        |: ("alerts" := Json.Decode.list decodeComplexType)
        |: ("warnings" := Json.Decode.list decodeComplexType)
        |: ("precision" := Json.Decode.int)
        |: ("page" := decodeMetaPage)
        |: ("engine" := decodeMetaEngine)
        |: ("request_id" := Json.Decode.string)

encode :  -> Json.Encode.Value
encode record =
    Json.Encode.object
        [ ("",  encode <| record.)
        , ("meta",  encodeMeta <| record.meta)
        , ("results",  Json.Encode.list <| List.map encodeComplexType <| record.results)
        ]

encodeMetaPage : MetaPage -> Json.Encode.Value
encodeMetaPage record =
    Json.Encode.object
        [ ("current",  Json.Encode.int <| record.current)
        , ("total_pages",  Json.Encode.int <| record.total_pages)
        , ("total_results",  Json.Encode.int <| record.total_results)
        , ("size",  Json.Encode.int <| record.size)
        ]

encodeMetaEngine : MetaEngine -> Json.Encode.Value
encodeMetaEngine record =
    Json.Encode.object
        [ ("name",  Json.Encode.string <| record.name)
        , ("type",  Json.Encode.string <| record.type)
        ]

encodeMeta : Meta -> Json.Encode.Value
encodeMeta record =
    Json.Encode.object
        [ ("alerts",  Json.Encode.list <| List.map encodeComplexType <| record.alerts)
        , ("warnings",  Json.Encode.list <| List.map encodeComplexType <| record.warnings)
        , ("precision",  Json.Encode.int <| record.precision)
        , ("page",  encodeMetaPage <| record.page)
        , ("engine",  encodeMetaEngine <| record.engine)
        , ("request_id",  Json.Encode.string <| record.request_id)
        ]


