Shader "Correction/Disappearing"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _MaskProgress("Mask Progress", range(0, 1)) = 1
        _MaskProgressWith("Mask Progress With", range(0, 1)) = 0

        _OffsetScaleNoise ("Offset Scale Noise", vector) = (0,0,0,1)
        _RemapNoise ("Remap Noise", vector) = (0,1,0,1)
        [Toggle(DEBUG_NOISE)] _DebugNoise("Debug Noise", Float) = 0
    }
    SubShader
    {
        Tags {  "Queue" = "Transparent"}

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            HLSLPROGRAM

            #pragma shader_feature DEBUG_NOISE

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/jp.keijiro.noiseshader/Shader/SimplexNoise3D.hlsl"
            #include "Interpolation.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;

            float _MaskProgress;
            float _MaskProgressWith;

            float4 _OffsetScaleNoise;
            float4 _RemapNoise;

            #pragma vertex vert
            #pragma fragment frag

            struct Input
            {
                float4 positionOS:POSITION;
                float2 uv:TEXCOORD0;
            };

            struct v2f
            {
                float4 positionCS:SV_POSITION;
                float3 positionOS:TEXCOORD1;
                float2 uv:TEXCOORD0;
            };


            v2f vert (Input vertInput)
            {
                v2f ret;
                ret.positionCS = mul(UNITY_MATRIX_MVP, vertInput.positionOS);    
                ret.positionOS = vertInput.positionOS;
                ret.uv = TRANSFORM_TEX(vertInput.uv, _MainTex);
                return ret;
            }
             
            float4 frag (v2f fragInput) : SV_Target
            {
                float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, fragInput.uv);
                float3 inputMask = fragInput.positionOS;
                inputMask += _OffsetScaleNoise.xyz;
                inputMask *= _OffsetScaleNoise.w;
                float mask = SimplexNoise(inputMask) * 0.5 + 0.5;
                mask = Remap(_RemapNoise.x, _RemapNoise.y, _RemapNoise.z, _RemapNoise.w, mask);
                #ifdef DEBUG_NOISE
                return float4(mask, mask, mask, 1);
                #endif
                float theshold = saturate(1 - _MaskProgress);
                float lerpValue = smoothstep(theshold, theshold + _MaskProgressWith, mask);
               
                return lerp(float4(color.rgb, 1), float4(color.rgb, 0), lerpValue);
            }
            ENDHLSL
        }
    }
}