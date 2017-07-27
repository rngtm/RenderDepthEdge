// Thanks to http://qiita.com/bokkuri_orz/items/08cbaeae6a34fed7f903
Shader "Hidden/RenderDepthEdge" {
    Properties {
        [HideInInspector] _MainTex ("Depth Texture", 2D) = "white" {}
        _EdgeColor ("Edge Color", Color) = (1,1,1,1)
        _Threshold ("Edge Threshold", Range(0.0001, 1)) = 0.01
        _Thick("Thick", Range(0.1, 5)) = 1
    }

    SubShader {
        Tags { "RenderType"="Opaque" }
        ZTest Off
        ZWrite Off
        Lighting Off
        AlphaTest Off

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4  _MainTex_ST;
            float _Threshold;
            float4 _EdgeColor;
            float _Thick;
            float4 _MainTex_TexelSize; // 1テクセルを正規化した値

            struct appdata_t {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };
            struct v2f {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            float4 frag(v2f input) : Color
            {
                float2 t = _MainTex_TexelSize * _Thick;
                float col00 = Linear01Depth(tex2D(_MainTex, input.texcoord + float2(-t.x, -t.y)).r);
                float col10 = Linear01Depth(tex2D(_MainTex, input.texcoord + float2(+t.x, -t.y)).r);
                float col01 = Linear01Depth(tex2D(_MainTex, input.texcoord + float2(-t.x, +t.y)).r);
                float col11 = Linear01Depth(tex2D(_MainTex, input.texcoord + float2(+t.x, +t.y)).r);
                float val = (col00 - col11) * (col00 - col11) + (col10 - col01) * (col10 - col01);

                // 閾値以下ならクリップする
                clip(val - _Threshold);

                return _EdgeColor;
            }
            ENDCG
        }
    } 
}