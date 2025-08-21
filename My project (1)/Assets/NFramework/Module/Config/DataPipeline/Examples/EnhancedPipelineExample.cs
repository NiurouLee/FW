using System;
using System.IO;
using UnityEngine;
using UnityEditor;
using NFramework.Module.Config.DataPipeline.Core;
using NFramework.Module.Config.DataPipeline.Processors;

namespace NFramework.Module.Config.DataPipeline.Examples
{
    /// <summary>
    /// 增强管道使用示例 - 演示新功能的完整使用
    /// </summary>
    public static class EnhancedPipelineExample
    {
        /// <summary>
        /// 根据CSV生成代码
        /// </summary>
        [MenuItem("NFramework/2. Generate Code from CSV")]
        public static void CompleteExcelToCodeExample()
        {
            try
            {
                Debug.Log("=== 增强管道完整示例 ===");

                // 1. 创建增强的管道配置
                var config = CreateEnhancedPipelineConfiguration();

                // 2. 创建管道
                var pipeline = ConfigPipelineFactory.CreateStandardPipeline(config);

                // 3. 添加增强的处理器
                RegisterEnhancedProcessors(pipeline);

                // 4. 确保示例数据存在
                EnsureSampleDataExists();

                // 5. 批量处理所有配置文件
                ProcessAllConfigFiles(pipeline);

                Debug.Log("所有配置文件处理完成！");

                Debug.Log("增强管道示例执行完成");
            }
            catch (Exception ex)
            {
                Debug.LogError($"增强管道示例失败: {ex.Message}");
            }
        }

        /// <summary>
        /// 创建增强的管道配置
        /// </summary>
        private static PipelineConfiguration CreateEnhancedPipelineConfiguration()
        {
            return new PipelineConfiguration
            {
                // 基本设置
                EnableValidation = true,
                EnableCodeGeneration = true,
                StopOnValidationError = false,
                CodeOutputDirectory = "Assets/Generated/Config",

                // 启用所有增强功能
                EnableDataCleaning = true,
                EnableSchemaGeneration = true,
                EnableLocalization = true,
                EnableReferenceResolution = true,
                EnableIndexBuilding = true,
                EnableDataValidation = true,
                EnableBusinessRuleValidation = true,
                EnableAccessorGeneration = true,

                // 本地化设置
                LocalizationSettings = new LocalizationSettings
                {
                    GenerateLocalizationFile = true,
                    DefaultLanguage = "zh-CN",
                    LocalizationKeyFormat = "LOC_{key}"
                },

                // 引用设置
                ReferenceSettings = new ReferenceSettings
                {
                    ValidateReferences = true,
                    ResolveCircularReferences = false
                },

                // 代码生成设置
                CodeGenerationSettings = new CodeGenerationSettings
                {
                    Namespace = "GameConfig.Generated",
                    GenerateAccessors = true,
                    GenerateValidation = true,
                    GenerateComments = true
                }
            };
        }

        /// <summary>
        /// 注册增强的处理器
        /// </summary>
        private static void RegisterEnhancedProcessors(ConfigPipeline pipeline)
        {
            // 添加增强的代码生成器
            var enhancedCodeGenerator = new EnhancedCodeGenerator(new EnhancedCodeGenerationSettings
            {
                Namespace = "GameConfig.Generated",
                GenerateAccessors = true,
                GenerateValidation = true,
                GenerateComments = true
            });

            pipeline.RegisterCodeGenerator(enhancedCodeGenerator);

            Debug.Log("已注册增强处理器");
        }

        /// <summary>
        /// 确保示例数据存在
        /// </summary>
        private static void EnsureSampleDataExists()
        {
            var configDataDir = Path.Combine(Application.dataPath, "ConfigData", "Excel");
            
            // 检查是否有任何配置文件
            if (!Directory.Exists(configDataDir) || Directory.GetFiles(configDataDir, "*.csv").Length == 0)
            {
                Debug.Log("示例配置文件不存在，正在生成...");
                SimpleExcelGenerator.CreateSampleConfigFiles();
            }
        }

        /// <summary>
        /// 处理所有配置文件
        /// </summary>
        private static void ProcessAllConfigFiles(ConfigPipeline pipeline)
        {
            var configDataDir = Path.Combine(Application.dataPath, "ConfigData", "Excel");
            var csvFiles = Directory.GetFiles(configDataDir, "*.csv", SearchOption.TopDirectoryOnly);
            
            Debug.Log($"找到 {csvFiles.Length} 个配置文件");
            
            foreach (var csvFile in csvFiles)
            {
                try
                {
                    var fileName = Path.GetFileNameWithoutExtension(csvFile);
                    var configType = DetermineConfigType(fileName);
                    
                    Debug.Log($"处理配置文件: {fileName} -> {configType}");
                    
                    var input = EnhancedExcelDataLoader.CreatePipelineInput(csvFile, configType, fileName);
                    var result = pipeline.Execute(input);
                    
                    ProcessResult(result, fileName);
                }
                catch (Exception ex)
                {
                    Debug.LogError($"处理配置文件 {Path.GetFileName(csvFile)} 失败: {ex.Message}");
                }
            }
        }

