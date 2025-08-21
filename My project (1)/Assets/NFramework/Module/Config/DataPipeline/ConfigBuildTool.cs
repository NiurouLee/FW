using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 配置构建工具 - Editor专用
    /// </summary>
    public static class ConfigBuildTool
    {
        private const string EXCEL_PATH = "ConfigData/Excel";
        private const string OUTPUT_PATH = "ConfigData/Output";
        private const string DATABASE_PATH = "ConfigData/game_config.db";
        
        // [MenuItem("NFramework/Config/Build All Configs")]  // 已禁用，简化菜单
        public static void BuildAllConfigs()
        {
            try
            {
                Debug.Log("开始构建所有配置数据...");
                
                // 1. 检查Excel文件目录
                string excelDir = Path.Combine(Application.dataPath, "..", EXCEL_PATH);
                if (!Directory.Exists(excelDir))
                {
                    Debug.LogError($"Excel目录不存在: {excelDir}");
                    return;
                }
                
                // 2. 初始化数据库
                string dbPath = Path.Combine(Application.dataPath, "..", DATABASE_PATH);
                string dbDir = Path.GetDirectoryName(dbPath);
                Directory.CreateDirectory(dbDir);
                
                using (var dataManager = new SQLiteDataManager(dbPath))
                {
                    // 3. 处理所有Excel文件
                    var excelFiles = Directory.GetFiles(excelDir, "*.xlsx", SearchOption.AllDirectories);
                    
                    foreach (var excelFile in excelFiles)
                    {
                        ProcessExcelFile(excelFile, dataManager);
                    }
                    
                    // 4. 显示统计信息
                    var stats = dataManager.GetDatabaseStats();
                    Debug.Log($"配置构建完成！统计信息: {stats}");
                }
                
                Debug.Log("所有配置数据构建完成！");
            }
            catch (Exception ex)
            {
                Debug.LogError($"构建配置数据失败: {ex.Message}");
            }
        }
        
        // [MenuItem("NFramework/Config/Build Single Config")]  // 已禁用，简化菜单
        public static void BuildSingleConfig()
        {
            // 弹出文件选择对话框
            string excelFile = EditorUtility.OpenFilePanel("选择Excel配置文件", 
                Path.Combine(Application.dataPath, "..", EXCEL_PATH), "xlsx");
            
            if (!string.IsNullOrEmpty(excelFile))
            {
                try
                {
                    string dbPath = Path.Combine(Application.dataPath, "..", DATABASE_PATH);
                    var dataManager = CreateDataManager(dbPath);
                    
                    try
                    {
                        ProcessExcelFile(excelFile, dataManager);
                    }
                    finally
                    {
                        if (dataManager is IDisposable disposable)
                        {
                            disposable.Dispose();
                        }
                    }
                    
                    Debug.Log($"单个配置文件构建完成: {Path.GetFileName(excelFile)}");
                }
                catch (Exception ex)
                {
                    Debug.LogError($"构建单个配置失败: {ex.Message}");
                }
            }
        }
        
        // [MenuItem("NFramework/Config/View Database Stats")]  // 已禁用，简化菜单
        public static void ViewDatabaseStats()
        {
            try
            {
                string dbPath = Path.Combine(Application.dataPath, "..", DATABASE_PATH);
                
                if (!File.Exists(dbPath))
                {
                    EditorUtility.DisplayDialog("提示", "数据库文件不存在，请先构建配置数据", "确定");
                    return;
                }
                
                var dataManager = CreateDataManager(dbPath);
                try
                {
                    var stats = GetDatabaseStats(dataManager);
                    var configTypes = GetAllConfigTypes(dataManager);
                    
                    string message = $"{stats}\n\n配置类型:\n{string.Join("\n", configTypes)}";
                    EditorUtility.DisplayDialog("数据库统计信息", message, "确定");
                }
                finally
                {
                    if (dataManager is IDisposable disposable)
                    {
                        disposable.Dispose();
                    }
                }
            }
            catch (Exception ex)
            {
                EditorUtility.DisplayDialog("错误", $"查看数据库统计失败: {ex.Message}", "确定");
            }
        }
        
        // [MenuItem("NFramework/Config/Clear Database")]  // 已禁用，简化菜单
        public static void ClearDatabase()
        {
            if (EditorUtility.DisplayDialog("确认", "确定要清空配置数据库吗？", "确定", "取消"))
            {
                try
                {
                    string dbPath = Path.Combine(Application.dataPath, "..", DATABASE_PATH);
                    
                    if (File.Exists(dbPath))
                    {
                        File.Delete(dbPath);
                        Debug.Log("配置数据库已清空");
                    }
                    else
                    {
                        Debug.LogWarning("数据库文件不存在");
                    }
                }
                catch (Exception ex)
                {
                    Debug.LogError($"清空数据库失败: {ex.Message}");
                }
            }
        }
        
        private static void ProcessExcelFile(string excelFilePath, object dataManager)
        {
            try
            {
                string fileName = Path.GetFileNameWithoutExtension(excelFilePath);
                string configType = DetermineConfigType(fileName);
                
                Debug.Log($"处理Excel文件: {fileName} -> {configType}");
                
                // 使用新的增强管道系统
                var config = new PipelineConfiguration
                {
                    EnableValidation = true,
                    EnableCodeGeneration = true,
                    EnableLocalization = true,
                    EnableReferenceResolution = true
                };
                
                var pipeline = ConfigPipelineFactory.CreateForConfigType(configType, config);
                
                // 创建管道输入
                var input = EnhancedExcelDataLoader.CreatePipelineInput(excelFilePath, configType, fileName);
                
                // 执行管道处理
                var result = pipeline.Execute(input);
                
                if (result.Success)
                {
                    Debug.Log($"✓ 处理成功: {fileName}");
                    
                    // 存储到数据库
                    if (result.BinaryData != null && result.BinaryData.Length > 0)
                    {
                        StoreBinaryData(dataManager, configType, fileName, result.BinaryData);
                    }
                }
                else
                {
                    Debug.LogError($"✗ 处理失败: {fileName}");
                    foreach (var error in result.Errors)
                    {
                        Debug.LogError($"    {error}");
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"处理Excel文件失败: {Path.GetFileName(excelFilePath)}, 错误: {ex.Message}");
            }
        }
        
        /// <summary>
        /// 确定配置类型
        /// </summary>
        private static string DetermineConfigType(string fileName)
        {
            var lowerName = fileName.ToLower();
            
            if (lowerName.Contains("character") || lowerName.Contains("角色"))
                return "Character";
            if (lowerName.Contains("item") || lowerName.Contains("物品"))
                return "Item";
            if (lowerName.Contains("skill") || lowerName.Contains("技能"))
                return "Skill";
            if (lowerName.Contains("localization") || lowerName.Contains("本地化"))
                return "Localization";
                
            return "Generic";
        }
        
        /// <summary>
        /// 存储二进制数据到数据库（兼容两种数据管理器）
        /// </summary>
        private static void StoreBinaryData(object dataManager, string configType, string configName, byte[] binaryData)
        {
            try
            {
#if SQLITE4UNITY3D
                if (dataManager is SQLite4Unity3dDataManager sqlite4Manager)
                {
                    sqlite4Manager.StoreFlatBufferData(configType, configName, binaryData);
                    return;
                }
#endif
#if MONO_SQLITE
                if (dataManager is SQLiteDataManager sqliteManager)
                {
                    sqliteManager.StoreFlatBufferData(configType, configName, binaryData);
                    return;
                }
#endif
                Debug.LogWarning($"无法存储数据到数据库，数据管理器类型不支持: {dataManager?.GetType().Name}");
            }
            catch (Exception ex)
            {
                Debug.LogError($"存储数据到数据库失败: {configType}.{configName}, 错误: {ex.Message}");
            }
        }
        
        // [MenuItem("NFramework/Config/Open Config Folder")]  // 已禁用，简化菜单
        public static void OpenConfigFolder()
        {
            string configDir = Path.Combine(Application.dataPath, "..", "ConfigData");
            
            if (Directory.Exists(configDir))
            {
                EditorUtility.RevealInFinder(configDir);
            }
            else
            {
                Directory.CreateDirectory(configDir);
                Directory.CreateDirectory(Path.Combine(configDir, "Excel"));
                Directory.CreateDirectory(Path.Combine(configDir, "Output"));
                
                EditorUtility.RevealInFinder(configDir);
                Debug.Log("配置目录已创建，请将Excel文件放入Excel文件夹中");
            }
        }
        
        /// <summary>
        /// 创建数据管理器（兼容两种SQLite库）
        /// </summary>
        private static object CreateDataManager(string databasePath)
        {
#if SQLITE4UNITY3D
            return new SQLite4Unity3dDataManager(databasePath);
#elif MONO_SQLITE
            return new SQLiteDataManager(databasePath);
#else
            Debug.LogWarning("未找到可用的SQLite库，将使用空实现");
            return new EmptyDataManager();
#endif
        }
        
        /// <summary>
        /// 获取数据库统计信息（兼容两种数据管理器）
        /// </summary>
        private static DatabaseStats GetDatabaseStats(object dataManager)
        {
#if SQLITE4UNITY3D
            if (dataManager is SQLite4Unity3dDataManager sqlite4Manager)
            {
                return sqlite4Manager.GetDatabaseStats();
            }
#endif
#if MONO_SQLITE
            if (dataManager is SQLiteDataManager sqliteManager)
            {
                return sqliteManager.GetDatabaseStats();
            }
#endif
            return new DatabaseStats();
        }
        
        /// <summary>
        /// 获取所有配置类型（兼容两种数据管理器）
        /// </summary>
        private static List<string> GetAllConfigTypes(object dataManager)
        {
#if SQLITE4UNITY3D
            if (dataManager is SQLite4Unity3dDataManager sqlite4Manager)
            {
                return sqlite4Manager.GetAllConfigTypes();
            }
#endif
#if MONO_SQLITE
            if (dataManager is SQLiteDataManager sqliteManager)
            {
                return sqliteManager.GetAllConfigTypes();
            }
#endif
            return new List<string>();
        }
    }
    
    /// <summary>
    /// 空数据管理器（当没有SQLite库时使用）
    /// </summary>
    public class EmptyDataManager : IDisposable
    {
        public EmptyDataManager()
        {
            Debug.LogWarning("使用空数据管理器，数据不会被持久化");
        }
        
        public void StoreFlatBufferData(string configType, string configName, byte[] binaryData)
        {
            Debug.Log($"模拟存储数据: {configType}.{configName} ({binaryData?.Length ?? 0} bytes)");
        }
        
        public void Dispose() { }
    }
}
