port module Main exposing (ApiVersionState(..), Area, AreaGarbage, Garbage, LoadLocalStorageValue, MenuState(..), Model, Msg(..), Region, SubMenuType(..), ViewState(..), apiBaseUrl, convertAreaGarbage, convertRegions, copyText, decodeArea, decodeAreaGarbage, decodeAreas, decodeGarbage, decodeGarbages, decodeRegion, decodeRegions, getAreaGarbageWeb, getRegionsWeb, init, loadLocalStorage, localStorageSaved, main, onChange, onClickNoPrevent, retLoadLocalStorage, saveLocalStorage, subMenuOpenClass, subscriptions, update, view, viewArea, viewAreaGarbage, viewGarbage, viewGarbageDates, viewGarbageTitles, viewGarbages, viewHeader, viewLine, viewMain, viewMenu, viewMenuBackground, viewMenuClass, viewRegion, viewSubMenuCredit, viewSubMenuDisclaimer, viewSubMenuPrivacyPolicy)

import Browser
import CommonTime exposing (IntDate)
import CommonUtil
import Footer
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Json.Decode exposing (Decoder, decodeString, field, list, string)
import Task
import Time
import Time.Extra
import TimeZone


port loadLocalStorage : String -> Cmd msg


port retLoadLocalStorage : (LoadLocalStorageValue -> msg) -> Sub msg


port saveLocalStorage : LoadLocalStorageValue -> Cmd msg


port localStorageSaved : (String -> msg) -> Sub msg


port copyText : () -> Cmd msg


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


apiBaseUrl : String
apiBaseUrl =
    "/api"


getRegionsWeb : Cmd Msg
getRegionsWeb =
    Http.get
        { url = apiBaseUrl ++ "/regions.json"
        , expect = Http.expectString GotRegionsWeb
        }


getAreaGarbageWeb : String -> Cmd Msg
getAreaGarbageWeb areaNo =
    Http.get
        { url = apiBaseUrl ++ "/" ++ areaNo ++ ".json"
        , expect = Http.expectString GotAreaGarbageWeb
        }


decodeRegions : Decoder (List Region)
decodeRegions =
    list decodeRegion


decodeRegion : Decoder Region
decodeRegion =
    Json.Decode.map2 Region
        (field "regionName" string)
        (field "areas" decodeAreas)


decodeAreas : Decoder (List Area)
decodeAreas =
    list decodeArea


decodeArea : Decoder Area
decodeArea =
    Json.Decode.map2 Area
        (field "areaNo" string)
        (field "areaName" string)


decodeAreaGarbage : Decoder AreaGarbage
decodeAreaGarbage =
    Json.Decode.map3 AreaGarbage
        (field "areaNo" string)
        (field "areaName" string)
        (field "garbages" decodeGarbages)


decodeGarbages : Decoder (List Garbage)
decodeGarbages =
    list decodeGarbage


decodeGarbage : Decoder Garbage
decodeGarbage =
    Json.Decode.map2 Garbage
        (field "garbageTitles" (list string))
        (field "garbageDates" (list string))


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
            Err (CommonUtil.jsonError error)


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
            Err (CommonUtil.jsonError error)



-- MODEL


type alias Model =
    { viewState : ViewState
    , menuState : MenuState
    , nowOpenSubMenuType : SubMenuType
    , errorMessage : String
    , isVersionChange : Bool
    , time : Time.Posix
    , dispDate : String
    , currentDate : String
    , apiVersion : String
    , areaNo : String
    , regions : List Region
    , areaGarbage : AreaGarbage
    }


type alias LoadLocalStorageValue =
    { key : String
    , value : String
    }


type alias Region =
    { regionName : String
    , areas : List Area
    }


type alias Area =
    { areaNo : String
    , areaName : String
    }


type alias AreaGarbage =
    { areaNo : String
    , areaName : String
    , garbages : List Garbage
    }


type alias Garbage =
    { garbageTitles : List String
    , garbageDates : List String
    }


