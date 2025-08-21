using System;
using System.Collections.Generic;
using NFramework.Module.Config.DataPipeline.Core;
using NFramework.Module.Config.DataPipeline.Processors;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 配置管道工厂 - 创建和配置数据处理管道
    /// </summary>
    public static class ConfigPipelineFactory
    {
        /// <summary>
        /// 创建标准的配置处理管道
        /// </summary>
        public static ConfigPipeline CreateStandardPipeline(PipelineConfiguration config = null)
        {
            config ??= new PipelineConfiguration();
            
            var settings = new PipelineSettings
            {
                EnableValidation = config.EnableValidation,
                EnableCodeGeneration = config.EnableCodeGeneration,
                StopOnValidationError = config.StopOnValidationError,
                CodeOutputDirectory = config.CodeOutputDirectory,
                CompressionSettings = config.CompressionSettings,
                EncryptionSettings = config.EncryptionSettings,
                CodeGenerationSettings = config.CodeGenerationSettings
            };

            var pipeline = new ConfigPipeline(settings);

            // 注册前处理器
            RegisterPreProcessors(pipeline, config);
            
            // 注册数据处理器
            RegisterDataProcessors(pipeline, config);
            
            // 注册后处理器
            RegisterPostProcessors(pipeline, config);
            
            // 注册验证器
            RegisterValidators(pipeline, config);
            
            // 注册代码生成器
            RegisterCodeGenerators(pipeline, config);

            Debug.Log($"创建标准配置管道完成，共注册了 {GetTotalProcessorCount(pipeline)} 个处理器");
            
            return pipeline;
        }

        /// <summary>
        /// 创建自定义配置管道
        /// </summary>
        public static ConfigPipeline CreateCustomPipeline(Action<ConfigPipeline> configurator)
        {
            var pipeline = new ConfigPipeline();
            configurator?.Invoke(pipeline);
            return pipeline;
        }

        private static void RegisterPreProcessors(ConfigPipeline pipeline, PipelineConfiguration config)
        {
            // 数据清理处理器
            if (config.EnableDataCleaning)
            {
                pipeline.RegisterPreProcessor(new DataCleanerProcessor(config.DataCleaningSettings));
            }

            // Schema生成处理器
            if (config.EnableSchemaGeneration)
            {
                pipeline.RegisterPreProcessor(new SchemaGeneratorProcessor());
            }

            // 本地化处理器
            if (config.EnableLocalization)
            {
                pipeline.RegisterPreProcessor(new LocalizationProcessor(config.LocalizationSettings));
            }

            // 引用类型验证处理器
            if (config.EnableReferenceResolution)
            {
                pipeline.RegisterPreProcessor(new ReferenceTypeValidatorProcessor());
                pipeline.RegisterPreProcessor(new ReferenceResolverProcessor(config.ReferenceSettings));
            }

            // 二维数组处理器
            if (config.EnableArray2DProcessing)
            {
                // TODO: 注册Array2DProcessor
                // pipeline.RegisterPreProcessor(new Array2DProcessor(config.Array2DSettings));
            }

            // 自定义前处理器
            foreach (var processor in config.CustomPreProcessors)
            {
                pipeline.RegisterPreProcessor(processor);
            }
        }

        private static void RegisterDataProcessors(ConfigPipeline pipeline, PipelineConfiguration config)
        {
            // FlatBuffer序列化处理器
            // TODO: 实现FlatBufferSerializerProcessor
            // pipeline.RegisterDataProcessor(new FlatBufferSerializerProcessor());

            // 自定义数据处理器
            foreach (var processor in config.CustomDataProcessors)
            {
                pipeline.RegisterDataProcessor(processor);
            }
        }

        private static void RegisterPostProcessors(ConfigPipeline pipeline, PipelineConfiguration config)
        {
            // 索引构建处理器
            if (config.EnableIndexBuilding)
            {
                pipeline.RegisterPostProcessor(new IndexBuilderProcessor(config.IndexSettings));
            }

            // 压缩处理器
            if (config.CompressionSettings?.Enabled == true)
            {
                pipeline.RegisterPostProcessor(new CompressionProcessor());
            }

            // 加密处理器
            if (config.EncryptionSettings?.Enabled == true)
            {
                pipeline.RegisterPostProcessor(new EncryptionProcessor());
            }

            // 备份处理器
            if (config.EnableBackup)
            {
                // TODO: 实现BackupProcessor
                // pipeline.RegisterPostProcessor(new BackupProcessor(config.BackupSettings));
            }

            // 自定义后处理器
            foreach (var processor in config.CustomPostProcessors)
            {
                pipeline.RegisterPostProcessor(processor);
            }
        }

        private static void RegisterValidators(ConfigPipeline pipeline, PipelineConfiguration config)
        {
            // 数据完整性验证器
            if (config.EnableDataValidation)
            {
                // TODO: 实现DataIntegrityValidator
                // pipeline.RegisterValidator(new DataIntegrityValidator());
            }

            // 业务规则验证器
            if (config.EnableBusinessRuleValidation)
            {
                // TODO: 实现BusinessRuleValidator
                // pipeline.RegisterValidator(new BusinessRuleValidator(config.BusinessRules));
            }

            // 自定义验证器
            foreach (var validator in config.CustomValidators)
            {
                pipeline.RegisterValidator(validator);
            }
        }

        private static void RegisterCodeGenerators(ConfigPipeline pipeline, PipelineConfiguration config)
        {
            // FlatBuffer代码生成器
            if (config.EnableCodeGeneration)
            {
                pipeline.RegisterCodeGenerator(new FlatBufferCodeGenerator(config.FlatcPath));
            }

            // 访问器代码生成器
            if (config.EnableAccessorGeneration)
            {
                // TODO: 实现AccessorCodeGenerator
                // pipeline.RegisterCodeGenerator(new AccessorCodeGenerator());
            }

            // 自定义代码生成器
            foreach (var generator in config.CustomCodeGenerators)
            {
                pipeline.RegisterCodeGenerator(generator);
            }
        }

        private static int GetTotalProcessorCount(ConfigPipeline pipeline)
        {
            var info = pipeline.GetPipelineInfo();
            return info.PreProcessors.Count + info.DataProcessors.Count + 
                   info.PostProcessors.Count + info.Validators.Count + info.CodeGenerators.Count;
        }

        /// <summary>
        /// 创建用于特定配置类型的管道
        /// </summary>
        public static ConfigPipeline CreateForConfigType(string configType, PipelineConfiguration baseConfig = null)
        {
            var config = baseConfig ?? new PipelineConfiguration();
            
            // 根据配置类型调整设置
            switch (configType.ToLower())
            {
                case "character":
                case "角色":
                    return CreateCharacterConfigPipeline(config);
                    
                case "item":
                case "物品":
                    return CreateItemConfigPipeline(config);
                    
                case "skill":
                case "技能":
                    return CreateSkillConfigPipeline(config);
                    
                case "localization":
                case "本地化":
                    return CreateLocalizationPipeline(config);
                    
                default:
                    return CreateStandardPipeline(config);
            }
        }

        private static ConfigPipeline CreateCharacterConfigPipeline(PipelineConfiguration config)
        {
            // 角色配置特定的管道设置
            config.EnableReferenceResolution = true; // 角色可能引用技能、物品等
            config.EnableBusinessRuleValidation = true; // 需要验证数值平衡
            
            return CreateStandardPipeline(config);
        }

        private static ConfigPipeline CreateItemConfigPipeline(PipelineConfiguration config)
        {
            // 物品配置特定的管道设置
            config.EnableLocalization = true; // 物品名称和描述需要本地化
            config.EnableDataValidation = true; // 验证物品属性
            
            return CreateStandardPipeline(config);
        }

        private static ConfigPipeline CreateSkillConfigPipeline(PipelineConfiguration config)
        {
            // 技能配置特定的管道设置
            config.EnableBusinessRuleValidation = true; // 技能效果验证
            config.EnableLocalization = true; // 技能描述本地化
            
            return CreateStandardPipeline(config);
        }

        private static ConfigPipeline CreateLocalizationPipeline(PipelineConfiguration config)
        {
            // 本地化配置特定的管道设置
            config.EnableLocalization = false; // 本地化数据本身不需要再本地化
            config.EnableDataCleaning = true; // 清理文本数据
            config.CompressionSettings.Enabled = true; // 文本数据压缩效果好
            
            return CreateStandardPipeline(config);
        }
    }

    /// <summary>
    /// 管道配置
    /// </summary>
    public class PipelineConfiguration
    {
        // 基本设置
        public bool EnableValidation { get; set; } = true;
        public bool EnableCodeGeneration { get; set; } = true;
        public bool StopOnValidationError { get; set; } = true;
        public string CodeOutputDirectory { get; set; } = "Assets/Generated/Config";
        public string FlatcPath { get; set; }

        // 处理器开关
        public bool EnableDataCleaning { get; set; } = true;
        public bool EnableSchemaGeneration { get; set; } = true;
        public bool EnableLocalization { get; set; } = false;
        public bool EnableReferenceResolution { get; set; } = false;
        public bool EnableArray2DProcessing { get; set; } = true;
        public bool EnableIndexBuilding { get; set; } = true;
        public bool EnableBackup { get; set; } = false;
        public bool EnableDataValidation { get; set; } = true;
        public bool EnableBusinessRuleValidation { get; set; } = false;
        public bool EnableAccessorGeneration { get; set; } = true;

        // 处理器设置
        public DataCleaningSettings DataCleaningSettings { get; set; } = new DataCleaningSettings();
        public LocalizationSettings LocalizationSettings { get; set; } = new LocalizationSettings();
        public ReferenceSettings ReferenceSettings { get; set; } = new ReferenceSettings();
        public Array2DSettings Array2DSettings { get; set; } = new Array2DSettings();
        public IndexSettings IndexSettings { get; set; } = new IndexSettings();
        public BackupSettings BackupSettings { get; set; } = new BackupSettings();
        public CompressionSettings CompressionSettings { get; set; } = new CompressionSettings();
        public EncryptionSettings EncryptionSettings { get; set; } = new EncryptionSettings();
        public CodeGenerationSettings CodeGenerationSettings { get; set; } = new CodeGenerationSettings();
        public BusinessRuleSettings BusinessRules { get; set; } = new BusinessRuleSettings();

        // 自定义处理器
        public List<IPreProcessor> CustomPreProcessors { get; set; } = new List<IPreProcessor>();
        public List<IDataProcessor> CustomDataProcessors { get; set; } = new List<IDataProcessor>();
        public List<IPostProcessor> CustomPostProcessors { get; set; } = new List<IPostProcessor>();
        public List<IValidator> CustomValidators { get; set; } = new List<IValidator>();
        public List<ICodeGenerator> CustomCodeGenerators { get; set; } = new List<ICodeGenerator>();
    }

    /// <summary>
    /// 引用解析设置
    /// </summary>
    public class ReferenceSettings
    {
        public Dictionary<string, string> ReferenceColumns { get; set; } = new Dictionary<string, string>();
        public bool ResolveCircularReferences { get; set; } = true;
        public bool ValidateReferences { get; set; } = true;
        
        /// <summary>
        /// 引用解析超时时间（毫秒）
        /// </summary>
        public int ResolveTimeoutMs { get; set; } = 5000;

        /// <summary>
        /// 自定义引用解析器
        /// </summary>
        public Dictionary<string, Func<string, object>> CustomResolvers { get; set; } = new Dictionary<string, Func<string, object>>();
    }

    /// <summary>
    /// 备份设置
    /// </summary>
    public class BackupSettings
    {
        public bool CreateBackup { get; set; } = true;
        public string BackupDirectory { get; set; } = "ConfigData/Backup";
        public int MaxBackupCount { get; set; } = 10;
        public bool CompressBackup { get; set; } = true;
    }

    /// <summary>
    /// 业务规则设置
    /// </summary>
    public class BusinessRuleSettings
    {
        public Dictionary<string, List<IValidationRule>> FieldRules { get; set; } = new Dictionary<string, List<IValidationRule>>();
        public List<IValidationRule> GlobalRules { get; set; } = new List<IValidationRule>();
    }

    /// <summary>
    /// 二维数组设置
    /// </summary>
    public class Array2DSettings
    {
        /// <summary>
        /// 行分隔符
        /// </summary>
        public char RowSeparator { get; set; } = ';';

        /// <summary>
        /// 列分隔符
        /// </summary>
        public char ColumnSeparator { get; set; } = ',';

        /// <summary>
        /// 是否验证数组元素类型
        /// </summary>
        public bool ValidateElementTypes { get; set; } = true;

        /// <summary>
        /// 是否允许不规则数组（每行列数不同）
        /// </summary>
        public bool AllowJaggedArrays { get; set; } = true;

        /// <summary>
        /// 最大行数限制
        /// </summary>
        public int MaxRows { get; set; } = 1000;

        /// <summary>
        /// 最大列数限制
        /// </summary>
        public int MaxColumns { get; set; } = 1000;
    }
}
