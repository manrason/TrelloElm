port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)

port receiveMsg : String -> Cmd msg

port sendMsg : (String -> msg) -> Sub msg

type alias Model =
    { messages : List String }


initialModel : Model
initialModel =
    { messages = [] }


type Msg
    = NewMessage String

subscriptions : Model -> Sub Msg
subscriptions _ =
  sendMsg NewMessage

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NewMessage newMsg ->
          let 
            _ = Debug.log "msg" newMsg
          in
          ({ model | messages = newMsg :: model.messages}, Cmd.none)

view : Model -> Html Msg
view model =
    ul []
      (List.map (li [] << List.singleton << text ) model.messages)


main : Program () Model Msg
main =
    Browser.element
        { init = \() -> (initialModel, Cmd.none)
        , view = view
        , update = update
        , subscriptions = subscriptions
        }