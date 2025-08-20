using System.Collections.Generic;
using System.Linq;
using NFramework.Module.UIModule;
using Sirenix.OdinInspector.Editor;
using Sirenix.Utilities.Editor;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(UIFacade))]
public class UIFacadeInspector : OdinEditor
{
    private UIFacade m_UIFacade;
    private ViewConfig m_ViewConfig;
    private bool m_EnableSubModule = false;

    protected override void OnEnable()
    {
        base.OnEnable();
        m_UIFacade = (UIFacade)target;

        // 初始化子模块toggle状态（根据是否有子模块名称来判断）
        m_EnableSubModule = !string.IsNullOrEmpty(m_UIFacade.SubModuleName);

        // 确保ViewConfig正确初始化
        m_ViewConfig = UIConfigUtilsEditor.GetViewConfig(m_UIFacade);
        
        if (m_ViewConfig != null)
        {
            Debug.Log($"ViewConfig initialized successfully. ID: '{m_ViewConfig.ID}', IsWindow: {m_ViewConfig.IsWindow}");
        }
        else
        {
            Debug.LogError("ViewConfig initialization failed!");
        }
    }

    public override void OnInspectorGUI()
    {
        if (m_UIFacade == null) return;

        // 绘制标题
        SirenixEditorGUI.Title("UI Facade Configuration", "配置UI门面组件", TextAlignment.Center, true);

        EditorGUILayout.Space(10);

        // 基本信息组
        SirenixEditorGUI.BeginBox("基本信息");
        {
            EditorGUI.BeginChangeCheck();

            // 第一行：两个toggle开关横向排列
            SirenixEditorGUI.BeginHorizontalToolbar();
            {
                // 启用子模块 Toggle
                EditorGUI.BeginChangeCheck();
                EditorGUILayout.LabelField("启用子模块:", GUILayout.Width(80));
                bool newEnableSubModule = EditorGUILayout.Toggle(m_EnableSubModule, GUILayout.Width(20));
                bool subModuleToggleChanged = EditorGUI.EndChangeCheck();
                
                // 显示子模块状态
                if (m_EnableSubModule)
                {
                    GUILayout.Label("(已启用)", SirenixGUIStyles.RightAlignedGreyMiniLabel, GUILayout.Width(50));
                }
                else
                {
                    GUILayout.Label("(已禁用)", SirenixGUIStyles.RightAlignedGreyMiniLabel, GUILayout.Width(50));
                }
                
                GUILayout.Space(20); // 分隔空间
                
                // 是否Window Toggle
                EditorGUI.BeginChangeCheck();
                EditorGUILayout.LabelField("是否Window:", GUILayout.Width(80));
                bool newIsWindow = false;
                bool currentIsWindow = false;
                
                if (m_ViewConfig != null)
                {
                    currentIsWindow = m_ViewConfig.IsWindow;
                    newIsWindow = EditorGUILayout.Toggle(currentIsWindow, GUILayout.Width(20));
                    
                    // 显示窗口模式状态
                    if (currentIsWindow)
                    {
                        GUILayout.Label("(窗口)", SirenixGUIStyles.RightAlignedGreyMiniLabel, GUILayout.Width(40));
                    }
                    else
                    {
                        GUILayout.Label("(视图)", SirenixGUIStyles.RightAlignedGreyMiniLabel, GUILayout.Width(40));
                    }
                }
                else
                {
                    GUI.enabled = false;
                    EditorGUILayout.Toggle(false, GUILayout.Width(20));
                    GUI.enabled = true;
                    GUILayout.Label("(未初始化)", SirenixGUIStyles.RightAlignedGreyMiniLabel, GUILayout.Width(60));
                }
                bool windowToggleChanged = EditorGUI.EndChangeCheck();
                
                GUILayout.FlexibleSpace();
                
                // 处理子模块toggle变化
                if (subModuleToggleChanged)
                {
                    m_EnableSubModule = newEnableSubModule;
                    if (!m_EnableSubModule)
                    {
                        if (!string.IsNullOrEmpty(m_UIFacade.SubModuleName))
                        {
                            if (EditorUtility.DisplayDialog("确认", "禁用子模块将清空子模块名称，确定继续吗？", "确定", "取消"))
                            {
                                m_UIFacade.SubModuleName = "";
                                GenerateScriptNameAndID(); // 立即重新生成
                            }
                            else
                            {
                                m_EnableSubModule = true; // 取消操作，恢复toggle状态
                            }
                        }
                        else
                        {
                            GenerateScriptNameAndID(); // 立即重新生成
                        }
                    }
                    else
                    {
                        GenerateScriptNameAndID(); // 启用时也重新生成
                    }
                }
                
                // 处理窗口模式toggle变化
                if (windowToggleChanged && m_ViewConfig != null)
                {
                    Debug.Log($"窗口模式toggle变化检测: currentIsWindow={currentIsWindow}, newIsWindow={newIsWindow}");
                    
                    if (currentIsWindow != newIsWindow)
                    {
                        m_ViewConfig.SetWindow(newIsWindow);
                        GenerateScriptNameAndID(); // 窗口模式变化时重新生成脚本名称
                        EditorUtility.SetDirty(target);
                        Debug.Log($"窗口模式已切换为: {(newIsWindow ? "窗口" : "视图")}，验证结果: {m_ViewConfig.IsWindow}");
                    }
                }
            }
            SirenixEditorGUI.EndHorizontalToolbar();
            
            EditorGUILayout.Space(5);

            // 模块名称
            EditorGUI.BeginChangeCheck();
            string oldModuleName = m_UIFacade.ModuleName;
            m_UIFacade.ModuleName = SirenixEditorFields.TextField("模块名称", m_UIFacade.ModuleName);
            bool moduleNameChanged = EditorGUI.EndChangeCheck();

            // 子模块名称输入框（仅在启用时显示）
            bool subModuleNameChanged = false;
            if (m_EnableSubModule)
            {
                EditorGUI.BeginChangeCheck();
                string oldSubModuleName = m_UIFacade.SubModuleName;
                m_UIFacade.SubModuleName = SirenixEditorFields.TextField("子模块名称", m_UIFacade.SubModuleName);
                subModuleNameChanged = EditorGUI.EndChangeCheck();
            }

            // 其他基本信息
            EditorGUI.BeginChangeCheck();
            string oldUIName = m_UIFacade.UIName;
            m_UIFacade.UIName = SirenixEditorFields.TextField("UI名称", m_UIFacade.UIName);
            bool uiNameChanged = EditorGUI.EndChangeCheck();
            
            // 检查是否需要重新生成脚本名称和ID
            if (moduleNameChanged || subModuleNameChanged || uiNameChanged || 
                string.IsNullOrEmpty(m_UIFacade.ScriptName) || string.IsNullOrEmpty(m_UIFacade.ID))
            {
                GenerateScriptNameAndID();
            }
            
            // 脚本名称（只读显示）
            EditorGUILayout.BeginHorizontal();
            {
                EditorGUILayout.LabelField("脚本名称:", GUILayout.Width(80));
                EditorGUILayout.LabelField(m_UIFacade.ScriptName ?? "未生成", SirenixGUIStyles.RightAlignedGreyMiniLabel);
                
                if (GUILayout.Button("重新生成", GUILayout.Width(70)))
                {
                    GenerateScriptNameAndID();
                }
            }
            EditorGUILayout.EndHorizontal();
            
            // ID（只读显示）
            EditorGUILayout.BeginHorizontal();
            {
                EditorGUILayout.LabelField("ID:", GUILayout.Width(80));
                EditorGUILayout.LabelField(m_UIFacade.ID ?? "未生成", SirenixGUIStyles.RightAlignedGreyMiniLabel);
                
                if (GUILayout.Button("复制ID", GUILayout.Width(70)))
                {
                    if (!string.IsNullOrEmpty(m_UIFacade.ID))
                    {
                        EditorGUIUtility.systemCopyBuffer = m_UIFacade.ID;
                        Debug.Log($"已复制ID到剪贴板: {m_UIFacade.ID}");
                    }
                }
            }
            EditorGUILayout.EndHorizontal();
            
            // 显示生成规则说明和示例
            SirenixEditorGUI.BeginBox("生成规则");
            {
                EditorGUILayout.LabelField("脚本名称: 模块名 + 子模块名 + UI名称 + Window/View (PascalCase)", SirenixGUIStyles.LeftAlignedGreyMiniLabel);
                EditorGUILayout.LabelField("ID格式: module_name.sub_module_name.ui_name (snake_case)", SirenixGUIStyles.LeftAlignedGreyMiniLabel);
                
                EditorGUILayout.Space(3);
                
                // 显示示例
                string exampleScript = GenerateExampleScriptName();
                string exampleID = GenerateExampleID();
                
                if (!string.IsNullOrEmpty(exampleScript) || !string.IsNullOrEmpty(exampleID))
                {
                    EditorGUILayout.LabelField("当前示例:", EditorStyles.boldLabel);
                    if (!string.IsNullOrEmpty(exampleScript))
                    {
                        EditorGUILayout.LabelField($"  脚本名称: {exampleScript}", SirenixGUIStyles.RightAlignedGreyMiniLabel);
                    }
                    if (!string.IsNullOrEmpty(exampleID))
                    {
                        EditorGUILayout.LabelField($"  ID: {exampleID}", SirenixGUIStyles.RightAlignedGreyMiniLabel);
                    }
                }
            }
            SirenixEditorGUI.EndBox();

            if (EditorGUI.EndChangeCheck())
            {
                EditorUtility.SetDirty(m_UIFacade);
            }
        }
        SirenixEditorGUI.EndBox();

        EditorGUILayout.Space(10);

        // UI元素列表
        DrawUIElementsList();

        EditorGUILayout.Space(10);

        // 工具按钮组
        DrawToolButtons();

        EditorGUILayout.Space(10);

        // ViewConfig配置组
        DrawViewConfig();

        // 应用修改
        if (GUI.changed)
        {
            EditorUtility.SetDirty(m_UIFacade);
        }
    }

