//#define DEBUG_EVENT_CLICK
using System;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace client
{
    /**
     * 仅响应点击事件
     * 
     * 不可以移除 IPointerDownHandler 接口，
     * 否则事件可能会被下方别的控件阻塞掉，导致点击事件无响应
     * 
     * 另：此脚本不阻塞当前对象下方的拖拽事件等响应
     * 
     * 2017-06-16 把 Button 也管起来吧
     */
    public class EventTriggerClick : MonoBehaviour, IPointerClickHandler, IPointerDownHandler, IMoveHandler
    {
        [SerializeField]
        private float m_requireInterval = 0.01f;     // 点击事件响应要求间隔
        private float m_lastAccessTime = -10000f;   // 最后一次响应点击时刻
        private bool m_interactable = true;         // 是否激活可以响应点击
        private Button m_btn = null;                // 按钮控件（非必须）

        public bool IgnoreInteractable = true;     // Interactabel也要求响应事件 如果是true 就是在 Interactable=false下可以点击

        public bool isIgnoreDrag = false;       //屏蔽按下后移动一段距离的情况
        //private float mDeltaMagnitudeThreshold = 5f;

        public Action<GameObject> onClick;

        public Action onPlayClickSound;


        private PointerEventData eventData = null;

        private EAlreadCallFlags m_Flags = EAlreadCallFlags.None;

        public static int limitGameObject = 0; // hashcode

        private static float s_MagnitudeThreshold = 0f;

        static EventTriggerClick()
        {
            int width = Screen.width;
            int height = Screen.height;

            float offsetRadio = 1f / 200f;
            Vector2 deltaSize = new Vector2(width * offsetRadio, height * offsetRadio);
            s_MagnitudeThreshold = deltaSize.magnitude;
        }

        [System.Flags]
        public enum EAlreadCallFlags : uint
        {
            None = 0,
            Button = 0x1,
            BIComp = 0x2,
            IgnoreComp = 0x4,
        }

        public static void ResetLimitGobj()
        {
            limitGameObject = 0;
        }

        public PointerEventData GetPointerEventData()
        {
            return eventData;
        }

        private void Awake()
        {
            // remove, GameObject.AddComponent : EventTriggerClick.Awake, about 1.65KB GC...(per component)
        }

        private Button GetButton()
        {
            if (!HasCallGetComponent(EAlreadCallFlags.Button))
            {
                m_btn = GetComponent<Button>();
                m_Flags |= EAlreadCallFlags.Button;
            }
            return m_btn;
        }

        private bool HasCallGetComponent(EAlreadCallFlags flag)
        {
            if ((m_Flags & flag) == EAlreadCallFlags.None)
            {
                return false;
            }
            else
            {
                return true;
            }
        }

        public bool interactable
        {
            get
            {
                if (GetButton() != null)
                    return GetButton().interactable;
                else
                    return m_interactable;
            }
            set
            {
                if (GetButton() != null)
                    GetButton().interactable = value;
                else
                    m_interactable = value;
            }
        }

        void IPointerClickHandler.OnPointerClick(PointerEventData eventData)
        {
            PointEvent(eventData);
        }

        void IPointerDownHandler.OnPointerDown(PointerEventData eventData)
        {
        }

        public virtual void OnMove(AxisEventData eventData)
        {

        }

        private void PointEvent(PointerEventData eventData)
        {

            if (onClick == null)
            {
#if UNITY_EDITOR
                Debug.LogFormat("button '{0}' EventTriggerClick.onClick is null", gameObject.name);
#endif
                return;
            }


            if (!interactable)
            {
                if (!IgnoreInteractable)
                {
                    //Log.LogWarning(string.Format("current button '{0}' interactable is false.", Global.GetPathName(transform)));
                    return;
                }
            }

            if (Time.realtimeSinceStartup - m_lastAccessTime < m_requireInterval)
            {
#if UNITY_EDITOR
                float invercal = Time.realtimeSinceStartup - m_lastAccessTime;
#endif
                return;
            }
            Vector2 delta = eventData.pressPosition - eventData.position;
            if (delta.magnitude > s_MagnitudeThreshold && isIgnoreDrag)
            {//拖拽
                return;
            }

            if (onPlayClickSound != null)
                onPlayClickSound();
            this.eventData = eventData;
            m_lastAccessTime = Time.realtimeSinceStartup;

            int gobjHashCode = gameObject.GetHashCode();

            //Debug.LogError($"Click button:{Global.GetPathName(transform)}");
            var uvt = gameObject.GetComponent<Game.IOnClick>(); // 暂时先只支持一个吧
            if (uvt != null)
            {
                uvt.OnClick();
            }
            onClick(gameObject);
        }

        #region static functions
        // 可以在 Prefab 上挂脚本指定时间
        public static EventTriggerClick Register(GameObject obj, System.Action<GameObject> callback, bool isIgnoreDrag = false)
        {
            if (obj == null)
            {
                return null;
            }

            EventTriggerClick listen = GameObjectExtension.GetOrAddComponent<EventTriggerClick>(obj);
            if (listen != null)
            {
                listen.onClick = callback;
                listen.isIgnoreDrag = isIgnoreDrag;
            }
            return listen;
        }

        // 程序指定响应间隔
        public static EventTriggerClick Register(GameObject obj, System.Action<GameObject> callback, float clickInterval, bool isIgnoreDrag = false)
        {
            EventTriggerClick listen = Register(obj, callback, isIgnoreDrag);
            if (listen != null)
            {
                listen.m_requireInterval = clickInterval;
            }
            return listen;
        }

        // 获取点击响应组件（没有会自动创建）
        public static EventTriggerClick GetEventTrigger(GameObject obj, bool isToCreate = true)
        {
            if (obj == null)
            {
                return null;
            }
            EventTriggerClick listen = obj.GetComponent<EventTriggerClick>();
            if (listen == null && isToCreate)
            {
                object objs = new object();
                lock (objs)
                {
                    EventTriggerClick retlisten = obj.AddComponent<EventTriggerClick>();
                    return retlisten;
                }
            }
            return listen;
        }

        public static void UnRegisterButtonClick(GameObject gobj, bool destroyImmediately)
        {
            if (gobj == null)
            {
                Debug.LogWarningFormat("EventTriggerClick.UnRegisterButtonClick param gobj is null.");
                return;
            }

            EventTriggerClick eventclick = gobj.GetComponent<EventTriggerClick>();
            if (eventclick != null)
            {
                eventclick.onClick = null;
                if (destroyImmediately)
                {
                    GameObject.DestroyImmediate(eventclick);
                }
                else
                {
                    GameObject.Destroy(eventclick);
                }
            }
        }
        #endregion
    }
}
