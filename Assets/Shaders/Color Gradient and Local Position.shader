Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _TopColor ("Color top", Color) = (0,0,0,1)
        _BotColor ("Color Bottom", Color) = (1,1,1,1)
        _MinHeight("Minimal Height ", float) = -0.5
        _MaxHeight("Maximal Height ", float) = 0.5
        _OffSetHeight ("Off set Height", float )= 0
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
            float _MinHeight;
            float _MaxHeight;
            float  _OffSetHeight;
            
            
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
                ret.positionCS = mul(UNITY_MATRIX_MVP, v.positionOS);
                ret.positionOS = v.positionOS;
                return ret;
            }

            float4 frag (v2f i) : SV_Target
            {
                float localHeight = i.positionOS.y +  _OffSetHeight;
                float totalRange = _MaxHeight - _MinHeight;
                float currentVal = localHeight/totalRange;
                float4 color = float4(currentVal,currentVal,currentVal, 1);
                return _BotColor * (1-color) + _TopColor * color;
                return lerp(_BotColor,_TopColor,color);
            }
            ENDHLSL
        }
    } 
}
