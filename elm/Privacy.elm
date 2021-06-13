module Privacy exposing (viewPrivacy)

import Html exposing (Html, a, div, h2, p, span, text)
import Html.Attributes exposing (class, href, target)


viewPrivacy : Html msg
viewPrivacy =
    div [ class "submenu__window" ]
        [ h2 [] [ text "プライバシーポリシー" ]
        , div [ class "text" ]
            [ p [] [ text "当サイトでは、Googleによるアクセス解析ツール「Googleアナリティクス」を使用しています。このGoogleアナリティクスはデータの収集のためにCookieを使用しています。このデータは匿名で収集されており、個人を特定するものではありません。" ]
            , p []
                [ span [] [ text "この機能はCookieを無効にすることで収集を拒否することが出来ますので、お使いのブラウザの設定をご確認ください。この規約に関しての詳細は" ]
                , a
                    [ href "https://marketingplatform.google.com/about/analytics/terms/jp/"
                    , target "_blank"
                    ]
                    [ text "Googleアナリティクスサービス利用規約のページ" ]
                , span [] [ text "や" ]
                , a
                    [ href "https://policies.google.com/technologies/ads?hl=ja"
                    , target "_blank"
                    ]
                    [ text "Googleポリシーと規約ページ" ]
                , span [] [ text "をご覧ください。" ]
                ]
            ]
        ]
