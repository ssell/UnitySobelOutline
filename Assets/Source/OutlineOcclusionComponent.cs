using UnityEngine;

namespace VertexFragment
{
    /// <summary>
    /// Responsible for generating depth texture used to exclude certain objects from the <see cref="PostSobelOutline"/> effect.
    /// </summary>
    public class OutlineOcclusionComponent : MonoBehaviour
    {
        /// <summary>
        /// The target texture of the <see cref="OutlineOcclusionCamera"/>.
        /// </summary>
        public static RenderTexture OutlineOcclusionRenderTexture = null;

        /// <summary>
        /// For editor previewing of the output texture.
        /// </summary>
        public RenderTexture Texture { get { return OutlineOcclusionRenderTexture; } }

        /// <summary>
        /// The camera responsible for rendering the outline occlusion depth texture.
        /// </summary>
        public Camera OutlineOcclusionCamera = null;

        /// <summary>
        /// The shader used to selectively render to the depth render target texture.
        /// </summary>
        private static Shader ReplacementShader = null;

        /// <summary>
        /// A debug option which can be checked in the editor to output the render texture to disk.
        /// </summary>
        public bool ShouldOutputTexture = false;

        protected void Start()
        {
            if (ReplacementShader == null)
            {
                ReplacementShader = Shader.Find("VertexFragment/OutlineOcclusion");
            }
        }

        protected void LateUpdate()
        {
            if (OutlineOcclusionCamera == null)
            {
                return;
            }

            OutlineOcclusionCamera.enabled = true;

            OnResize();
            UpdateCamera();

            // Render with the bare-bones replacement shader to generate our depth texture.
            // It will render for all objects whose shaders have a "RenderType" tag (most, if not all) which has a replacement pass in the pass through shader.
            // Any objects whose shader does not have this tag, or the tag does not have a replacement, will not be rendered.
            OutlineOcclusionCamera.RenderWithShader(ReplacementShader, "DisableOutlines");

            // Set the occlusion texture globally so it can be used by any other shader.
            Shader.SetGlobalTexture("_OcclusionDepthMap", OutlineOcclusionRenderTexture);

            OutlineOcclusionCamera.enabled = false;
        }

        /// <summary>
        /// Ensures that the RenderTexture is kept at the correct size/width.
        /// </summary>
        private void OnResize()
        {
            if ((OutlineOcclusionRenderTexture == null) || (Screen.width != OutlineOcclusionRenderTexture.width) || (Screen.height != OutlineOcclusionRenderTexture.height))
            {
                OutlineOcclusionRenderTexture = new RenderTexture(Screen.width, Screen.height, 16, RenderTextureFormat.Depth);
            }
        }

        /// <summary>
        /// Ensures the <see cref="OutlineOcclusionCamera"/> is kept up-to-date with the main camera.
        /// </summary>
        private void UpdateCamera()
        {
            Camera main = Camera.main;

            // Note that we do not use Camera.CopyFrom as, for currently unknown reasons, it does not produce the correct results.

            // Update it's transform to match the main camera
            OutlineOcclusionCamera.transform.position = main.transform.position;
            OutlineOcclusionCamera.transform.rotation = main.transform.rotation;
            OutlineOcclusionCamera.nearClipPlane = main.nearClipPlane;
            OutlineOcclusionCamera.farClipPlane = main.farClipPlane;
            OutlineOcclusionCamera.fieldOfView = main.fieldOfView;

            // Make sure all of the clear and target settings are correct
            OutlineOcclusionCamera.depthTextureMode = DepthTextureMode.Depth;
            OutlineOcclusionCamera.targetTexture = OutlineOcclusionRenderTexture;
            OutlineOcclusionCamera.clearFlags = CameraClearFlags.SolidColor;
            OutlineOcclusionCamera.backgroundColor = Color.black;
            OutlineOcclusionCamera.enabled = false;                                 // Disable so it does not perform normal rendering
        }
    }
}
