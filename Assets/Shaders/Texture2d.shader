Shader "Unlit/Test"
{
    Properties
    {
        _MainTex("Main texture",2D) = "white" {}
        [Header(Rotation)]
        [Toggle(Rotation)]
        _ActivateRot("Rotate actif", float) = 1 
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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;
            float _ActivateRot;
            
            struct Input
            {
                float3 positionOS:POSITION;
                float2 uv:TEXCOORD0;
            };
            struct v2f
            {
                float4 positionHS:SV_POSITION;
                float2 uv:TEXCOORD0;
            };
            
            v2f vert (Input vertInput) 
            {
                v2f ret;
                float3 os =vertInput.positionOS; // os = object space || ws = world space || ls = local space
                ret.uv = TRANSFORM_TEX(vertInput.uv, _MainTex);
                ret.positionHS = mul(UNITY_MATRIX_MVP, float4 (os,1));
                if(_ActivateRot>0)
                ret.uv.x += _Time.y * 0.05;
                return ret ;
            }

            float4 frag (v2f fragInput) : SV_Target
            {
                float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, fragInput.uv);
                return color;
            }
            ENDHLSL
        } 
    }
}
