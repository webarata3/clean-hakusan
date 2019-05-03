port module Main exposing (apiBaseUrl, decodeArea, decodeAreaGarbage, decodeAreas, decodeGarbage, decodeGarbages, decodeRegion, decodeRegions, getAreaGarbage, getRegions, getWebJsonAreaGarbage, getWebJsonRegions, init, loadLocalStorage, localStorageSaved, main, retLoadLocalStorage, saveLocalStorage, subscriptions, update)

import AppModel exposing (..)
import AppView exposing (..)
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
