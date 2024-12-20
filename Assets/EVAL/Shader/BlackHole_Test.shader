Shader "Custom/BlackHole_Test"
{
    Properties 
    {
        _Maintex("texture",2D) = "Red" {}
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
            #pragma target 3.0


            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
       

            
            sampler2D _Maintex;
            uniform float4x4 _CamFrustrum, _CamToWorld;
            uniform float _maxDistance;
            uniform float4 _sphere1;
            
            struct Input
            {
                float4 positionOS:POSITION;
                float2 uv : TEXCOORD0;
            };

            struct V2F
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 ray : TEXCOORD1;
            };

            float sdSphere (float3 p, float s)
            {
                return length(p) - s;
            }
            
            float distanceField(float3 p)
            {
                float Sphere1 = sdSphere(p- _sphere1.xzw, _sphere1.y/2);
                return Sphere1;
            }

            float4 raymarching(float3 ro, float3 rd)
            {
                float4  result = float4(1,1,1,1);
                const int max_iteration = 64;
                float t = 0; //distance of the ray

                for (int i=0; i < max_iteration;i++)
                {
                    if (t>_maxDistance)
                    {
                        result = float4(rd,1);
                        break;
                    }
                    float3 p = ro + rd * t;
                    float d = distanceField(p);
                    if (d<0.01)
                    {
                        result = float4(1,0,0,1);
                        break;
                    }
                    t+=d;
                }
                return result;
            }

            
            V2F vert(Input input)
            {
                V2F output;
                half index = input.positionOS.z;
                input.positionOS.z = 0;
                output.vertex = mul(UNITY_MATRIX_MVP, input.positionOS);
                output.uv = input.uv;

                output.ray = _CamFrustrum[(int)index].xyz;

                output.ray/= abs(output.ray.z);
                output.ray = mul(_CamToWorld, output.ray);
                return output;
            }

            float4 frag(V2F input) : SV_TARGET
            {
                float3 RayDirection = normalize(input.ray.xyz);
                float3 RayOrigin = _WorldSpaceCameraPos;
                float4 result = raymarching(RayOrigin,RayDirection);
                return result; 
                
            }
            ENDHLSL
        }
    }
}
