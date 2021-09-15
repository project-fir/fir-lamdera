module Api.Data exposing (Data(..), map, toMaybe)


type alias CurrentPage =
    Int


type alias BatchSize =
    Int


type Data value
    = NotAsked
    | Loading
    | BatchedLoading CurrentPage BatchSize (Maybe Int) value
    | Failure (List String)
    | Success value


map : (a -> b) -> Data a -> Data b
map fn data =
    case data of
        NotAsked ->
            NotAsked

        Loading ->
            Loading

        BatchedLoading cp bs pc v ->
            BatchedLoading cp bs pc (fn v)

        Failure reason ->
            Failure reason

        Success value ->
            Success (fn value)


toMaybe : Data value -> Maybe value
toMaybe data =
    case data of
        Success value ->
            Just value

        _ ->
            Nothing
