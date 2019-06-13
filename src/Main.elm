port module Main exposing (main)

import Browser
import Browser.Dom
import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode as Decode exposing (Decoder, Value)
import Json.Encode as Encode
import Task


port elmToJs : Value -> Cmd msg


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
    | UpdateLogin String
    | SubmitLogin
    | Connected
    | NoOp


expectStringAt : String -> String -> Decoder ()
expectStringAt field expected =
    Decode.field field Decode.string
        |> Decode.andThen
            (\value ->
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
                    ( Asleep { data | events = data.events ++ [ event ] }, Cmd.none )

                UpdateMessage s ->
                    ( Asleep { data | currentDream = s }, Cmd.none )

                SubmitCurrentMessage ->
                    ( Asleep { data | currentDream = "" }
                    , elmToJs <|
                        Encode.object [ ( "tag", Encode.string "dream" ), ( "dream", Encode.string data.currentDream ) ]
                    )

                _ ->
                    ( model, Cmd.none )

        Awake login ->
            case msg of
                UpdateLogin newLogin ->
                    ( Awake newLogin, Cmd.none )

                SubmitLogin ->
                    ( model, postLogin login )

                Connected ->
                    ( Asleep { events = [], currentDream = "" }
                    , Cmd.batch
                        [ elmToJs <|
                            Encode.object
                                [ ( "tag", Encode.string "fallAsleep" )
                                ]
                        , Task.attempt (\_ -> NoOp) (Browser.Dom.focus "dream-input")
                        ]
                    )

                _ ->
                    ( model, Cmd.none )


postLogin : String -> Cmd Msg
postLogin login =
    Http.post
        { url = "/login"
        , body = Http.jsonBody <| Encode.object [ ( "login", Encode.string login ) ]
        , expect = Http.expectWhatever (\_ -> Connected)
        }


view : Model -> Html Msg
view model =
    case model of
        Awake currentLogin ->
            form [ onSubmit SubmitLogin ]
                [ text "Hello dreamer... What is your name?"
                , br [] []
                , input
                    [ onInput UpdateLogin
                    , Attributes.placeholder "Who are you?"
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
                [ ul [] <|
                    List.map (li [] << List.singleton << viewEvent) data.events
                , form [ onSubmit SubmitCurrentMessage ]
                    [ input
                        [ onInput UpdateMessage
                        , Attributes.placeholder "Let me know your dreams..."
                        , Attributes.value data.currentDream
                        , Attributes.id "dream-input"
                        ]
                        []
                    ]
                ]


viewEvent : Event -> Html Msg
viewEvent event =
    case event of
        EDream dream ->
            span []
                [ span [ Attributes.style "font-weight" "bold" ] [ text <| dream.from ++ " : " ]
                , text dream.content
                ]

        ELogin login ->
            span [ Attributes.style "font-style" "italic" ] [ text <| login ++ " fell asleep... We will know his dreams!" ]

        ELoggout login ->
            span [ Attributes.style "font-style" "italic" ] [ text <| login ++ " awoke. We can't hear his dreams anymore." ]


type alias Dream =
    { from : String
    , content : String
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
