//---------------------------------------------------------
//将SafeAreaPannel 下的子节点全屏 即反安全区
//---------------------------------------------------------
using UnityEngine;

namespace Ez.UI
{
    /// <summary>
    /// 适配全屏
    /// 文件名 BkgFitFullScreen.cs
    /// </summary>
    public class BkgFitFullScreen : MonoBehaviour
    {
        private RectTransform target;

        void Awake()
        {
            target = GetComponent<RectTransform>();
            ApplySafeArea();

            UGUIRoot.AddUpdateCallback(OnScreenUpdate);
        }

        void OnScreenUpdate()
        {
            ApplySafeArea();
        }

        //[ContextMenu("Apply")]
        //private void TestFullScreen()
        //{
        //    ApplySafeArea();
        //}

        void ApplySafeArea()
        {
            ScreenOrientation deviceOrientation = Core.ScreenManager.ScreenOrientation;

            float rawScreenWidth = UGUIRoot.GetRawScreenWidth();
            float rawScreenHeight = UGUIRoot.GetRawScreenHeight();
            var area = UGUIRoot.GetCorrectSafeArea();

            //Debug.LogWarning($"==== {nameof(BkgFitFullScreen)}: ({rawScreenWidth}, {rawScreenHeight}, area: {area})");

            target.anchorMin = Vector2.zero;
            target.anchorMax = Vector3.one;
            target.pivot = new Vector2(0.5f, 0.5f);
            if (deviceOrientation == ScreenOrientation.LandscapeRight)
            {
                float top = -(rawScreenHeight - area.y - area.height);
                float right = -(rawScreenWidth - area.x - area.width);
                float bottom = -area.y;
                float left = -area.x;
                //right和top
                target.offsetMax = new Vector3(-right, -top);
                //left和bottom
                target.offsetMin = new Vector3(left, bottom);
            }
            else if (deviceOrientation == ScreenOrientation.LandscapeLeft)
            {
                float top = -(rawScreenHeight - area.y - area.height);
                float right = -(rawScreenWidth - area.x - area.width);
                float bottom = -area.y;
                float left = -area.x;
                //right和top
                target.offsetMax = new Vector3(-right, -top);
                //left和bottom
                target.offsetMin = new Vector3(left, bottom);
            }
            else
            {
                float top = -(rawScreenHeight - area.y - area.height);
                float right = -(rawScreenWidth - area.x - area.width);
                float bottom = -area.y;
                float left = -area.x;
                //right和top
                target.offsetMax = new Vector3(-right, -top);
                //left和bottom
                target.offsetMin = new Vector3(left, bottom);
            }
        }

        private void OnDestroy()
        {
            UGUIRoot.RemoveUpdateCallback(OnScreenUpdate);
        }
    }
}