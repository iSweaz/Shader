Shader "Custom/ScrollingTexWithNoise"
{
    Properties 
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _SpeedU("Speed U", float) = 0
        _SpeedV("Speed V", float) = 1
        _NoiseU("Noise U", float) = 0.05
        _NoiseV("Noise V", float) = 0
        _NoiseOffsetScale("Noise Offset and Scale", Vector) = (0,0,0,1)
        _RemapNoise("Remap Noise", Vector) = (-1, 1, -1, 1)
        [Toggle(DEBUG_NOISE)] _DebugNoise("Debug Noise", Float) = 0
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Geometry" }

        Pass {
            

            HLSLPROGRAM

            #pragma shader_feature DEBUG_NOISE

            #pragma vertex vert
            #pragma fragment frag


            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #include "Packages/jp.keijiro.noiseshader/Shader/SimplexNoise3D.hlsl"
            #include "Interpolation.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;

            float _SpeedU;
            float _SpeedV;
            float _NoiseU;
            float _NoiseV;

            float4 _NoiseOffsetScale;
            float4 _RemapNoise;

            struct Input
            {
                float3 positionOS:POSITION;
                float2 uv:TEXCOORD0;
            };

            struct V2F
            {
                float4 screenPos:SV_POSITION;
                float2 uv:TEXCOORD0;
                float3 positionWS:TEXCOORD1;
            };


            V2F vert(Input input)
            {
                V2F output;
                output.screenPos =  TransformObjectToHClip(input.positionOS);               
                // This macro transforms the float2 UV by tiling/offset propertyies
                float2 originalUv = TRANSFORM_TEX(input.uv, _MainTex);
                float2 uvSpeed = float2(_SpeedU , _SpeedV) * _Time.y;
                output.uv = originalUv + uvSpeed;
                output.positionWS = mul(unity_ObjectToWorld, float4(input.positionOS, 0));
                return output;
            }

            float4 frag(V2F input) : SV_TARGET {
                float noise = SimplexNoise(input.positionWS * _NoiseOffsetScale.w + _NoiseOffsetScale.xyz);
                noise = Remap(_RemapNoise.x, _RemapNoise.y, _RemapNoise.z, _RemapNoise.w, noise);
                #ifdef DEBUG_NOISE
                return float4(noise,noise,noise,1);
                #endif
                float2 noiseUV = noise * float2(_NoiseU, _NoiseV);
                return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv + noiseUV);
            }
            ENDHLSL
        }
    }
}
