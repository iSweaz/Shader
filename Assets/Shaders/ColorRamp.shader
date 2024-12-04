Shader "Unlit/ColorRamp"
{
    Properties
    {
      
         [NoScaleOffset] _MainTex("Main texture",2D) = "white" {}
        _LightDirection("Direction Light", Vector) = (0,-1,0,0)
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Geometry" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            float4  _LightDirection;
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            struct Input
            {
                float4 positionOS:POSITION;
                float2 uv: TEXCOORD0;
                float3 normalOS :NORMAL;
            };
            struct v2f
            {
                float4 positionCS:SV_POSITION;
                float2 uv: TEXCOORD0;
                float3 normalWS:TEXCOORD1;
               
            };
            
            v2f vert (Input vertInput) 
            {
                v2f ret;
                ret.positionCS = mul(UNITY_MATRIX_MVP,vertInput.positionOS);
                ret.uv = vertInput.uv;
                ret.normalWS = mul(UNITY_MATRIX_M, float4(vertInput.normalOS, 0));
                return ret ;
            }

            float4 frag (v2f fragInput) : SV_Target
            {
                float3 normalizedNormal  = normalize(fragInput.normalWS);
                float3 normalizedLight  = normalize(_LightDirection);
                float Ndotl = dot(normalizedNormal,-normalizedLight);
                float remappedNdL = (Ndotl + 1) *0.5;
                
                float4 Lightness = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,float2(remappedNdL,0));
                return Lightness;
            }
            ENDHLSL
        } 
    }
}
