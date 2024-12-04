Shader "Custom/FakeWave"
{
    Properties {
       _LightColor("Light Color", Color) = (0,0.43,1,1)
       _DarkColor("Dark Color", Color) = (0,0,0.37,1)
       [Toggle(USE_GRADIENT)] _UseGradient("Use Gradient", Float) = 0
       [NoScaleOffset] _GradientTex("Gradient Texture", 2D) = "white" {}
       _RemapColors("Remap Colors", Vector) = (0,1,0,1)
       _Banding("_Banding", Range(0, 20)) = 0
       _SampleSize("SampleSize", float) = 0.1
       _SampleHeightFactor("SampleHeightFactor", float) = 1
       _WaveHeight("Wave Height", float) = 1
       _NoiseSpeedScale("Noise Speeds and Scale", Vector) = (0.1,0.5,0.1,0.24)
       [Toggle(DEBUG_NOISE)] _DebugNoise("Debug Noise", Float) = 0
       _Stencil ("Stencil ID [0;255]", Float) = 0
       [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Int) = 8

    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Geometry" }
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
        }

        Pass {
            ColorMask RGB
            HLSLPROGRAM

            #pragma shader_feature DEBUG_NOISE
            #pragma shader_feature USE_GRADIENT

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/jp.keijiro.noiseshader/Shader/SimplexNoise3D.hlsl"
            #include "Interpolation.hlsl"

            struct Input
            {
                float4 positionOS:POSITION;
            };

            struct V2F
            {
                float4 positionCS:SV_POSITION;
                float3 positionWS:TEXCOORD4;
                float3 positionWSWithoutNoise:TEXCOORD5;
            };

            float4 _LightColor;
            float4 _DarkColor;
            float4 _RemapColors;
            float _WaveHeight;
            float4 _NoiseSpeedScale;
            float _Banding;
            float _SampleSize;
            float _SampleHeightFactor;
#ifdef USE_GRADIENT
            TEXTURE2D(_GradientTex);
            SAMPLER(sampler_GradientTex);
#endif
            float GetNoise(float3 pos) {
                return SimplexNoise(pos * _NoiseSpeedScale.w + _NoiseSpeedScale.xyz * _Time.y);
            }

            float3 GetFakeNormal(float3 pos) {
                float3 du = float3(_SampleSize, 0, 0);
	            float u1 = (GetNoise(pos - du) + 1) * 0.5;
	            float u2 = (GetNoise(pos + du) + 1) * 0.5;
	            float3 tangent = float3(_SampleSize, (u2 - u1) * _SampleHeightFactor, 0);

	            float3 dv = float3(0, 0, _SampleSize);
	            float v1 = (GetNoise(pos - dv) + 1) * 0.5;
	            float v2 = (GetNoise(pos + dv) + 1) * 0.5;
	            float3 bitangent = float3(0, (v2 - v1) * _SampleHeightFactor, _SampleSize);

	            float3 normal = cross(bitangent, tangent);
	            normal = normalize(normal);
                return normal;
            }

            V2F vert(Input input)
            {
                V2F output;
                output.positionWS = mul(unity_ObjectToWorld, input.positionOS);

                float noise = GetNoise(output.positionWS) * _WaveHeight * 0.5;

                output.positionWSWithoutNoise = output.positionWS;
                output.positionWS.y += noise;
                output.positionCS = mul(UNITY_MATRIX_VP, float4(output.positionWS, 1));
     
                return output;
            }


            float4 frag(V2F input):SV_TARGET
            {
                float noise = GetNoise(input.positionWSWithoutNoise) * _WaveHeight * 0.5;
                float3 fakePosition = input.positionWSWithoutNoise;
                fakePosition.y += noise;
                #ifdef DEBUG_NOISE
                return noise;
                #endif
                Light mainLight = GetMainLight();
		        float3 mainLightDirection = normalize(mainLight.direction);
                //float3 mainLightColor = mainLight.color;
               
                float3 normalWS = GetFakeNormal(fakePosition);
                float NdL = saturate(dot(normalWS, mainLightDirection));
                NdL = Remap(_RemapColors.x, _RemapColors.y, _RemapColors.z, _RemapColors.w, NdL);
                if (_Banding > 0) 
                { 
                    NdL = floor(NdL * _Banding) / _Banding;                    
                }
                #ifdef USE_GRADIENT
                return SAMPLE_TEXTURE2D(_GradientTex, sampler_GradientTex, saturate(NdL));
                #else
                return Lerp(_DarkColor, _LightColor, NdL);
                #endif
            }

            ENDHLSL
        }
    }
}
