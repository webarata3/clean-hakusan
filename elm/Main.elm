port module Main exposing (..)

import Browser
import Credit
import Html exposing (Attribute, Html, a, article, button, div, h1, h2, h3, img, label, li, main_, menu, optgroup, option, p, pre, select, span, text, ul)
import Html.Attributes exposing (attribute, class, for, href, id, selected, src, target, type_, value)
import Html.Events exposing (on, onClick)
import Http
import Json.Decode exposing (Decoder, decodeString, field, string)
import Privacy
import Task
import Time
import TimeUtil
import Url.Builder
import Util
import View.Footer


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


port operateLocalStorage : LocalStorageValue -> Cmd msg


port retOperateLocalStorage : (LocalStorageValue -> msg) -> Sub msg



-- MODEL


type alias Model =
    { viewState : ViewState
    , menuState : MenuState
    , nowOpenSubMenuType : SubMenuType
    , currentDate : String
    , isVersionChange : Bool
    , areaNo : String
    , apiVersion : String
    , regions : List Region
    , maybeAreaGarbage : Maybe AreaGarbage
    }


type alias Area =
    { areaNo : String
    , areaName : String
    }


type alias Region =
    { regionName : String
    , areas : List Area
    }


type alias AreaGarbage =
    { areaNo : String
    , areaName : String
    , calendarUrl : String
    , garbages : List Garbage
    }


type alias Garbage =
    { garbageTitles : List String
    , garbageDates : List String
    }


type Msg
    = DataError String
    | SetCurrentDate Time.Posix
    | OperatedLocalStorage LocalStorageValue
    | GotApiVersionLocalStorage String
    | GotApiVersionWeb (Result Http.Error String)
    | ClearedLocalStorage
    | GotRegionsLocalStorage String
    | GotRegionsWeb (Result Http.Error String)
    | GotAreaGarbageLocalStorage String
    | GotAreaGarbageWeb (Result Http.Error String)
    | ChangeArea String
    | ViewAreaGarbage
    | Tick Time.Posix
    | ClickMenuOpen
    | ClickMenuClose
    | ClickSubMenu SubMenuType


type ApiVersionState
    = NoChange
    | RequireRegion String
    | GetError String


type ViewState
    = PrepareData
    | SystemError
    | DataOk


type MenuState
    = MenuClose
    | MenuOpen


type SubMenuType
    = NoOpenSubMenu
    | Privacy
    | Disclaimer
    | Credit


type alias LocalStorageValue =
    { tag : String
    , key : String
    , value : String
    }


decodeRegions : Decoder (List Region)
decodeRegions =
    Json.Decode.list decodeRegion


decodeRegion : Decoder Region
decodeRegion =
    Json.Decode.map2 Region
        (field "regionName" string)
        (field "areas" decodeAreas)


decodeAreas : Decoder (List Area)
decodeAreas =
    Json.Decode.list decodeArea


decodeArea : Decoder Area
decodeArea =
    Json.Decode.map2 Area
        (field "areaNo" string)
        (field "areaName" string)


decodeAreaGarbage : Decoder AreaGarbage
decodeAreaGarbage =
    Json.Decode.map4 AreaGarbage
        (field "areaNo" string)
        (field "areaName" string)
        (field "calendarUrl" string)
        (field "garbages" decodeGarbages)


decodeGarbages : Decoder (List Garbage)
decodeGarbages =
    Json.Decode.list decodeGarbage


decodeGarbage : Decoder Garbage
decodeGarbage =
    Json.Decode.map2 Garbage
        (field "garbageTitles" (Json.Decode.list string))
        (field "garbageDates" (Json.Decode.list string))


