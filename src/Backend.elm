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
    let
        initModel =
            BackendModel (Dict.insert 0 (Cell "") Dict.empty) Dict.empty
    in
    ( initModel
    , Cmd.batch
        [ Lamdera.broadcast <| PushCellsState initModel.cells
        ]
    )


parseColor : Maybe Color -> Color
parseColor color =
    case color of
        Just c ->
            c

        Nothing ->
            lightBrown


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        ClientConnected sessionId clientId ->
            let
                updatedUsers =
                    Dict.insert ( sessionId, clientId ) (LiveUser sessionId clientId) model.liveUsers

                updatedModel =
                    { model | liveUsers = updatedUsers }
            in
            ( updatedModel
            , Cmd.batch
                [ Lamdera.broadcast (PushCellsState updatedModel.cells)
                , Lamdera.broadcast (PushCurrentLiveUsers updatedModel.liveUsers)
                ]
            )

        ClientDisconnected sessionId clientId ->
            let
                updatedUsers =
                    Dict.remove ( sessionId, clientId ) model.liveUsers

                updatedModel =
                    { model | liveUsers = updatedUsers }
            in
            ( updatedModel, Cmd.batch [ Lamdera.broadcast (PushCurrentLiveUsers updatedModel.liveUsers) ] )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        SubmitNewCell ix newCell ->
            ( { model | cells = Dict.insert ix newCell model.cells }
            , Cmd.batch
                [ Lamdera.broadcast <| PushCellsState model.cells
                ]
            )

        FetchHistory ->
            ( model, Cmd.none )


subscriptions _ =
    Sub.batch
        [ Lamdera.onConnect ClientConnected
        , Lamdera.onDisconnect ClientDisconnected
        ]


colorGenerator : Generator ( Maybe Color, List Color )
colorGenerator =
    -- TODO: I'd like to return Generator Color (I'd settle for Generator (Maybe Color),
    -- but having this List floating around feels weird to me)
    let
        colors =
            -- TODO: Custom palette; these colors are more "neon" than what I'm going for
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
