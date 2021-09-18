module Pages.Catalog exposing (Model, Msg(..), page)

import Api.Card exposing (CardEnvelope, CardId, FlashCard(..), Grade(..), MarkdownCard, PlainTextCard, StudySessionSummary)
import Api.Data exposing (Data(..))
import Api.User exposing (User)
import Bridge exposing (ToBackend(..))
import Components.Styling as S exposing (..)
import Effect exposing (Effect)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input
import Gen.Params.Catalog exposing (Params)
import Lamdera exposing (sendToBackend)
import Page
import Request
import Shared
import Time exposing (toHour, toMinute, toSecond, utc)
import Time.Extra
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.protected.advanced
        (\user ->
            { init = init shared
            , update = update
            , subscriptions = subscriptions
            , view = view user
            }
        )



-- INIT


type alias Model =
    { user : Maybe User
    , zone : Time.Zone
    , wiredCards : Data (List CardEnvelope)
    , selectedEnv : Maybe CardEnvelope
    }


init : Shared.Model -> ( Model, Effect Msg )
init shared =
    let
        wiredCatalogInit =
            case shared.user of
                Just _ ->
                    Loading

                Nothing ->
                    NotAsked

        model =
            { user = shared.user
            , wiredCards = wiredCatalogInit
            , zone = shared.zone
            , selectedEnv = Nothing
            }
    in
    ( model
    , Effect.none
    )



-- UPDATE


type Msg
    = ReplaceMe


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        _ ->
            ( model, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : User -> Model -> View Msg
view _ model =
    { title = "Catalog"
    , body =
        [ layout [] <| viewElements model
        ]
    }


viewElements : Model -> Element Msg
viewElements model =
    let
        elements =
            case model.wiredCards of
                NotAsked ->
                    Element.text "Catalog not asked for"

                Loading ->
                    Element.text "Catalog is laoding"

                BatchedLoading _ _ _ _ ->
                    Element.text "Catalog is not intended for BatchLoad!"

                Success catalog ->
                    Element.text "Catalog is loaded"

                Failure errs ->
                    Element.column [] <| List.map (\e -> Element.text e) errs
    in
    elements