init : () -> ( Model, Cmd Msg )
init _ =
    ( { viewState = PrepareData
      , menuState = MenuClose
      , nowOpenSubMenuType = NoOpenSubMenu
      , currentDate = ""
      , isVersionChange = False
      , areaNo = ""
      , apiVersion = ""
      , regions = []
      , maybeAreaGarbage = Nothing
      }
    , Task.perform SetCurrentDate Time.now
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ retOperateLocalStorage OperatedLocalStorage
        , Time.every (60 * 1000) Tick
        ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DataError message ->
            ( model, Cmd.none )

        Tick newTime ->
            let
                now =
                    TimeUtil.intDateToYyyymmddDate <| TimeUtil.posixToIntDate newTime
            in
            case model.currentDate of
                "" ->
                    ( model, Cmd.none )

                currentDate ->
                    if now == currentDate then
                        ( model, Cmd.none )

                    else
                        ( model, Task.perform SetCurrentDate Time.now )

        SetCurrentDate time ->
            ( { model
                | currentDate =
                    TimeUtil.intDateToYyyymmddDate <|
                        TimeUtil.posixToIntDate time
              }
            , operateLocalStorage
                { tag = "load"
                , key = "areaNo"
                , value = ""
                }
            )

        OperatedLocalStorage localStorageValue ->
            case localStorageValue.tag of
                "load" ->
                    case localStorageValue.key of
                        "areaNo" ->
                            let
                                areaNo =
                                    if localStorageValue.value == "" then
                                        "01"

                                    else
                                        localStorageValue.value
                            in
                            ( { model | areaNo = areaNo }
                            , operateLocalStorage
                                { tag = "load"
                                , key = "apiVersion"
                                , value = ""
                                }
                            )

                        "apiVersion" ->
                            update
                                (GotApiVersionLocalStorage localStorageValue.value)
                                model

                        "regions" ->
                            update
                                (GotRegionsLocalStorage localStorageValue.value)
                                model

                        _ ->
                            update
                                (GotAreaGarbageLocalStorage localStorageValue.value)
                                model

                "save" ->
                    case localStorageValue.key of
                        "apiVersion" ->
                            ( model, getRegionsWeb )

                        "regions" ->
                            update (ChangeArea model.areaNo) model

                        "areaNo" ->
                            update ViewAreaGarbage model

                        _ ->
                            if String.startsWith "areaGarbage-" localStorageValue.key then
                                ( model, Cmd.none )

                            else
                                ( model, Cmd.none )

                "clear" ->
                    ( model, getAreaGarbageWeb model.areaNo )

                _ ->
                    ( model, Cmd.none )

        GotApiVersionLocalStorage localStorageValue ->
            ( { model | apiVersion = localStorageValue }
            , noCacheGet
                { url = getApiUrl [ "version.json" ]
                , expect = Http.expectString GotApiVersionWeb
                }
            )

        GotApiVersionWeb (Ok resp) ->
            let
                jsonApiVersion =
                    decodeString (field "apiVersion" string) resp

                apiVersionState =
                    case jsonApiVersion of
                        Ok webApiVersion ->
                            if model.apiVersion == "" || webApiVersion > model.apiVersion then
                                RequireRegion webApiVersion

                            else
                                NoChange

                        Err error ->
                            GetError (Util.jsonError error)
            in
            case apiVersionState of
                RequireRegion webApiVersion ->
                    -- バージョンが変わっているので、localStorageにバージョンを保存
                    ( { model
                        | isVersionChange = True
                        , apiVersion = webApiVersion
                        , viewState = DataOk
                      }
                    , operateLocalStorage
                        { tag = "save"
                        , key = "apiVersion"
                        , value = webApiVersion
                        }
                    )

                NoChange ->
                    -- バージョンが変わっていないのでlocalStorageを使う
                    ( model
                    , operateLocalStorage
                        { tag = "load"
                        , key = "regions"
                        , value = ""
                        }
                    )

                GetError errorMessage ->
                    update (DataError errorMessage) model

        GotApiVersionWeb (Err error) ->
            -- TODO 取れない場合はローカルにあるデータを使う
            ( model, Cmd.none )

        ClearedLocalStorage ->
            ( model, getAreaGarbageWeb model.areaNo )

        -- 以前データを取得していてバージョンが変わっていない場合には
        -- localStorageから取得する
        GotRegionsLocalStorage jsonRegions ->
            let
                regionsResult =
                    convertRegions jsonRegions
            in
            case regionsResult of
                Ok regions ->
                    update (ChangeArea model.areaNo)
                        { model
                            | viewState = DataOk
                            , regions = regions
                        }

                -- localStorageにデータがなければWebから取得する
                Err error ->
                    ( model, getRegionsWeb )

        GotRegionsWeb (Ok resp) ->
            let
                regionsResult =
                    convertRegions resp
            in
            case regionsResult of
                Ok regions ->
                    ( { model | viewState = DataOk, regions = regions }
                    , operateLocalStorage
                        { tag = "save"
                        , key = "regions"
                        , value = resp
                        }
                    )

                Err error ->
                    update (DataError error) model

        GotRegionsWeb (Err error) ->
            update (DataError (Util.httpError "[REGIONS]" error)) model

        GotAreaGarbageWeb (Ok resp) ->
            let
                areaGarbageResult =
                    convertAreaGarbage resp
            in
            case areaGarbageResult of
                Ok areaGarbage ->
                    ( { model
                        | maybeAreaGarbage = Just areaGarbage
                      }
                    , operateLocalStorage
                        { tag = "save"
                        , key = "areaGarbage-" ++ model.areaNo
                        , value = resp
                        }
                    )

                Err error ->
                    update (DataError error) model

        GotAreaGarbageWeb (Err error) ->
            update (DataError (Util.httpError "[AREA GARBAGE]" error)) model

        GotAreaGarbageLocalStorage jsonAreaGarbage ->
            let
                areaGarbageResult =
                    convertAreaGarbage jsonAreaGarbage
            in
            case areaGarbageResult of
                Ok areaGarbage ->
                    ( { model
                        | maybeAreaGarbage = Just areaGarbage
                      }
                    , Cmd.none
                    )

                -- localStorageにデータがなければWebから取得する
                Err error ->
                    ( model, getAreaGarbageWeb model.areaNo )

        ChangeArea areaNo ->
            -- エリアが変わったら最初にareaNoを保存する
            ( { model | areaNo = areaNo }
            , operateLocalStorage
                { tag = "save"
                , key = "areaNo"
                , value = areaNo
                }
            )

        ViewAreaGarbage ->
            if model.isVersionChange then
                -- バージョンが変わっていたらWebから取得する
                ( model
                , operateLocalStorage
                    { tag = "clear"
                    , key = ""
                    , value = ""
                    }
                )

            else
                -- バージョンが変わっていなければlocalStorageから取得する
                ( model
                , operateLocalStorage
                    { tag = "load"
                    , key = "areaGarbage-" ++ model.areaNo
                    , value = ""
                    }
                )

        ClickMenuOpen ->
            ( { model | menuState = MenuOpen }, Cmd.none )

        ClickMenuClose ->
            let
                nowOpenSubMenu =
                    model.nowOpenSubMenuType /= NoOpenSubMenu

                subMenuOpen =
                    not nowOpenSubMenu

                nowOpenSubMenuType =
                    if subMenuOpen then
                        model.nowOpenSubMenuType

                    else
                        NoOpenSubMenu

                menuOpen =
                    if nowOpenSubMenu then
                        MenuOpen

                    else
                        MenuClose
            in
            ( { model
                | menuState = menuOpen
                , nowOpenSubMenuType = nowOpenSubMenuType
              }
            , Cmd.none
            )

        ClickSubMenu subMenuType ->
            case subMenuType of
                NoOpenSubMenu ->
                    ( { model | nowOpenSubMenuType = NoOpenSubMenu }, Cmd.none )

                Privacy ->
                    ( { model | nowOpenSubMenuType = Privacy }, Cmd.none )

                Disclaimer ->
                    ( { model | nowOpenSubMenuType = Disclaimer }, Cmd.none )

                Credit ->
                    ( { model | nowOpenSubMenuType = Credit }, Cmd.none )



-- FUNCTION


noCacheGet : { url : String, expect : Http.Expect msg } -> Cmd msg
noCacheGet r =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "pragma" "no-cache"
            , Http.header "Cache-Control" "no-cache"
            , Http.header "If-Modified-Since" "Sat, 01 Jan 2000 00:00:00 GMT"
            ]
        , url = r.url
        , body = Http.emptyBody
        , expect = r.expect
        , timeout = Nothing
        , tracker = Nothing
        }


