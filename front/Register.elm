port module Main exposing (main)

import Browser
import Browser.Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Task


type alias Model =
    ()


initialModel : Model
initialModel =
    ()


type Msg
    = NoOp


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    Html.form [ action "/register", method "POST" ]
        [ label []
            [ text "Email: "
            , input [ name "email", type_ "email" ]
                []
            ]
        , label []
            [ text "Name: "
            , input [ name "name", type_ "text" ]
                []
            ]
        , label []
            [ text "Password: "
            , input [ name "password1", type_ "password" ]
                []
            ]
        , label []
            [ text "Repeat: "
            , input [ name "password2", type_ "password" ]
                []
            ]
        , input [ name "", type_ "submit", value "Send" ]
            []
        , text ""
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = \() -> ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