type Msg
    = DataError String
    | Loading
    | CopyText
    | ClickMenuOpen
    | ClickMenuClose
    | ClickSubMenu SubMenuType
    | SetCurrentDate Time.Posix
    | LoadedLocalStorage LoadLocalStorageValue
    | LocalStorageSaved String
    | GotApiVersionLocal String
    | GotApiVersionWeb (Result Http.Error String)
    | GotRegionsLocal String
    | GotRegionsWeb (Result Http.Error String)
    | GotAreaGarbageLocal String
    | GotAreaGarbageWeb (Result Http.Error String)
    | ChangeArea String
    | ViewAreaGarbage


type ViewState
    = PrepareData
    | SystemError
    | DataOk


type MenuState
    = MenuClose
    | MenuOpen


type ApiVersionState
    = NoChange
    | RequireRegion String
    | GetError String


type SubMenuType
    = NoOpenSubMenu
    | Disclaimer
    | PrivacyPolicy
    | Credit


init : () -> ( Model, Cmd Msg )
init _ =
    ( { viewState = PrepareData
      , menuState = MenuClose
      , nowOpenSubMenuType = NoOpenSubMenu
      , errorMessage = ""
      , isVersionChange = False
      , time = Time.millisToPosix 0
      , dispDate = ""
      , currentDate = ""
      , apiVersion = ""
      , areaNo = ""
      , regions = []
      , areaGarbage = { areaNo = "", areaName = "", garbages = [] }
      }
    , Task.perform SetCurrentDate Time.now
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ retLoadLocalStorage LoadedLocalStorage
        , localStorageSaved LocalStorageSaved
        ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Loading ->
            ( { model | apiVersion = "" }
            , Cmd.none
            )

        DataError errorMessage ->
            ( { model | viewState = SystemError, errorMessage = errorMessage }
            , Cmd.none
            )

        CopyText ->
            ( model, copyText () )

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

                Disclaimer ->
                    ( { model | nowOpenSubMenuType = Disclaimer }, Cmd.none )

                PrivacyPolicy ->
                    ( { model | nowOpenSubMenuType = PrivacyPolicy }, Cmd.none )

                Credit ->
                    ( { model | nowOpenSubMenuType = Credit }, Cmd.none )

        SetCurrentDate time ->
            let
                intDate =
                    CommonTime.posixToIntDate time
            in
            ( { model
                | dispDate = CommonTime.intDateToDispDate intDate
                , currentDate = CommonTime.intDateToYyyymmddDate intDate
              }
            , loadLocalStorage "areaNo"
            )

        LoadedLocalStorage localStorageValue ->
            case Debug.log "分岐" localStorageValue.key of
                "areaNo" ->
                    let
                        areaNo =
                            if localStorageValue.value == "" then
                                "01"

                            else
                                localStorageValue.value
                    in
                    ( { model | areaNo = areaNo }
                    , loadLocalStorage "apiVersion"
                    )

                "apiVersion" ->
                    update
                        (GotApiVersionLocal localStorageValue.value)
                        model

                "regions" ->
                    update
                        (GotRegionsLocal localStorageValue.value)
                        model

                _ ->
                    update
                        (GotAreaGarbageLocal localStorageValue.value)
                        model

        GotApiVersionLocal json ->
            ( { model | apiVersion = json }
            , Http.get
                { url = apiBaseUrl ++ "/version.json"
                , expect = Http.expectString GotApiVersionWeb
                }
            )

        GotApiVersionWeb (Ok resp) ->
            let
                jsonApiVersion =
                    decodeString (field "apiVersion" string) resp

                apiVersionState =
                    Debug.log "apiVersionState"
                        (case jsonApiVersion of
                            Ok webApiVersion ->
                                if model.apiVersion == "" || webApiVersion > model.apiVersion then
                                    RequireRegion webApiVersion

                                else
                                    NoChange

                            Err error ->
                                GetError (CommonUtil.jsonError error)
                        )
            in
            case apiVersionState of
                RequireRegion webApiVersion ->
                    -- バージョンが変わっているので、localStorageにバージョンを保存
                    ( { model
                        | isVersionChange = True
                        , apiVersion = webApiVersion
                        , viewState = DataOk
                      }
                    , saveLocalStorage
                        { key = "apiVersion"
                        , value = webApiVersion
                        }
                    )

                NoChange ->
                    -- バージョンが変わっていないのでlocalStorageを使う
                    ( model, loadLocalStorage "regions" )

                GetError errorMessage ->
                    update (DataError errorMessage) model

        LocalStorageSaved key ->
            case key of
                "apiVersion" ->
                    ( model, loadLocalStorage "regions" )

                "regions" ->
                    update (ChangeArea model.areaNo) model

                "areaNo" ->
                    update ViewAreaGarbage model

                _ ->
                    if String.startsWith "areaGarbage-" key then
                        ( model, Cmd.none )

                    else
                        ( model, Cmd.none )

        GotApiVersionWeb (Err error) ->
            -- Webから取れず、localStorageにもなければエラー
            if model.apiVersion == "" then
                update (DataError (CommonUtil.httpError "[API VERSION]" error)) model

            else
                -- localStorageにデータがあればそれを使う
                update (GotRegionsLocal "regions") model

        -- 以前データを取得していてバージョンが変わっていない場合には
        -- localStorageから取得する
        GotRegionsLocal jsonRegions ->
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
                    , saveLocalStorage
                        { key = "regions"
                        , value = resp
                        }
                    )

                Err error ->
                    update (DataError error) model

        GotRegionsWeb (Err error) ->
            update (DataError (CommonUtil.httpError "[REGIONS]" error)) model

        GotAreaGarbageWeb (Ok resp) ->
            let
                areaGarbageResult =
                    convertAreaGarbage resp
            in
            case areaGarbageResult of
                Ok areaGarbage ->
                    ( { model
                        | areaGarbage = areaGarbage
                      }
                    , saveLocalStorage
                        { key = "areaGarbage-" ++ model.areaNo
                        , value = resp
                        }
                    )

                Err error ->
                    update (DataError error) model

        GotAreaGarbageWeb (Err error) ->
            update (DataError (CommonUtil.httpError "[AREA GARBAGE]" error)) model

        GotAreaGarbageLocal jsonAreaGarbage ->
            let
                areaGarbageResult =
                    convertAreaGarbage jsonAreaGarbage
            in
            case areaGarbageResult of
                Ok areaGarbage ->
                    ( { model
                        | areaGarbage = areaGarbage
                      }
                    , Cmd.none
                    )

                -- localStorageにデータがなければWebから取得する
                Err error ->
                    ( model, getAreaGarbageWeb model.areaNo )

        ChangeArea areaNo ->
            -- エリアが変わったら最初にareaNoを保存する
            ( { model | areaNo = areaNo }
            , saveLocalStorage { key = "areaNo", value = areaNo }
            )

        ViewAreaGarbage ->
            if model.isVersionChange then
                -- バージョンが変わっていたらWebから取得する
                ( model, getAreaGarbageWeb model.areaNo )

            else
                -- バージョンが変わっていなければlocalStorageから取得する
                ( model, loadLocalStorage model.areaNo )



