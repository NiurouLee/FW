//-----------------------------------------
//将SafeAreaPannel下的节点按照设计分辨率适配
//-----------------------------------------
using UnityEngine;

namespace Ez.UI
{
    public class BkgAutoFit : MonoBehaviour
    {
        private RectTransform target;
        [SerializeField]
        private float BgDesignWidth = 1920f;
        [SerializeField]
        private float BgDesignHeight = 1080f;


        private void Awake()
        {
            target = GetComponent<RectTransform>();
            AutoMach();
            UGUIRoot.AddUpdateCallback(OnScreenUpdate);
        }

        void OnScreenUpdate()
        {
            AutoMach();
        }

        private void AutoMach()
        {
            float DesignBgAspectRatio = BgDesignWidth / BgDesignHeight;
            float ScreenAspectRatio = (float)Screen.width / (float)Screen.height; // -- STD: Use screen manager

            var cvsWidth = UGUIRoot.GetRawScreenWidth();
            var cvsHeight = UGUIRoot.GetRawScreenHeight();

            // 先计算尺寸
            float fixWidth = cvsWidth;
            float fixHeight = cvsHeight;
            if (ScreenAspectRatio > DesignBgAspectRatio)
            {//要按照宽来适配
                fixHeight = fixWidth / DesignBgAspectRatio;
            }
            else
            {//要按照高来适配
                fixWidth = fixHeight * DesignBgAspectRatio;
            }

            target.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, fixWidth);
            target.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, fixHeight);
        }

        private void OnDestroy()
        {
            UGUIRoot.RemoveUpdateCallback(OnScreenUpdate);
        }
    }
}