    private void DrawUIElementsList()
    {
        SirenixEditorGUI.BeginBox("UI元素列表");
        {
            if (m_UIFacade.Elements == null)
            {
                m_UIFacade.Elements = new List<UIElement>();
            }

            // 列表标题和添加按钮
            SirenixEditorGUI.BeginHorizontalToolbar();
            {
                GUILayout.Label($"元素数量: {m_UIFacade.Elements.Count}", SirenixGUIStyles.LeftAlignedGreyMiniLabel);
                GUILayout.FlexibleSpace();

                // 添加按钮 - 使用更明显的样式
                GUI.backgroundColor = Color.green;
                if (GUILayout.Button(new GUIContent("+", "添加新UI元素"),
                    GUILayout.Width(30), GUILayout.Height(20)))
                {
                    AddNewUIElement();
                }
                GUI.backgroundColor = Color.white;

                // 刷新按钮
                if (GUILayout.Button(new GUIContent("↻", "刷新并清理无效元素"),
                    GUILayout.Width(30), GUILayout.Height(20)))
                {
                    RefreshUIElements();
                }
            }
            SirenixEditorGUI.EndHorizontalToolbar();

            EditorGUILayout.Space(5);

            // 如果列表为空，显示提示
            if (m_UIFacade.Elements.Count == 0)
            {
                SirenixEditorGUI.InfoMessageBox("暂无UI元素，点击上方的 + 按钮添加新元素，或使用下方的\"自动收集子对象\"功能。");
            }
            else
            {
                // 绘制元素列表
                for (int i = 0; i < m_UIFacade.Elements.Count; i++)
                {
                    DrawUIElement(i);
                }
            }
        }
        SirenixEditorGUI.EndBox();
    }

