module AppView exposing (onChange, view, viewArea, viewAreaGarbage, viewFooter, viewGarbage, viewGarbageDates, viewGarbageTitles, viewGarbages, viewHeader, viewLine, viewMain, viewRegion)

import AppModel exposing (..)
import CommonTime exposing (..)
import CommonUtil
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode


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
        , div [ class "menu" ] [ button [ class "header-button" ] [] ]
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
