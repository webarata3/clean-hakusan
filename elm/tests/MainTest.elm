module MainTest exposing (suite)

import Expect exposing (..)
import Main exposing (..)
import Test exposing (..)


suite : Test
suite =
    describe "The String module"
        [ describe "String.reverse"
            [ test "has no effect on a palindrome" <|
                \_ ->
                    let
                        palindrome =
                            "hannah"
                    in
                    Expect.equal "/api" apiBaseUrl
            ]
        ]
