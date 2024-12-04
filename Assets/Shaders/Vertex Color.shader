Shader "Unlit/Vertex Color"
{
    Properties
    {
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
 
       
            struct Input
            {
                float4 vertexColor:COLOR0;
                float4 positionOS : POSITION;
            };

            struct v2f
            {
                float4 vertexColor:COLOR0;
                float4 positionCS : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (Input v)
            {
                v2f ret;
                ret.positionCS = mul(UNITY_MATRIX_MVP, v.positionOS);
                ret.vertexColor = v.vertexColor;
                return ret;
            }

            float4 frag (v2f i) : SV_Target
            {
                return i.vertexColor;
            }
            ENDHLSL
        }
    }
}
