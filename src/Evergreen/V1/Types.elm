module Evergreen.V1.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Lamdera
import Url


type alias CellIndex =
    Int


type alias Cell =
    { text : String
    }


type alias LiveUser =
    { sessionId : Lamdera.SessionId
    , clientId : Lamdera.ClientId
    }


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , cells : Dict.Dict CellIndex Cell
    , liveUsers : Dict.Dict ( Lamdera.SessionId, Lamdera.ClientId ) LiveUser
    }


type alias BackendModel =
    { cells : Dict.Dict CellIndex Cell
    , liveUsers : Dict.Dict ( Lamdera.SessionId, Lamdera.ClientId ) LiveUser
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | CellTextChanged String CellIndex
    | ClickedCreateCell


type ToBackend
    = SubmitNewCell CellIndex
    | PostCellState (Dict.Dict CellIndex Cell)


type BackendMsg
    = ClientConnected Lamdera.SessionId Lamdera.ClientId
    | ClientDisconnected Lamdera.SessionId Lamdera.ClientId


type ToFrontend
    = PushCellsState (Dict.Dict CellIndex Cell)
    | PushCurrentLiveUsers (Dict.Dict ( Lamdera.SessionId, Lamdera.ClientId ) LiveUser)
