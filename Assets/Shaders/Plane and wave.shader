Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _TopColor ("Color top", Color) = (0,0,0,1)
        _BotColor ("Color Bottom", Color) = (1,1,1,1)
        _Bot("Bottom ", float) = -1
        _Top("Top ", float) =1
        _Speed("Speed", float) = 4
        _MaxHeight("Maximal Height ", float) =1
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
            float4 _TopColor;
            float4 _BotColor;
            float _Bot;
            float _Top;
            float _MaxHeight;
 
            float _Speed;
            
            struct Input
            {
                float4 positionOS : POSITION;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float4 positionOS : TEXCOORD0;
            };



            v2f vert (Input v)
            {
                v2f ret;
                float4 positionWS = mul(UNITY_MATRIX_M, v.positionOS);
                float inputSinus = _Time.y * _Speed + v.positionOS.x;
                float DeltaY= sin(inputSinus) * _MaxHeight;
                positionWS.y += DeltaY;
                ret.positionCS = mul(UNITY_MATRIX_VP, positionWS);
                ret.positionOS = v.positionOS;
                ret.positionOS.y += DeltaY;
                return ret;
            }

            float4 frag (v2f i) : SV_Target
            {
                float value = i.positionOS.y;
                float invlerp = (value - _Bot) / (_Top - _Bot);
                return lerp(_BotColor,_TopColor,invlerp);
            }
            ENDHLSL
        }
    } 
}
