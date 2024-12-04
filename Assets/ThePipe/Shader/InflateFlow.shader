Shader "Custom/inflateFlow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _InflateFactor("Inflate Factor", float) = 0.3
        _Progress("Progress",Range(0,2)) = 0.5
        _InflateLength("Inflate Length", Range(0,1)) = 0.03
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);
            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;

            float _Progress;
            float _InflateFactor;
            float _InflateLength;
            
            struct input
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float2 uvFlow : TEXCOORD2;
                float3 normalOS : NORMAL;
                float4 vertexColor:COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 screenPos : SV_POSITION;
            };
            

            v2f vert (input v)
            {
                v2f ret;
                float3 newPositionOs = v.positionOS;
                float3 localMove = v.normalOS * _InflateFactor;
                float smoothStepMin = smoothstep(v.uvFlow.y - 0.01, v.uvFlow.y + 0.01, _Progress);
                float smoothStepMax = smoothstep(v.uvFlow.y + _InflateLength + 0.01, v.uvFlow.y +_InflateLength - 0.01, _Progress);
                float localMoveFactor = smoothStepMin * smoothStepMax ;
                localMove *= localMoveFactor;
                
                newPositionOs+= localMove;
                ret.screenPos = TransformObjectToHClip(newPositionOs);
                ret.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return ret;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 Color = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
                return Color ;
            }
            ENDHLSL
        }
    }
}
