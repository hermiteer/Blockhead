<app icon>

# Blockhead
### There and back again, a pixel's tale...

One of the fascinating things to me is how ARKit enables a blending of visual realities (what you see and what the device shows you). I wanted to explore this in detail, plus learn more about how a pixel can be projected from 3D space into 2D coordinates, then re-applied back in 3D space. Blockhead is an experiment to do something visually interesting with ARKit, the TrueDepth camera, plus develop some utilities to make all the coordinate space transforms easier to grasp.

[![Blockhead](https://yt-embed.herokuapp.com/embed?v=qv_Cb7TkmHQ)](https://www.youtube.com/watch?v=qv_Cb7TkmHQ "Blockhead")

## How does it work
The project was built from the default ARKit, single-view Xcode project. All of the 3D and 2D processing happens in a function from the `ARSCNViewDelegate.renderer(nodeForAnchor:ARAnchor)` delegate method. As the code evolves, things will move into new classes and extensions, but for now everything is here to keep all the transforms in logical order.

1. Create an `SNCBox` node when a face is detected
1. Position the box node over the face node
1. Determine a bounding box around the face
1. Project the bounding box from local space into world space
1. Project the bounding box from world space to screen coordinates
1. Create a red rectangle with the screen coordinates
1. Project the screen rectangle to the frame buffer coordinates
1. Calculate the texture coordinates from the frame buffer coordinates
1. Apply the frame buffer to the box using the texture coordinates

The pixellation effect is created using CoreImage for simplicity, but has performance implications as discussed in TODOs.

The top left thumbnail is the entire AR frame buffer, with an overlay indicating the texture coordinates, with the same overlay on the screen. When both of these are aligned, the 2D transforms are working as expected. There are on-screen toggles for those features, plus pixellation and face geometry visibility.

## TODOs

#### Rear camera support
Using the front camera makes it easy to see the various debug views the app has, but this should support the rear camera on iPad Pros.

#### Visual polish
When the face is no longer recognized, the cube could smoothly disappear instead of remaining on screen.

#### Texture rotation
When the face geometry rotate the texture as applied to the cube rotates further than expected. This is because the texture is always square aligned with the frame buffer, and should inverse rotate to compensate. This will require some additional calculation for the texture size dependent on the largest diameter when rotated.

#### CoreImage Filter Performance
Once the CIFilter is enabled, the framerate drops by move than 50%. All of the effort is being spent in the SCNRendererDelegate callback and applying the filter to the entire framebuffer is expensive. Initially the thought to use texture transforms instead of cropping the framebuffer was valid, but now I need to investigate if that is still the best way. Perhaps CoreImage moves the pixel data across CPU/GPU boundaries.

#### Device Orientation Support
Right now the app is limited to "landscape right" to simplify the framebuffer to texture process, but this needs to support all orientations to correctly build the transform utilities.

#### Cube Model Culling
The cube is a very simple SCNBox bound to the ARKit detected face geometry. When the head tilts up or down, the cube is not cut out where the neck and top of the head exists. I need to figure out how to add geometry, or modify the cube geometry, to hide those parts of the cube so it appears that cube is really surrounding the head and face. A long time ago I did some experiments in the Unreal Engine and objects had a "negative" mode where geometry intersections would "cut out" other objects, not sure if there is an equivalent in SceneKit.
