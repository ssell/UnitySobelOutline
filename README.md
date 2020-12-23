# Unity Sobel Outline Example

![](Media/SobelOutline.gif#center)

This repository contains the source code for a deferred renderer Sobel Outline post-processing effect for Unity.

There is an accompanying article,

* https://www.vertexfragment.com/ramblings/unity-postprocessing-sobel-outline/

which provides a step-by-step tutorial on how the effect was created.

It should be noted that this project is for demonstration purposes only, and there is no guarantess of its correctness. This project _may_ see occasional future updates to support new Unity or package versions or bug fixes.

The code was written against:

* Unity v2020.2.0f1
* [Post Processing v2.3.0](https://docs.unity3d.com/Packages/com.unity.postprocessing@2.3/index.html)

## Exclude from Outline

Sometimes you don't want the outlines affecting certain geometry. One way this can be done is by setting signals in the sampled buffers.

Personally, I have gone about this two different ways:

1. Using a secondary depth buffer to render excluded geometry to, combined with ShaderLab tags. See the `OutlineOcclusion` related objects in the project (C# class, shader, material).
2. Setting a signal in the deferred renderer G-Buffer. Personally have done this by setting the world normal `.w` to `0.0` and interpreting it in the Sobel shader. This is not demonstrated in the example project.

## Contact

Any questions or comments may be directed to the contact information [found here](https://www.vertexfragment.com/about/).