module CommonTime exposing (DispDate, IntDate, YyyymmddDate, diffDayYyyymmddDate, intDateToDispDate, intDateToPosix, intDateToYyyymmddDate, numberToMonth, posixToIntDate, sliceToInt, toMonthNumber, yyyymmddDateToDispDate, yyyymmddDateToIntDate)

import Time
import Time.Extra
import TimeZone


type alias YyyymmddDate =
    String


type alias DispDate =
    String


type alias IntDate =
    { year : Int
    , month : Int
    , day : Int
    }


{-| Time.Monthで定義されている月を数字の月に置き換える

    toMonthNumber Time.Jan == 1

-}
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


{-| 数字の月をTime.Monthで定義されている月に置き換える
TODO 1〜12以外の数字の場合にはどうするか。。。

    numberToMonth 1 == Time.Jan

-}
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


posixToIntDate : Time.Posix -> IntDate
posixToIntDate time =
    let
        year =
            Time.toYear (TimeZone.asia__tokyo ()) time

        month =
            toMonthNumber
                (Time.toMonth (TimeZone.asia__tokyo ()) time)

        day =
            Time.toDay (TimeZone.asia__tokyo ()) time
    in
    { year = year
    , month = month
    , day = day
    }


intDateToYyyymmddDate : IntDate -> YyyymmddDate
intDateToYyyymmddDate intDate =
    let
        stringYear =
            String.fromInt intDate.year

        stringMonth =
            String.fromInt intDate.month |> String.padLeft 2 '0'

        stringDay =
            String.fromInt intDate.day |> String.padLeft 2 '0'
    in
    stringYear ++ stringMonth ++ stringDay


intDateToDispDate : IntDate -> DispDate
intDateToDispDate intDate =
    String.fromInt intDate.year
        ++ "年"
        ++ String.fromInt intDate.month
        ++ "月"
        ++ String.fromInt intDate.day
        ++ "日"
        ++ "("
        ++ intDateToDayOfWeek intDate
        ++ ")"


yyyymmddDateToDispDate : YyyymmddDate -> DispDate
yyyymmddDateToDispDate yyyymmddDate =
    intDateToDispDate (yyyymmddDateToIntDate yyyymmddDate)


yyyymmddDateToIntDate : YyyymmddDate -> IntDate
yyyymmddDateToIntDate yyyymmddDate =
    let
        sliceToInt2 =
            sliceToInt yyyymmddDate
    in
    { year = sliceToInt2 0 4
    , month = sliceToInt2 4 6
    , day = sliceToInt2 6 8
    }


sliceToInt : String -> Int -> Int -> Int
sliceToInt dateString begin end =
    case String.toInt (String.slice begin end dateString) of
        Just value ->
            value

        Nothing ->
            0


diffDayYyyymmddDate : YyyymmddDate -> YyyymmddDate -> Int
diffDayYyyymmddDate yyyymmddDate1 yyyymmddDate2 =
    let
        intDate1 =
            yyyymmddDateToIntDate yyyymmddDate1

        intDate2 =
            yyyymmddDateToIntDate yyyymmddDate2
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


intDateToDayOfWeek : IntDate -> String
intDateToDayOfWeek intDate =
    let
        y =
            intDate.year

        m =
            intDate.month

        d =
            intDate.day

        days =
            365 * y + y // 4 - y // 100 + y // 400 + 306 * (m + 1) // 10 + d - 428

        dayOfWeek =
            remainderBy 7 days
    in
    case dayOfWeek of
        0 ->
            "日"

        1 ->
            "月"

        2 ->
            "火"

        3 ->
            "水"

        4 ->
            "木"

        5 ->
            "金"

        6 ->
            "土"

        _ ->
            "？"
