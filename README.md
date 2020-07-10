<app icon>

# Blockhead
### There and back again, a 3D pixel's story...

One of the fascinating things to me is how ARKit enables a blending of visual realities (what you see and what the device shows you). I wanted to explore this in detail, plus learn more about how a 3D point/pixel can be projected from 3D space into 2D coordinates, then re-applied back in 3D space. So, Blockhead is an attempt to do something visually interesting with ARKit, the TrueDepth camera, and develop some transform utilities to make all the coordinate space conversions easier to grasp.

<animated gif>


## Known Issues
#### CoreImage Filter Performance
Once the CIFilter is enabled, the framerate drops by move than 50%. All of the effort is being spent in the SCNRendererDelegate callback and applying the filter to the entire framebuffer is expensive. Initially the thought to use texture transforms instead of cropping the framebuffer was valid, but now I need to investigate if that is still the best way. Perhaps CoreImage moves the pixel data across CPU/GPU boundaries.

#### Device Orientation Support
Right now the app is limited to "landscape right" to simplify the framebuffer to texture process, but this needs to support all orientations to correctly build the transform utilities.

#### Cube Model Culling
The cube is a very simple SCNBox bound to the ARKit detected face geometry. When the head tilts up or down, the cube is not cut out where the neck and top of the head exists. I need to figure out how to add geometry, or modify the cube geometry, to hide those parts of the cube so it appears that cube is really surrounding the head and face. A long time ago I did some experiments in the Unreal Engine and objects had a "negative" mode where geometry intersections would "cut out" other objects, not sure if there is an equivalent in SceneKit.
