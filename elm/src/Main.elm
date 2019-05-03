port module Main exposing (ApiVersionState(..), Area, AreaGarbage, Garbage, LoadLocalStorageValue, Model, Msg(..), Region, ViewState(..), apiBaseUrl, decodeArea, decodeAreaGarbage, decodeAreas, decodeGarbage, decodeGarbages, decodeRegion, decodeRegions, getAreaGarbage, getRegions, getWebJsonAreaGarbage, getWebJsonRegions, init, loadLocalStorage, localStorageSaved, main, onChange, retLoadLocalStorage, saveLocalStorage, subscriptions, update, view, viewArea, viewAreaGarbage, viewGarbage, viewGarbageDates, viewGarbageTitles, viewGarbages, viewLine, viewMain, viewRegion)

import Browser
import CommonTime exposing (DispDate, IntDate, YyyymmddDate)
import CommonUtil
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


getWebJsonRegions : Cmd Msg
getWebJsonRegions =
    Http.get
        { url = apiBaseUrl ++ "/regions.json"
        , expect = Http.expectString GotWebRegions
        }


getWebJsonAreaGarbage : String -> Cmd Msg
getWebJsonAreaGarbage areaNo =
    Http.get
        { url = apiBaseUrl ++ "/" ++ areaNo ++ ".json"
        , expect = Http.expectString GotWebAreaGarbage
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


getRegions : String -> Result String (List Region)
getRegions regionJson =
    let
        regionsResult =
            decodeString (field "regions" decodeRegions) regionJson
    in
    case regionsResult of
        Ok resultJson ->
            Ok resultJson

        Err error ->
            Err (CommonUtil.jsonError error)


getAreaGarbage : String -> Result String AreaGarbage
getAreaGarbage areaGarbageJson =
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
    , errorMessage : String
    , isVersionChange : Bool
    , time : Time.Posix
    , dispDate : DispDate
    , currentDate : YyyymmddDate
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
    , garbageDates : List YyyymmddDate
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { viewState = PrepareData
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


type Msg
    = DataError String
    | Loading
    | SetCurrentDate Time.Posix
    | LoadedLocalStorage LoadLocalStorageValue
    | LocalStorageSaved String
    | GotSavedApiVersion String
    | GotWebApiVersion (Result Http.Error String)
    | GotSavedRegions String
    | GotWebRegions (Result Http.Error String)
    | GotSavedAreaGarbage String
    | GotWebAreaGarbage (Result Http.Error String)
    | ChangeArea String
    | ViewAreaGarbage


type ViewState
    = PrepareData
    | SystemError
    | DataOk


type ApiVersionState
    = NoChange
    | RequireRegion String
    | GetError String


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
                        (GotSavedApiVersion localStorageValue.value)
                        model

                "regions" ->
                    update
                        (GotSavedRegions localStorageValue.value)
                        model

                _ ->
                    update
                        (GotSavedAreaGarbage localStorageValue.value)
                        model

        GotSavedApiVersion json ->
            ( { model | apiVersion = json }
            , Http.get
                { url = apiBaseUrl ++ "/version.json"
                , expect = Http.expectString GotWebApiVersion
                }
            )

        GotWebApiVersion (Ok resp) ->
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
                    ( model, Cmd.none )

                "regions" ->
                    update (ChangeArea model.areaNo) model

                "areaNo" ->
                    update ViewAreaGarbage model

                _ ->
                    if String.startsWith "areaGarbage-" key then
                        ( model, Cmd.none )

                    else
                        ( model, Cmd.none )

        GotWebApiVersion (Err error) ->
            -- Webから取れず、localStorageにもなければエラー
            if model.apiVersion == "" then
                update (DataError (CommonUtil.httpError error)) model

            else
                -- localStorageにデータがあればそれを使う
                update (GotSavedRegions "regions") model

        -- 以前データを取得していてバージョンが変わっていない場合には
        -- localStorageから取得する
        GotSavedRegions jsonRegions ->
            let
                regionsResult =
                    getRegions jsonRegions
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
                    ( model, getWebJsonRegions )

        GotWebRegions (Ok resp) ->
            let
                regionsResult =
                    getRegions resp
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

        GotWebRegions (Err error) ->
            update (DataError (CommonUtil.httpError error)) model

        GotWebAreaGarbage (Ok resp) ->
            let
                areaGarbageResult =
                    getAreaGarbage resp
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

        GotWebAreaGarbage (Err error) ->
            update (DataError (CommonUtil.httpError error)) model

        GotSavedAreaGarbage jsonAreaGarbage ->
            let
                areaGarbageResult =
                    getAreaGarbage jsonAreaGarbage
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
                    ( model, getWebJsonAreaGarbage model.areaNo )

        ChangeArea areaNo ->
            -- エリアが変わったら最初にareaNoを保存する
            ( { model | areaNo = areaNo }
            , saveLocalStorage { key = "areaNo", value = areaNo }
            )

        ViewAreaGarbage ->
            if model.isVersionChange then
                -- バージョンが変わっていたらWebから取得する
                ( model, getWebJsonAreaGarbage model.areaNo )

            else
                -- バージョンが変わっていなければlocalStorageから取得する
                ( model, loadLocalStorage model.areaNo )



-- VIEW


view : Model -> Html Msg
view model =
    article [ id "app" ]
        [ viewHeader
        , viewMain model
        , viewFooter
        ]


viewHeader : Html Msg
viewHeader =
    Html.header []
        [ h1 [ class "header-title" ] [ text "白山市ごみ収集日程" ]
        , div [ class "menu" ] [ button [ class "" ] [] ]
        ]


viewFooter : Html Msg
viewFooter =
    footer []
        [ div [ class "copyright" ]
            [ text "©2019 "
            , a [ href "https://webarata3.link" ] [ text "Shinichi ARATA（webarata3）" ]
            ]
        , div [ class "sns" ]
            [ ul []
                [ li []
                    [ a [ href "https://twitter.com/webarata3" ]
                        [ span [ class "fab fa-twitter" ] [] ]
                    ]
                , li []
                    [ a [ href "https://facebook.com/arata.shinichi" ]
                        [ span [ class "fab fa-facebook" ] [] ]
                    ]
                , li []
                    [ a [ href "https://github.com/webarata3" ]
                        [ span [ class "fab fa-github" ] [] ]
                    ]
                , li []
                    [ a [ href "https://ja.stackoverflow.com/users/2214/webarata3?tab=profile" ]
                        [ span [ class "fab fa-stack-overflow" ] [] ]
                    ]
                ]
            ]
        ]


viewMain : Model -> Html Msg
viewMain model =
    let
        handler selectedValue =
            ChangeArea selectedValue
    in
    case model.viewState of
        SystemError ->
            div [] [ text model.errorMessage ]

        PrepareData ->
            div []
                [ div [] [ text "準備中" ]
                , img [ class "loading-icon", src "image/ball-triangle.svg" ] []
                ]

        DataOk ->
            main_ []
                [ div [] [ text model.apiVersion ]
                , div [ class "alert" ] [ text "※ 白山市公式のアプリではありません。" ]
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


viewAreaGarbage : YyyymmddDate -> AreaGarbage -> Html Msg
viewAreaGarbage currentDate areaGarbage =
    let
        t =
            Debug.log "1" areaGarbage.areaNo
    in
    viewGarbages currentDate areaGarbage.garbages


viewGarbages : YyyymmddDate -> List Garbage -> Html Msg
viewGarbages currentDate garbages =
    let
        t =
            Debug.log "2" garbages

        viewGarbage2 =
            viewGarbage currentDate
    in
    div [ class "garbages" ] (List.map viewGarbage2 garbages)


viewGarbage : YyyymmddDate -> Garbage -> Html Msg
viewGarbage currentDate garbage =
    div [ class "garbage-item" ]
        [ viewGarbageTitles garbage.garbageTitles
        , viewGarbageDates currentDate garbage.garbageDates
        ]


viewGarbageTitles : List String -> Html Msg
viewGarbageTitles garbageTitles =
    div [ class "garbage-title" ] (List.map viewLine garbageTitles)


viewGarbageDates : YyyymmddDate -> List YyyymmddDate -> Html Msg
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


onChange : (String -> msg) -> Attribute msg
onChange handler =
    on "change" (Json.Decode.map handler Html.Events.targetValue)
