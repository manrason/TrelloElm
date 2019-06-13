port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode exposing(Decoder, Value)

port elmToJs : String -> Cmd msg


port jsToElm : (Value -> msg) -> Sub msg

type Event
    = EDream Dream
    | ELoggout String
    

type alias Model =
    { events : List Event, currentDream : String }


initialModel : Model
initialModel =
    { dreams = [], currentDream = "" }




type Msg
    = NewDream Dream
    | Loggout String
    | UpdateMessage String
    | SubmitCurrentMessage
    | NoOp

expectStringAt : String -> String -> Decoder ()
expectStringAt field expected =
    Decode.field field Decode.string
      |> Decode.andThen (\value ->
          if value == expected then
              Decode.succeed ()
          else
              Decode.fail <| "expected " ++ expected ++ " got " ++ value
      )

decodeExternalMessage : Decoder Msg
decodeExternalMessage =
    Decode.oneOf 
        [ expectStringAt "tag" "dream" |> Decode.andThen (always decodeDream) |> Decode.map NewDream]


subscriptions : Model -> Sub Msg
subscriptions _ =
    jsToElm <| (Decode.decodeValue decodeExternalMessage >> Result.withDefault NoOp)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewDream dream ->
            ( { model | events = EDream dream :: model.events }, Cmd.none )
        
        Loggout login ->
            ({ model | events = ELoggout login :: model.events}, Cmd.none)

        UpdateMessage s ->
            ( { model | currentDream = s }, Cmd.none )

        SubmitCurrentMessage ->
            ( { model | currentDream = "" }, elmToJs model.currentDream )
        
        NoOp ->
            (model, Cmd.none)


view : Model -> Html Msg
view model =
    div []
        [ form [ onSubmit SubmitCurrentMessage ]
            [ input
                [ onInput UpdateMessage
                , Attributes.placeholder "Nouveau message..."
                , Attributes.value model.currentDream
                ]
                []
            ]
        , ul [] <|
            List.map (li [] << List.singleton<< viewEvent) model.events
        ]


viewLoggout : String -> Html Msg
viewLoggout login =
    span [Attributes.style "font-style" "italic"] [text <| login ++ " s'est déconnecté. Bye bye!"]
    
    
viewDream : Dream -> Html Msg
viewDream dream =
    span [] 
      [ span [Attributes.style "font-style" "bold"] [text <| dream.from ++ " : "]
      , text dream.content
      ]

type alias Dream = 
    { from: String
    , content: String
    }

decodeDream : Decoder Dream
decodeDream =
    Decode.map2 Dream
        (Decode.field "from" Decode.string)
        (Decode.field "content" Decode.string)

main : Program () Model Msg
main =
    Browser.element
        { init = \() -> ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
