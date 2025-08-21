using System;
using System.Data;
using System.IO;
using NFramework.Module.Config.DataPipeline.Core;
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
                var result = pipeline.Execute(input);

                // 4. 处理结果
                if (result.Success)
                {
                    Debug.Log($"管道执行成功！耗时: {result.Duration.TotalMilliseconds:F0}ms");
                    Debug.Log($"生成的文件: {string.Join(", ", result.GeneratedFiles.Keys)}");
                    
                                            // 存储到SQLite
#if SQLITE4UNITY3D
                        using (var dataManager = new SQLite4Unity3dDataManager("ConfigData/game_config.db"))
#else
                        using (var dataManager = new SQLiteDataManager("ConfigData/game_config.db"))
#endif
                        {
                            dataManager.StoreFlatBufferData(input.ConfigType, input.ConfigName, result.BinaryData);
                        }
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
                    EnableDataCleaning = true,
                    EnableLocalization = true,
                    EnableCodeGeneration = true,
                    CompressionSettings = new CompressionSettings
                    {
                        Enabled = true,
                        Type = Core.CompressionType.GZip,
                        Level = 9
                    },
                    EncryptionSettings = new EncryptionSettings
                    {
                        Enabled = true,
                        Type = Core.EncryptionType.XOR,
                        Key = "MySecretKey123"
                    }
                };

                // 2. 创建管道
                var pipeline = ConfigPipelineFactory.CreateStandardPipeline(config);

                // 3. 添加自定义处理器
                pipeline.RegisterPreProcessor(new CustomCharacterProcessor())
                       .RegisterValidator(new CustomCharacterValidator());

                // 4. 执行处理
                var input = new PipelineInput
                {
                    ConfigType = "Character",
                    ConfigName = "NPCs",
                    SourceFilePath = "ConfigData/Excel/NPCs.xlsx"
                };

                var result = pipeline.Execute(input);

                Debug.Log(result.Success ? "自定义管道执行成功" : "自定义管道执行失败");
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

                foreach (var excelFile in excelFiles)
                {
                    var fileName = Path.GetFileNameWithoutExtension(excelFile);
                    var configType = DetermineConfigType(fileName);

                    // 为每种配置类型创建专门的管道
                    var pipeline = ConfigPipelineFactory.CreateForConfigType(configType);

                    var input = new PipelineInput
                    {
                        ConfigType = configType,
                        ConfigName = fileName,
                        SourceFilePath = excelFile
                    };

                    var result = pipeline.Execute(input);

                    if (result.Success)
                    {
                        Debug.Log($"处理成功: {fileName}");
                        
                        // 存储到数据库
#if SQLITE4UNITY3D
                        using (var dataManager = new SQLite4Unity3dDataManager("ConfigData/game_config.db"))
#else
                        using (var dataManager = new SQLiteDataManager("ConfigData/game_config.db"))
#endif
                        {
                            dataManager.StoreFlatBufferData(configType, fileName, result.BinaryData);
                        }
                    }
                    else
                    {
                        Debug.LogError($"处理失败: {fileName}, 错误: {string.Join("; ", result.Errors)}");
                    }
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

    /// <summary>
    /// 自定义角色处理器示例
    /// </summary>
    public class CustomCharacterProcessor : IPreProcessor
    {
        public string Name => "Custom Character Processor";
        public int Priority => 90;
        public bool IsEnabled { get; set; } = true;

        public bool Process(PreProcessContext context)
        {
            context.AddLog("执行自定义角色数据处理");
            
            // 这里可以实现特定于角色数据的处理逻辑
            // 例如：计算派生属性、验证数值平衡、处理技能引用等
            
            return true;
        }
    }

    /// <summary>
    /// 自定义角色验证器示例
    /// </summary>
    public class CustomCharacterValidator : IValidator
    {
        public string Name => "Custom Character Validator";
        public int Priority => 100;
        public bool IsEnabled { get; set; } = true;

        public ValidationResult Validate(ValidationContext context)
        {
            var result = new ValidationResult { IsValid = true };
            
            // 这里可以实现特定于角色数据的验证逻辑
            // 例如：属性值范围检查、技能组合验证、平衡性检查等
            
            return result;
        }
    }
}
