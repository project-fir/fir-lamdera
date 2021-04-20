module Types exposing (..)

import Array exposing (Array)
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Lamdera exposing (ClientId, SessionId)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key -- TODO: what's key for??
    , cells : Array Cell
    , liveUsers : List LiveUser
    }


type alias LiveUser =
    -- a "live user" is a user that is actively working, kinda like google docs does with the color icons
    -- TODO: Q for #lamdera?? Would auth stuff go here? How do we avoid broadcasting private info to clients?
    { sessionId : SessionId
    , clientId : ClientId
    }


type alias BackendModel =
    { cells : List Cell
    , liveUsers : List LiveUser
    }


type alias Cell =
    { text : String
    }


type alias CellIndex =
    Int


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | CellTextChanged String CellIndex


type ToBackend
    = SubmitNewCell Cell
    | FetchHistory


type BackendMsg
    = NoOpBackendMsg
    | ClientConnected SessionId ClientId -- TODO: we are not fetching those in the room at the time of connecting!!
    | ClientDisconnected SessionId ClientId -- TODO: ^^ how do we write unit tests for this? Does elm-test work?


type ToFrontend
    = PushCellsState (List Cell)
    | BroadcastUserJoined LiveUser
    | BroadcastUserLeft LiveUser
