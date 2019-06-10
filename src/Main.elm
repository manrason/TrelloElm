port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events exposing (onClick, onInput)

port receiveMsg : String -> Cmd msg

port sendMsg : (String -> msg) -> Sub msg

type alias Model =
    { messages : List String , currentMessage : String }


initialModel : Model
initialModel =
    { messages = [], currentMessage = "" }


type Msg
    = NewMessage String
    | UpdateMessage String
    | SubmitCurrentMessage

subscriptions : Model -> Sub Msg
subscriptions _ =
  sendMsg NewMessage

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NewMessage newMsg ->
          ({ model | messages = newMsg :: model.messages}, Cmd.none)
        
        UpdateMessage s ->
          ({model | currentMessage = s}, Cmd.none)
        
        SubmitCurrentMessage ->
          ({model | currentMessage = })
        

view : Model -> Html Msg
view model =
    div [] 
    [ ul []
       (List.map (li [] << List.singleton << text ) model.messages)
    , form [onSubmit SubmitCurrentMessage] 
        [input [ onInput UpdateMessage, Attributes.placeholder "Nouveau message..."] []]
    ]

main : Program () Model Msg
main =
    Browser.element
        { init = \() -> (initialModel, Cmd.none)
        , view = view
        , update = update
        , subscriptions = subscriptions
        }