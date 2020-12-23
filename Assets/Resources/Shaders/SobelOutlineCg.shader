Shader "VertexFragment/SobelOutlineCg"
{
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM

            #pragma vertex VertMain
            #pragma fragment FragMain

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            sampler2D _CameraGBufferTexture2;
            sampler2D _OcclusionDepthMap;

            float _OutlineThickness;
            float _OutlineDepthMultiplier;
            float _OutlineDepthBias;
            float _OutlineNormalMultiplier;
            float _OutlineNormalBias;
            float _OutlineDensity;
            float4 _OutlineColor;

            struct VertData
            {
                float4 vertex : POSITION;
                float4 uv     : TEXCOORD0;
            };

            struct FragData
            {
                float4 vertex   : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };

            FragData VertMain(VertData input)
            {
                FragData output;

                output.vertex = float4(input.vertex.xy, 0.0, 1.0);
                output.texcoord = (input.vertex.xy + 1.0) * 0.5;

                // For Direct3D Build
                output.texcoord.y = 1.0 - output.texcoord.y;

                // For Open/WebGL build
                //output.texcoord.y = output.texcoord.y;

                return output;
            }

            float4 SobelSample(sampler2D t, float2 uv, float3 offset)
            {
                float4 pixelCenter = tex2D(t, uv);
                float4 pixelLeft   = tex2D(t, uv - offset.xz);
                float4 pixelRight  = tex2D(t, uv + offset.xz);
                float4 pixelUp     = tex2D(t, uv + offset.zy);
                float4 pixelDown   = tex2D(t, uv - offset.zy);

                return abs(pixelLeft - pixelCenter)  +
                       abs(pixelRight - pixelCenter) +
                       abs(pixelUp - pixelCenter)    +
                       abs(pixelDown - pixelCenter);
            }

            float SobelSampleDepth(sampler2D t, float2 uv, float3 offset)
            {
                float pixelCenter = LinearEyeDepth(tex2D(t, uv).r);
                float pixelLeft   = LinearEyeDepth(tex2D(t, uv - offset.xz).r);
                float pixelRight  = LinearEyeDepth(tex2D(t, uv + offset.xz).r);
                float pixelUp     = LinearEyeDepth(tex2D(t, uv + offset.zy).r);
                float pixelDown   = LinearEyeDepth(tex2D(t, uv - offset.zy).r);

                return abs(pixelLeft - pixelCenter)  +
                       abs(pixelRight - pixelCenter) +
                       abs(pixelUp - pixelCenter)    +
                       abs(pixelDown - pixelCenter);
            }

            float4 FragMain(FragData input) : SV_Target
            {
                float3 sceneColor = tex2D(_MainTex, input.texcoord).rgb;
                float3 color = sceneColor;
                float3 offset = float3((1.0 / _ScreenParams.x), (1.0 / _ScreenParams.y), 0.0) * _OutlineThickness;

                // -------------------------------------------------------------------------
                // Check if this geometry is occluded
                // -------------------------------------------------------------------------

                float occlusion = SobelSample(_OcclusionDepthMap, input.texcoord.xy, offset);

                if (occlusion > 0.0)
                {
                    return float4(sceneColor, 1.0);
                }

                // -------------------------------------------------------------------------
                // Fade out the outline for distant objects.
                // -------------------------------------------------------------------------

                // Generate an alpha value based on scene depth.
                //     >= 0.4 = No outline
                //      > 0.2 = Partial outline
                //     <= 0.2 = Full outline

                float depth01   = Linear01Depth(tex2D(_CameraDepthTexture, input.texcoord.xy).r);
                float minDepth  = 0.2;
                float depthSpan = 0.2;
                float alpha     = lerp(1.0, 0.0, (clamp(depth01, minDepth, minDepth + depthSpan) - minDepth) / depthSpan);

                if (alpha <= 0.0)
                {
                    return float4(sceneColor, 1.0);
                }

                // -------------------------------------------------------------------------
                // Generate the outline
                // -------------------------------------------------------------------------

                // Get the sobel depth from our pre-sampled linear depth values
                float sobelDepth = SobelSampleDepth(_CameraDepthTexture, input.texcoord.xy, offset);
                sobelDepth = pow(abs(saturate(sobelDepth) * _OutlineDepthMultiplier), _OutlineDepthBias);

                // Sample the normals from the GBuffer to get our normal contribution
                float3 sobelNormalVec = abs(SobelSample(_CameraGBufferTexture2, input.texcoord.xy, offset).rgb);
                float sobelNormal = sobelNormalVec.x + sobelNormalVec.y + sobelNormalVec.z;
                sobelNormal = pow(abs(sobelNormal * _OutlineNormalMultiplier), _OutlineNormalBias);

                // Calculate the combined contribution between normals and depth
                float sobelOutline = saturate(max(sobelDepth, sobelNormal));
                sobelOutline = smoothstep(_OutlineDensity, 1.0, sobelOutline) * alpha;

                // Colorize the outline
                float3 outlineColor = lerp(sceneColor, _OutlineColor.rgb, clamp(_OutlineColor.a, 0.0f, 1.0f));
                color = lerp(sceneColor, outlineColor, sobelOutline);

                return float4(color, 1.0);
            }

            ENDCG
        }
    }
}