    private void DrawUIElement(int index)
    {
        var element = m_UIFacade.Elements[index];
        if (element == null)
        {
            m_UIFacade.Elements[index] = new UIElement();
            element = m_UIFacade.Elements[index];
        }

        SirenixEditorGUI.BeginBox();
        {
            // 主要信息行
            SirenixEditorGUI.BeginHorizontalToolbar();
            {
                // 索引标签
                GUILayout.Label($"[{index}]", SirenixGUIStyles.BoldLabel, GUILayout.Width(35));

                // 名称字段
                EditorGUI.BeginChangeCheck();
                GUILayout.Label("名称:", GUILayout.Width(35));
                string newName = EditorGUILayout.TextField(element.Name, GUILayout.MinWidth(80));
                if (EditorGUI.EndChangeCheck())
                {
                    if (ValidateElementName(index, newName))
                    {
                        element.Name = newName;
                        EditorUtility.SetDirty(m_UIFacade);
                    }
                    else
                    {
                        EditorUtility.DisplayDialog("错误", "元素名称重复或无效！", "确定");
                    }
                }

                // 状态下拉
                GUILayout.Label("状态:", GUILayout.Width(35));
                element.ActiveDefault = (ElementActiveDefault)EditorGUILayout.EnumPopup(
                    element.ActiveDefault, GUILayout.Width(70));

                GUILayout.FlexibleSpace();

                // 删除按钮
                GUI.color = Color.red;
                if (GUILayout.Button("×", GUILayout.Width(20), GUILayout.Height(18)))
                {
                    if (EditorUtility.DisplayDialog("确认删除", $"确定要删除元素 '{element.Name}' 吗？", "确定", "取消"))
                    {
                        RemoveUIElement(index);
                        return;
                    }
                }
                GUI.color = Color.white;
            }
            SirenixEditorGUI.EndHorizontalToolbar();

            EditorGUILayout.Space(3);

                        // GameObject选择字段行
            GameObject selectedGO = null;
            EditorGUILayout.BeginHorizontal();
            {
                GUILayout.Label("对象:", GUILayout.Width(40));
                
                // GameObject选择字段
                EditorGUI.BeginChangeCheck();
                GameObject targetGO = null;
                if (element.Component != null)
                {
                    targetGO = element.Component.gameObject;
                }
                
                selectedGO = (GameObject)EditorGUILayout.ObjectField(targetGO, typeof(GameObject), true, GUILayout.MinWidth(80));
                bool gameObjectChanged = EditorGUI.EndChangeCheck();
                
                if (gameObjectChanged && selectedGO != targetGO)
                {
                    // GameObject改变时，清空当前组件选择
                    element.Component = null;
                    EditorUtility.SetDirty(m_UIFacade);
                }
            }
            EditorGUILayout.EndHorizontal();
            
            // 组件选择下拉列表行
            EditorGUILayout.BeginHorizontal();
            {
                GUILayout.Label("组件:", GUILayout.Width(40));
                
                GameObject currentGO = selectedGO;
                
                if (currentGO != null)
                {
                    // 获取GameObject上的所有组件
                    Component[] allComponents = currentGO.GetComponents<Component>();
                    Component[] validComponents = allComponents.Where(c => c != null && !(c is Transform)).ToArray();
                    
                    if (validComponents.Length > 0)
                    {
                        // 创建组件名称数组
                        string[] componentNames = validComponents.Select(c => c.GetType().Name).ToArray();
                        
                        // 找到当前选中的组件索引
                        int selectedIndex = -1;
                        if (element.Component != null)
                        {
                            selectedIndex = System.Array.IndexOf(validComponents, element.Component);
                        }
                        
                        // 绘制下拉列表
                        EditorGUI.BeginChangeCheck();
                        int newIndex = EditorGUILayout.Popup(selectedIndex, componentNames, GUILayout.MinWidth(120));
                        
                        if (EditorGUI.EndChangeCheck() && newIndex >= 0 && newIndex < validComponents.Length)
                        {
                            element.Component = validComponents[newIndex];
                            if (string.IsNullOrEmpty(element.Name))
                            {
                                element.Name = element.Component.gameObject.name;
                            }
                            EditorUtility.SetDirty(m_UIFacade);
                        }
                        
                        // 显示组件详细信息
                        if (element.Component != null)
                        {
                            GUILayout.Label($"({element.Component.GetType().Namespace})", SirenixGUIStyles.RightAlignedGreyMiniLabel, GUILayout.MaxWidth(150));
                        }
                    }
                    else
                    {
                        EditorGUILayout.LabelField("该对象没有可用组件", SirenixGUIStyles.RightAlignedGreyMiniLabel);
                    }
                }
                else
                {
                    EditorGUILayout.LabelField("请先选择GameObject", SirenixGUIStyles.RightAlignedGreyMiniLabel);
                }
            }
            EditorGUILayout.EndHorizontal();

            // 显示组件信息
            if (element.Component != null)
            {
                EditorGUILayout.Space(2);
                SirenixEditorGUI.BeginIndentedVertical();
                {
                    EditorGUILayout.LabelField("类型", element.Component.GetType().Name, SirenixGUIStyles.RightAlignedGreyMiniLabel);
                    EditorGUILayout.LabelField("路径", GetGameObjectPath(element.Component.gameObject), SirenixGUIStyles.RightAlignedGreyMiniLabel);
                }
                SirenixEditorGUI.EndIndentedVertical();
            }
            else
            {
                EditorGUILayout.Space(2);
                SirenixEditorGUI.WarningMessageBox("请拖拽一个组件到上方的组件字段");
            }
        }
        SirenixEditorGUI.EndBox();

        EditorGUILayout.Space(3);
    }

