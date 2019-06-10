module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)


type alias Model =
    { messages : List String }


initialModel : Model
initialModel =
    { messages = [] }


type Msg
    = NewMessage String


update : Msg -> Model -> Model
update msg model =
    case msg of
        NewMessage newMsg ->
            { model | messages = newMsg :: model.messages}

view : Model -> Html Msg
view model =
    ul []
      (List.map (li [] << List.singleton << text ) model.messages)


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }

