module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { input : String
    , memos : List String
    }


init : Model
init =
    { input = "", memos = [] }



-- UPDATE


type Msg
    = Input String -- String はユーザー入力した文字列
    | Submit


update : Msg -> Model -> Model
update msg model =
    case msg of
        Input input ->
            -- 入力文字列を更新する
            { model | input = input }

        Submit ->
            { model
              -- 入力文字列をリセットする
                | input = ""

                -- 最新のメモを追加する
                , memos = model.input :: model.memos
            }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ Html.form [ onSubmit Submit ]
            [ input [ value model.input, onInput Input ] []
            , button [ disabled (String.length model.input < 1) ] [ text "Submit" ]
            ]
        , ul [] (List.map viewMemo model.memos)
        ]


viewMemo : String -> Html Msg
viewMemo memo =
    li [] [ text memo ]
