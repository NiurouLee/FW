using System;
using System.IO;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using NFramework.Module.Config.DataPipeline;

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
                var settings = CreateEnhancedPipelineSettings();

                // 2. 创建管道
                var pipeline = new ConfigPipeline(settings);

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
        private static PipelineSettings CreateEnhancedPipelineSettings()
        {
            return new PipelineSettings
            {
                EnableCodeGeneration = true,
                CodeOutputDirectory = "Assets/Generated/Config",
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
            // 注册收集器
            pipeline.RegisterCollector(new TypeCollectorProcessor());

            // 注册批处理器
            pipeline.RegisterBatchProcessor(new TypeBatchProcessor());

            // 注册代码生成器
            var enhancedCodeGenerator = new EnhancedCodeGenerator(new EnhancedCodeGenerationSettings
            {
                Namespace = "GameConfig.Generated",
                GenerateAccessors = true,
                GenerateValidation = true,
                GenerateComments = true
            });

            pipeline.RegisterGenerator(enhancedCodeGenerator);

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

            var inputs = new List<PipelineInput>();

            // 准备所有输入
            foreach (var csvFile in csvFiles)
            {
                try
                {
                    var fileName = Path.GetFileNameWithoutExtension(csvFile);
                    var configType = DetermineConfigType(fileName);

                    var input = EnhancedExcelDataLoader.CreatePipelineInput(csvFile, configType, fileName);
                    inputs.Add(input);
                }
                catch (Exception ex)
                {
                    Debug.LogError($"准备输入失败 {Path.GetFileName(csvFile)}: {ex.Message}");
                }
            }

            // 执行管道处理
            Debug.Log("开始处理所有配置文件...");
            var result = pipeline.Execute(inputs);
            ProcessResult(result);
        }

        /// <summary>
        /// 处理管道执行结果
        /// </summary>
        private static void ProcessResult(PipelineResult result)
        {
            if (result.Success)
            {
                Debug.Log($"✓ 处理成功！耗时: {result.Duration.TotalMilliseconds:F0}ms");

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
                Debug.LogError($"✗ 处理失败！");

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