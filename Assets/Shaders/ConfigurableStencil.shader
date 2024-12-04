Shader "Custom/ConfigurableStencil"
{
    Properties 
    {
        [Header(Stencil)]
        _Stencil ("Stencil ID [0;255]", Float) = 1
		[Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Int) = 8
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilOp ("Stencil Operation", Int) = 2
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilFail ("Stencil Fail", Int) = 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilZFail ("Stencil ZFail", Int) = 0
        [Header(Rendering)]
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull Mode", Int) = 2
		[Enum(Off,0,On,1)] _ZWrite("ZWrite", Int) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Int) = 2
		[Enum(None,0,Alpha,1,Red,8,Green,4,Blue,2,RGB,14,RGBA,15)] _ColorMask("Color Mask", Int) = 0
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Geometry" }

		Cull [_CullMode]
		ZWrite [_ZWrite]
		ZTest [_ZTest]
		ColorMask [_ColorMask]

		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp] 
			Fail [_StencilFail]
			ZFail [_StencilZFail]
		}


        Pass {
            

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag


            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"


            struct Input
            {
                float3 positionOS:POSITION;
            };

            struct V2F
            {
                float4 screenPos:SV_POSITION;
            };


            V2F vert(Input input)
            {
                V2F output;
                output.screenPos =  TransformObjectToHClip(input.positionOS);
                return output;  
            }

            float4 frag(V2F input) : SV_TARGET {
                return float4(1,1,1,1);
            }
            ENDHLSL
        }
    }
}
