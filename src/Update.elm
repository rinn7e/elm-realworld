module Update exposing (..)

import Api.Handler.User as UserApi
import Browser
import Browser.Navigation as Nav
import Component.DebugPanel.Type as DebugPanelType
import Component.DebugPanel.Update as DebugPanel
import Data.Route.Parser as RouteParser
import Data.Route.Type exposing (AppPage(..), AppRoute)
import Http
import Page.Article.Type as ArticleType
import Page.Article.Update as Article
import Page.Auth.Type as AuthType
import Page.Auth.Update as Auth
import Page.Editor.Update as Editor
import Page.Home.Update as Home
import Page.Profile.Update as Profile
import Page.Settings.Type as SettingsType
import Page.Settings.Update as Settings
import Package.Prelude exposing (delayCmd, extraCmd, updateAndCmd)
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
            , debugPanel = DebugPanelType.init
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
navigate route isInternal model =
    let
        -- do redirection/guard route here
        actualRoute =
            case route.page of
                SettingsPage ->
                    if model.shared.token == Nothing then
                        { page = LoginPage }

                    else
                        route

                EditorPage _ ->
                    if model.shared.token == Nothing then
                        { page = LoginPage }

                    else
                        route

                _ ->
                    route

        urlCmd =
            if isInternal then
                Nav.pushUrl model.navKey (RouteParser.toUrlString actualRoute)

            else
                Cmd.none

        ( newPageModel, subCmd ) =
            case actualRoute.page of
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
                    Settings.init
                        |> Tuple.mapBoth Settings (Cmd.map SettingsMsg)

                ProfilePage { username, favorites } ->
                    Profile.init username model.shared.token favorites
                        |> Tuple.mapBoth Profile (Cmd.map ProfileMsg)

                EditorPage slug ->
                    Editor.init slug model.shared.token
                        |> Tuple.mapBoth Editor (Cmd.map EditorMsg)

                NotFoundPage ->
                    ( NotFound, Cmd.none )
    in
    ( { model
        | route = actualRoute
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


logoutHandler : Model -> ( Model, Cmd Msg )
logoutHandler model =
    let
        shared =
            model.shared

        newShared =
            { shared | user = Nothing, token = Nothing }
    in
    changeRouteHandler { page = HomePage } True { model | shared = newShared }
        |> extraCmd (\_ -> Ports.removeToken ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "Msg" (Debug.toString msg)
    in
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

        LinkClick (Browser.External url) ->
            ( model, Nav.load url )

        LinkClick (Browser.Internal url) ->
            let
                route =
                    RouteParser.parseAppRoute url
            in
            changeRouteHandler route True model

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

                ( newPage, subCmd ) =
                    case ( model.page, user ) of
                        ( Settings _, Just u ) ->
                            Settings.reInit u |> Tuple.mapBoth Settings (Cmd.map SettingsMsg)

                        ( Profile subModel, _ ) ->
                            Profile.reInit token subModel |> Tuple.mapBoth Profile (Cmd.map ProfileMsg)

                        ( Editor subModel, _ ) ->
                            Editor.reInit token subModel |> Tuple.mapBoth Editor (Cmd.map EditorMsg)

                        _ ->
                            ( model.page, Cmd.none )
            in
            ( { model | shared = newShared, page = newPage }
            , Cmd.batch
                [ subCmd
                , case token of
                    Just t ->
                        Ports.saveToken t

                    Nothing ->
                        Ports.removeToken ()
                ]
            )

        HomeMsg subMsg ->
            case model.page of
                Home subModel ->
                    Home.update model.shared.token subMsg subModel
                        |> Tuple.mapBoth (\newSubModel -> { model | page = Home newSubModel }) (Cmd.map HomeMsg)

                _ ->
                    ( model, Cmd.none )

        AuthMsg subMsg ->
            case model.page of
                Auth subModel ->
                    Auth.update subMsg subModel
                        |> Tuple.mapBoth (\newSubModel -> { model | page = Auth newSubModel }) (Cmd.map AuthMsg)
                        |> updateAndCmd
                            (\m ->
                                case subMsg of
                                    AuthType.SubmitResponse (Ok res) ->
                                        let
                                            user =
                                                res.user

                                            newShared =
                                                { user = Just user, token = Just user.token }
                                        in
                                        changeRouteHandler { page = HomePage } True { m | shared = newShared }
                                            |> extraCmd (\_ -> Ports.saveToken user.token)

                                    _ ->
                                        ( m, Cmd.none )
                            )

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

        SettingsMsg subMsg ->
            case model.page of
                Settings subModel ->
                    Settings.update (Maybe.withDefault "" model.shared.token) subMsg subModel
                        |> Tuple.mapBoth (\newSubModel -> { model | page = Settings newSubModel }) (Cmd.map SettingsMsg)
                        |> updateAndCmd
                            (\m ->
                                case subMsg of
                                    SettingsType.Logout ->
                                        logoutHandler m

                                    _ ->
                                        ( m, Cmd.none )
                            )

                _ ->
                    ( model, Cmd.none )

        ArticleMsg subMsg ->
            case model.page of
                Article subModel ->
                    Article.update model.shared.token subMsg subModel
                        |> Tuple.mapBoth (\newSubModel -> { model | page = Article newSubModel }) (Cmd.map ArticleMsg)
                        |> updateAndCmd
                            (\m ->
                                case subMsg of
                                    ArticleType.DeleteArticleResponse (Ok _) ->
                                        changeRouteHandler { page = HomePage } True m

                                    _ ->
                                        ( m, Cmd.none )
                            )

                _ ->
                    ( model, Cmd.none )

        ProfileMsg subMsg ->
            case model.page of
                Profile subModel ->
                    Profile.update subModel.username model.shared.token subMsg subModel
                        |> Tuple.mapBoth (\newSubModel -> { model | page = Profile newSubModel }) (Cmd.map ProfileMsg)

                _ ->
                    ( model, Cmd.none )

        EditorMsg subMsg ->
            case model.page of
                Editor subModel ->
                    Editor.update (Maybe.withDefault "" model.shared.token) subMsg subModel
                        |> Tuple.mapBoth (\newSubModel -> { model | page = Editor newSubModel }) (Cmd.map EditorMsg)

                _ ->
                    ( model, Cmd.none )

        DebugPanelMsg subMsg ->
            DebugPanel.update subMsg model.debugPanel
                |> Tuple.mapBoth (\newSubModel -> { model | debugPanel = newSubModel }) (Cmd.map DebugPanelMsg)

        Logout ->
            logoutHandler model

        _ ->
            ( model, Cmd.none )


