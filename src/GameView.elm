module GameView exposing (gameView)

import Html exposing (Html)
import Json.Decode as Json
import Set exposing (Set)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Events exposing (on)
import Messages exposing (Msg(..))
import Model exposing (Model)
import Cell exposing (Cell)
import Coordinates exposing (Coordinates)
import ViewConfig exposing (ViewConfig)
import ZoomLevel


gameView : Model -> Html Msg
gameView model =
    let
        config =
            model.viewConfig

        svgSize =
            toString config.svgSize
    in
        svg
            [ width svgSize
            , height svgSize
            , viewBox (viewBoxSizeString model)
            , on "click" (Json.map MouseClick (relativeCoordinates config))
            ]
            (List.concat
                [ gridLines model
                , gridCells model
                ]
            )


relativeCoordinates : ViewConfig -> Json.Decoder Coordinates
relativeCoordinates config =
    -- Decode the Coordinates of the current mouse position relative to the origin.
    let
        offsetX =
            Json.field "offsetX" Json.int

        offsetY =
            Json.field "offsetY" Json.int

        scale =
            ZoomLevel.scale config.zoomLevel

        coordinatesFromOffsetPosition =
            \x ->
                \y ->
                    ( floor ((toFloat x / scale) - toFloat config.borderSize)
                    , floor ((toFloat y / scale) - toFloat config.borderSize)
                    )
    in
        Json.map2 coordinatesFromOffsetPosition offsetX offsetY


farBorderPosition : ViewConfig -> Int
farBorderPosition config =
    ViewConfig.farBorderPosition config


lineWidth : String
lineWidth =
    "0.5"


viewBoxSizeString : Model -> String
viewBoxSizeString model =
    let
        sizeString =
            toString (ViewConfig.viewBoxSize model.viewConfig)
    in
        "0 0 " ++ sizeString ++ " " ++ sizeString


gridLines : Model -> List (Svg Msg)
gridLines model =
    let
        config =
            model.viewConfig

        lineRange =
            List.range 0 (ViewConfig.visibleCells config)

        linesUsing =
            \lineFunction ->
                List.map (\n -> lineFunction ((config.cellSize * n) + config.borderSize)) lineRange
    in
        List.concat
            [ linesUsing (verticalLineAt model.viewConfig)
            , linesUsing (horizontalLineAt model.viewConfig)
            ]


verticalLineAt : ViewConfig -> Int -> Svg Msg
verticalLineAt config xCoord =
    lineBetween ( xCoord, config.borderSize ) ( xCoord, farBorderPosition config )


horizontalLineAt : ViewConfig -> Int -> Svg Msg
horizontalLineAt config yCoord =
    lineBetween ( config.borderSize, yCoord ) ( farBorderPosition config, yCoord )


lineBetween : Coordinates -> Coordinates -> Svg Msg
lineBetween ( xStart, yStart ) ( xEnd, yEnd ) =
    line
        [ x1 (toString xStart)
        , y1 (toString yStart)
        , x2 (toString xEnd)
        , y2 (toString yEnd)
        , strokeWidth lineWidth
        , stroke "black"
        ]
        []


gridCells : Model -> List (Svg Msg)
gridCells model =
    let
        topLeftCell =
            ( 0, 0 )

        bottomRightCellCoordinate =
            (ViewConfig.visibleCells config) - (1)

        bottomRightCell =
            ( bottomRightCellCoordinate, bottomRightCellCoordinate )

        isVisible =
            Cell.isVisible topLeftCell bottomRightCell

        config =
            model.viewConfig

        drawCellRect =
            \( x, y ) ->
                -- TODO: make cellRectAt just take config and (x,y) as args,
                -- and do calculation there?
                cellRectAt
                    config
                    ( config.borderSize + (config.cellSize * x)
                    , config.borderSize + (config.cellSize * y)
                    )
    in
        Set.filter isVisible model.livingCells
            |> Set.toList
            |> List.map drawCellRect


cellRectAt : ViewConfig -> Coordinates -> Svg Msg
cellRectAt config ( rectX, rectY ) =
    rect
        [ x (toString rectX)
        , y (toString rectY)
        , width (toString config.cellSize)
        , height (toString config.cellSize)
        , strokeWidth lineWidth
        , stroke "black"
        , fill "darkgrey"
        ]
        []
