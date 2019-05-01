module CommonTime exposing (numberToMonth, toMonthNumber)

import Time


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
