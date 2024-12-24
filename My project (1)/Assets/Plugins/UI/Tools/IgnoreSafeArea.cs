using UnityEngine;

namespace Ez.UI
{
    /// <summary>
    /// 设计安全区域面板
    /// 文件名 SafeAreaPanel.cs
    /// </summary>
    public class IgnoreSafeArea : MonoBehaviour
    {
        private RectTransform target;

        void Awake()
        {
            target = GetComponent<RectTransform>();
            ApplySafeArea();
            UGUIRoot.AddUpdateCallback(OnScreenUpdate);
        }

        [ContextMenu("TEST")]
        void OnScreenUpdate()
        {
            ApplySafeArea();
        }

        void ApplySafeArea()
        {
            ScreenOrientation screenOrt = Core.ScreenManager.ScreenOrientation;
            var area = UGUIRoot.GetCorrectSafeArea();

            var screenWidth = UGUIRoot.GetRawScreenWidth();
            var screenHeight = UGUIRoot.GetRawScreenHeight();

            float top = screenHeight - area.y - area.height;
            float right = screenWidth - area.x - area.width;
            float bottom = area.y;
            float left = area.x;

            target.offsetMax = new Vector2(-right, top);
            target.offsetMin = new Vector2(left, -bottom);
        }

        private void OnDestroy()
        {
            UGUIRoot.RemoveUpdateCallback(this.OnScreenUpdate);
        }
    }
}
