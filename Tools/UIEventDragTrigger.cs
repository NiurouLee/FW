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
    public class UIEventDragTrigger : MonoBehaviour, IBeginDragHandler, IDragHandler, IEndDragHandler
    {
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

        public virtual void OnBeginDrag(PointerEventData eventData)
        {
            Execute(EventTriggerType.BeginDrag, eventData);
        }

        public virtual void OnDrag(PointerEventData eventData)
        {
            Execute(EventTriggerType.Drag, eventData);
        }

        public virtual void OnEndDrag(PointerEventData eventData)
        {
            Execute(EventTriggerType.EndDrag, eventData);
        }

    }
}
