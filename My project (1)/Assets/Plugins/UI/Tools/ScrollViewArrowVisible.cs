using UnityEngine;
using UnityEngine.UI;

namespace Combo
{
    /// <summary>
    /// 指示箭头，暂不支持ScrollRect
    /// </summary>
    public class ScrollViewArrowVisible : MonoBehaviour, ILayoutController
    {
        [SerializeField]
        private GameObject prevArrow;
        [SerializeField]
        private GameObject nextArrow;

        private ScrollRect scrollRect;
        // Start is called before the first frame update
        void Start()
        {
        }

        private void OnValueChanged(Vector2 value)
        {

        }

        private void OnScrollViewChanged(Vector2 value)
        {
            //需要修改UGUI源码方可使用
            //if(scrollRect.horizontal)
            //{
            //    if (scrollRect.hScrollingNeeded)
            //    {
            //        var offset = 1f / scrollRect.content.sizeDelta.x;
            //        SetArrowActive(prevArrow, value.x > offset);
            //        SetArrowActive(nextArrow, value.x < 1 - offset);
            //    }
            //    else
            //    {
            //        SetArrowActive(prevArrow, false);
            //        SetArrowActive(nextArrow, false);
            //    }
            //}
            //else
            //{
            //    if (scrollRect.vScrollingNeeded)
            //    {
            //        var offset = 1f / scrollRect.content.sizeDelta.y;
            //        SetArrowActive(nextArrow, value.y > offset);
            //        SetArrowActive(prevArrow, value.y < 1 - offset);
            //    }
            //    else
            //    {
            //        SetArrowActive(prevArrow, false);
            //        SetArrowActive(nextArrow, false);
            //    }
            //}
        }

        private void SetArrowActive(GameObject go, bool visible)
        {
            if (go && go.activeSelf != visible)
            {
                go.SetActive(visible);
            }
        }

        private void LayoutChanged()
        {

        }

        private bool isChanged = false;
        private void LateUpdate()
        {
            if (isChanged)
            {
                isChanged = false;
                LayoutChanged();
            }
        }

        public void SetLayoutHorizontal()
        {
            isChanged = true;
        }

        public void SetLayoutVertical()
        {
            isChanged = true;
        }
    }
}
