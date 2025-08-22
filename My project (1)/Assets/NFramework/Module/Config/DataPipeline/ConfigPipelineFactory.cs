using System;
using System.Collections.Generic;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 配置管道工厂 - 创建和配置数据处理管道
    /// </summary>
    public static class ConfigPipelineFactory
    {
        // ... [保持其他代码不变] ...
    }

    /// <summary>
    /// 管道配置
    /// </summary>
    public class PipelineConfiguration
    {
        // 基本设置
        public bool EnableCodeGeneration { get; set; } = true;
        public bool EnableValidation { get; set; } = true;
        public bool StopOnValidationError { get; set; } = true;
        public string CodeOutputDirectory { get; set; } = "Assets/Generated/Config";

        // 处理器开关
        public bool EnableReferenceResolution { get; set; } = false;
        public bool EnableBackup { get; set; } = false;
        public bool EnableDataValidation { get; set; } = true;
        public bool EnableAccessorGeneration { get; set; } = true;
        public bool EnableSchemaGeneration { get; set; } = true;
        public bool EnableLocalization { get; set; } = false;
        public bool EnableArray2DProcessing { get; set; } = true;
        public bool EnableIndexBuilding { get; set; } = true;

        // 处理器设置
        public ReferenceSettings ReferenceSettings { get; set; } = new ReferenceSettings();
        public BackupSettings BackupSettings { get; set; } = new BackupSettings();
        public CompressionSettings CompressionSettings { get; set; } = new CompressionSettings();
        public EncryptionSettings EncryptionSettings { get; set; } = new EncryptionSettings();
        public CodeGenerationSettings CodeGenerationSettings { get; set; } = new CodeGenerationSettings();
        public Array2DSettings Array2DSettings { get; set; } = new Array2DSettings();

        // 自定义处理器
        public List<ICollector> CustomCollectors { get; set; } = new List<ICollector>();
        public List<IBatchProcessor> CustomBatchProcessors { get; set; } = new List<IBatchProcessor>();
        public List<IPreProcessor> CustomPreProcessors { get; set; } = new List<IPreProcessor>();
        public List<IGenerator> CustomGenerators { get; set; } = new List<IGenerator>();
        public List<IPostProcessor> CustomPostProcessors { get; set; } = new List<IPostProcessor>();
        public List<IFinalProcessor> CustomFinalProcessors { get; set; } = new List<IFinalProcessor>();
    }
}