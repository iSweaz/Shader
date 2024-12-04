Shader "Custom/BlendedTex"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [NoScaleOffset] _UpperTex("Upper texture", 2D) = "White" {}
        [NoScaleOffset] _MaskTex("Mask texture", 2D) = "White" {}
        _ProgressBar("Mask Progress",Range(0,1)) = 0
        _ProgressBarWidth("Mask Progress width",Range(0,1)) = 0
        
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
            #include "Assets/Shaders/Photoshop.hlsl"

            TEXTURE2D(_MainTex);
            TEXTURE2D(_UpperTex);
            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;
            
            

            float _ProgressBar;
            float _ProgressBarWidth;
            
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
                ret.uv = v.uv;
                return ret;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 Mask = SAMPLE_TEXTURE2D(_MaskTex,sampler_MainTex,i.uv);
                float4 Stone = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
                float4 Moss = SAMPLE_TEXTURE2D(_UpperTex,sampler_MainTex,i.uv);
                float4 edge1 = step(Mask,_ProgressBar);
                float4 edge2 = edge1 + _ProgressBarWidth;
                float4 LimitValue = smoothstep(edge1,edge2,Mask);
                float4 overlayBlend = Stone * Moss * 2;
                float4 Color = lerp(Moss,overlayBlend,LimitValue);
                return Color ;
            }
            ENDHLSL
        }
    }
}
