Shader "Custom/SimpleNoise"
{
    Properties
    {
        _Step("Step",float) = 0
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
            #include "WhiteNoise.hlsl"
            

            TEXTURE2D(_MainTex);
            TEXTURE2D(_UpperTex);
            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;
            float _Step;
            

            float _ProgressBar;
            float _ProgressBarWidth;
            
            struct input
            {
                float4 positionOS : POSITION;
            };

            struct v2f
            {
                float3 positionWS : TEXCOORD0;
                float4 positionCS : SV_POSITION;
            };
            

            v2f vert (input v)
            {
                v2f ret;
                ret.positionCS = mul(UNITY_MATRIX_MVP, v.positionOS);
                ret.positionWS = mul(UNITY_MATRIX_M,v.positionOS);
                return ret;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 Color = rand3dTo3d(floor(i.positionWS * _Step)/_Step); 
                return float4(Color,1) ;
            }
            ENDHLSL
        }
    }
}
