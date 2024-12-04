Shader "Custom/BlackHole"
{
    Properties 
    {
        _FirstColor("First Color", Color) = (1,0,0,0)
        _HoleColor("Hole Color",Color) = (0,0,0,1)
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
            #include "Ray.hlsl"
            
            float4 _FirstColor;
            float4 _HoleColor;
            
            struct Input
            {
                float4 positionOS:POSITION;
                float3 normalOS : NORMAL;
            };

            struct V2F
            {
                float4 vertex : SV_POSITION;
                float3 positionWS : TEXCOORD1;
                float3 positionOS : TEXCOORD5;
                float3 normalWS : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
                float4 screenpos : TEXCOORD4;
            };

            float chef(float3 Rayorigin, float3 RayDir, float3 SphereOrigin, float SphereSize)
            {
                float t = 0.0f;
                float3 L = SphereOrigin - Rayorigin ;
                float tca = dot(L, -RayDir);

                if(tca < 0)
                {
                    return 0.0f;
                }
                float d2 = dot(L,L) - tca * tca;
                float radius2 = SphereSize * SphereSize;

                if(d2 > radius2)
                {
                    return 1.0f;
                }
                float thc = sqrt(radius2 - d2);
                t = tca - thc;

                return 0.0f;
                
            }

            
            V2F vert(Input input)
            {
                V2F output;
                output.vertex = TransformObjectToHClip(input.positionOS);
                output.normalWS = mul(unity_ObjectToWorld, float4(input.normalOS, 0));
                float3 positionWS = mul(UNITY_MATRIX_M,input.positionOS);
                output.viewDir = _WorldSpaceCameraPos - positionWS;
                output.positionWS = positionWS;
                output.screenpos = ComputeScreenPos(output.vertex);
                output.positionOS = input.positionOS;
                return output;
            }

            float4 frag(V2F input) : SV_TARGET
            {
                float4 NormalizedVertex = normalize(input.vertex);
                float Hit;
                float3 HitPosition;
                float3 HitNormal;
                // float3 _Object_Position = SHADERGRAPH_OBJECT_POSITION;

                /*Raycast_float(_WorldSpaceCameraPos,normalize(input.viewDir),
                    input.vertex,0.5,Hit,HitPosition,HitNormal);*/

                Hit = chef(_WorldSpaceCameraPos,normalize(input.vertex),
                    input.positionOS,0.5);
                float4 fresnel = dot(normalize(HitNormal), normalize(input.viewDir))*8;
                float4 SphereColor = mul(NormalizedVertex,_FirstColor);
                fresnel *= .5;
                return SphereColor;
               // return  lerp(SphereColor,_HoleColor,Hit);
            }
            ENDHLSL
        }
    }
}
