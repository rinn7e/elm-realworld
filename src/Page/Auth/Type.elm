module Page.Auth.Type exposing (..)

import Api.Type.User exposing (UserResponse)
import Http
import Package.ElmForm as Form


type alias Model =
    { isRegister : Bool
    , loginForm : Form.Model Msg
    , signupForm : Form.Model Msg
    , errors : Maybe String
    , submitting : Bool
    }


type Msg
    = FormMsg Form.Msg
    | Submit
    | SubmitResponse (Result Http.Error UserResponse)
