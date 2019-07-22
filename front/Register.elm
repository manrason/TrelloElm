module Register exposing (main)

import Browser
import Browser.Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode as Decode exposing (Decoder)
import Regex exposing (Regex)


type alias TestEmail =
    { email : String
    , free : Bool
    }


testEmailDecoder : Decoder TestEmail
testEmailDecoder =
    Decode.map2 TestEmail
        (Decode.field "email" Decode.string)
        (Decode.field "free" Decode.bool)


type Msg
    = EmailUpdated String
    | Password1Updated String
    | Password2Updated String
    | GotTestEmail (Result Http.Error TestEmail)


type EmailStatus
    = NotAnEmail
    | Loading
    | ServerError
    | Free
    | AlreadyUsed


type PasswordCheck
    = Password1NotDone
    | PasswordsMatch
    | PasswordsMismatch


type alias Model =
    { email : String
    , emailStatus : EmailStatus
    , password1 : String
    , password2 : String
    , passwordCheck : PasswordCheck
    }


initialModel : Model
initialModel =
    { email = ""
    , emailStatus = NotAnEmail
    , password1 = ""
    , password2 = ""
    , passwordCheck = Password1NotDone
    }


isFormValid : Model -> Bool
isFormValid model =
    model.password1 == model.password2 && model.emailStatus == Free


getTestEmail : String -> Cmd Msg
getTestEmail email =
    Http.get
        { url = "/is-email-used/" ++ email
        , expect = Http.expectJson GotTestEmail testEmailDecoder
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EmailUpdated email ->
            -- We send a request to the server only if the email
            -- is valid!
            let
                ok =
                    isValidEmail email
            in
            ( { model
                | email = email
                , emailStatus =
                    if ok then
                        Loading

                    else
                        NotAnEmail
              }
            , if ok then
                getTestEmail email

              else
                Cmd.none
            )

        Password1Updated password1 ->
            ( case model.passwordCheck of
                Password1NotDone ->
                    { model | password1 = password1 }

                _ ->
                    { model
                        | password1 = password1
                        , passwordCheck =
                            if password1 == model.password2 then
                                PasswordsMatch

                            else
                                PasswordsMismatch
                    }
            , Cmd.none
            )

        Password2Updated password2 ->
            ( { model
                | password2 = password2
                , passwordCheck =
                    if password2 == model.password1 then
                        PasswordsMatch

                    else
                        PasswordsMismatch
              }
            , Cmd.none
            )

        GotTestEmail (Ok testEmail) ->
            ( -- if the email in the model doesnt match the email in the test,
              -- just ignore the response
              if testEmail.email == model.email then
                { model
                    | emailStatus =
                        if testEmail.free then
                            Free

                        else
                            AlreadyUsed
                }

              else
                model
            , Cmd.none
            )

        GotTestEmail (Err _) ->
            ( { model | emailStatus = ServerError }, Cmd.none )


view : Model -> Html Msg
view model =
    Html.form [ action "/register", method "POST", class "register-form"]
        [ label []
            [ text "Email: "
            , input [ name "email", type_ "email", value model.email, onInput EmailUpdated ]
                []
            , viewEmailStatus model.emailStatus
            ]
        , label []
            [ text "Name: "
            , input [ name "name", type_ "text" ]
                []
            ]
        , label []
            [ text "Password: "
            , input [ name "password1", type_ "password", value model.password1, onInput Password1Updated ]
                []
            ]
        , label []
            [ text "Repeat: "
            , input [ name "password2", type_ "password", value model.password2, onInput Password2Updated ]
                []
            , viewPasswordCheck model.passwordCheck
            ]
        , input
            (if isFormValid model then
                [ name "", type_ "submit", value "Register" ]

             else
                [ name "", type_ "submit", value "Correct errors to register", disabled True ]
            )
            []
        ]

viewEmailStatus : EmailStatus -> Html Msg
viewEmailStatus emailStatus =
    case emailStatus of
        NotAnEmail ->
            span [class "status error"] [text "This is not an email!"]
        
        Loading ->
            span [class "status loading"] [text "..."]
            
        Free ->
            span [class "status ok"] [text "✅"]
        
        AlreadyUsed ->
            span []
               [ span [class "status error"] [text "Email Already used..."],
                 a [ href "/login"] [ text "Do you want to log you in?"]
                ]
       
        ServerError ->
            span [class "status error"] [text "I can not speak with the server..."]
            
viewPasswordCheck: PasswordCheck -> Html Msg
viewPasswordCheck passwordCheck =
     case passwordCheck of
         Password1NotDone ->
             span [class "status warning"] [text "Fullfil the passwords fields!"]
        
         PasswordsMatch ->
             span [class "status ok"] [text "✅"]
         
         PasswordsMismatch ->
             span [class "status error"] [text "The passwords mismatch!"]


main : Program () Model Msg
main =
    Browser.element
        { init = \() -> ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


isValidEmail : String -> Bool
isValidEmail email =
    Regex.contains validEmail email


validEmail : Regex
validEmail =
    "^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        |> Regex.fromStringWith { caseInsensitive = True, multiline = False }
        |> Maybe.withDefault Regex.never
