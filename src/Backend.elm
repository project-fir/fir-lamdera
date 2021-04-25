module Backend exposing (..)

import Color exposing (..)
import Dict exposing (..)
import Html
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import Random exposing (Generator, generate)
import Random.List as RL exposing (choose)
import Types exposing (BackendModel, BackendMsg(..), Cell, LiveUser, ToBackend(..), ToFrontend(..))


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


init : ( Model, Cmd BackendMsg )
init =
    ( BackendModel [] Dict.empty
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        ClientConnected sessionId clientId ->
            let
                newUser =
                    createLiveUser sessionId clientId

                newLiveUsers =
                    Dict.insert ( sessionId, clientId ) newUser model.liveUsers
            in
            ( { model | liveUsers = newLiveUsers }
            , Cmd.batch
                [ sendToFrontend clientId (PushCellsState model.cells)
                , broadcast <| BroadcastUserJoined newUser
                ]
            )

        ClientDisconnected sessionId clientId ->
            let
                oldUser =
                    Dict.get ( sessionId, clientId ) model.liveUsers

                updatedUsers =
                    Dict.remove ( sessionId, clientId ) model.liveUsers
            in
            ( { model | liveUsers = updatedUsers }, Cmd.batch [ broadcast <| BroadcastUserLeft oldUser ] )


createLiveUser : SessionId -> ClientId -> LiveUser
createLiveUser sessionId clientId =
    let
        assignedColor =
            -- TODO: Generator stuff???
            lightCharcoal
    in
    LiveUser sessionId clientId assignedColor



-- AssignColorToUser color ->
--     ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        SubmitNewCell newCell ->
            let
                updatedCells =
                    model.cells ++ [ newCell ]
            in
            ( { model | cells = updatedCells }, Cmd.none )

        FetchHistory ->
            ( model, Cmd.none )


subscriptions model =
    Sub.batch
        [ Lamdera.onConnect ClientConnected
        , Lamdera.onDisconnect ClientDisconnected
        ]


assignColor : Generator ( Maybe Color, List Color )
assignColor =
    let
        colors =
            [ red
            , orange
            , yellow
            , green
            , blue
            , purple
            , brown
            , lightRed
            , lightOrange
            , lightYellow
            , lightGreen
            , lightBlue
            , lightPurple
            , lightBrown
            , darkRed
            , darkOrange
            , darkYellow
            , darkGreen
            , darkBlue
            , darkPurple
            , darkBrown
            , white
            , lightGrey
            , grey
            , darkGrey
            , lightCharcoal
            , charcoal
            , darkCharcoal
            , black
            , lightGray
            , gray
            , darkGray
            ]
    in
    RL.choose colors
