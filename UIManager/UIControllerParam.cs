
using Game;
using System.Collections.Generic;
using UnityEngine;

namespace Ez.UI
{
    public class UIControllerParam
    {
        public string ControllerName = string.Empty;
        //public string UIPrefabKey = string.Empty;

        public UIWindowLayer layer = UIWindowLayer.CommonLayer;
        //public UIShowAnimation uiShowAnimation = UIShowAnimation.None;
        //public UICloseAnimation uiCloseAnimation = UICloseAnimation.None;

        public bool IsFullScreen = false;
        public bool IsExclusion = false;
        //public bool exclusion = false;//是否互斥UI 互斥UI之间具有排他性 会挂起之前的互斥UI
        public bool OutSideClose = false;
        //public bool isModel = false;  //是否模态UI 模态UI会屏蔽点击事件 只相应自己的事件
        //public bool outsideClickEvent = false;  //接收其他界面的点击事件

        //public int AudioId = 0; // TODO@bao wwise
        //public int AudioEffectId = 0;
        public bool IsClearItemFly = false;
        public bool blurBackground = false;
        public uint blurColor = 0x8C8C8CFF;
        public List<int> resids = new List<int>();//资源ID 用于界面的资源显示信息获取
    }

    public sealed class UIControllerParamSet
    {
        private Dictionary<string, UIControllerParam> m_Dict;

        public UIControllerParamSet()
        {
        }

        public void Init(string filePath)
        {
            if (!Core.FileSystem.VFileSystem.Exists(filePath))
            {
                DevDebuger.LogError(nameof(UIControllerParamSet), $"can not find file: {filePath}");
                return;
            }

            var lines = Core.FileSystem.VFileSystem.ReadAllLines(filePath, System.Text.Encoding.UTF8);
            m_Dict = new Dictionary<string, UIControllerParam>(lines.Length);
            foreach (var line in lines)
            {
                if (string.IsNullOrEmpty(line))
                    continue;

                UIControllerParam viewParam = JsonUtility.FromJson<UIControllerParam>(line);
                if (!m_Dict.ContainsKey(viewParam.ControllerName))
                {
                    m_Dict.Add(viewParam.ControllerName, viewParam);
                }
                else
                {
                    DevDebuger.LogError(nameof(UIControllerParamSet), $"repeated key: {viewParam.ControllerName}");
                }
            }
        }

        public UIControllerParam Get(string controllerName)
        {
            if (controllerName.Contains('.'))
            {
                controllerName = controllerName.Substring(controllerName.IndexOf('.') + 1);
            }

            if (!m_Dict.TryGetValue(controllerName, out UIControllerParam viewParam))
            {
                viewParam = new UIControllerParam();
                viewParam.ControllerName = controllerName;
                m_Dict.Add(controllerName, viewParam);
            }
            return viewParam;
        }

#if UNITY_EDITOR
        public List<UIControllerParam> GetList()
        {
            return new List<UIControllerParam>(m_Dict.Values);
        }
#endif
    }
}