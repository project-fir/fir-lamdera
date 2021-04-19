module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Lamdera exposing (ClientId, SessionId)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , cards : List Card
    , liveUsers : List LiveUser
    , markdown : String
    }


type alias LiveUser =
    { sessionId : String
    , clientId : String
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
    | MarkdownInputChanged


type ToBackend
    = SubmitNewCard Card
    | FetchHistory


type BackendMsg
    = NoOpBackendMsg
    | ClientConnected SessionId ClientId
    | ClientDisconnected SessionId ClientId


type ToFrontend
    = HistoryReceived (List Card)
    | CardReceived Card
    | UserJoined LiveUser
    | UserLeft LiveUser
