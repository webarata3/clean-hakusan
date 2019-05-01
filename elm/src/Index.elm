module Main exposing (Area, AreaGarbage, Garbage, IntDate, Model, Msg(..), Region, decodeArea, decodeAreaGarbage, decodeAreas, decodeGarbage, decodeGarbages, decodeRegion, decodeRegions, diffStringDay, dispHowManyDays, getAreaGarbage, getRegions, httpErr, init, intDateToJapaneseDate, intDateToPosix, main, nextDate, numberToMonth, onChange, sliceToInt, stringToIntDate, stringToJapaneseDate, toMonthNumber, update, view, viewArea, viewAreaGarbage, viewGarbage, viewGarbageDates, viewGarbageTitles, viewGarbages, viewLine, viewRegion)

import Browser
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


toMonthNumber : Time.Month -> Int
toMonthNumber month =
    case month of
        Time.Jan ->
            1

        Time.Feb ->
            2

        Time.Mar ->
            3

        Time.Apr ->
            4

        Time.May ->
            5

        Time.Jun ->
            6

        Time.Jul ->
            7

        Time.Aug ->
            8

        Time.Sep ->
            9

        Time.Oct ->
            10

        Time.Nov ->
            11

        Time.Dec ->
            12


numberToMonth : Int -> Time.Month
numberToMonth month =
    case month of
        1 ->
            Time.Jan

        2 ->
            Time.Feb

        3 ->
            Time.Mar

        4 ->
            Time.Apr

        5 ->
            Time.May

        6 ->
            Time.Jun

        7 ->
            Time.Jul

        8 ->
            Time.Aug

        9 ->
            Time.Sep

        10 ->
            Time.Oct

        11 ->
            Time.Nov

        12 ->
            Time.Dec

        _ ->
            Time.Dec


nextDate : String -> List String -> String
nextDate currentDate garbageDates =
    case List.head (List.filter (\d -> d >= currentDate) garbageDates) of
        Just date ->
            date

        Nothing ->
            ""


stringToIntDate : String -> IntDate
stringToIntDate dateString =
    let
        sliceToInt2 =
            sliceToInt dateString
    in
    { year = sliceToInt2 0 4
    , month = sliceToInt2 4 6
    , day = sliceToInt2 6 8
    }


intDateToJapaneseDate : IntDate -> String
intDateToJapaneseDate intDate =
    String.fromInt intDate.year
        ++ "年"
        ++ String.fromInt intDate.month
        ++ "月"
        ++ String.fromInt intDate.day
        ++ "日"


stringToJapaneseDate : String -> String
stringToJapaneseDate dateString =
    intDateToJapaneseDate (stringToIntDate dateString)


sliceToInt : String -> Int -> Int -> Int
sliceToInt dateString begin end =
    case String.toInt (String.slice begin end dateString) of
        Just value ->
            value

        Nothing ->
            0


diffStringDay : String -> String -> Int
diffStringDay dateString1 dateString2 =
    let
        intDate1 =
            stringToIntDate dateString1

        intDate2 =
            stringToIntDate dateString2
    in
    Time.Extra.diff Time.Extra.Day
        Time.utc
        (intDateToPosix intDate1)
        (intDateToPosix intDate2)


intDateToPosix : IntDate -> Time.Posix
intDateToPosix intDate =
    Time.Extra.partsToPosix
        Time.utc
        (Time.Extra.Parts
            intDate.year
            (numberToMonth intDate.month)
            intDate.day
            0
            0
            0
            0
        )


dispHowManyDays : Int -> String
dispHowManyDays howManyDays =
    case howManyDays of
        0 ->
            "今日"

        1 ->
            "明日"

        2 ->
            "明後日"

        _ ->
            String.fromInt howManyDays ++ "日後"


howManyDaysCss : Int -> String
howManyDaysCss howManyDays =
    case howManyDays of
        0 ->
            "garbage-schedule today"

        1 ->
            "garbage-schedule tomorrow"

        2 ->
            "garbage-schedule day-after-tomorrow"

        _ ->
            "garbage-schedule"



-- MODEL


type alias Model =
    { time : Time.Posix
    , dispDate : String
    , currentDate : String
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
    , garbageDates : List String
    }


type alias IntDate =
    { year : Int
    , month : Int
    , day : Int
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
                year =
                    String.fromInt (Time.toYear (TimeZone.asia__tokyo ()) time)

                month =
                    String.fromInt
                        (toMonthNumber
                            (Time.toMonth (TimeZone.asia__tokyo ()) time)
                        )

                day =
                    String.fromInt (Time.toDay (TimeZone.asia__tokyo ()) time)
            in
            ( { model
                | dispDate = year ++ "年" ++ month ++ "月" ++ day ++ "日"
                , currentDate = year ++ String.padLeft 2 '0' month ++ String.padLeft 2 '0' day
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
            nextDate currentDate garbageDates

        howManyDays =
            diffStringDay currentDate nextGarbageDate

        dispDays =
            dispHowManyDays (diffStringDay currentDate nextGarbageDate)
    in
    div [ class (howManyDaysCss howManyDays) ]
        [ div [ class "garbage-how-many-days" ] [ text dispDays ]
        , div [ class "garbage-next-date" ] [ text (stringToJapaneseDate nextGarbageDate) ]
        ]


viewLine : String -> Html Msg
viewLine value =
    div [] [ text value ]


onChange : (String -> msg) -> Attribute msg
onChange handler =
    on "change" (Json.Decode.map handler Html.Events.targetValue)
