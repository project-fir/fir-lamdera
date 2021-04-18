module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Element exposing (..)
import Element.Background as Background exposing (..)
import Element.Input as Input exposing (..)
import Html exposing (Html)
import Html.Attributes as Attr
import Lamdera
import Types exposing (Card, FrontendModel, FrontendMsg(..), LiveUser, ToFrontend(..))
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
    ( FrontendModel key [] []
      -- no cards, we fetch from backend??
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
            ( { model | cards = cs }, Cmd.none )

        CardReceived card ->
            let
                cards_ =
                    model.cards ++ [ card ]
            in
            -- TODO: this!
            ( { model | cards = cards_ }, Cmd.none )

        UserJoined newUser ->
            ( { model | liveUsers = model.liveUsers ++ [ newUser ] }, Cmd.none )

        UserLeft oldUser ->
            let
                updatedUsers =
                    List.filter (\u -> not <| u.clientId == oldUser.clientId) model.liveUsers
            in
            -- TODO: This!
            ( { model | liveUsers = updatedUsers }, Cmd.none )


view : Model -> Browser.Document FrontendMsg
view model =
    { title = "This is the title"
    , body = viewLayout model
    }


viewLayout : Model -> List (Html FrontendMsg)
viewLayout model =
    [ layout [ width fill, Background.color <| rgb255 255 255 255 ]
        (el [] <| viewElements model)
    ]


viewElements : Model -> Element FrontendMsg
viewElements model =
    column []
        [ column [] <| List.map viewCard model.cards
        , Element.text <| "Currently connected users:"
        , viewLiveUsersTable model.liveUsers
        ]


viewCard : Card -> Element FrontendMsg
viewCard card =
    row [ padding 20 ]
        [ Element.text card.prompt
        , Element.text " | "
        , Element.text card.answer
        ]


viewLiveUsersTable : List LiveUser -> Element FrontendMsg
viewLiveUsersTable users =
    Element.table
        [ Element.centerX
        , Element.centerY
        , Element.spacing 5
        , Element.padding 10
        ]
        { data = users
        , columns =
            [ { header = Element.text "Session Id:"
              , width = px 200
              , view =
                    \u ->
                        Element.text u.sessionId
              }
            , { header = Element.text "Client Id:"
              , width = fill
              , view =
                    \u ->
                        Element.text u.clientId
              }
            ]
        }


viewLiveUser : LiveUser -> Element FrontendMsg
viewLiveUser u =
    row [] [ Element.text <| u.sessionId ++ ":" ++ u.clientId ++ " is here!" ]


viewLiveUsers : List LiveUser -> List (Element FrontendMsg)
viewLiveUsers liveUsers =
    List.map viewLiveUser liveUsers


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
