module Frontend exposing (..)

import Array exposing (Array)
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
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
    ( FrontendModel key (Array.fromList [ Cell "" ]) []
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
            ( { model | liveUsers = model.liveUsers ++ [ newUser ] }, Cmd.none )

        BroadcastUserLeft oldUser ->
            let
                updatedUsers =
                    List.filter (\lu -> lu /= oldUser) model.liveUsers
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
            , EB.color <| rgb255 240 234 214 -- eggshell white
            , E.padding 20
            ]
            (viewElements model)
        )
    ]


viewElements : Model -> Element FrontendMsg
viewElements model =
    column [ E.centerX ]
        [ viewCells model.cells
        , E.text <| "Currently connected users:"
        , viewLiveUsersTable model.liveUsers
        ]


viewLiveUsersTable : List LiveUser -> Element FrontendMsg
viewLiveUsersTable users =
    E.table
        [ E.centerX
        , E.centerY
        , E.spacing 5
        , E.padding 10
        ]
        { data = users
        , columns =
            [ { header = E.text "Session Id:"
              , width = px 200
              , view =
                    \u ->
                        E.text u.sessionId
              }
            , { header = E.text "Client Id:"
              , width = fill
              , view =
                    \u ->
                        E.text u.clientId
              }
            ]
        }


viewCells : Array Cell -> Element FrontendMsg
viewCells cells =
    E.column [] <|
        List.map viewCell (Array.toList cells)


viewCell : Cell -> Element FrontendMsg
viewCell cell =
    row [] <|
        [ EI.multiline
            []
            { onChange = \text -> CellTextChanged text 0
            , text = cell.text
            , placeholder = Just <| EI.placeholder [] (E.text "Start typing here!")
            , label = EI.labelHidden "TODO: What to put here?"
            , spellcheck = True
            }
        ]
