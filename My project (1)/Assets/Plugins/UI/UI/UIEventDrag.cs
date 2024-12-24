using Ez.Core;
using Ez.Lua;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

namespace Ez.UI
{
    public class UIEventDrag : MonoBehaviour, IBeginDragHandler, IDragHandler, IEndDragHandler
    {
        public static void AddEvent(string keyName, GameObject gobj, bool allowMultiTouch = false)
        {
            if (gobj == null)
            {
                Debug.LogError($"{nameof(UIEventDrag)}: param 'gobj' is null");
                return;
            }

            if (string.IsNullOrEmpty(keyName) || keyName.Length < 8)
            {
                Debug.LogError($"{nameof(UIEventDrag)}: param 'keyname' is null or len < 8");
                return;
            }

            UIEventDrag evtDrag = gobj.GetComponent<UIEventDrag>();
            if (evtDrag == null)
            {
                evtDrag = gobj.AddComponent<UIEventDrag>();
            }

            evtDrag.Init(keyName, allowMultiTouch);
        }

        public static void RemoveEvent(GameObject gobj)
        {
            if (gobj == null)
            {
                Debug.LogError($"{nameof(UIEventDrag)}: param 'gobj' is null");
                return;
            }

            UIEventDrag evtDrag = gobj.GetComponent<UIEventDrag>();
            if (evtDrag != null)
            {
                GameObject.Destroy(evtDrag);
            }
        }

        private bool m_Inited = false;
        private string m_KeyName = string.Empty;
        private GameObject m_Gobj = null;
        public bool allowMultiTouch = false;
        private float distanceDelta = 0;
        private float oldDistance = 0;

        // Start is called before the first frame update
        void Start()
        {

        }

        private void Init(string keyName, bool allowMultiTouch = false)
        {
            m_Inited = true;
            m_KeyName = keyName;
            m_Gobj = gameObject;
            this.allowMultiTouch = allowMultiTouch;
        }

        public void OnBeginDrag(PointerEventData eventData)
        {
            LogEventDataStr("OnBeginDrag", eventData);
            if (m_Inited)
            {
                oldDistance = 0f;
                LuaEventBridge.GetInstance().SendToLuaEvent(m_KeyName, m_Gobj, eventData, "begin");
            }
        }

#if UNITY_EDITOR
        void Update()
        {
            float distanceDelta = Input.GetAxis("Mouse ScrollWheel");
            if (!NumUtil.IsZero(distanceDelta))
            {
                LuaEventBridge.GetInstance().SendToLuaEvent(m_KeyName, m_Gobj, distanceDelta * 25f, "mutifingerdraging");
                return;
            }
        }
#endif


        public void OnDrag(PointerEventData eventData)
        {
            LogEventDataStr("OnDrag", eventData);
            if (m_Inited)
            {
                if (allowMultiTouch && Input.touchCount == 2)//双指缩放
                {
                    var touch0 = Input.GetTouch(0);
                    var touch1 = Input.GetTouch(1);
                    if (NumUtil.IsZero(oldDistance))
                    {
                        oldDistance = (touch0.position - touch1.position).magnitude;
                        return;
                    }

                    var newDistance = (touch0.position - touch1.position).magnitude;
                    distanceDelta = newDistance - oldDistance;
                    oldDistance = newDistance;
                    if (!NumUtil.IsZero(distanceDelta))
                    {
                        LuaEventBridge.GetInstance().SendToLuaEvent(m_KeyName, m_Gobj, distanceDelta, "mutifingerdraging");
                    }
                }
                else
                {
                    oldDistance = 0f;
                    LuaEventBridge.GetInstance().SendToLuaEvent(m_KeyName, m_Gobj, eventData, "draging");
                }
            }

        }

        public void OnEndDrag(PointerEventData eventData)
        {
            LogEventDataStr("OnEndDrag", eventData);
            if (m_Inited)
            {
                oldDistance = 0f;
                LuaEventBridge.GetInstance().SendToLuaEvent(m_KeyName, m_Gobj, eventData, "end");
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="position">屏幕坐标</param>
        /// <returns></returns>
        public static bool IsPointerOverGameObject(PointerEventData s_pointerEventData, Vector3 position)
        {
            if (EventSystem.current == null)
            {
                return false;
            }
            if (s_pointerEventData == null || s_pointerEventData.currentInputModule != EventSystem.current.currentInputModule)
            {
                s_pointerEventData = new PointerEventData(EventSystem.current);
            }
            s_pointerEventData.pressPosition = position;
            s_pointerEventData.position = position;

            List<RaycastResult> s_eventRaycastResult = new List<RaycastResult>();
            EventSystem.current.RaycastAll(s_pointerEventData, s_eventRaycastResult);
            for (int i = 0; i < s_eventRaycastResult.Count; i++)
            {
                var result = s_eventRaycastResult[i];
                if (result.gameObject && result.gameObject.layer != 0)
                {
                    return true;
                }
            }
            return false;
        }


        [System.Diagnostics.Conditional("UNITY_EDITOR_TEST_UIDRAG")]
        private void LogEventDataStr(string prefix, PointerEventData eventData)
        {
            var sb = Ez.Core.StringBuilderPool.Acquire();
            sb.Append(prefix);
            sb.Append(": gobj=");
            sb.Append(eventData.pointerDrag.name);
            sb.Append(", position=");
            sb.Append(eventData.position);
            sb.Append(", delta=");
            sb.Append(eventData.delta);

            Debug.LogWarning(Ez.Core.StringBuilderPool.GetStringAndRelease(sb));
        }
    }
}
