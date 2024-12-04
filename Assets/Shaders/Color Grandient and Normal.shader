Shader "Unlit/Vertex Color"
{
    Properties
    {
         _FirstColor ("Color 1", Color) = (0,0,0,1)
        _SecondColor("Color 2", Color) = (1,1,1,1)
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
 
            float4 _FirstColor;
            float4 _SecondColor;
            
            struct Input
            {
                float3 normalVertex:NORMAL;
                float4 positionOS: POSITION;
            };

            struct v2f
            {
                float4 normalVertexWS:TEXCOORD0;
                float4 positionCS : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (Input v)
            {
                v2f ret;
                ret.positionCS = mul(UNITY_MATRIX_MVP, v.positionOS);
                ret.normalVertexWS = mul(UNITY_MATRIX_M,float4(v.normalVertex,0));
                return ret;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 normalizedNormal = i.normalVertexWS/length(i.normalVertexWS);
                float lerpCoeff = dot(float3(0,1,0), normalizedNormal);
                return lerp(_FirstColor,_SecondColor,lerpCoeff);
            }
            ENDHLSL
        }
    }
}