getApiUrl : List String -> String
getApiUrl paths =
    Url.Builder.absolute ("api" :: paths) []


getRegionsWeb : Cmd Msg
getRegionsWeb =
    noCacheGet
        { url = getApiUrl <| List.singleton "regions.json"
        , expect = Http.expectString GotRegionsWeb
        }


getAreaGarbageWeb : String -> Cmd Msg
getAreaGarbageWeb areaNo =
    noCacheGet
        { url = getApiUrl <| List.singleton (areaNo ++ ".json")
        , expect = Http.expectString GotAreaGarbageWeb
        }


convertRegions : String -> Result String (List Region)
convertRegions regionJson =
    let
        regionsResult =
            decodeString (field "regions" decodeRegions) regionJson
    in
    case regionsResult of
        Ok resultJson ->
            Ok resultJson

        Err error ->
            Err <| Util.jsonError error


convertAreaGarbage : String -> Result String AreaGarbage
convertAreaGarbage areaGarbageJson =
    let
        areaGarbageResult =
            decodeString decodeAreaGarbage areaGarbageJson
    in
    case areaGarbageResult of
        Ok resultJson ->
            Ok resultJson

        Err error ->
            Err <| Util.jsonError error



-- VIEW


view : Model -> Html Msg
view model =
    article [ id "app" ]
        [ viewHeader
        , viewMain model
        , View.Footer.viewFooter
        , viewMenuBackground model
        , viewMenu model
        , viewSubMenuPrivacy (model.nowOpenSubMenuType == Privacy)
        , viewSubMenuDisclaimer (model.nowOpenSubMenuType == Disclaimer)
        , viewSubMenuCredit (model.nowOpenSubMenuType == Credit)
        ]