    private void DrawToolButtons()
    {
        SirenixEditorGUI.BeginBox("工具栏");
        {
            SirenixEditorGUI.InfoMessageBox("使用以下工具来管理UI元素和配置");

            EditorGUILayout.Space(5);

            // 第一行工具按钮
            EditorGUILayout.BeginHorizontal();
            {
                // 自动收集按钮
                GUI.backgroundColor = new Color(0.7f, 1f, 0.7f);
                if (GUILayout.Button(new GUIContent("自动收集子对象", "自动收集GameObject下的所有组件"), GUILayout.Height(25)))
                {
                    AutoCollectChildComponents();
                }

                // 清空按钮
                GUI.backgroundColor = new Color(1f, 0.7f, 0.7f);
                if (GUILayout.Button(new GUIContent("清空列表", "清空所有UI元素"), GUILayout.Height(25)))
                {
                    if (EditorUtility.DisplayDialog("确认", "确定要清空所有UI元素吗？", "确定", "取消"))
                    {
                        ClearUIElements();
                    }
                }

                // 保存按钮
                GUI.backgroundColor = new Color(0.7f, 0.9f, 1f);
                if (GUILayout.Button(new GUIContent("保存配置", "保存当前配置到文件"), GUILayout.Height(25)))
                {
                    SaveComponent();
                }
                GUI.backgroundColor = Color.white;
            }
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.Space(5);

            // 第二行工具按钮
            EditorGUILayout.BeginHorizontal();
            {
                // 验证按钮
                GUI.backgroundColor = new Color(1f, 0.9f, 0.7f);
                if (GUILayout.Button(new GUIContent("验证配置", "检查配置的完整性和有效性"), GUILayout.Height(25)))
                {
                    ValidateConfiguration();
                }

                // 生成脚本按钮
                GUI.backgroundColor = new Color(0.9f, 0.7f, 1f);
                if (GUILayout.Button(new GUIContent("生成脚本", "根据配置生成相关脚本代码"), GUILayout.Height(25)))
                {
                    GenerateScript();
                }
                GUI.backgroundColor = Color.white;
            }
            EditorGUILayout.EndHorizontal();
        }
        SirenixEditorGUI.EndBox();
    }

