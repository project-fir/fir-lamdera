module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Lamdera exposing (ClientId, SessionId)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , cards : List Card
    , liveUsers : List LiveUser
    }


type alias LiveUser =
    -- a "live user" is a user that is actively working, kinda like google docs does with the color icons
    -- TODO: Q for #lamdera?? Would auth stuff go here? How do we avoid broadcasting private info to clients?
    { sessionId : SessionId
    , clientId : ClientId
    }


type alias BackendModel =
    { cards : List Card
    , liveUsers : List LiveUser
    }


type alias Card =
    { prompt : String
    , answer : String
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg


type ToBackend
    = SubmitNewCard Card
    | FetchHistory


type BackendMsg
    = NoOpBackendMsg
    | ClientConnected SessionId ClientId -- TODO: we are not fetching those in the room at the time of connecting!!
    | ClientDisconnected SessionId ClientId -- TODO: ^^ how do we write unit tests for this? Does elm-test work?


type ToFrontend
    = HistoryReceived (List Card)
    | CardReceived Card
    | BroadcastUserJoined LiveUser
    | BroadcastUserLeft LiveUser
