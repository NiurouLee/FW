using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;

namespace Ez.UI
{
    public class UIEventTrigger : UIEventTriggerBase
    {
        [SerializeField]
        [Tooltip("How long must pointer be down on this object to trigger a long press")]
        private float holdTime = 1f;
        public bool Hold = false;

        [Tooltip("How long between in two click on this object to trigger a double click")]
        public float ClickedInterval = 0.3f;
        public int ClickedCount = 2;
        private float lastClickedTime = 0;
        private float count = 0;

        public UnityEvent onBeginLongPress = new UnityEvent();
        public UnityEvent onEndLongPress = new UnityEvent();
        public UnityEvent onDoubleClick = new UnityEvent();

        public override void OnPointerExit(PointerEventData eventData)
        {
            base.OnPointerExit(eventData);
            CancelInvoke("OnBeginLongPress");
            OnEndLongPress();
        }

        public override void OnPointerDown(PointerEventData eventData)
        {
            base.OnPointerDown(eventData);
            Invoke("OnBeginLongPress", holdTime);
            OnCheckDoubleClick();
        }

        public override void OnPointerUp(PointerEventData eventData)
        {
            base.OnPointerUp(eventData);
            CancelInvoke("OnBeginLongPress");
            OnEndLongPress();
        }

        private void OnBeginLongPress()
        {
            Hold = true;
            onBeginLongPress.Invoke();
        }

        private void OnEndLongPress()
        {
            if (Hold)
            {
                onEndLongPress.Invoke();
            }
            Hold = false;
        }
        private void OnCheckDoubleClick()
        {
            float interval = Time.realtimeSinceStartup - lastClickedTime;
            if (interval <= ClickedInterval)
            {
                count++;
                if (count == ClickedCount - 1)
                {
                    onDoubleClick.Invoke();
                }
            }
            else
            {
                count = 0;
            }
            lastClickedTime = Time.realtimeSinceStartup;
        }

        private void OnDestroy()
        {
            //LuaEventBridge.GetInstance().SendToLuaEvent("UIEventTrigger_Destroy_Gobj", gameObject, gameObject.GetHashCode(), null);
        }
    }
}
