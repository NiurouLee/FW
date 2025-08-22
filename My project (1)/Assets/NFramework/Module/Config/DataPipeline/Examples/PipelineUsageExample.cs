using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using NFramework.Module.Config.DataPipeline;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline.Examples
{
    /// <summary>
    /// 管道使用示例
    /// </summary>
    public static class PipelineUsageExample
    {
        /// <summary>
        /// 基础使用示例
        /// </summary>
        public static void BasicUsageExample()
        {
            try
            {
                Debug.Log("=== 基础管道使用示例 ===");

                // 1. 创建标准管道
                var pipeline = ConfigPipelineFactory.CreateStandardPipeline();

                // 2. 准备输入数据
                var input = new PipelineInput
                {
                    ConfigType = "Character",
                    ConfigName = "PlayerCharacters",
                    SourceFilePath = "ConfigData/Excel/Characters.xlsx",
                    OutputPath = "ConfigData/Output"
                };

                // 3. 执行管道
                var result = pipeline.Execute(new List<PipelineInput> { input });

                // 4. 处理结果
                if (result.Success)
                {
                    Debug.Log($"管道执行成功！耗时: {result.Duration.TotalMilliseconds:F0}ms");
                    Debug.Log($"生成的文件: {string.Join(", ", result.GeneratedFiles.Keys)}");
                }
                else
                {
                    Debug.LogError($"管道执行失败！错误: {string.Join("; ", result.Errors)}");
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"基础使用示例失败: {ex.Message}");
            }
        }

        /// <summary>
        /// 自定义管道示例
        /// </summary>
        public static void CustomPipelineExample()
        {
            try
            {
                Debug.Log("=== 自定义管道使用示例 ===");

                // 1. 创建自定义配置
                var config = new PipelineConfiguration
                {
                    EnableCodeGeneration = true,
                    EnableValidation = true,
                    EnableLocalization = true,
                    EnableReferenceResolution = true,
                    CompressionSettings = new CompressionSettings
                    {
                        EnableCompression = true
                    },
                    EncryptionSettings = new EncryptionSettings
                    {
                        EnableEncryption = true,
                        EncryptionKey = "MySecretKey123"
                    }
                };

                // 2. 创建管道
                var pipeline = ConfigPipelineFactory.CreateStandardPipeline(config);

                // 3. 准备输入数据
                var inputs = new List<PipelineInput>
                {
                    new PipelineInput
                    {
                        ConfigType = "Character",
                        ConfigName = "NPCs",
                        SourceFilePath = "ConfigData/Excel/NPCs.xlsx",
                        OutputPath = "ConfigData/Output/NPCs"
                    },
                    new PipelineInput
                    {
                        ConfigType = "Item",
                        ConfigName = "Weapons",
                        SourceFilePath = "ConfigData/Excel/Weapons.xlsx",
                        OutputPath = "ConfigData/Output/Items"
                    }
                };

                // 4. 执行处理
                var result = pipeline.Execute(inputs);

                // 5. 处理结果
                if (result.Success)
                {
                    Debug.Log($"自定义管道执行成功！耗时: {result.Duration.TotalMilliseconds:F0}ms");
                    Debug.Log($"生成的文件: {string.Join(", ", result.GeneratedFiles.Keys)}");

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
                    Debug.LogError($"自定义管道执行失败！错误: {string.Join("; ", result.Errors)}");
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"自定义管道示例失败: {ex.Message}");
            }
        }

        /// <summary>
        /// 批量处理示例
        /// </summary>
        public static void BatchProcessingExample()
        {
            try
            {
                Debug.Log("=== 批量处理示例 ===");

                var excelDirectory = "ConfigData/Excel";
                var excelFiles = Directory.GetFiles(excelDirectory, "*.xlsx", SearchOption.AllDirectories);

                var inputs = new List<PipelineInput>();
                foreach (var excelFile in excelFiles)
                {
                    var fileName = Path.GetFileNameWithoutExtension(excelFile);
                    var configType = DetermineConfigType(fileName);

                    inputs.Add(new PipelineInput
                    {
                        ConfigType = configType,
                        ConfigName = fileName,
                        SourceFilePath = excelFile,
                        OutputPath = Path.Combine("ConfigData/Output", configType)
                    });
                }

                // 创建管道并执行
                var config = new PipelineConfiguration
                {
                    EnableCodeGeneration = true,
                    EnableValidation = true,
                    EnableReferenceResolution = true
                };

                var pipeline = ConfigPipelineFactory.CreateStandardPipeline(config);
                var result = pipeline.Execute(inputs);

                // 处理结果
                if (result.Success)
                {
                    Debug.Log($"批量处理成功！耗时: {result.Duration.TotalMilliseconds:F0}ms");
                    Debug.Log($"处理的文件数: {inputs.Count}");
                    Debug.Log($"生成的文件: {string.Join(", ", result.GeneratedFiles.Keys)}");
                }
                else
                {
                    Debug.LogError($"批量处理失败！错误: {string.Join("; ", result.Errors)}");
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"批量处理示例失败: {ex.Message}");
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