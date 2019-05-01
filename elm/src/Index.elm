module Main exposing (Area, AreaGarbage, Garbage, Model, Msg(..), Region, decodeArea, decodeAreaGarbage, decodeAreas, decodeGarbage, decodeGarbages, decodeRegion, decodeRegions, getAreaGarbage, getRegions, httpErr, init, main, onChange, update, view, viewArea, viewAreaGarbage, viewGarbage, viewGarbageDates, viewGarbageTitles, viewGarbages, viewLine, viewRegion)

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


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


getRegions : () -> Cmd Msg
getRegions _ =
    Http.get
        { url = "/src/api/areas.json"
        , expect = Http.expectString GotRegions
        }


getAreaGarbage : String -> Cmd Msg
getAreaGarbage areaNo =
    Http.get
        { url = "/src/api/" ++ areaNo ++ ".json"
        , expect = Http.expectString GotAreaGarbage
        }


httpErr : Error -> String
httpErr error =
    Debug.toString error


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



-- MODEL


type alias Model =
    { time : Time.Posix
    , dispDate : DispDate
    , currentDate : YyyymmddDate
    , apiVersion : String
    , areaNo : String
    , regions : List Region
    , areaGarbage : AreaGarbage
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
    ( { time = Time.millisToPosix 0
      , dispDate = ""
      , currentDate = ""
      , apiVersion = ""
      , areaNo = ""
      , regions = []
      , areaGarbage = { areaNo = "", areaName = "", garbages = [] }
      }
    , Http.get
        { url = "/src/api/version.json"
        , expect = Http.expectString GotApiVersion
        }
    )



-- UPDATE


type Msg
    = LoadingArea
    | SetCurrentDate Time.Posix
    | GotApiVersion (Result Http.Error String)
    | GotRegions (Result Http.Error String)
    | GotAreaGarbage (Result Http.Error String)
    | ChangeArea String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadingArea ->
            ( { model | apiVersion = "" }
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
            , Cmd.none
            )

        GotApiVersion (Ok resp) ->
            let
                result =
                    decodeString (field "apiVersion" string) resp

                apiVersion =
                    case result of
                        Ok version ->
                            version

                        Err _ ->
                            "error"
            in
            ( { model | apiVersion = apiVersion }
            , getRegions ()
            )

        GotApiVersion (Err message) ->
            ( { model | apiVersion = Debug.toString message }
            , Cmd.none
            )

        GotRegions (Ok resp) ->
            let
                regionResult =
                    decodeString (field "regions" decodeRegions) resp

                regions =
                    case regionResult of
                        Ok result ->
                            result

                        Err message ->
                            [ { regionName = Debug.toString message, areas = [] } ]
            in
            ( { model | regions = regions }
              -- , Cmd.none
            , Task.perform SetCurrentDate Time.now
            )

        GotRegions (Err message) ->
            ( { model | apiVersion = httpErr message }
            , Cmd.none
            )

        GotAreaGarbage (Ok resp) ->
            let
                areaGarbageResult =
                    decodeString decodeAreaGarbage resp

                areaGarbage =
                    case areaGarbageResult of
                        Ok result ->
                            result

                        Err message ->
                            let
                                t =
                                    Debug.log "" message
                            in
                            { areaNo = "", areaName = "", garbages = [] }
            in
            ( { model | areaGarbage = areaGarbage }
            , Cmd.none
            )

        GotAreaGarbage (Err message) ->
            ( { model | apiVersion = httpErr message }
            , Cmd.none
            )

        ChangeArea areaNo ->
            ( { model | areaNo = areaNo }, getAreaGarbage areaNo )



-- VIEW


view : Model -> Html Msg
view model =
    let
        handler selectedValue =
            ChangeArea selectedValue
    in
    article [ id "app" ]
        [ Html.header []
            [ h1 [ class "header-title" ] [ text "白山市ごみ収集日程" ]
            , div [ class "menu" ] [ button [ class "" ] [] ]
            ]
        , main_ []
            [ div [ class "alert" ] [ text "※ 白山市公式のアプリではありません。" ]
            , div [ class "area" ]
                [ div [ class "select-area" ]
                    [ label
                        [ for "area" ]
                        [ text "地域" ]
                    , select [ id "area", onChange handler ]
                        (List.map viewRegion model.regions)
                    ]
                , a
                    [ href "http://www.city.hakusan.ishikawa.jp/shiminseikatsubu/kankyo/4r/gomi_chikunokensaku.html" ]
                    [ text "地域が不明な方はこちらで確認してください" ]
                ]
            , viewAreaGarbage model.currentDate model.areaGarbage
            ]
        ]


viewRegion : Region -> Html Msg
viewRegion region =
    optgroup
        [ attribute "label" region.regionName ]
        (List.map viewArea region.areas)


viewArea : Area -> Html Msg
viewArea area =
    option [ value area.areaNo ] [ text area.areaName ]


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