viewHeader : Html Msg
viewHeader =
    Html.header []
        [ div
            [ class "menu-button"
            , onClick ClickMenuOpen
            ]
            [ button [ class "header-menu-button" ] []
            ]
        , h1 [ class "header-title" ] [ text "白山市ごみ収集日程" ]
        , div [ class "menu-button" ]
            [ button
                [ class "header-reload-button"

                -- , onClick ClickReload
                ]
                []
            ]
        ]


viewMenuBackground : Model -> Html Msg
viewMenuBackground model =
    div
        [ class "menu-background"
        , viewMenuClass model
        , onClick ClickMenuClose
        ]
        []


viewMenu : Model -> Html Msg
viewMenu model =
    menu [ type_ "toolbar", viewMenuClass model ]
        [ div [ class "submenu-header" ]
            [ img
                [ src "image/times-solid.svg"
                , class "close-button"
                , onClick ClickMenuClose
                ]
                []
            ]
        , ul []
            [ li []
                [ a
                    [ href "how-to-use/"
                    , target "_blank"
                    ]
                    [ text "使い方"
                    , img
                        [ src "image/external-link-alt-solid.svg"
                        , class "toolbar-external-link-image"
                        ]
                        []
                    ]
                ]
            , li []
                [ a
                    [ href "#", onClickNoPrevent (ClickSubMenu Privacy) ]
                    [ text "プライバシーポリシー" ]
                ]
            , li []
                [ a
                    [ href "#", onClickNoPrevent (ClickSubMenu Disclaimer) ]
                    [ text "免責事項" ]
                ]
            , li []
                [ a
                    [ href "#", onClickNoPrevent (ClickSubMenu Credit) ]
                    [ text "クレジット" ]
                ]
            ]
        ]


onClickNoPrevent : Msg -> Html.Attribute Msg
onClickNoPrevent message =
    Html.Events.custom "click"
        (Json.Decode.succeed
            { message = message, stopPropagation = True, preventDefault = True }
        )


viewMenuClass : Model -> Html.Attribute Msg
viewMenuClass model =
    let
        appendClass =
            if model.nowOpenSubMenuType == NoOpenSubMenu then
                ""

            else
                " sub-menu-open"
    in
    case model.menuState of
        MenuClose ->
            class ("menu-close" ++ appendClass)

        MenuOpen ->
            class ("menu-open" ++ appendClass)


viewMain : Model -> Html Msg
viewMain model =
    let
        handler selectedValue =
            ChangeArea selectedValue
    in
    case model.viewState of
        SystemError ->
            main_
                [ class "error" ]
                [ div [ class "error-message" ] [ text "エラーが発生しました。" ]
                , div [ class "error-message" ] [ text "動かない場合には、再読み込みしてみてください。" ]
                , div [ class "error-message" ] [ text "報告して頂ける場合には、下の理由をお知らせください。" ]

                -- , div [ id "reason", class "message" ]
                --     [ text ("理由: " ++ model.errorMessage) ]
                --     -- , button [ id "errorMessageButton", onClick CopyText ]
                --     [ text "メッセージをコピー" ]
                ]

        PrepareData ->
            main_
                [ class "loading" ]
                [ div [ class "message" ] [ text "読み込み中。" ]
                , div [ class "message" ] [ text "動かない場合には、再読み込みしてみてください。" ]
                , div []
                    [ img [ class "loading-icon", src "image/ball-triangle.svg" ] [] ]
                ]

        DataOk ->
            case model.maybeAreaGarbage of
                Just areaGarbage ->
                    main_ []
                        [ div [ class "alert" ] [ text "※ 白山市公式のアプリではありません。" ]
                        , div [ class "area" ]
                            [ div [ class "select-area" ]
                                [ label
                                    [ for "area" ]
                                    [ text "地域" ]
                                , select [ id "area", onChange handler ]
                                    (List.map (viewRegion model.areaNo) model.regions)
                                ]
                            , div [ class "external-link" ]
                                [ a
                                    [ href "https://www.city.hakusan.lg.jp/shiminseikatsubu/kankyo/4r/gomi_chikunokensaku_calendar_3.html"
                                    , target "_blank"
                                    ]
                                    [ text "地域が不明な方" ]
                                , a
                                    [ href "https://gb.hn-kouiki.jp/hakusan"
                                    , target "_blank"
                                    ]
                                    [ text "ゴミ分別検索" ]
                                , a
                                    [ href areaGarbage.calendarUrl
                                    , target "_blank"
                                    ]
                                    [ text "ゴミの出し方" ]
                                ]
                            ]
                        , viewAreaGarbage model.currentDate areaGarbage
                        ]

                Nothing ->
                    main_ [] []


