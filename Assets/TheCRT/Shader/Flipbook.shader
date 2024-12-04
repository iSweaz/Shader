Shader "Custom/FlipBook"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        _NumberCellX("Columns(x)",int) = 4
        _NumberCellY("Rows(Y)",int) = 4
        _AnimationSpeedFPS("Frame per seconds", float) = 8
        
       
        
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
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;
            uint  _NumberCellX;
            uint  _NumberCellY;
            float _AnimationSpeedFPS;
            
            


            
            struct input
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 ScreenPos : SV_POSITION;
            };
            

            v2f vert (input v)
            {
                v2f ret;
                ret.ScreenPos = mul(UNITY_MATRIX_MVP, v.positionOS);
                uint totalFrames = _NumberCellX * _NumberCellY;
                uint indexToDisplay = (_Time.y * _AnimationSpeedFPS) %totalFrames ;
                uint indexX = totalFrames/_NumberCellX + indexToDisplay;
                uint indexY = totalFrames/_NumberCellY + indexToDisplay;

                float2 singleSpriteSize = float2(1.0f/ _NumberCellX, 1.0f / _NumberCellY);
                float2 offset = float2(singleSpriteSize.x * indexX, singleSpriteSize.y * indexY);
                    
                ret.uv = v.uv * singleSpriteSize + offset;
                return ret;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
              
                float4 Screen = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
                return Screen ;
            }
            ENDHLSL
        }
    }
}
