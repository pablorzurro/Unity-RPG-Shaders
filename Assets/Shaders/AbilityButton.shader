Shader "Custom/AbilityButton"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_EnchantmentColor("Enchantment color ", Color) = (1,1,1,1)
        _MainTex ("Base (RGB), Axe Mask(A)", 2D) = "white" {}
		_NoiseTex("Noise (A)", 2D) = "white" {}
		_SaturationMaskTex("Saturation Mask", 2D) = "white" {}
 		_LoadingAlphaGradient("Loading alpha gradient (A)", 2D) = "white" {}  // Alpha mask textures for this shader are from https://forum.unity.com/threads/circular-fade-in-out-shader.344816/ or other internet pages
		_EnchantmentSpeedX("Effect speed X", Range(-1,1)) = 0.0
		_EnchantmentSpeedY("Effect speed Y", Range(-1,1)) = 0.0
		_BrightnessFactor("Additive brightness", Range(0,5)) = 1.0
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex, _NoiseTex, _LoadingAlphaGradient, _SaturationMaskTex;
	
        struct Input
        {
            float2 uv_MainTex;
			float2 uv_NoiseTex;
			float2 uv_LoadingAlphaGradient;
			float2 uv_SaturationMaskTex;
        };

		float _LoadingValue;/*("Loading value", Float) = 0.0*/

        half _Glossiness;
        half _Metallic;
		half _EnchantmentSpeedX;
		half _EnchantmentSpeedY;
		half _BrightnessFactor;
		
        fixed4 _Color, _EnchantmentColor;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
			
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			float2 fixedNoiseUV = IN.uv_NoiseTex;
			fixedNoiseUV.x = fixedNoiseUV.x -_Time.y * _EnchantmentSpeedX; // -_Time.y is a correction to follow the standard axis representation
			fixedNoiseUV.y = fixedNoiseUV.y -_Time.y * _EnchantmentSpeedY;

            // Save all the color values from the uvs of each texture
            fixed4 color = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			float saturationMaskColor = tex2D(_SaturationMaskTex, IN.uv_SaturationMaskTex).r;
			fixed4 noiseColor = tex2D(_NoiseTex, fixedNoiseUV) * _EnchantmentColor;
			float loadingMaskColor = tex2D(_LoadingAlphaGradient, IN.uv_LoadingAlphaGradient).r;
			
			// Operate with the colors
			float greyscale = Luminance(color.rgb); // r + g + b / 3
			fixed3 colorGreyscale = fixed3(greyscale, greyscale, greyscale);
			fixed lum = saturate(greyscale * _BrightnessFactor);
			
			// Save certain comprobations
			float isSaturationMask = step(saturationMaskColor, 0.0);
			float isLoadMask = step(loadingMaskColor, _LoadingValue); 
			float isLoading = step(1.0, _LoadingValue);

			fixed3 saturatedColor = isSaturationMask * color.rgb + (1.0 - isSaturationMask) * (color.rgb + lum) + (noiseColor * color.a);
			fixed3 loadingColor = isLoadMask * color.rgb + (1.0 - isLoadMask) * colorGreyscale;

            o.Albedo = isLoading * saturatedColor + (1 - isLoading) * loadingColor;

            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = color.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
