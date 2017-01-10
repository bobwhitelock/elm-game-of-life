module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Messages exposing (..)
import Model exposing (Model)
import GameView
import ZoomLevel


view : Model -> Html Msg
view model =
    let
        runButtonText =
            if model.running then
                "Pause"
            else
                "Run"
    in
        div []
            [ GameView.gameView model
            , button
                [ onClick ToggleRunning ]
                [ text runButtonText ]
            , button
                [ onClick ZoomIn
                , disabled (ZoomLevel.isMaximum model.viewConfig.zoomLevel)
                ]
                [ text "+" ]
            , button
                [ onClick ZoomOut
                , disabled (ZoomLevel.isMinimum model.viewConfig.zoomLevel)
                ]
                [ text "-" ]
            ]
