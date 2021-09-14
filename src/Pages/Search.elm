module Pages.Search exposing (Model, Msg, page)

import Components.Styling as S
import Effect exposing (Effect)
import ElasticSearch as ES exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input
import Gen.Params.Search exposing (Params)
import Page
import Request
import Shared
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
                            , value = model.searchText
                            , boost = Nothing
                            , queryName = Nothing
                            }
                    , sort = []
                    }
            in
            ( model
            , Effect.none
            )



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