    private void AddNewUIElement()
    {
        m_UIFacade.Elements.Add(new UIElement
        {
            Name = $"Element_{m_UIFacade.Elements.Count}",
            Component = null,
            ActiveDefault = ElementActiveDefault.Default
        });
        EditorUtility.SetDirty(m_UIFacade);
    }

    private void RemoveUIElement(int index)
    {
        if (index >= 0 && index < m_UIFacade.Elements.Count)
        {
            m_UIFacade.Elements.RemoveAt(index);
            EditorUtility.SetDirty(m_UIFacade);
        }
    }

    private void RefreshUIElements()
    {
        // 移除空的元素
        m_UIFacade.Elements.RemoveAll(e => e == null || e.Component == null);
        EditorUtility.SetDirty(m_UIFacade);
    }

    private bool ValidateElementName(int index, string name)
    {
        if (string.IsNullOrEmpty(name)) return false;
        return UIFacadeUtils.CheckName(m_UIFacade, index, name);
    }

        private void AutoCollectChildComponents()
    {
        // 获取所有子GameObject（包括自己）
        var allGameObjects = m_UIFacade.GetComponentsInChildren<Transform>(true)
            .Select(t => t.gameObject)
            .Where(go => go != m_UIFacade.gameObject) // 排除自己
            .ToArray();

        foreach (var go in allGameObjects)
        {
            // 获取GameObject上的所有组件，排除Transform和UIFacade
            var components = go.GetComponents<Component>()
                .Where(c => c != null && !(c is Transform) && !(c is UIFacade))
                .ToArray();

            if (components.Length > 0)
            {
                // 优先选择UI相关的组件
                Component selectedComponent = SelectBestComponent(components);
                
                string elementName = go.name;
                
                // 检查是否已存在同名元素
                if (!m_UIFacade.Elements.Any(e => e.Name == elementName))
                {
                    m_UIFacade.Elements.Add(new UIElement
                    {
                        Name = elementName,
                        Component = selectedComponent,
                        ActiveDefault = go.activeInHierarchy ? 
                            ElementActiveDefault.Active : ElementActiveDefault.DeActive
                    });
                }
            }
        }
        
        EditorUtility.SetDirty(m_UIFacade);
        Debug.Log($"自动收集完成，添加了 {m_UIFacade.Elements.Count} 个UI元素");
    }
    
    private Component SelectBestComponent(Component[] components)
    {
        // 定义组件优先级（从高到低）
        System.Type[] priorityTypes = new System.Type[]
        {
            typeof(UnityEngine.UI.Button),
            typeof(UnityEngine.UI.Image),
            typeof(UnityEngine.UI.Text),
            typeof(UnityEngine.UI.InputField),
            typeof(UnityEngine.UI.Slider),
            typeof(UnityEngine.UI.Toggle),
            typeof(UnityEngine.UI.Dropdown),
            typeof(UnityEngine.UI.ScrollRect),
            typeof(UnityEngine.UI.Scrollbar),
            typeof(UnityEngine.CanvasGroup),
            typeof(UnityEngine.Canvas),
            typeof(UnityEngine.UI.GraphicRaycaster),
            typeof(UnityEngine.RectTransform)
        };

        // 按优先级查找组件
        foreach (var priorityType in priorityTypes)
        {
            var component = components.FirstOrDefault(c => priorityType.IsAssignableFrom(c.GetType()));
            if (component != null)
            {
                return component;
            }
        }

        // 如果没有找到优先级组件，返回第一个
        return components[0];
    }

    private void ClearUIElements()
    {
        m_UIFacade.Elements.Clear();
        EditorUtility.SetDirty(m_UIFacade);
    }

