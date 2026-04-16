module Page.Settings.Type exposing (..)

import Api.Type.User exposing (UserResponse)
import Http
import Package.ElmForm as Form


type alias Model =
    { form : Form.Model
    , errors : Maybe String
    , submitting : Bool
    }


type Msg
    = FormMsg String String
    | Submit
    | SubmitResponse (Result Http.Error UserResponse)
    | Logout
