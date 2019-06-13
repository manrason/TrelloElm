port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode exposing(Decoder, Value)

import Http

port elmToJs : String -> Cmd msg


port jsToElm : (Value -> msg) -> Sub msg

type Event
    = EDream Dream
    | ELogin String
    | ELoggout String

type Model 
    = Awake String
    | Asleep { events : List Event, currentDream : String }


initialModel : Model
initialModel =
    Awake ""




type Msg
    = NewEvent Event
    | UpdateMessage String
    | SubmitCurrentMessage
    | SubmitLogin
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
        [ expectStringAt "tag" "dream" |> Decode.andThen (always decodeDream) |> Decode.map EDream
        , expectStringAt "tag" "login" |> Decode.andThen (always (Decode.field "login" Decode.string)) |> Decode.map ELogin
        , expectStringAt "tag" "loggout" |> Decode.andThen (always (Decode.field "login" Decode.string)) |> Decode.map ELoggout
        ]
        |> Decode.map NewEvent

subscriptions : Model -> Sub Msg
subscriptions _ =
    jsToElm <| (Decode.decodeValue decodeExternalMessage >> Result.withDefault NoOp)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        Asleep data ->
            case msg of
                NewEvent event ->
                    ( { model | events = event :: model.events }, Cmd.none )

                UpdateMessage s ->
                    ( { model | currentDream = s }, Cmd.none )

                SubmitCurrentMessage ->
                    ( { model | currentDream = "" }, elmToJs model.currentDream )

                _ ->
                    (model, Cmd.none)
        
        Awake login ->
            case msg of
                UpdateLogin newLogin ->
                    (Awake newLogin, Cmd.none)
                
                SubmitLogin ->
                    (Asleep {events = [], currentDream = ""}, postLogin login )
                
                _ ->
                    (model, Cmd.none)

postLogin : String -> Cmd Msg
postLogin login =
    Http.post 
      { url= "/login"
      , body = Http.jsonBody }

view : Model -> Html Msg
view model =
    case model of
        Awake currentLogin ->
            form [ onSubmit SubmitLogin ]
                  [ input
                      [ onInput UpdateLogin
                      , Attributes.placeholder "Hello dreamer... What is your name?"
                      , Attributes.value currentLogin
                      ]
                      []
                  , input 
                      [ Attributes.type_ "submit"
                      , Attributes.value "Fall asleep"
                      ]
                      []
                  ]
        Asleep data ->
          div []
              [ form [ onSubmit SubmitCurrentMessage ]
                  [ input
                      [ onInput UpdateMessage
                      , Attributes.placeholder "Let me know your dreams..."
                      , Attributes.value data.currentDream
                      ]
                      []
                  ]
              , ul [] <|
                  List.map (li [] << List.singleton<< viewEvent) data.events
              ]


viewEvent : Event -> Html Msg
viewEvent event =
    case event of
        EDream dream -> 
            span [] 
              [ span [Attributes.style "font-weight" "bold"] [text <| dream.from ++ " : "]
              , text dream.content
              ]
            
        ELogin login ->
            span [Attributes.style "font-style" "italic"] [text <| login ++ " fell asleep... We will know his dreams!"]
            
        ELoggout login ->
            span [Attributes.style "font-style" "italic"] [text <| login ++ " awoke. We can't hear his dreams anymore."]
        
    

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
