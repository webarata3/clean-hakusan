module View.Footer exposing (viewFooter)

import Html exposing (..)
import Html.Attributes exposing (..)


viewFooter : Html msg
viewFooter =
    footer []
        [ div [ class "copyright" ]
            [ text "©2019 "
            , a
                [ href "https://webarata3.dev"
                , target "_blank"
                ]
                [ text "Shinichi ARATA（webarata3）" ]
            ]
        , div [ class "sns" ]
            [ ul []
                [ li []
                    [ a
                        [ href "https://twitter.com/webarata3"
                        , target "_blank"
                        ]
                        [ span [ class "fab fa-twitter" ] [] ]
                    ]
                , li []
                    [ a
                        [ href "https://facebook.com/arata.shinichi"
                        , target "_blank"
                        ]
                        [ span [ class "fab fa-facebook" ] [] ]
                    ]
                , li []
                    [ a
                        [ href "https://github.com/webarata3"
                        , target "_blank"
                        ]
                        [ span [ class "fab fa-github" ] [] ]
                    ]
                , li []
                    [ a
                        [ href "https://ja.stackoverflow.com/users/2214/webarata3?tab=profile"
                        , target "_blank"
                        ]
                        [ span [ class "fab fa-stack-overflow" ] [] ]
                    ]
                ]
            ]
        ]
