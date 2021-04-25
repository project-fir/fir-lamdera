module Frontend exposing (..)

import Array exposing (Array)
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Color as C exposing (..)
import Dict
import Element as E exposing (..)
import Element.Background as EB exposing (..)
import Element.Input as EI exposing (..)
import Html exposing (Html)
import Html.Attributes as Attr
import Lamdera exposing (..)
import Types exposing (BackendMsg(..), Cell, FrontendModel, FrontendMsg(..), LiveUser, ToFrontend(..))
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
        , subscriptions = \_ -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( FrontendModel key (Array.fromList [ Cell "" ]) Dict.empty
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

        CellTextChanged newText ix ->
            let
                updatedCells =
                    Array.set ix (Cell newText) model.cells
            in
            ( { model | cells = updatedCells }, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        PushCellsState cells ->
            -- TODO: q for #lamdera I believe this'll trample state, right? But is there Lamdera magic?
            ( model, Cmd.none )

        BroadcastUserJoined newUser ->
            let
                updatedUsers =
                    Dict.insert ( newUser.sessionId, newUser.clientId ) newUser model.liveUsers
            in
            ( { model | liveUsers = updatedUsers }, Cmd.none )

        BroadcastUserLeft oldUser ->
            let
                updatedUsers =
                    case oldUser of
                        Just ou ->
                            Dict.remove ( ou.sessionId, ou.clientId ) model.liveUsers

                        Nothing ->
                            model.liveUsers
            in
            ( { model | liveUsers = updatedUsers }, Cmd.none )


view : Model -> Browser.Document FrontendMsg
view model =
    { title = "This is the title"
    , body = viewLayout model
    }


viewLayout : Model -> List (Html FrontendMsg)
viewLayout model =
    [ layout
        []
        (el
            [ E.width E.fill
            , E.height <| E.fill
            , EB.color <| elementFromColor <| C.rgb255 240 234 214 -- eggshell white
            , E.padding 20
            ]
            (viewElements model)
        )
    ]


viewIndicator : LiveUser -> Element FrontendMsg
viewIndicator user =
    E.el [ E.padding 10, EB.color <| elementFromColor C.lightBrown ] <| E.text "+"


viewCurrentCollaboratorsPanel : Dict.Dict ( SessionId, ClientId ) LiveUser -> Element FrontendMsg
viewCurrentCollaboratorsPanel users =
    let
        -- TODO: I believe this list sort order is deterministic by conincidence (across clients), I'm cool with that for this use-case but what if I wasn't?
        ul =
            Dict.values users
    in
    E.row [ E.padding 10, E.spacingXY 10 10 ] <|
        List.map viewIndicator ul


viewElements : Model -> Element FrontendMsg
viewElements model =
    column
        [ E.centerX
        , E.width <| E.px 800
        , EB.color <| elementFromColor <| C.rgb255 255 255 255 -- eggshell white
        ]
        [ viewCurrentCollaboratorsPanel model.liveUsers
        , viewCells model.cells
        ]


viewCells : Array Cell -> Element FrontendMsg
viewCells cells =
    E.column
        [ E.width E.fill
        , EB.color <| E.rgb255 100 100 154
        ]
    <|
        List.map viewCell (Array.toList cells)


viewCell : Cell -> Element FrontendMsg
viewCell cell =
    row
        [ E.padding 0
        , E.width E.fill
        ]
    <|
        [ EI.multiline
            []
            { onChange = \text -> CellTextChanged text 0
            , text = cell.text
            , placeholder = Just <| EI.placeholder [] (E.text "Start typing here!")
            , label = EI.labelHidden "TODO: What to put here?"
            , spellcheck = True
            }
        ]


elementFromColor : C.Color -> E.Color
elementFromColor c =
    E.fromRgb <| C.toRgba c
