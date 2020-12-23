// This shader is used to generate a depth-texture of all objects which should not be outlined.
// It is used by the OutlineOcclusionCamera as a replacement shader, and then sampled in the SobelOutline shader.

Shader "VertexFragment/OutlineOcclusion"
{
    SubShader
    {
        // Any object with the "DisableOutlines" tag set to "True" will be rendered and the depth captured.
        Tags { "RenderType" = "Transparent" "DisableOutlines" = "True" }

        Pass
        {
            CGPROGRAM
            #pragma target 3.0

            #pragma vertex VertMain
            #pragma fragment FragMain

            #include "UnityCG.cginc"

            struct VertInput
            {
                float4 position : POSITION;
            };

            struct FragInput
            {
                float4 position : SV_POSITION;
            };

            FragInput VertMain(VertInput vertData)
            {
                FragInput fragData;

                fragData.position = UnityObjectToClipPos(vertData.position);

                return fragData;
            }

            float4 FragMain(FragInput fragData) : SV_Target
            {
                return float4(1.0, 1.0, 1.0, 1.0);
            }

            ENDCG
        }
    }
}