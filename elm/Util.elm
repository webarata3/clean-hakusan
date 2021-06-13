module Util exposing (dispHowManyDays, howManyDaysCss, httpError, jsonError, nextDate)

import Http
import Json.Decode


nextDate : String -> List String -> String
nextDate currentDate garbageDates =
    case List.head (List.filter (\d -> d >= currentDate) garbageDates) of
        Just date ->
            date

        Nothing ->
            ""


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
            "garbage__schedule garbage__today"

        1 ->
            "garbage__schedule garbage__tomorrow"

        2 ->
            "garbage__schedule garbage__day-after-tomorrow"

        _ ->
            "garbage__schedule"


jsonError : Json.Decode.Error -> String
jsonError error =
    "Json Error"


httpError : String -> Http.Error -> String
httpError url error =
    case error of
        Http.BadUrl message ->
            url ++ " " ++ message

        Http.Timeout ->
            url ++ " " ++ "サーバから応答がない"

        Http.NetworkError ->
            url ++ " " ++ "ネットワークにつながらない"

        Http.BadStatus statusCode ->
            url ++ " " ++ "ステータスコード" ++ String.fromInt statusCode

        Http.BadBody message ->
            url ++ " " ++ message
