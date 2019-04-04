Shader "Unlit/AbilityButton 1"
{
    Properties
    {
		_EnchantmentColor("Enchantment color ", Color) = (1,1,1,1)
		_MainTex("Base (RGB), Axe Mask(A)", 2D) = "white" {}
		_NoiseTex("Noise (A)", 2D) = "white" {}
		_SaturationMaskTex("Saturation Mask", 2D) = "white" {}
		_LoadingAlphaGradient("Loading alpha gradient (A)", 2D) = "white" {}  // Alpha mask textures for this shader are from https://forum.unity.com/threads/circular-fade-in-out-shader.344816/ or other internet pages
		_EnchantmentSpeedX("Effect speed X", Range(-1,1)) = 0.0
		_EnchantmentSpeedY("Effect speed Y", Range(-1,1)) = 0.0
		_BrightnessFactor("Additive brightness", Range(0,5)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex, _NoiseTex, _LoadingAlphaGradient, _SaturationMaskTex;
            float4 _MainTex_ST;

			fixed4 _EnchantmentColor;

			float _LoadingValue;
			half _EnchantmentSpeedX;
			half _EnchantmentSpeedY;
			half _BrightnessFactor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float2 fixedNoiseUV = i.uv;
				fixedNoiseUV.x = i.uv.x - _Time.y * _EnchantmentSpeedX; // -_Time.y is a correction to follow the standard axis representation
				fixedNoiseUV.y = i.uv.y - _Time.y * _EnchantmentSpeedY;

				// Sample color of textures
				fixed4 color = tex2D(_MainTex, i.uv);
				float saturationMaskColor = tex2D(_SaturationMaskTex, i.uv).r;
				fixed4 noiseColor = tex2D(_NoiseTex, fixedNoiseUV) * _EnchantmentColor;
				float loadingMaskColor = tex2D(_LoadingAlphaGradient, i.uv).r;

				// Operate with the colors
				float greyscale = Luminance(color.rgb); // r + g + b / 3
				fixed3 colorGreyscale = fixed3(greyscale, greyscale, greyscale);
				fixed lum = saturate(greyscale * _BrightnessFactor);

				// Save certain comprobations
				float isSaturationMask = step(saturationMaskColor, 0.0);
				float isLoadMask = step(loadingMaskColor, _LoadingValue);
				float isLoading = step(1.0, _LoadingValue);

				//Calculate the color 
				fixed3 saturatedColor = isSaturationMask * color.rgb + (1.0 - isSaturationMask) * (color.rgb + lum) + (noiseColor * color.a);
				fixed3 loadingColor = isLoadMask * color.rgb + (1.0 - isLoadMask) * colorGreyscale;

				fixed3 col = isLoading * saturatedColor + (1 - isLoading) * loadingColor;

				// Return the obtained color
                return fixed4(col.r, col.g, col.b, 1.0);
            }
            ENDCG
        }
    }
}
