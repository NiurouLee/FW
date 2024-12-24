// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "UI/UIOutMask"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
        //-------------------add----------------------
        _MaskTex ("Sprite Texture", 2D) = "white" {}
        _Center("Center", vector) = (0, 0, 0, 0)
        _Radius("Radius", Range(0,1000)) = 1 
        _TransitionRange("Transition Range", Range(1, 100)) = 10
        [KeywordEnum(ROUND, TEXTURE)] _MaskMode("Mask mode", Float) = 0
        
        _MinX ("Min X", Float) = -10
        _MaxX ("Max X", Float) = 10
        _MinY ("Min Y", Float) = -10
        _MaxY ("Max Y", Float) = 10
        //-------------------add----------------------
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile __ UNITY_UI_CLIP_RECT
            #pragma multi_compile __ UNITY_UI_ALPHACLIP
            #pragma multi_compile _MASKMODE_ROUND _MASKMODE_TEXTURE

            struct appdata_t
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;

                float2 uvAlpha : TEXCOORD2;
                
                UNITY_VERTEX_OUTPUT_STEREO
            };

            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            //-------------------add----------------------

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            half _Radius;
            float2 _Center;
            half _TransitionRange;

            float _MinX;
            float _MaxX;
            float _MinY;
            float _MaxY;

            float4x4 _WorldToMask;

            //-------------------add----------------------

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                //OUT.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                OUT.vertex = UnityObjectToClipPos(v.vertex);

                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                //OUT.texcoord = v.texcoord;

                OUT.color = v.color * _Color;
                
				OUT.uvAlpha = mul(_WorldToMask, OUT.worldPosition).xy + float2(0.5f, 0.5f);
				OUT.uvAlpha = OUT.uvAlpha * _MaskTex_ST.xy + _MaskTex_ST.zw;
                
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

                #ifdef UNITY_UI_CLIP_RECT
                    color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                    clip (color.a - 0.001);
                #endif

                //-------------------add----------------------
                #ifdef _MASKMODE_ROUND
                //计算片元世界坐标和目标中心位置的距离
                float dis = distance(IN.worldPosition.xy, _Center.xy);
                //过滤掉距离小于（半径-过渡范围）的片元
                clip(dis - (_Radius - _TransitionRange));
                //优化if条件判断，如果距离小于半径则执行下一步，等于if(dis < _Radius)
                fixed tmp = step(dis, _Radius);
                //计算过渡范围内的alpha值
                color.a *= (1 - tmp) + tmp * (dis - (_Radius - _TransitionRange)) / _TransitionRange;
                #else
                
                // color.a *= (IN.worldPosition.x >= _MinX );
                // color.a *= (IN.worldPosition.x <= _MaxX);
                // color.a *= (IN.worldPosition.y >= _MinY);
                // color.a *= (IN.worldPosition.y <= _MaxY);
                // color.rgb *= color.a;
                #endif
                //-------------------add----------------------
                return color;
            }
            ENDCG
        }
    }
}