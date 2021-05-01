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
import Types exposing (BackendMsg(..), Cell, CellIndex, FrontendModel, FrontendMsg(..), LiveUser, ToBackend(..), ToFrontend(..))
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
init _ key =
    ( FrontendModel key Dict.empty Dict.empty
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
                updatedCell =
                    Cell newText

                updatedCells =
                    Dict.insert ix updatedCell model.cells
            in
            ( { model | cells = updatedCells }
            , Cmd.batch
                [ Lamdera.sendToBackend (PostCellState updatedCells) ]
            )

        ClickedCreateCell ->
            let
                cellIndex =
                    Dict.size model.cells + 1

                newCell =
                    Cell ""
            in
            ( model
            , Cmd.batch
                [ Lamdera.sendToBackend (SubmitNewCell cellIndex newCell)
                ]
            )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        PushCellsState newCells ->
            -- TODO: q for #lamdera I believe this'll trample state, right? But is there Lamdera magic?
            ( { model | cells = newCells }, Cmd.none )

        PushCurrentLiveUsers liveUsers ->
            ( { model | liveUsers = liveUsers }, Cmd.none )


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


viewCurrentCollaboratorsPanel : Dict.Dict ( SessionId, ClientId ) LiveUser -> Element FrontendMsg
viewCurrentCollaboratorsPanel users =
    let
        ul =
            Dict.values users
    in
    E.row [ E.padding 10, E.spacingXY 10 10 ]
        [ E.table [ E.padding 10 ]
            { data = ul
            , columns =
                [ { header = E.text "Client Id"
                  , width = E.fill
                  , view = \u -> E.text u.clientId
                  }
                ]
            }
        ]


viewAddCellButton : Element FrontendMsg
viewAddCellButton =
    E.row []
        [ EI.button
            [ EB.color <| E.rgb255 238 238 238
            ]
            { onPress = Just ClickedCreateCell
            , label = E.text "+"
            }
        ]


viewElements : Model -> Element FrontendMsg
viewElements model =
    column
        [ E.centerX
        , E.width <| E.px 800
        , EB.color <| elementFromColor <| C.white
        ]
        [ viewCurrentCollaboratorsPanel model.liveUsers
        , viewCells model.cells
        , viewAddCellButton
        ]


viewCells : Dict.Dict CellIndex Cell -> Element FrontendMsg
viewCells cells =
    let
        cellsList =
            Dict.toList cells
    in
    E.column
        [ E.width E.fill
        , EB.color <| E.rgb255 100 100 154
        ]
    <|
        List.map viewCell cellsList


viewCell : ( CellIndex, Cell ) -> Element FrontendMsg
viewCell cell =
    let
        ix =
            Tuple.first cell

        c =
            Tuple.second cell
    in
    row
        [ E.padding 10
        , E.width E.fill
        ]
    <|
        [ EI.multiline
            [ E.padding 5 ]
            { onChange = \text -> CellTextChanged text ix
            , text = c.text
            , placeholder = Just <| EI.placeholder [] (E.text "Start typing here!")
            , label = EI.labelHidden "TODO: What to put here?"
            , spellcheck = True
            }
        ]


elementFromColor : C.Color -> E.Color
elementFromColor c =
    E.fromRgb <| C.toRgba c
