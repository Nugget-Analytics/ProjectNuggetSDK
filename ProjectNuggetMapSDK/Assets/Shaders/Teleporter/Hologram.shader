Shader "Shader Forge/Hologram"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        _Gradient("Gradient", 2D) = "white" {}
        _Color("Color", Color) = (1,0,0,1)
        _GradientUspeed("Gradient U speed", Float) = 0
        _GradientVspeed("Gradient V speed", Float) = 0.1
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }

        Pass
        {
            Name "Forward"

            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            Lighting Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _Gradient;

            float4 _MainTex_ST;
            float4 _Gradient_ST;

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
                UNITY_DEFINE_INSTANCED_PROP(float, _GradientUspeed)
                UNITY_DEFINE_INSTANCED_PROP(float, _GradientVspeed)
            UNITY_INSTANCING_BUFFER_END(Props)

            struct Attributes
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            float RGBtoGrayscale(float3 c)
            {
                return dot(c, float3(0.299, 0.587, 0.114));
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);

                float4 positionWS = mul(unity_ObjectToWorld, IN.vertex);

                OUT.positionCS = mul(UNITY_MATRIX_VP, positionWS);
                OUT.positionWS = positionWS.xyz;
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);

                return OUT;
            }

            fixed4 frag(Varyings IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);

                float4 color = UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
                float uspeed = UNITY_ACCESS_INSTANCED_PROP(Props, _GradientUspeed);
                float vspeed = UNITY_ACCESS_INSTANCED_PROP(Props, _GradientVspeed);

                float3 mainTex = tex2D(_MainTex, IN.uv).rgb;

                float gray = RGBtoGrayscale(mainTex);

                float2 gradUV = float2(0.0, IN.positionWS.y)
                    + _Time.y * float2(uspeed, vspeed);

                gradUV = TRANSFORM_TEX(gradUV, _Gradient);

                float gradient = tex2D(_Gradient, gradUV).r;

                return fixed4(color.rgb, gray * gradient);
            }

            ENDCG
        }
    }
}
