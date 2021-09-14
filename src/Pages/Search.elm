module Pages.Search exposing (Model, Msg, page)

import Components.Styling as S
import Debug
import Effect exposing (Effect)
import ElasticSearch as ES exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input
import Gen.Params.Search exposing (Params)
import Http
import Json.Decode as JD
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
    }


init : Shared.Model -> ( Model, Effect Msg )
init _ =
    ( { searchText = ""
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = SearchTextChanged String
    | UserClickedSearch
    | SearchResponded (Result Http.Error SearchResponse)


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
            , Effect.fromCmd <| submitSearchRequest searchRequest
            )

        SearchResponded result ->
            case result of
                Ok str ->
                    ( model, Effect.none )

                Err errs ->
                    ( model, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = ""
    , body =
        [ layout [] <| viewElements model
        ]
    }


viewElements : Model -> Element Msg
viewElements model =
    Element.row
        [ padding 20
        , spacing 10
        ]
        [ Input.search [ width <| px 600 ]
            { onChange = \text -> SearchTextChanged text
            , text = model.searchText
            , placeholder = Nothing
            , label = Input.labelAbove [] <| Element.text "Search Fir:"
            }
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
            { onPress = Just UserClickedSearch
            , label = el [ centerX ] <| Element.text "Go:"
            }
        ]



-- HTTP
-- TODO: Does this belong in ElasticSearch.elm? How do I map Msgs to Pages then??


host =
    "https://fir-sandbox.ent.eastus2.azure.elastic-cloud.com"


endpoint =
    "/api/as/v1/engines/presidential-approval-ratings-dev/documents"


submitSearchRequest : ES.SearchRequest -> Cmd Msg
submitSearchRequest searchRequest =
    let
        endcodedRequest =
            ES.encodeSearchRequest searchRequest

        url =
            host ++ endpoint
    in
    Http.request
        { method = "POST"
        , headers =
            [ Http.header "Content-Type" "application/json"
            , Http.header "Authorization" "Bearer TODO: Make this private!"
            ]
        , url = url
        , body = Http.jsonBody endcodedRequest
        , expect = Http.expectJson SearchResponded searchResponseDecoder
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