    private void ValidateConfiguration()
    {
        var issues = new List<string>();

        if (string.IsNullOrEmpty(m_UIFacade.UIName))
            issues.Add("UI名称不能为空");

        if (string.IsNullOrEmpty(m_UIFacade.ScriptName))
            issues.Add("脚本名称不能为空");

        var duplicateNames = m_UIFacade.Elements
            .GroupBy(e => e.Name)
            .Where(g => g.Count() > 1)
            .Select(g => g.Key);

        if (duplicateNames.Any())
            issues.Add($"发现重复的元素名称: {string.Join(", ", duplicateNames)}");

        var nullComponents = m_UIFacade.Elements
            .Where((e, i) => e.Component == null)
            .Select((e, i) => i);

        if (nullComponents.Any())
            issues.Add($"以下索引的组件为空: {string.Join(", ", nullComponents)}");

        if (issues.Any())
        {
            EditorUtility.DisplayDialog("配置验证",
                $"发现以下问题:\n{string.Join("\n", issues)}", "确定");
        }
        else
        {
            EditorUtility.DisplayDialog("配置验证", "配置验证通过！", "确定");
        }
    }

    private void GenerateScript()
    {
        // TODO: 实现脚本生成功能
        EditorUtility.DisplayDialog("功能开发中", "脚本生成功能正在开发中...", "确定");
    }

    private void SaveComponent()
    {
        EditorUtility.SetDirty(m_UIFacade);
        AssetDatabase.SaveAssets();
        Debug.Log("UI Facade配置已保存");
    }

    private void DrawViewConfig()
    {
        SirenixEditorGUI.BeginBox("View配置");
        {
            if (m_ViewConfig == null)
            {
                // 尝试重新初始化ViewConfig
                m_ViewConfig = UIConfigUtilsEditor.GetViewConfig(m_UIFacade);
                
                if (m_ViewConfig == null)
                {
                    SirenixEditorGUI.ErrorMessageBox("ViewConfig初始化失败！");
                    SirenixEditorGUI.EndBox();
                    return;
                }
            }

            // 配置说明
            SirenixEditorGUI.InfoMessageBox("配置UI视图的显示层级和窗口属性");

            EditorGUILayout.Space(8);

            EditorGUI.BeginChangeCheck();

            // ID字段（只读显示）
            EditorGUILayout.BeginHorizontal();
            {
                EditorGUILayout.LabelField("配置ID:", GUILayout.Width(80));
                EditorGUILayout.LabelField(m_ViewConfig.ID ?? "未设置", SirenixGUIStyles.RightAlignedGreyMiniLabel);
            }
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.Space(3);

            // AssetID字段
            string newAssetID = SirenixEditorFields.TextField("资源ID", m_ViewConfig.AssetID ?? "");
            if (m_ViewConfig.AssetID != newAssetID)
            {
                m_ViewConfig.AssetID = newAssetID;
            }

            EditorGUILayout.Space(8);

            // UI层级设置
            UIlayer currentLayer = m_ViewConfig.Layer;
            UIlayer newLayer = (UIlayer)SirenixEditorFields.EnumDropdown("UI层级", currentLayer);
            if (currentLayer != newLayer)
            {
                m_ViewConfig.SetLayer(newLayer);
            }

            // 显示层级数值和说明
            SirenixEditorGUI.BeginIndentedHorizontal();
            {
                EditorGUILayout.LabelField("层级值:", $"{(int)newLayer}", SirenixGUIStyles.RightAlignedGreyMiniLabel);
                EditorGUILayout.LabelField("说明:", GetLayerDescription(newLayer), SirenixGUIStyles.RightAlignedGreyMiniLabel);
            }
            SirenixEditorGUI.EndIndentedHorizontal();

            EditorGUILayout.Space(5);

            // 显示窗口模式说明
            SirenixEditorGUI.BeginIndentedHorizontal();
            {
                bool isWindow = m_ViewConfig != null && m_ViewConfig.IsWindow;
                string modeText = isWindow ? "窗口模式 - 可独立管理的UI窗口" : "视图模式 - 普通UI视图";
                EditorGUILayout.LabelField("当前模式:", modeText, SirenixGUIStyles.RightAlignedGreyMiniLabel);
            }
            SirenixEditorGUI.EndIndentedHorizontal();

            if (EditorGUI.EndChangeCheck())
            {
                EditorUtility.SetDirty(target);
            }

            EditorGUILayout.Space(10);

            // ViewConfig工具按钮
            DrawViewConfigTools();
        }
        SirenixEditorGUI.EndBox();
    }



    private string GetLayerDescription(UIlayer layer)
    {
        return layer switch
        {
            UIlayer.BackGround => "背景层 - 用于背景UI元素",
            UIlayer.Hud => "HUD层 - 游戏界面HUD元素",
            UIlayer.Common => "通用层 - 普通UI界面",
            UIlayer.CommonH => "通用高层 - 高优先级通用界面",
            UIlayer.Pop => "弹窗层 - 弹出窗口",
            UIlayer.PopH => "弹窗高层 - 高优先级弹窗",
            UIlayer.Guide => "引导层 - 新手引导界面",
            UIlayer.Toast => "提示层 - 消息提示",
            UIlayer.ToastH => "提示高层 - 高优先级提示",
            UIlayer.loading => "加载层 - 加载界面",
            UIlayer.Lock => "锁定层 - 锁屏界面",
            UIlayer.SystemToast => "系统提示层 - 系统级提示",
            _ => "未知层级"
        };
    }

