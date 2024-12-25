using UnityEngine;

namespace Ez.UI
{
    [System.Serializable]
    public class UIElement
    {
        /// <summary>
        /// Attention ！！！
        /// 添加新类型只能顺序往后添加
        /// （中间插入会导致既有数据错误）
        /// </summary>
        public enum ElementType
        {
            TEXT,
            BUTTON,
            IMAGE,
            RAWIMAGE,
            CANVAS,
            SLIDER,
            DROPDOWN,
            GRID,
            INPUTFIELD,
            TOGGLE,
            TOGGLEGROUP,
            ANIMATION,
            TRANSFORM,
            ANIMATOR,
            CAMERA,
            NESTPREFAB,

            TEXTMESH,
            RECTTRANSFORM,
            PARTICLESYSTEM,
            //VBUTTON,
            //VSTICK,

            UIFacade = 100,
            LoopVerticalScrollRect,
            LoopHorizontalScrollRect,
            ContentSizeFitter,
            ExtensionsToggle,
            ExtensionsToggleGroup,
            SerializeBind,
            Component,

            DROPDOWN_TMP,
            INPUTFIELD_TMP,
        }

        public enum ElementActiveDefault
        {
            Default,
            Active,
            DeActive,
        }


        public ElementType type;
        public string name;
        public Component reference;
        public bool isEvent { get { return eventType != UIEventType.None; } }
        public string eventId;

        public UIEventType eventType = UIEventType.None;
        public ElementActiveDefault defaultActive = ElementActiveDefault.Default;

        public UIElement() : this("", ElementType.BUTTON, UIEventType.None)
        {
        }

        public UIElement(string name, ElementType type, UIEventType eventType)
        {
            this.name = name;
            this.type = type;
            this.eventType = eventType;
        }

        internal void InitDefaultActiveState()
        {
            if (defaultActive != ElementActiveDefault.Default && reference != null)
            {
                reference.gameObject.SetActive(defaultActive == ElementActiveDefault.Active);
            }
        }
    }
}

