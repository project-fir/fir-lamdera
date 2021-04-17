module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Lamdera exposing (SessionId, ClientId)
import Url exposing (Url)


type alias FrontendModel =
    {
    key : Key,
    cards : List Card
    }


type alias BackendModel =
    { 
        cards : List Card
    }

type alias Card = {
        prompt: String
        , answer: String
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
    | ClientConnected SessionId ClientId
    | ClientDisconnected SessionId ClientId


type ToFrontend
    = HistoryReceived (List Card)
    | CardReceived Card