-- VIEW


view : Model -> Html Msg
view model =
    article [ id "app" ]
        [ viewHeader
        , viewMain model
        , Footer.viewFooter
        , viewMenuBackground model
        , viewMenu model
        , viewSubMenuDisclaimer (model.nowOpenSubMenuType == Disclaimer)
        , viewSubMenuCredit (model.nowOpenSubMenuType == Credit)
        , viewSubMenuPrivacyPolicy (model.nowOpenSubMenuType == PrivacyPolicy)
        ]


viewHeader : Html Msg
viewHeader =
    Html.header []
        [ div
            [ class "menu-button"
            , onClick ClickMenuOpen
            ]
            [ button [ class "header-button" ] [] ]
        , h1 [ class "header-title" ] [ text "白山市ごみ収集日程" ]
        , div [ class "nothing" ] []
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
        [ ul []
            [ li []
                [ a [ href "how-to-use/" ] [ text "使い方" ] ]
            , li []
                [ a
                    [ href "#", onClickNoPrevent (ClickSubMenu Disclaimer) ]
                    [ text "免責事項" ]
                ]
            , li []
                [ a
                    [ href "#", onClickNoPrevent (ClickSubMenu PrivacyPolicy) ]
                    [ text "プライバシーポリシー" ]
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


subMenuOpenClass : Bool -> Html.Attribute Msg
subMenuOpenClass isOpen =
    if isOpen then
        class "sub-menu-open"

    else
        class "sub-menu-close"


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
                , div [ id "reason", class "message" ] [ text ("理由: " ++ model.errorMessage) ]
                , button [ id "errorMessageButton", onClick CopyText ]
                    [ text "メッセージをコピー" ]
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
                    , a
                        [ href "http://www.city.hakusan.ishikawa.jp/shiminseikatsubu/kankyo/4r/gomi_chikunokensaku.html" ]
                        [ text "地域が不明な方はこちらで確認してください" ]
                    ]
                , viewAreaGarbage model.currentDate model.areaGarbage
                ]


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
    let
        t =
            Debug.log "1" areaGarbage.areaNo
    in
    viewGarbages currentDate areaGarbage.garbages


viewGarbages : String -> List Garbage -> Html Msg
viewGarbages currentDate garbages =
    let
        t =
            Debug.log "2" garbages

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
            CommonUtil.nextDate currentDate garbageDates

        howManyDays =
            CommonTime.diffDayYyyymmddDate currentDate nextGarbageDate

        dispDays =
            CommonUtil.dispHowManyDays
                (CommonTime.diffDayYyyymmddDate
                    currentDate
                    nextGarbageDate
                )
    in
    div [ class (CommonUtil.howManyDaysCss howManyDays) ]
        [ div [ class "garbage-how-many-days" ] [ text dispDays ]
        , div [ class "garbage-next-date" ]
            [ text (CommonTime.yyyymmddDateToDispDate nextGarbageDate)
            ]
        ]


viewLine : String -> Html Msg
viewLine value =
    div [] [ text value ]


onChange : (String -> Msg) -> Attribute Msg
onChange handler =
    on "change" (Json.Decode.map handler Html.Events.targetValue)


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


viewSubMenuPrivacyPolicy : Bool -> Html Msg
viewSubMenuPrivacyPolicy isOpen =
    div
        [ class "sub-menu"
        , subMenuOpenClass isOpen
        , onClick ClickMenuClose
        ]
        [ div [ class "sub-menu-window" ]
            [ h2 []
                [ text "プライバシーポリシー" ]
            , div [ class "text" ]
                [ h3 []
                    [ text "当サイトが使用しているアクセス解析ツールについて" ]
                , p []
                    [ text "当サイトでは、Googleによるアクセス解析ツール"
                    , a [ href "https://analytics.google.com/analytics/start" ]
                        [ text "Googleアナリティクス" ]
                    , text "を利用しています。"
                    ]
                , p [] [ text """このGoogleアナリティクスはトラフィックデータの収集のためにCookieを使用しています。
このトラフィックデータは匿名で収集されており、個人を特定するものではありません。
この機能はCookieを無効にすることで収集を拒否することが出来ますので、お使いのブラウザの設定をご確認ください。""" ]
                , p []
                    [ a [ href "https://www.google.com/analytics/terms/jp.html" ]
                        [ text "この規約に関して、詳しくはこちらの利用規約" ]
                    , text "、または"
                    , a
                        [ href "https://policies.google.com/technologies/partner-sites?hl=ja" ]
                        [ text "こちらのGoogle ポリシーと規約をクリック" ]
                    , text "してください。"
                    ]
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
        [ div [ class "sub-menu-window credit" ]
            [ h2 [] [ text "クレジット" ]
            , div []
                [ h3 []
                    [ a [ href "https://github.com/elm/compiler" ] [ text "Elm Compiler" ]
                    ]
                , div []
                    [ pre [] [ text """Copyright (c) 2012-present, Evan Czaplicki

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.

    * Neither the name of Evan Czaplicki nor the names of other
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.""" ]
                    ]
                ]
            , div []
                [ h3 []
                    [ a [ href "https://github.com/justinmimbs/time-extra" ] [ text "justinmimbs/time-extra" ]
                    ]
                , div []
                    [ pre [] [ text """BSD 3-Clause

Copyright (c) 2018, Justin Mimbs. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.""" ]
                    ]
                ]
            , div []
                [ h3 []
                    [ a
                        [ href "https://github.com/justinmimbs/timezone-data" ]
                        [ text "justinmimbs/time-zone-data" ]
                    ]
                , div []
                    [ pre [] [ text """BSD 3-Clause

Copyright (c) 2018, Justin Mimbs. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.""" ]
                    ]
                ]
            ]
        ]
