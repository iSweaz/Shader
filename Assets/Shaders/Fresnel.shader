Shader "Custom/Fresnel"
{
    Properties 
    {
    }
    SubShader
    {
        Tags {  }

        Pass {
            

            HLSLPROGRAM
            

            #pragma vertex vert
            #pragma fragment frag


            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            

            struct Input
            {
                float4 positionOS:POSITION;
                float3 normalOS : NORMAL;
            };

            struct V2F
            {
                float4 vertex : SV_POSITION;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
            };


            V2F vert(Input input)
            {
                V2F output;
                output.vertex = TransformObjectToHClip(input.positionOS);
                output.positionWS = mul(unity_ObjectToWorld, input.positionOS);
                output.normalWS = mul(unity_ObjectToWorld, float4(input.normalOS, 0));
                output.viewDir = _WorldSpaceCameraPos - output.positionWS;
                return output;
            }

            float4 frag(V2F input) : SV_TARGET
            {
                float4 fresnel = dot(normalize(input.normalWS), normalize(input.viewDir));
                return fresnel;
            }
            ENDHLSL
        }
    }
}
