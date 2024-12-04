Shader "Custom/FakeDepth"
{
    Properties
    {
    }
    SubShader
    {
        Tags {  }

        Pass
        {
            ColorMask 0

            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #pragma vertex vert
            #pragma fragment frag

            struct Input
            {
                float4 positionOS:POSITION;
            };

            struct v2f
            {
                float4 positionCS:SV_POSITION;
            };


            v2f vert (Input vertInput)
            {
                v2f ret;
                ret.positionCS = mul(UNITY_MATRIX_MVP, vertInput.positionOS);
                return ret;
            }
             
            float4 frag (v2f fragInput) : SV_Target
            {
                return 1;
            }
            ENDHLSL
        }
    }
}