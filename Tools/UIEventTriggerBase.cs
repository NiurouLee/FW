using System;
using System.Collections.Generic;
using System.ComponentModel;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Serialization;
using static UnityEngine.EventSystems.EventTrigger;

namespace Ez.UI
{
    //复制的EventTrigger 去掉了Drag相关的接口,为了解决ScrollView拖拽事件被拦截的问题
    //TODO：需要写个DragTrigger
    public class UIEventTriggerBase : MonoBehaviour, IPointerEnterHandler, IEventSystemHandler, IPointerExitHandler, IPointerDownHandler, IPointerUpHandler, IPointerClickHandler, IInitializePotentialDragHandler, IDropHandler, IScrollHandler, IUpdateSelectedHandler, ISelectHandler, IDeselectHandler, IMoveHandler, ISubmitHandler, ICancelHandler
    {
        [Serializable]
        public class TriggerEvent : UnityEvent<BaseEventData>
        {
        }

        //[Serializable]
        //public class Entry
        //{
        //    public EventTriggerType eventID = EventTriggerType.PointerClick;

        //    public TriggerEvent callback = new TriggerEvent();
        //}
        [Tooltip("How long between in two click can take effect")]
        public float delayClick = 0.3f;
        private float simpleCickedLastTime = -10000f;

        [FormerlySerializedAs("delegates")]
        [SerializeField]
        private List<Entry> m_Delegates;

        [EditorBrowsable(EditorBrowsableState.Never)]
        [Obsolete("Please use triggers instead (UnityUpgradable) -> triggers", true)]
        public List<Entry> delegates
        {
            get
            {
                return triggers;
            }
            set
            {
                triggers = value;
            }
        }

        public List<Entry> triggers
        {
            get
            {
                if (m_Delegates == null)
                {
                    m_Delegates = new List<Entry>();
                }
                return m_Delegates;
            }
            set
            {
                m_Delegates = value;
            }
        }

        protected UIEventTriggerBase()
        {
        }

        private void Execute(EventTriggerType id, BaseEventData eventData)
        {
            int i = 0;
            for (int count = triggers.Count; i < count; i++)
            {
                Entry entry = triggers[i];
                if (entry.eventID == id && entry.callback != null)
                {
                    entry.callback.Invoke(eventData);
                }
            }
        }

        public virtual void OnPointerEnter(PointerEventData eventData)
        {
            Execute(EventTriggerType.PointerEnter, eventData);
        }

        public virtual void OnPointerExit(PointerEventData eventData)
        {
            Execute(EventTriggerType.PointerExit, eventData);
        }

        //public virtual void OnDrag(PointerEventData eventData)
        //{
        //    Execute(EventTriggerType.Drag, eventData);
        //}

        public virtual void OnDrop(PointerEventData eventData)
        {
            Execute(EventTriggerType.Drop, eventData);
        }

        public virtual void OnPointerDown(PointerEventData eventData)
        {
            Execute(EventTriggerType.PointerDown, eventData);
        }

        public virtual void OnPointerUp(PointerEventData eventData)
        {
            Execute(EventTriggerType.PointerUp, eventData);
        }

        public virtual void OnPointerClick(PointerEventData eventData)
        {
            bool isContinuityClick = IsContinuityClick();
            if (!isContinuityClick)
            {
                Execute(EventTriggerType.PointerClick, eventData);
            }
            else
            {
                Debug.Log("ContinuityClick will be return");
            }
        }

        public virtual void OnSelect(BaseEventData eventData)
        {
            Execute(EventTriggerType.Select, eventData);
        }

        public virtual void OnDeselect(BaseEventData eventData)
        {
            Execute(EventTriggerType.Deselect, eventData);
        }

        public virtual void OnScroll(PointerEventData eventData)
        {
            Execute(EventTriggerType.Scroll, eventData);
        }

        public virtual void OnMove(AxisEventData eventData)
        {
            Execute(EventTriggerType.Move, eventData);
        }

        public virtual void OnUpdateSelected(BaseEventData eventData)
        {
            Execute(EventTriggerType.UpdateSelected, eventData);
        }

        public virtual void OnInitializePotentialDrag(PointerEventData eventData)
        {
            Execute(EventTriggerType.InitializePotentialDrag, eventData);
        }

        //public virtual void OnBeginDrag(PointerEventData eventData)
        //{
        //    Execute(EventTriggerType.BeginDrag, eventData);
        //}

        //public virtual void OnEndDrag(PointerEventData eventData)
        //{
        //    Execute(EventTriggerType.EndDrag, eventData);
        //}

        public virtual void OnSubmit(BaseEventData eventData)
        {
            Execute(EventTriggerType.Submit, eventData);
        }

        public virtual void OnCancel(BaseEventData eventData)
        {
            Execute(EventTriggerType.Cancel, eventData);
        }

        private bool IsContinuityClick()
        {
            float interval = Time.realtimeSinceStartup - simpleCickedLastTime;
            if (interval > delayClick)
            {
                simpleCickedLastTime = Time.realtimeSinceStartup;
                return false;
            }
            else
            {
                return true;
            }
        }
    }
}
