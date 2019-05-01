module CommonUtil exposing (dispHowManyDays, howManyDaysCss, nextDate)

import CommonTime exposing (YyyymmddDate)


nextDate : YyyymmddDate -> List YyyymmddDate -> String
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
            "garbage-schedule today"

        1 ->
            "garbage-schedule tomorrow"

        2 ->
            "garbage-schedule day-after-tomorrow"

        _ ->
            "garbage-schedule"
