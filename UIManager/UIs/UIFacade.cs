using Ez.Core;
using System.Collections.Generic;
using Game;
using Game.Utils;
using UnityEngine;

namespace Ez.UI
{
    /// <summary>
    /// 事件系统暂时拔掉，后续拓展写
    /// </summary>
    public class UIFacade : MonoBehaviour
    {
        public const string eventIdPrefix = "UI_EVENT_";

        public string moduleName;
        public string uiName;

        public string GetUiName()
        {
            var list = StringReadTools.ReadStringArray(uiName, "/");
            if(list.Count==0)
            {
                Debug.LogError(" uiName is empty");
                return "";
            }
            return  list[list.Count - 1].Replace("\n\r", "").Replace("\n", "").Replace("\r", "");;
        }
        public string GetClassName()
        {
            string dir = GetSubModlesName();

            if (dir.Length > 0)
                return $"{dir}_{GetUiName()}";
            else
                return GetUiName();
        }

        public string GetSubModlesNameInCodeName()
        {
            string dir = GetSubModlesName();
            if (dir == "")
            {
                return "";
            }
            else
            {
                dir = dir + "_";
                return dir;
            }
        }

        public string GetSubModlesNameInPath()
        {
            string dir = GetSubModlesName();
            if (dir == "")
            {
                return "";
            }
            else
            {
                dir =  "/"+dir;
                return dir;
            }
        }
        
        public string GetSubModlesName()
        {
            var list = StringReadTools.ReadStringArray(uiName, "/");
            if(list.Count==1)
            {
                return "";
            }

            if (list == null || list.Count == 0)
            {
                return "";
            }
            var sb = list[0];
            return sb.Replace("\n\r", "").Replace("\n", "").Replace("\r", "").Replace("/","");
        }

        public string GetSubDirNameSpaceName()
        {
            string dir = GetSubModlesName();
            if (dir == "")
            {
                return  $".{moduleName}";;
            }
            else
            {
                dir = dir.Replace("/", ".");
                dir = dir.Substring(0, dir.Length - 1);
                return $".{moduleName}.{dir}";
            }
        }

        public List<UIElement> uiElements = new List<UIElement>();
        public List<Component> guides = new List<Component>();
        private Dictionary<string, UIElement> elementsDict;

        private bool init = false;
        public bool IsController = false;

        protected virtual void Awake()
        {
            Init();
        }

        private void Init()
        {
            if (!init)
            {
                init = true;
                elementsDict = new Dictionary<string, UIElement>(uiElements.Count);

                foreach (UIElement uiElement in uiElements)
                {
                    if (string.IsNullOrEmpty(uiElement.name) || uiElement.reference == null)
                    {
#if UNITY_EDITOR
                        Debug.LogError($"[{nameof(UIFacade)}] {nameof(name)} or {nameof(uiElement.reference)} is null: {TransformUtil.GetTransformPath(transform)}");
#endif
                        continue;
                    }
                    else
                    {
                        if (!elementsDict.ContainsKey(uiElement.name))
                        {
                            elementsDict.Add(uiElement.name, uiElement);
                            uiElement.InitDefaultActiveState();
                        }
                        else
                        {
#if UNITY_EDITOR
                            Debug.LogError($"[{nameof(UIFacade)}] name '{uiElement.name}' repeated: {TransformUtil.GetTransformPath(transform)}");
#endif
                        }
                    }
                }
            }
        }

        public UIFacade GetFacade(string name)
        {
            return GetReferenceByName(name) as UIFacade;
        }

        public T GetReferenceByName<T>(string name) where T : class
        {
            Init();
            if (!string.IsNullOrEmpty(name))
            {
                if (elementsDict.TryGetValue(name, out UIElement uiElement))
                {
                    return uiElement.reference as T;
                }
            }
#if UNITY_EDITOR
            Game.DevDebuger.LogError($"{gameObject.name}", $"can not find the item: {name}");
#endif
            return null;
        }

        public Component GetReferenceByName(string name)
        {
            Init();
            if (!string.IsNullOrEmpty(name))
            {
                if (elementsDict.TryGetValue(name, out UIElement uiElement))
                {
                    return uiElement.reference;
                }
            }
#if UNITY_EDITOR
            Game.DevDebuger.LogWarning($"{gameObject.name}", $"can not find the item: {name}");
#endif
            return null;
        }

        public Transform GetTransform(string name)
        {
            var comp = GetReferenceByName(name);
            return comp.transform;
        }

        public GameObject GetGameObject(string name)
        {
            Init();
            if (!string.IsNullOrEmpty(name))
            {
                if (elementsDict.TryGetValue(name, out UIElement uiElement))
                {
                    return uiElement.reference.gameObject;
                }
            }
            return null;
        }

        /**
         * 可以用于全局查找到指定 Facade，再获取到对象，引导可能会用
         */
        public string GetUniqueKey()
        {
            return $"{moduleName}_{GetUiName()}";
        }

