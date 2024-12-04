Shader "Custom/ScrollingTex"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _fU("Speed u", float) = 0
        _fV("Speed v", float) = 0
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

            float _fU;
            float _fV;
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;

            struct input
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            

            v2f vert (input v)
            {
                v2f ret;
                ret.vertex = mul(UNITY_MATRIX_MVP, v.positionOS);

                float x = _Time.y * _fU;
                float y = _Time.y * _fV;
                
                v.uv = float2(x + v.uv.x, y + v.uv.y);
                ret.uv = TRANSFORM_TEX(v.uv,_MainTex);
                
                return ret;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 Color = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,float2(i.uv.x,i.uv.y));
                return Color;
            }
            ENDHLSL
        }
    }
}
