Shader "Unlit/Lambert"
{
   
    Properties
    {
        [Header(Material Infos)]
        _MainColor ("Albedo", Color) = (1,1,1,1)

        [Header(Light Infos)]
         _LightDirection ("Light Direction", Vector) = (0,-1,0,1)
         _LightColor ("Light Color", Color) = (1,1,1,1)
         _LightAttenuation ("Light Attenuation", Range(0, 1)) = 1
         _LightHardness("Light Hardness", Range(0,1)) = 1
         _Smoothness ("Smoothness", Range(1, 200)) = 10
         _Step ("Step", float) = 3
    }
    SubShader
    {
        Tags {  }

        Pass
        {
            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #pragma vertex vert
            #pragma fragment frag

            struct Input
            {
                float4 positionOS:POSITION;
                float3 normalOS:NORMAL;
            };

            struct v2f
            {
                float4 positionCS:SV_POSITION;
                float3 normalWS:TEXCOORD1;
                float4 positionWS:TEXCOORD2;
            };

            float4 _MainColor;
            float4 _LightDirection;
            float4 _LightColor;
            float _LightAttenuation;
            float _LightHardness;
            float _Smoothness;
            float _Step;

            float3 Lambert(float3 lightDir, float3 normal, float3 lightColor, float3 albedo, float lightAttenuation) {
                float NdL = max(0, dot(lightDir, normal));
                NdL = NdL * _LightHardness + 1 - _LightHardness;
                float3 finalColor = albedo * lightColor * NdL * lightAttenuation;
                return finalColor;
            }

            float3 LambertCelShading(float3 lightDir, float3 normal, float3 lightColor, float3 albedo, float lightAttenuation, float step) {
                float NdL = max(0, dot(lightDir, normal));

                NdL = round(NdL * step) / step;

                NdL = NdL * _LightHardness + 1 - _LightHardness;

                float3 finalColor = albedo * lightColor * NdL * lightAttenuation;
                return finalColor;
            }

            float3 BlinnPhong(float3 lightDir, float3 normal, float3 positionWS, float3 lightColor, float shininess) {
                float3 viewDir = normalize(_WorldSpaceCameraPos - positionWS);
                float3 H = normalize(lightDir + viewDir);
                float specular = pow(saturate(dot(normal, H)), shininess);
                return lightColor * specular;
             }

             float3 BlinnPhongCelShading(float3 lightDir, float3 normal, float3 positionWS, float3 lightColor, float shininess) {
                float3 viewDir = normalize(_WorldSpaceCameraPos - positionWS);
                float3 H = normalize(lightDir + viewDir);
                float specular = pow(saturate(dot(normal, H)), shininess);
                specular = 1 - step(specular, 0.5);
                return lightColor * specular;
             }


            v2f vert (Input vertInput)
            {
                v2f ret;
                ret.positionCS = mul(UNITY_MATRIX_MVP, vertInput.positionOS);
                ret.normalWS = mul(unity_ObjectToWorld, float4(vertInput.normalOS, 0));
                ret.positionWS = mul(unity_ObjectToWorld, float4(vertInput.positionOS.xyz, 1));
                return ret;
            }
             
            float4 frag (v2f v) : SV_Target
            {
                float3 diffuseColor = LambertCelShading(
                    normalize(_LightDirection) * -1, 
                    normalize(v.normalWS),
                    _LightColor.rgb,
                    _MainColor.rgb,
                    _LightAttenuation,
                    _Step);

                 float3 specularColor = BlinnPhongCelShading(
                    normalize(_LightDirection) * -1, 
                    normalize(v.normalWS),
                    v.positionWS.xyz,
                    _LightColor.rgb,
                    _Smoothness);
                float3 finalColor = diffuseColor + specularColor;
                return float4(finalColor, 1);
            }
            ENDHLSL
        }
    }
}

