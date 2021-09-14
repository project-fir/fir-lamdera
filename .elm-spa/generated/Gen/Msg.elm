module Gen.Msg exposing (Msg(..))

import Gen.Params.Catalog
import Gen.Params.Home_
import Gen.Params.Login
import Gen.Params.NotFound
import Gen.Params.Register
import Gen.Params.Search
import Gen.Params.Settings
import Gen.Params.Profile.Username_
import Pages.Catalog
import Pages.Home_
import Pages.Login
import Pages.NotFound
import Pages.Register
import Pages.Search
import Pages.Settings
import Pages.Profile.Username_


type Msg
    = Catalog Pages.Catalog.Msg
    | Login Pages.Login.Msg
    | Register Pages.Register.Msg
    | Search Pages.Search.Msg
    | Settings Pages.Settings.Msg
    | Profile__Username_ Pages.Profile.Username_.Msg

