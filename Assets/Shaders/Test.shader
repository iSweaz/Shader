Shader "Unlit/Test"
{
    Properties
    {
        _MyColor("WonderFul Color",Color) = (0.5,0.5,0.5,1)
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
            float4 _MyColor ; 
            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct v2f
            {
                float4 positionCS : SV_POSITION;
            };
            struct Input
            {
                float3 positionOS : POSITION;
            };
            
            v2f vert (Input vertInput) 
            {
                v2f ret;
                float3 os =vertInput.positionOS; // os = object space || ws = world space || ls = local space
                //os.y += sin(_Time.y); // move the wall
                ret.positionCS = mul(UNITY_MATRIX_MVP, float4 (os,1));
                return ret;
            }

            float4 frag (v2f fragInput) : SV_Target
            {
                return _MyColor;
            }
            ENDHLSL
        } 
    }
}
