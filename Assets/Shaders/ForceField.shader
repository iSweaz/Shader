Shader "Custom/ForceField"
{
    Properties {
        _MainColor ("Main Color", Color) = (0,0.13,0.67,0.1)
        _FresnelColor ("Fresnel Color", Color) = (0,0.99,0.91,1)
		_FresnelExponent ("Fresnel Exponent", float) = 3
        _PulseSpeed("Pulse Speed", float) = 0
        _PulseRange("Pulse Range", float) = 0

        _OffsetScaleNoise ("Offset Scale Noise", vector) = (0,0,0,1)
        _NoiseMoveSpeed ("Noise Move Speed", vector) = (0,0,0,0)
        
        _RemapNoise ("Remap Noise", vector) = (0,1,0,1)

        [MainTexture] _MainTex("Main Texture", 2D) = "white" {}

        [Toggle(DEBUG_MASK)] _DebugNoise("Debug Mask", Float) = 0
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Transparent" }

        Pass {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature DEBUG_MASK

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/jp.keijiro.noiseshader/Shader/SimplexNoise3D.hlsl"
            #include "Interpolation.hlsl"

            float4 _MainColor;
            float4 _FresnelColor;
		    float _FresnelExponent;
            float _PulseSpeed;
            float _PulseRange;

            float4 _OffsetScaleNoise;
            float4 _RemapNoise;
            float4 _NoiseMoveSpeed;

             // This macro declares _MainTex as a Texture2D object.
            TEXTURE2D(_MainTex);
            // This macro declares the sampler for the _MainTex texture.
            SAMPLER(sampler_MainTex);
            // Necessary for the tiling and offset function to work
            float4 _MainTex_ST;

            struct Input
            {
                float3 positionOS:POSITION;
                float3 normal:NORMAL;
                float2 uv:TEXCOORD0;
            };

            struct V2F
            {
                float4 positionCS:SV_POSITION;
                float3 normalWS:TEXCOORD0;
                float3 viewDir: TEXCOORD1;
                float3 positionWS: TEXCOORD2;
                float2 uv:TEXCOORD3;
            };

            V2F vert(Input input)
            {
                V2F output;
                output.positionCS = TransformObjectToHClip(input.positionOS);
                output.normalWS = mul(unity_ObjectToWorld, float4(input.normal, 0));
                float3 positionWS = mul(unity_ObjectToWorld, float4(input.positionOS, 1));
                output.viewDir = _WorldSpaceCameraPos - positionWS;
                output.positionWS = positionWS;
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                return output;
            }

            float4 frag(V2F input):SV_TARGET
            {
                float3 inputNoise = input.positionWS;
                inputNoise += _OffsetScaleNoise.xyz;
                inputNoise *= _OffsetScaleNoise.w;
                inputNoise += _NoiseMoveSpeed * _Time.y;
                float colorNoise = SimplexNoise(inputNoise);
                colorNoise = Remap(_RemapNoise.x, _RemapNoise.y, _RemapNoise.z, _RemapNoise.w, colorNoise);
                #ifdef DEBUG_MASK
                return float4(colorNoise, colorNoise, colorNoise, 1);
                #endif

                //get the dot product between the normal and the view direction
			    float fresnel = dot(normalize(input.normalWS), normalize(input.viewDir));
			    //invert the fresnel so the big values are on the outside
			    fresnel = saturate(1 - fresnel);
			    //raise the fresnel value to the exponents power to be able to adjust it

                _FresnelExponent += sin(_Time.y * _PulseSpeed) * _PulseRange;

			    fresnel = pow(fresnel, _FresnelExponent);
                fresnel *= colorNoise;
                
                float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);

                fresnel *= color;

			    //lerp between the main color and the fresnel color depends on the fresnel value
                return lerp(_MainColor, _FresnelColor, fresnel);
            }

            ENDHLSL
        }
    }
}
