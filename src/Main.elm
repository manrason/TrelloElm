port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events exposing (onClick, onInput, onSubmit)


port receiveDream : String -> Cmd msg


port sendDream : (String -> msg) -> Sub msg


type alias Model =
    { dreams : List String, currentDream : String }


initialModel : Model
initialModel =
    { dreams = [], currentDream = "" }


type Msg
    = NewMessage String
    | UpdateMessage String
    | SubmitCurrentMessage


subscriptions : Model -> Sub Msg
subscriptions _ =
    sendDream NewMessage


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewMessage newMsg ->
            ( { model | dreams = newMsg :: model.dreams }, Cmd.none )

        UpdateMessage s ->
            ( { model | currentDream = s }, Cmd.none )

        SubmitCurrentMessage ->
            ( { model | currentDream = "" }, receiveDream model.currentDream )


view : Model -> Html Msg
view model =
    div []
        [ ul [] <|
            List.map (li [] << List.singleton << text) model.dreams
        , form [ onSubmit SubmitCurrentMessage ]
            [ input [ onInput UpdateMessage, Attributes.placeholder "Nouveau message...", Attributes.value model.currentDream ] [] ]
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = \() -> ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