    private void DrawViewConfigTools()
    {
        SirenixEditorGUI.BeginBox("ViewConfig工具");
        {
            EditorGUILayout.BeginHorizontal();
            {
                // 同步ID按钮
                GUI.backgroundColor = new Color(0.8f, 0.9f, 1f);
                if (GUILayout.Button(new GUIContent("同步ID", "将UIFacade的ID同步到ViewConfig"), GUILayout.Height(25)))
                {
                    SyncIDToViewConfig();
                }

                // 重置配置按钮
                GUI.backgroundColor = new Color(1f, 0.8f, 0.8f);
                if (GUILayout.Button(new GUIContent("重置配置", "重置ViewConfig到默认状态"), GUILayout.Height(25)))
                {
                    if (EditorUtility.DisplayDialog("确认重置", "确定要重置ViewConfig配置吗？", "确定", "取消"))
                    {
                        ResetViewConfig();
                    }
                }

                // 保存配置按钮
                GUI.backgroundColor = new Color(0.8f, 1f, 0.8f);
                if (GUILayout.Button(new GUIContent("保存配置", "保存ViewConfig配置"), GUILayout.Height(25)))
                {
                    SaveViewConfig();
                }
                GUI.backgroundColor = Color.white;
            }
            EditorGUILayout.EndHorizontal();
        }
        SirenixEditorGUI.EndBox();
    }

    private void SyncIDToViewConfig()
    {
        if (!string.IsNullOrEmpty(m_UIFacade.ID))
        {
            m_ViewConfig.ID = m_UIFacade.ID;
            EditorUtility.SetDirty(target);
            Debug.Log($"已同步ID: {m_UIFacade.ID}");
        }
        else
        {
            EditorUtility.DisplayDialog("错误", "UIFacade的ID为空，无法同步", "确定");
        }
    }

    private void ResetViewConfig()
    {
        m_ViewConfig.SetLayer(UIlayer.Common);
        m_ViewConfig.SetWindow(false);
        m_ViewConfig.AssetID = "";
        EditorUtility.SetDirty(target);
        Debug.Log("ViewConfig已重置到默认状态");
    }

    private void SaveViewConfig()
    {
        UIConfigUtilsEditor.SaveViewConfig(m_UIFacade);
        EditorUtility.SetDirty(target);
        Debug.Log("ViewConfig配置已保存");
    }

    private void GenerateScriptNameAndID()
    {
        if (m_UIFacade == null) return;
        
        // 获取各个组件
        string moduleName = CleanName(m_UIFacade.ModuleName);
        string subModuleName = m_EnableSubModule ? CleanName(m_UIFacade.SubModuleName) : "";
        string uiName = CleanName(m_UIFacade.UIName);
        
        // 生成脚本名称 (PascalCase)
        // 规则: ModuleNameSubModuleNameUINameWindow/View
        if (!string.IsNullOrEmpty(uiName))
        {
            string scriptName = "";
            
            // 添加模块名
            if (!string.IsNullOrEmpty(moduleName))
            {
                scriptName += ToPascalCase(moduleName);
            }
            
            // 添加子模块名（如果启用）
            if (!string.IsNullOrEmpty(subModuleName))
            {
                scriptName += ToPascalCase(subModuleName);
            }
            
            // 添加UI名称
            scriptName += ToPascalCase(uiName);
            
            // 添加后缀（根据是否为窗口模式）
            bool isWindow = m_ViewConfig != null && m_ViewConfig.IsWindow;
            scriptName += isWindow ? "Window" : "View";
            
            m_UIFacade.ScriptName = scriptName;
        }
        else
        {
            m_UIFacade.ScriptName = "";
        }
        
        // 生成ID (snake_case)
        // 规则: module_name.sub_module_name.ui_name
        if (!string.IsNullOrEmpty(uiName))
        {
            List<string> idParts = new List<string>();
            
            // 添加模块名
            if (!string.IsNullOrEmpty(moduleName))
            {
                idParts.Add(ToSnakeCase(moduleName));
            }
            
            // 添加子模块名（如果启用）
            if (!string.IsNullOrEmpty(subModuleName))
            {
                idParts.Add(ToSnakeCase(subModuleName));
            }
            
            // 添加UI名称
            idParts.Add(ToSnakeCase(uiName));
            
            m_UIFacade.ID = string.Join(".", idParts);
        }
        else
        {
            m_UIFacade.ID = "";
        }
        
        // 更新ViewConfig的ID
        if (m_ViewConfig != null && !string.IsNullOrEmpty(m_UIFacade.ID))
        {
            m_ViewConfig.ID = m_UIFacade.ID;
        }
        
        EditorUtility.SetDirty(m_UIFacade);
    }
    
