using System.Collections.Generic;
using NFramework.Core.Collections;
using NFramework.Module.UIModule;
using Sirenix.OdinInspector;
using UnityEngine;

public class UIFacade : MonoBehaviour
{
    [TabGroup("基本信息")]
    [LabelText("模块名称")]
    public string ModuleName;
    
    [TabGroup("基本信息")]
    [LabelText("子模块名称")]
    [InfoBox("子模块名称是可选的，用于更细粒度的模块分类", InfoMessageType.Info)]
    public string SubModuleName;
    
    [TabGroup("基本信息")]
    [LabelText("UI名称")]
    [Required("UI名称不能为空")]
    public string UIName;
    
    [TabGroup("基本信息")]
    [LabelText("脚本名称")]
    [Required("脚本名称不能为空")]
    public string ScriptName;
    
    [TabGroup("基本信息")]
    [LabelText("ID")]
    public string ID;
    
    [TabGroup("UI元素")]
    [ListDrawerSettings(ShowIndexLabels = true, ListElementLabelName = "Name", DraggableItems = true)]
    [LabelText("UI元素列表")]
    [SerializeField]
    public List<UIElement> Elements = new List<UIElement>();
    private Dictionary<string, Component> m_Coms;
    public T Q<T>(string inName) where T : Component
    {
        if (m_Coms == null)
        {
            InitComs();
        }
        if (this.m_Coms.TryGetValue(inName, out var com))
        {
            return com as T;
        }

        return null;
    }

    private void InitComs()
    {
        this.m_Coms = DictionaryPool.Alloc<string, Component>();
        foreach (var item in this.Elements)
        {
            this.m_Coms.Add(item.Name, item.Component);
        }
    }

    void OnDestroy()
    {
        if (this.m_Coms != null)
        {
            this.m_Coms.Clear();
            DictionaryPool.Free(this.m_Coms);
            this.m_Coms = null;
        }
    }

    public void Visible()
    {
        this.gameObject?.SetActive(true);
    }

    public void NotVisible()
    {
        this.gameObject?.SetActive(false);
    }
}