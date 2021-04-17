module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Element exposing (..)
import Element.Background as Background exposing (..)
import Element.Input as Input exposing (..)
import Html exposing (Html)
import Html.Attributes as Attr
import Lamdera
import Types exposing (ToFrontend(..), FrontendModel, FrontendMsg(..), Card)
import Url


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( FrontendModel key [Card "test frontend prompt" "test frontend ans"] -- no cards, we fetch from backend??
    , Cmd.none
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Cmd.batch [ Nav.pushUrl model.key (Url.toString url) ]
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( model, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        HistoryReceived cs ->
            ( {model | cards = cs}, Cmd.none )
        CardReceived card ->
            let
                cards_ = model.cards ++ [card]
            in
        -- TODO: this!
            ( {model | cards = cards_ } , Cmd.none )


view : Model -> Browser.Document FrontendMsg
view model =
    {
        title = "This is the title"
        , body = viewElements model
            -- layout [ width fill, Background.color <| rgb255 255 255 255 ] (el [] (Element.text "aaa"))
            -- (column [] (List.map viewCard model.cards))
    }



viewElements : Model -> List (Html FrontendMsg)
viewElements model =
    [
        layout [ width fill, Background.color <| rgb255 100 100 100 ]
            (el [] <| column [] <| List.map viewCard model.cards)
    ]

viewCard : Card -> Element FrontendMsg
viewCard card =
    row [padding 20] [
        Element.text card.prompt
        , Element.text " | "
        , Element.text card.answer
    ]


viewNav : Model -> Element FrontendMsg
viewNav model =
    column [] (List.map viewCard model.cards)
    -- row [ centerX, padding 10, spacing 100 ]
    --     [ Input.button [ spacing 100 ]
    --         { onPress = Just <| ClickedNavToHome model
    --         , label = el [] (text "Home")
    --         }
    --     , text " | "
    --     , Input.button []
    --         { onPress = Just <| ClickedNavToTodaysCards model
    --         , label = el [] (text "Today's Cards")
    --         }
    --     , text " | "
    --     , Input.button []
    --         { onPress = Just <| ClickedNavToCreateCard model
    --         , label = el [] (text "Create Cards")
    --         }
    --     ]
