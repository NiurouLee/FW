using System.Collections.Generic;
using UnityEngine;

namespace Ez.UI
{
    public class UIBlurBackground
    {
        private GameObject m_Gobj;

        public UIBlurBackground(Transform tf, int order)
        {
            var prefab = UnityEngine.Resources.Load("UIBlur/UIBlur"); //dep:Graphic, TODO@bao
            m_Gobj = GameObject.Instantiate(prefab) as GameObject;
            m_Gobj.SetActive(true);

            var transform = m_Gobj.transform as RectTransform;
            transform.SetParent(tf, false);
            transform.NormalizeRectTransform();

            var canvas = m_Gobj.GetComponent<Canvas>();
            canvas.sortingOrder = order;

            m_Gobj.AddComponent<UIBlurLayer>();
        }

        public void Show()
        {
            m_Gobj.GetComponent<UIBlurLayer>().SetRawTexture(Shader.GetGlobalTexture("_GlobalFullScreenBlurTexture"));
            m_Gobj.ExSetActive(true);
            Add(this);
            m_Gobj.AddComponent<BkgFitFullScreen>();
            UIEventManager.GetInstance().Fire(UIEventID.UIBlurBackGroundShown, this);
        }

        public void Hide()
        {
            m_Gobj.ExSetActive(false);
            Remove(this);
            UIEventManager.GetInstance().Fire(UIEventID.UIBlurBackGroundHided, this);
        }

        public void Dispose()
        {
            GameObject.Destroy(m_Gobj);
            UIEventManager.GetInstance().Fire(UIEventID.UIBlurBackGroundDispose, this);
        }


        #region static
        private static readonly HashSet<UIBlurBackground> s_Set = new HashSet<UIBlurBackground>();
        public static void Add(UIBlurBackground blur)
        {
            if (!s_Set.Contains(blur))
                s_Set.Add(blur);
        }

        public static void Remove(UIBlurBackground blur)
        {
            if (s_Set.Contains(blur))
                s_Set.Remove(blur);
        }

        public static bool HasBlur()
        {
            return s_Set.Count > 0;
        }

        public static void Clear()
        {
            s_Set.Clear();
        }
        #endregion
    }
}
