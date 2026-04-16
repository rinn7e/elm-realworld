module Update exposing (..)

import Api.Handler.User as UserApi
import Browser.Navigation as Nav
import Component.DebugPanel.Type as DebugPanel
import Component.DebugPanel.Update as DebugPanel
import Data.Route.Parser as RouteParser
import Data.Route.Type exposing (AppPage(..), AppRoute)
import Http
import Page.Article.Update as Article
import Page.Auth.Type as AuthType
import Page.Auth.Update as Auth
import Page.Editor.Update as Editor
import Page.Home.Update as Home
import Page.Profile.Update as Profile
import Page.Settings.Update as Settings
import Ports
import Type exposing (AnimateState(..), Model, Msg(..), PageModel(..))
import Url exposing (Url)
import Util.RemoteData as RD


init : { token : Maybe String } -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        route =
            RouteParser.parseAppRoute url

        model =
            { route = route
            , shared = { user = Nothing, token = flags.token }
            , page = Loading
            , isInternal = False
            , debugPanel = DebugPanel.init
            , navbarMobileOpen = { internal = (), state = Invisible }
            , navKey = key
            }

        ( initialModel, initialCmd ) =
            navigate route True model
    in
    case flags.token of
        Just token ->
            ( initialModel
            , Cmd.batch
                [ initialCmd
                , UserApi.getCurrentUser token (\res -> SetUser (Result.toMaybe res |> Maybe.map .user))
                ]
            )

        Nothing ->
            ( initialModel, initialCmd )


resultToMaybe : Result e a -> Maybe a
resultToMaybe res =
    case res of
        Ok a ->
            Just a

        Err _ ->
            Nothing


navigate : AppRoute -> Bool -> Model -> ( Model, Cmd Msg )
navigate newRoute isInternal model =
    let
        urlCmd =
            if isInternal then
                Nav.pushUrl model.navKey (RouteParser.toUrlString newRoute)

            else
                Cmd.none

        ( newPageModel, subCmd ) =
            case newRoute.page of
                HomePage ->
                    Home.init model.shared.token
                        |> Tuple.mapBoth Home (Cmd.map HomeMsg)

                LoginPage ->
                    Auth.init False
                        |> Tuple.mapBoth Auth (Cmd.map AuthMsg)

                RegisterPage ->
                    Auth.init True
                        |> Tuple.mapBoth Auth (Cmd.map AuthMsg)

                ArticlePage slug ->
                    Article.init slug model.shared.token
                        |> Tuple.mapBoth Article (Cmd.map ArticleMsg)

                SettingsPage ->
                    case model.shared.user of
                        Just user ->
                            Settings.init user
                                |> Tuple.mapBoth Settings (Cmd.map SettingsMsg)

                        Nothing ->
                            ( Loading, Nav.pushUrl model.navKey (RouteParser.toUrlString { page = LoginPage }) )

                ProfilePage { username, favorites } ->
                    Profile.init username favorites model.shared.user
                        |> Tuple.mapBoth Profile (Cmd.map ProfileMsg)

                EditorPage slug ->
                    case model.shared.user of
                        Just _ ->
                            Editor.init slug model.shared.token
                                |> Tuple.mapBoth Editor (Cmd.map EditorMsg)

                        Nothing ->
                            ( Loading, Nav.pushUrl model.navKey (RouteParser.toUrlString { page = LoginPage }) )

                NotFoundPage ->
                    ( NotFound, Cmd.none )
    in
    ( { model
        | route = newRoute
        , page = newPageModel
        , isInternal = isInternal
        , navbarMobileOpen = { internal = (), state = Invisible }
      }
    , Cmd.batch [ urlCmd, subCmd ]
    )


execChangeRoute : AppRoute -> Bool -> Model -> ( Model, Cmd Msg )
execChangeRoute newRoute isInternal model =
    if not (compareAppPage model.route.page newRoute.page) then
        navigate newRoute isInternal model

    else if isInternal then
        navigate newRoute isInternal model

    else
        ( model, Cmd.none )


compareAppPage : AppPage -> AppPage -> Bool
compareAppPage p1 p2 =
    case ( p1, p2 ) of
        ( HomePage, HomePage ) ->
            True

        ( LoginPage, LoginPage ) ->
            True

        ( RegisterPage, RegisterPage ) ->
            True

        ( SettingsPage, SettingsPage ) ->
            True

        ( EditorPage _, EditorPage _ ) ->
            True

        ( ArticlePage _, ArticlePage _ ) ->
            True

        ( ProfilePage _, ProfilePage _ ) ->
            True

        ( NotFoundPage, NotFoundPage ) ->
            True

        _ ->
            False


changeRouteHandler : AppRoute -> Bool -> Model -> ( Model, Cmd Msg )
changeRouteHandler newRoute isInternal model =
    execChangeRoute newRoute isInternal model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange url ->
            if model.isInternal then
                ( { model
                    | isInternal = False
                    , navbarMobileOpen = { internal = (), state = Invisible }
                  }
                , Cmd.none
                )

            else
                let
                    route =
                        RouteParser.parseAppRoute url
                in
                changeRouteHandler route False model

        ChangeRoute route ->
            changeRouteHandler route True model

        SetUser user ->
            let
                shared =
                    model.shared

                token =
                    Maybe.map .token user

                newShared =
                    { shared | user = user, token = token }
            in
            ( { model | shared = newShared }
            , case token of
                Just t ->
                    Ports.saveToken t

                Nothing ->
                    Ports.removeToken ()
            )

        HomeMsg subMsg ->
            case model.page of
                Home subModel ->
                    let
                        ( newSubModel, subCmd ) =
                            Home.update model.shared.token subMsg subModel
                    in
                    ( { model | page = Home newSubModel }, Cmd.map HomeMsg subCmd )

                _ ->
                    ( model, Cmd.none )

        AuthMsg subMsg ->
            case model.page of
                Auth subModel ->
                    let
                        ( newSubModel, subCmd ) =
                            Auth.update subMsg subModel
                    in
                    case subMsg of
                        AuthType.SubmitResponse (Ok res) ->
                            let
                                user =
                                    res.user

                                newShared =
                                    { user = Just user, token = Just user.token }

                                ( newModel, cmd ) =
                                    changeRouteHandler { page = HomePage } True { model | shared = newShared }
                            in
                            ( newModel, Cmd.batch [ cmd, Ports.saveToken user.token ] )

                        _ ->
                            ( { model | page = Auth newSubModel }, Cmd.map AuthMsg subCmd )

                _ ->
                    ( model, Cmd.none )

        ToggleNavbarMobile open ->
            if open then
                ( { model | navbarMobileOpen = { internal = (), state = AnimateIn } }, delayCmd 150 (SetNavbarMobileState Visible) )

            else
                ( { model | navbarMobileOpen = { internal = (), state = AnimateOut } }, delayCmd 150 (SetNavbarMobileState Invisible) )

        SetNavbarMobileState state ->
            let
                navState =
                    model.navbarMobileOpen
            in
            ( { model | navbarMobileOpen = { navState | state = state } }, Cmd.none )

        DebugPanelMsg subMsg ->
            ( { model | debugPanel = DebugPanel.update subMsg model.debugPanel }, Cmd.none )

        _ ->
            ( model, Cmd.none )


delayCmd : Float -> Msg -> Cmd Msg
delayCmd ms msg =
    Cmd.none |> Cmd.map (\_ -> msg)