        public void SetElemActive(string name, bool flag)
        {
            var comp = GetReferenceByName(name);
            if (comp && comp.gameObject.activeSelf != flag)
            {
                comp.gameObject.SetActive(flag);
            }
        }

        public string GetElementEventId(UIElement element)
        {
            System.Text.StringBuilder builder = StringBuilderPool.Acquire();
            builder.Clear();
            builder.Append(eventIdPrefix);
            builder.Append(GetUiName());
            builder.Append("_");
            builder.Append(element.name);
            builder.Append("_");
            builder.Append(GetDefaultEventTypeStr(element));
            return StringBuilderPool.GetStringAndRelease(builder);
        }


        private string GetDefaultEventTypeStr(UIElement element)
        {
            if (element.eventType == UIEventType.Default && element.type == UIElement.ElementType.BUTTON)
            {
                return UIEventType.PointerClick.ToString();
            }
            else
            {
                return element.eventType.ToString();
            }
        }

        public Component DuplicateElement(string sourceElement, string elementName, Transform parentTf)
        {
            Component newComponent = null;
            if (elementsDict.ContainsKey(sourceElement))
            {
                UIElement element = elementsDict[sourceElement];
                GameObject newObj = GameObject.Instantiate(element.reference.gameObject);
                newObj.transform.parent = parentTf;
                newObj.transform.localScale = Vector3.one;
                newObj.SetActive(true);
                if (elementName == null)
                {
                    elementName = element.name;
                }
                newComponent = newObj.GetComponent(element.reference.GetType());
                AddElement(newComponent, element.type, elementName, element.eventType);
            }
            return newComponent;
        }

        public void AddElement(Component elementRef, UIElement.ElementType elementType, string elementName, UIEventType eventType)
        {
            UIElement element = new UIElement();
            element.type = elementType;
            element.reference = elementRef;
            element.name = elementName;
            element.eventType = eventType;

            if (elementsDict.ContainsKey(element.name))
            {
                Debug.Log("AddElement repeated: " + element.name);
            }
            else
            {
                elementsDict.Add(element.name, element);
            }

            if (element.reference != null && element.isEvent)
            {
                element.eventId = GetElementEventId(element);
            }
        }

        public void RemoveElement(string elementName)
        {
            if (elementsDict != null && elementsDict.ContainsKey(elementName))
            {
                elementsDict.Remove(elementName);
            }
        }
        RectTransform _rectTransform;
        public RectTransform rectTransform
        {
            get
            {
                if (!_rectTransform)
                {
                    _rectTransform = this.gameObject.gameObject.GetComponent<RectTransform>();
                }
                return _rectTransform;
            }
        }

        /// <summary>
        /// 实例化创建
        /// </summary>
        /// <param name="parent"></param>
        /// <returns></returns>
        public UIFacade InstCreate(Transform parent)
        {
            var gobj = GameObject.Instantiate(this.gameObject);
            gobj.transform.SetParent(parent, false);
            return gobj.GetComponent<UIFacade>();
        }
#if UNITY_EDITOR
        #region UI编辑器使用
        /// <summary>
        /// 获取是否被绑定
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public bool CheckObjBind(Object obj)
        {
            //UnityEditor.GlobalObjectId goid = UnityEditor.GlobalObjectId.GetGlobalObjectIdSlow(obj);

            foreach (UIElement element in uiElements)
            {
                //UnityEditor.GlobalObjectId element_goid = UnityEditor.GlobalObjectId.GetGlobalObjectIdSlow(element.reference);

                if (element.reference && element.reference.gameObject == obj)
                {
                    return true;
                }
            }
            return false;
        }
        /// <summary>
        /// 如果是普通组件 返回名字
        /// 如果是uifacde 返回可能的管理器的名字和对象名字
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public string[] GetObjBindName(Object obj)
        {
            //UnityEditor.GlobalObjectId goid = UnityEditor.GlobalObjectId.GetGlobalObjectIdSlow(obj);

            foreach (UIElement element in uiElements)
            {
                //UnityEditor.GlobalObjec tId element_goid = UnityEditor.GlobalObjectId.GetGlobalObjectIdSlow(element.reference);
                if (!element.reference)
                {
                    continue;
                }
                if (element.reference.gameObject == obj)
                {
                    if (element.reference.GetType().FullName == "UnityEngine.UI.LoopVerticalScrollRect"
                        || element.reference.GetType().FullName == "UnityEngine.UI.LoopHorizontalScrollRect")
                    {
                        return new string[] { element.name, element.name + "_swift" };
                    }
                    else if (element.reference.GetType() == typeof(UIFacade))
                    {
                        if (element.reference.GetComponent<UIFacade>())
                        {
                            return new string[] { element.name, element.name + "View" };
                        }
                    }
                    return new string[] { element.name };
                }
            }
            return null;
        }
        #endregion
#endif
    }
}

