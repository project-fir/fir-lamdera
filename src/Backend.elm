module Backend exposing (..)

import Html
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
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
    ( BackendModel [] []
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )

        ClientConnected sessionId clientId ->
            let
                newUser =
                    LiveUser sessionId clientId

                newLiveUsers =
                    model.liveUsers ++ [ newUser ]
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
                    LiveUser sessionId clientId

                updatedUsers =
                    List.filter (\u -> not <| oldUser.clientId == u.clientId) model.liveUsers
            in
            ( { model | liveUsers = updatedUsers }, Cmd.batch [ broadcast <| BroadcastUserLeft oldUser ] )


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
