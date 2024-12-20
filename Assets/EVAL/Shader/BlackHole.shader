Shader "Custom/BlackHole"
{
    Properties 
    {
        _HoleColor("Hole Color",Color) = (0,0,0,1)
        _SphereSize("Sphere Size",Range(0,1)) = 0.5 
    }
    SubShader
    {
        Tags {"RenderPipeline"="UniversalRenderPipeline" "Queue" = "Transparent" "RenderType"= "Transparent"}
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass {
            

            HLSLPROGRAM
            

            #pragma vertex vert
            #pragma fragment frag


            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "SF_Raycast.hlsl"
            
            float _SphereSize;
            float4 _HoleColor;
            
            struct Input
            {
                float4 positionOS:POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct V2F
            {
                float4 vertex : SV_POSITION;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
                float4 screenpos : TEXCOORD4;
                float2 uv : TEXCOORD5;
            };
            
            
            V2F vert(Input input)
            {
                V2F output;
                output.vertex = TransformObjectToHClip(input.positionOS);
                output.normalWS = mul(unity_ObjectToWorld, float4(input.normalOS, 0));
                float3 positionWS = mul(UNITY_MATRIX_M,input.positionOS);
                output.viewDir = _WorldSpaceCameraPos - positionWS;
                output.positionWS = positionWS;
                output.screenpos = ComputeScreenPos(output.vertex);
                MirrorUVCoordinates_float(input.uv,output.uv);
                return output;
            }

            float4 frag(V2F input) : SV_TARGET
            {
                float4 NormalizedVertex = normalize(input.vertex);
                float Hit;
                float3 HitPosition;
                float3 HitNormal;

                Raycast_float(_WorldSpaceCameraPos,normalize(input.viewDir),
                    input.vertex,_SphereSize,Hit,HitPosition,HitNormal);
                
                float4 fresnel = dot(normalize(HitNormal), normalize(input.viewDir))*8;
                
                return  lerp(float4(input.uv,1,1),fresnel,Hit);
            }
            ENDHLSL
        }
    }
}