        /// <summary>
        /// 处理管道执行结果
        /// </summary>
        private static void ProcessResult(PipelineResult result, string fileName = "")
        {
            var prefix = string.IsNullOrEmpty(fileName) ? "" : $"[{fileName}] ";
            
            if (result.Success)
            {
                Debug.Log($"{prefix}✓ 处理成功！耗时: {result.Duration.TotalMilliseconds:F0}ms");
                
                // 显示生成的文件
                if (result.GeneratedFiles.Count > 0)
                {
                    Debug.Log("生成的文件:");
                    foreach (var file in result.GeneratedFiles)
                    {
                        Debug.Log($"  - {file.Key}");
                    }
                }

                // 显示日志
                if (result.Logs.Count > 0)
                {
                    Debug.Log("处理日志:");
                    foreach (var log in result.Logs)
                    {
                        Debug.Log($"  {log}");
                    }
                }

                // 显示警告
                if (result.Warnings.Count > 0)
                {
                    Debug.Log("警告信息:");
                    foreach (var warning in result.Warnings)
                    {
                        Debug.LogWarning($"  {warning}");
                    }
                }
            }
            else
            {
                Debug.LogError($"{prefix}✗ 处理失败！");
                
                // 显示错误信息
                if (result.Errors.Count > 0)
                {
                    foreach (var error in result.Errors)
                    {
                        Debug.LogError($"  错误: {error}");
                    }
                }
                
                // 显示处理日志，可能包含更多上下文信息
                if (result.Logs.Count > 0)
                {
                    Debug.Log("处理日志:");
                    foreach (var log in result.Logs)
                    {
                        Debug.Log($"  {log}");
                    }
                }
                
                // 显示警告信息
                if (result.Warnings.Count > 0)
                {
                    Debug.Log("警告信息:");
                    foreach (var warning in result.Warnings)
                    {
                        Debug.LogWarning($"  {warning}");
                    }
                }
            }
        }

        /// <summary>
        /// 测试特定功能的示例
        /// </summary>
        public static void TestSpecificFeatures()
        {
            Debug.Log("=== 测试特定功能 ===");

            // 测试引用字段处理
            TestReferenceFieldProcessing();

            // 测试多语言处理
            TestLocalizationProcessing();

            // 测试类型支持
            TestTypeSupport();

            // 测试客户端/服务端分离
            TestClientServerSeparation();
        }

        private static void TestReferenceFieldProcessing()
        {
            Debug.Log("测试引用字段处理...");
            // 这里可以添加具体的引用字段测试逻辑
        }

        private static void TestLocalizationProcessing()
        {
            Debug.Log("测试多语言处理...");
            // 这里可以添加具体的多语言测试逻辑
        }

        private static void TestTypeSupport()
        {
            Debug.Log("测试类型支持...");
            // 这里可以添加具体的类型支持测试逻辑
        }

        private static void TestClientServerSeparation()
        {
            Debug.Log("测试客户端/服务端分离...");
            // 这里可以添加具体的分离测试逻辑
        }

        /// <summary>
        /// 批量处理示例
        /// </summary>
        // [MenuItem("NFramework/Run Batch Processing Example")]  // 已禁用，简化菜单
        public static void BatchProcessingExample()
        {
            try
            {
                Debug.Log("=== 批量处理示例 ===");

                var excelDirectory = Path.Combine(Application.dataPath, "ConfigData", "Excel");
                
                if (!Directory.Exists(excelDirectory))
                {
                    Debug.LogWarning($"Excel目录不存在: {excelDirectory}");
                    return;
                }

                var excelFiles = Directory.GetFiles(excelDirectory, "*.xlsx", SearchOption.AllDirectories);
                Debug.Log($"找到 {excelFiles.Length} 个Excel文件");

                var config = CreateEnhancedPipelineConfiguration();
                
                foreach (var excelFile in excelFiles)
                {
                    try
                    {
                        var fileName = Path.GetFileNameWithoutExtension(excelFile);
                        var configType = DetermineConfigType(fileName);

                        Debug.Log($"处理文件: {fileName} -> {configType}");

                        var pipeline = ConfigPipelineFactory.CreateForConfigType(configType, config);
                        RegisterEnhancedProcessors(pipeline);

                        var input = EnhancedExcelDataLoader.CreatePipelineInput(excelFile, configType, fileName);
                        var result = pipeline.Execute(input);

                        if (result.Success)
                        {
                            Debug.Log($"✓ 成功处理: {fileName}");
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
                        Debug.LogError($"处理文件 {excelFile} 时发生异常: {ex.Message}");
                    }
                }

                Debug.Log("批量处理完成");
            }
            catch (Exception ex)
            {
                Debug.LogError($"批量处理失败: {ex.Message}");
            }
        }

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
    }
}