viewRegion : String -> Region -> Html Msg
viewRegion areaNo region =
    optgroup
        [ attribute "label" region.regionName ]
        (List.map (viewArea areaNo) region.areas)


viewArea : String -> Area -> Html Msg
viewArea areaNo area =
    option
        (if areaNo == area.areaNo then
            [ value area.areaNo
            , selected True
            ]

         else
            [ value area.areaNo, selected False ]
        )
        [ text area.areaName ]


viewAreaGarbage : String -> AreaGarbage -> Html Msg
viewAreaGarbage currentDate areaGarbage =
    viewGarbages currentDate areaGarbage.garbages


viewGarbages : String -> List Garbage -> Html Msg
viewGarbages currentDate garbages =
    let
        viewGarbage2 =
            viewGarbage currentDate
    in
    div [ class "garbages" ] (List.map viewGarbage2 garbages)


viewGarbage : String -> Garbage -> Html Msg
viewGarbage currentDate garbage =
    div [ class "garbage-item" ]
        [ viewGarbageTitles garbage.garbageTitles
        , viewGarbageDates currentDate garbage.garbageDates
        ]


viewGarbageTitles : List String -> Html Msg
viewGarbageTitles garbageTitles =
    div [ class "garbage-title" ] (List.map viewLine garbageTitles)


viewGarbageDates : String -> List String -> Html Msg
viewGarbageDates currentDate garbageDates =
    let
        nextGarbageDate =
            Util.nextDate currentDate garbageDates

        howManyDays =
            TimeUtil.diffDayYyyymmddDate currentDate nextGarbageDate

        dispDays =
            Util.dispHowManyDays
                (TimeUtil.diffDayYyyymmddDate
                    currentDate
                    nextGarbageDate
                )
    in
    div [ class (Util.howManyDaysCss howManyDays) ]
        [ div [ class "garbage-how-many-days" ] [ text dispDays ]
        , div [ class "garbage-next-date" ]
            [ text (TimeUtil.yyyymmddDateToShowDate nextGarbageDate)
            ]
        ]


viewLine : String -> Html Msg
viewLine value =
    div [] [ text value ]


onChange : (String -> Msg) -> Attribute Msg
onChange handler =
    on "change" (Json.Decode.map handler Html.Events.targetValue)


subMenuOpenClass : Bool -> Html.Attribute Msg
subMenuOpenClass isOpen =
    if isOpen then
        class "sub-menu-open"

    else
        class "sub-menu-close"


viewSubMenuPrivacy : Bool -> Html Msg
viewSubMenuPrivacy isOpen =
    div
        [ class "sub-menu"
        , subMenuOpenClass isOpen
        , onClick ClickMenuClose
        ]
        [ Privacy.viewPrivacy
        ]


viewSubMenuDisclaimer : Bool -> Html Msg
viewSubMenuDisclaimer isOpen =
    div
        [ class "sub-menu"
        , subMenuOpenClass isOpen
        , onClick ClickMenuClose
        ]
        [ div [ class "sub-menu-window" ]
            [ h2 [] [ text "免責事項" ]
            , div [ class "text" ]
                [ p [] [ text "当サイトの情報は、慎重に管理・作成しますが、すべての情報が正確・完全であることは保証しません。そのことをご承知の上、利用者の責任において情報を利用してください。当サイトを利用したことによるいかなる損失について、一切保証しません。" ]
                , p []
                    [ text "また、当サイトは白山市役所が作成したものではありません。"
                    , span [ class "warning" ]
                        [ text "問い合わせ等を白山市にしないようにお願いします。"
                        ]
                    ]
                , p [] [ text "問い合わせはTwitter（@webarata3）もしくは、webmaster at hakusan.appまでお願いします。" ]
                ]
            ]
        ]


viewSubMenuCredit : Bool -> Html Msg
viewSubMenuCredit isOpen =
    div
        [ class "sub-menu"
        , subMenuOpenClass isOpen
        , onClick ClickMenuClose
        ]
        [ div [ class "sub-menu-window credit" ] <|
            List.map viewCredit Credit.getCredits
        ]


viewCredit : Credit.Credit -> Html Msg
viewCredit credit =
    div []
        [ h3 []
            [ a
                [ href credit.link ]
                [ text credit.title ]
            ]
        , div [] [ pre [] [ text credit.license ] ]
        ]
