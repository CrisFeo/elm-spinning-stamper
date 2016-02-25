module SpinningStamper where

import Color exposing (..)
import Graphics.Collage as Collage
import Graphics.Element exposing (Element)
import Time exposing (Time, fps)
import Mouse
import Random


sceneWidth : Float
sceneWidth  = 300

sceneHeight : Float
sceneHeight = 300


-- Models

type alias Coordinates =
  { x : Float
  , y : Float
  }

type alias Shape =
  { angle    : Float
  , color    : Color
  , position : Coordinates
  , scale    : Float
  , speed    : Float
  }

type alias State =
  { elapsed : Float
  , shapes  : List Shape
  }

type Action = Tick Float | Click Coordinates


-- Signal Handlers

initialState : State
initialState = State 0 []

main : Signal Element
main =
  Signal.map view
    <| Signal.foldp update initialState
    <| Signal.merge tick click

tick : Signal Action
tick = Signal.map Tick <| fps 30

click : Signal Action
click =
    Signal.map (Click << screenToCollage)
      <| Signal.sampleOn Mouse.clicks Mouse.position


-- State Updates

update : Action -> State -> State
update action state =
  case action of
    Tick delta ->
      let
        elapsed = delta + state.elapsed
      in
        { state |
          elapsed = elapsed
        , shapes = List.map (updateShape elapsed) state.shapes
        }
    Click coord ->
      let
        newShape = createShape state.elapsed coord
      in
        {state | shapes = newShape :: state.shapes}

createShape : Float -> Coordinates -> Shape
createShape elapsed coord =
  let
    color = randomColor elapsed
    scale = randomFloat 0.5 1.5 elapsed
    speed = randomFloat  -3   3 elapsed
  in
    updateShape elapsed <| Shape 0 color coord scale speed

updateShape : Float -> Shape -> Shape
updateShape elapsed shape = { shape | angle = degrees elapsed * shape.speed }


-- Helper Functions

screenToCollage : (Int, Int) -> Coordinates
screenToCollage (x, y) =
  { x = toFloat x - sceneWidth / 2
  , y = sceneHeight / 2 - toFloat y
  }

randomColor : Float -> Color
randomColor seed =
  let
    generator = Random.map3 Color.rgb
      (Random.int 0 255)
      (Random.int 0 255)
      (Random.int 0 255)
  in
    fst <| Random.generate generator <| Random.initialSeed (round seed)

randomFloat : Float -> Float -> Float -> Float
randomFloat min max seed =
  let
    generator = Random.float min max
  in
    fst <| Random.generate generator <| Random.initialSeed (round seed)


-- Drawing

view : State -> Element
view state = Collage.collage 300 300 <| List.map drawShape state.shapes

drawShape : Shape -> Collage.Form
drawShape {angle, color, position, scale, speed} =
  Collage.ngon 6 40
    |> Collage.outlined (Collage.solid color)
    |> Collage.move (position.x, position.y)
    |> Collage.scale scale
    |> Collage.rotate (degrees angle)

