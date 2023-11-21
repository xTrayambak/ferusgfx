#[
 A 2D scene

 This code is licensed under the MIT license
]#
import canvas, drawable, 
       pixie, boxy, librng,
       opengl, fontmgr, std/[strutils, times]

var ALPHABETS: seq[char] = @[]

# populate ALPHABETS
for a in 'a'..'z':
 ALPHABETS.add(a)

for a in 'A'..'Z':
 ALPHABETS.add(a)

for n in '0'..'9':
 ALPHABETS.add(n)

proc genImageId(rng: RNG): string =
 var x = ""

 for _ in 0..16:
  x &= rng.choice(
   ALPHABETS
  )
  
 x

type Scene* = ref object of RootObj
 bxContext*: Boxy
 canvas*: Canvas
 tree*: seq[Drawable]

 fontManager*: FontManager

 minimized: bool
 maximized: bool

 # window lib-agnostic way of getting dt
 lastTime: float

 rng: RNG

proc getDt*(scene: Scene): float =
 let time = cpuTime() - scene.lastTime
 time

proc onResize*(scene: Scene, nDimensions: tuple[w, h: int]) =
 scene.canvas.width = nDimensions.w
 scene.canvas.height = nDimensions.h
 scene.canvas.image = newImage(nDimensions.w, nDimensions.h)

proc onMinimize*(scene: Scene) =
 if scene.minimized: return
 scene.maximized = false
 scene.minimized = true

proc onMaximize*(scene: Scene) =
 if scene.maximized: return
 scene.maximized = true
 scene.minimized = false

proc blit*(scene: Scene): string =
 scene.canvas.image.fill(rgba(255, 255, 255, 255))

 for drawObj in scene.tree:
  if drawObj.needsRedraw():
   drawObj.draw(scene.canvas.image)

 let imgId = genImageId(scene.rng)
 scene.bxContext.addImage(imgId, scene.canvas.image)

 imgId

proc draw*(scene: Scene, imgId: string) =
 # Now that every drawable has blitted itself to the
 # screen, let's go ahead and draw it to the window.
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
 glClearColor(0f, 0.5f, 0.5f, 1f)

 scene.bxContext.beginFrame(
  ivec2(scene.canvas.width.int32, scene.canvas.height.int32)
 )
 scene.bxContext.drawImage(imgId, vec2(0, 0))
 scene.bxContext.endFrame()

 scene.lastTime = cpuTime()

proc newScene*(width, height: int): Scene =
 Scene(
  bxContext: newBoxy(), lastTime: 0f,
  tree: @[], fontManager: newFontManager(),
  rng: newRNG(), canvas: newCanvas(width, height)
 )
