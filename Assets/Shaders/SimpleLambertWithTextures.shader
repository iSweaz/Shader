Shader "Custom/SimpleLambertWithTextures"
{
    Properties {
        _MainTex("Texture", 2D) = "white" {}
        [NoScaleOffset] _NormalMap("Normal", 2D) = "bump" {}
        _BumpScale("Bump Scale",float) = 1 
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Geometry" }

        Pass {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Input
            {
                float4 positionOS:POSITION;
                float3 normal:NORMAL; 
                float4 tangent:TANGENT; // xyz = tangent direction, w = tangent sign
                float2 uv : TEXCOORD0;
            };

            struct V2F
            {
                float4 positionCS:SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 tangentWS:TEXCOORD1;
                float3 bitangentWS:TEXCOORD2;
                float3 normalWS:TEXCOORD3;
            };

            TEXTURE2D(_MainTex); 
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;

            TEXTURE2D(_NormalMap); 
            SAMPLER(sampler_NormalMap);

            float _BumpScale;
            
            V2F vert(Input input)
            {
                V2F output;
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                output.positionCS = TransformObjectToHClip(input.positionOS);
                VertexNormalInputs normInputs = GetVertexNormalInputs(input.normal, input.tangent);
                output.normalWS = normInputs.normalWS;
                output.tangentWS = normInputs.tangentWS;
                output.bitangentWS = normInputs.bitangentWS;
                return output;
            }


            float4 frag(V2F input):SV_TARGET
            {
                Light mainLight = GetMainLight();
		        float3 mainLightDirection = normalize(mainLight.direction);
                float3 mainLightColor = mainLight.color;
                float4 mainTexColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
               
                float4 tangentSpaceNormalColor = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv);
                float3 tangentSpaceNormal = UnpackNormalScale(tangentSpaceNormalColor,_BumpScale);
                float3 normalWS = tangentSpaceNormal.r * normalize(input.tangentWS) 
                    + tangentSpaceNormal.g * normalize(input.bitangentWS)
                    + tangentSpaceNormal.b * normalize(input.normalWS);

                float3 NdL = saturate(dot(normalWS, mainLightDirection));
                return float4(NdL * mainLightColor * mainTexColor.rgb, 1);
            }

            ENDHLSL
        }
    }
}
