module Page.Auth.Type exposing (..)

import Api.Type.User exposing (UserResponse)
import Http
import Package.ElmForm as Form


type alias Model =
    { isRegister : Bool
    , loginForm : Form.Model
    , signupForm : Form.Model
    , errors : Maybe String
    , submitting : Bool
    }


type Msg
    = FormMsg String String -- Key Value
    | Submit
    | SubmitResponse (Result Http.Error UserResponse)
