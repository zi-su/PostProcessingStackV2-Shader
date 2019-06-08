Shader "Hidden/Custom/GaussianBlur"
{
	HLSLINCLUDE

#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

	TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
	TEXTURE2D_SAMPLER2D(_GrabTex, sampler_GrabTex);
	float4 _MainTex_TexelSize;
	int _SamplingCount = 11;
	int _Sigma = 7;
	struct appdata {
		float3 vertex: POSITION;
		float2 uv: TEXCOORD0;
	};
	struct v2f {
		float4 vertex : SV_POSITION;
		float2 texcoord : TEXCOORD0;
		float2 offsetV : TEXCOORD1;
		float2 offsetH : TEXCOORD2;
		float2 coordV : TEXCOORD3;
		float2 coordH : TEXCOORD4;
	};
	v2f Vert(appdata v)
	{
		v2f o;
		o.vertex = float4(v.vertex.xy, 0.0, 1.0);
		o.texcoord = TransformTriangleVertexToUV(v.vertex.xy);
		o.offsetV = (_MainTex_TexelSize.xy) * float2(0.0,1.0f);
		o.offsetH = (_MainTex_TexelSize.xy) * float2(1.0, 0.0f);

		// サンプリング開始ポイントのUV座標
		o.coordV = o.texcoord - o.offsetV * ((_SamplingCount - 1) * 0.5);
		o.coordH = o.texcoord - o.offsetH * ((_SamplingCount - 1) * 0.5);

		return o;
	}
	float normpdf(float x, float sigma)
	{
		return 0.39894*exp(-0.5*x*x / (sigma*sigma)) / sigma;
	}

	float4 Frag(v2f i) : SV_Target
	{
		float4 color = 0;
		int center = (_SamplingCount -1)/ 2;
		float z = 0.0;
		for (int j = 0; j < _SamplingCount; j++) {
			float x = float(j - center);
			float gauss = normpdf(x, _SamplingCount);
			z += gauss;
			color += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.coordV) * gauss;
			i.coordV += i.offsetV;
		}
		return color / (z);
	}

	float4 Frag2(v2f i) : SV_Target
	{
		float4 color = 0;
		int center = (_SamplingCount - 1) / 2;
		float z = 0.0;
		for (int j = 0; j < _SamplingCount; j++) {
			float x = float(j - center);
			float gauss = normpdf(x, _SamplingCount);
			z += gauss;
			color += SAMPLE_TEXTURE2D(_GrabTex, sampler_GrabTex, i.coordH) * gauss;
			i.coordH += i.offsetH;
		}
		return color / (z);
	}
	ENDHLSL


	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			HLSLPROGRAM

				#pragma vertex Vert
				#pragma fragment Frag

			ENDHLSL
		}

		GrabPass{"_GrabTex"}

		Pass
		{
			HLSLPROGRAM

				#pragma vertex Vert
				#pragma fragment Frag2

			ENDHLSL
		}
	}
}