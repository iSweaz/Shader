Shader "Custom/FlowMap" 
{
	Properties {
		_MainTex ("Main Texture", 2D) = "white" {}
		[NoScaleOffset] _FlowMap ("Flow Map", 2D) = "black" {}
		_FlowSpeed ("Flow Speed", Float) = 0.1
        _FlowStrength ("Flow Strength", Float) = 1
	}
	SubShader 
    {
        Tags { "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Geometry" }

        Pass {
        
		    HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

		    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

		    TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;

		    TEXTURE2D(_FlowMap);
            SAMPLER(sampler_FlowMap);

		    float _FlowSpeed;
            float _FlowStrength;

		    struct Input
            {
                float3 positionOS:POSITION;
                float2 uv:TEXCOORD0;
            };

            struct V2F
            {
                float4 screenPos:SV_POSITION;
                float2 uv:TEXCOORD0;
            };

            V2F vert(Input input)
            {
                V2F output;
                output.screenPos =  TransformObjectToHClip(input.positionOS);       
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                return output;
            }

            float3 FlowUVW (float2 uv, float2 flowVector, float time, bool flowB) {
	            float phaseOffset = flowB ? 0.5 : 0;
	            float progress = frac(time + phaseOffset);
	            float3 uvw;
	            uvw.xy = uv - flowVector * progress;
	            uvw.z = 1 - abs(1 - 2 * progress);
	            return uvw;
            }

            float4 frag(V2F input) : SV_TARGET {                
                float2 flowVector = SAMPLE_TEXTURE2D(_FlowMap, sampler_FlowMap, input.uv).rg;
                flowVector = (flowVector * 2) - 1; // remap from [0:1] to [-1:1]
                flowVector *= _FlowStrength;

                float time = _Time.y * _FlowSpeed;

			    float3 uvwA = FlowUVW(input.uv, flowVector, time, false);
			    float3 uvwB = FlowUVW(input.uv, flowVector, time, true);

			    float4 texA = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvwA.xy) * uvwA.z;
			    float4 texB = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvwB.xy) * uvwB.z;

			    return (texA + texB);
            }

            ENDHLSL
        }
	}
}