using UnityEngine;

namespace Ez.Lua
{
    public class UILuaUtil
    {
        /// <summary>
        /// 通过int数值设置颜色
        /// </summary>
        /// <param name="uicomp"></param>
        /// <param name="color">0xAABBCCFF</param>
        public static void SetColor(UnityEngine.UI.Graphic uicomp, uint color)
        {
            const float DIV_255 = 1.0f / 255f;
            if (uicomp != null)
            {
                Color col = new Color(
                    (color >> 24 & 0xff) * DIV_255,
                    (color >> 16 & 0xff) * DIV_255,
                    (color >> 8 & 0xff) * DIV_255,
                    (color & 0xff) * DIV_255);
                uicomp.color = col;
            }
        }

        /// <summary>
        /// 通过字符串设置颜色
        /// </summary>
        /// <param name="uicomp"></param>
        /// <param name="colorStr"> '#RRGGBBAA' </param>
        public static void SetColorStr(UnityEngine.UI.Graphic uicomp, string colorStr)
        {
            if (uicomp != null)
            {
                Color col;
                if (ColorUtility.TryParseHtmlString(colorStr, out col))
                {
                    uicomp.color = col;
                }
                else
                {
                    Debug.LogError("parse Html color string error:" + colorStr);
                }
            }
        }
    }
}