    private string CleanName(string name)
    {
        if (string.IsNullOrEmpty(name)) return "";
        
        // 移除特殊字符，只保留字母数字和空格
        return System.Text.RegularExpressions.Regex.Replace(name.Trim(), @"[^a-zA-Z0-9\s]", "");
    }
    
    private string ToPascalCase(string input)
    {
        if (string.IsNullOrEmpty(input)) return "";
        
        // 分割单词（按空格、下划线、连字符）
        string[] words = System.Text.RegularExpressions.Regex.Split(input, @"[\s_-]+");
        
        string result = "";
        foreach (string word in words)
        {
            if (!string.IsNullOrEmpty(word))
            {
                result += char.ToUpper(word[0]) + word.Substring(1).ToLower();
            }
        }
        
        return result;
    }
    
    private string ToSnakeCase(string input)
    {
        if (string.IsNullOrEmpty(input)) return "";
        
        // 分割单词（按空格、下划线、连字符、驼峰命名）
        string[] words = System.Text.RegularExpressions.Regex.Split(input, @"[\s_-]+|(?=[A-Z])");
        
        List<string> cleanWords = new List<string>();
        foreach (string word in words)
        {
            if (!string.IsNullOrEmpty(word))
            {
                cleanWords.Add(word.ToLower());
            }
        }
        
        return string.Join("_", cleanWords);
    }
    
    private string GenerateExampleScriptName()
    {
        // 使用当前输入生成示例
        string moduleName = CleanName(m_UIFacade.ModuleName);
        string subModuleName = m_EnableSubModule ? CleanName(m_UIFacade.SubModuleName) : "";
        string uiName = CleanName(m_UIFacade.UIName);
        
        if (string.IsNullOrEmpty(moduleName) && string.IsNullOrEmpty(subModuleName) && string.IsNullOrEmpty(uiName))
        {
            // 显示默认示例
            return "GameUILoginView";
        }
        
        string scriptName = "";
        
        if (!string.IsNullOrEmpty(moduleName))
        {
            scriptName += ToPascalCase(moduleName);
        }
        else
        {
            scriptName += "Game"; // 默认示例
        }
        
        if (!string.IsNullOrEmpty(subModuleName))
        {
            scriptName += ToPascalCase(subModuleName);
        }
        else if (string.IsNullOrEmpty(moduleName) && string.IsNullOrEmpty(uiName))
        {
            scriptName += "UI"; // 默认示例
        }
        
        if (!string.IsNullOrEmpty(uiName))
        {
            scriptName += ToPascalCase(uiName);
        }
        else
        {
            scriptName += "Login"; // 默认示例
        }
        
        bool isWindow = m_ViewConfig != null && m_ViewConfig.IsWindow;
        scriptName += isWindow ? "Window" : "View";
        
        return scriptName;
    }
    
    private string GenerateExampleID()
    {
        // 使用当前输入生成示例
        string moduleName = CleanName(m_UIFacade.ModuleName);
        string subModuleName = m_EnableSubModule ? CleanName(m_UIFacade.SubModuleName) : "";
        string uiName = CleanName(m_UIFacade.UIName);
        
        if (string.IsNullOrEmpty(moduleName) && string.IsNullOrEmpty(subModuleName) && string.IsNullOrEmpty(uiName))
        {
            // 显示默认示例
            return "game.ui.login";
        }
        
        List<string> idParts = new List<string>();
        
        if (!string.IsNullOrEmpty(moduleName))
        {
            idParts.Add(ToSnakeCase(moduleName));
        }
        else
        {
            idParts.Add("game"); // 默认示例
        }
        
        if (!string.IsNullOrEmpty(subModuleName))
        {
            idParts.Add(ToSnakeCase(subModuleName));
        }
        else if (string.IsNullOrEmpty(moduleName) && string.IsNullOrEmpty(uiName))
        {
            idParts.Add("ui"); // 默认示例
        }
        
        if (!string.IsNullOrEmpty(uiName))
        {
            idParts.Add(ToSnakeCase(uiName));
        }
        else
        {
            idParts.Add("login"); // 默认示例
        }
        
        return string.Join(".", idParts);
    }

    private string GetGameObjectPath(GameObject obj)
    {
        if (obj == null) return "";

        string path = obj.name;
        Transform parent = obj.transform.parent;

        while (parent != null && parent != m_UIFacade.transform)
        {
            path = parent.name + "/" + path;
            parent = parent.parent;
        }

        return path;
    }
}
