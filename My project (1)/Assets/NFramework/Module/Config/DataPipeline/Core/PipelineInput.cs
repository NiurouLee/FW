using System;
using System.Collections.Generic;
using System.Data;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 管道输入
    /// </summary>
    public class PipelineInput
    {
        #region 基本信息
        /// <summary>
        /// 配置类型
        /// </summary>
        public string ConfigType { get; set; }

        /// <summary>
        /// 配置名称
        /// </summary>
        public string ConfigName { get; set; }

        /// <summary>
        /// 源文件路径
        /// </summary>
        public string SourceFilePath { get; set; }

        /// <summary>
        /// 输出路径
        /// </summary>
        public string OutputPath { get; set; }

        /// <summary>
        /// 目标类型
        /// </summary>
        public Type TargetType { get; set; }

        /// <summary>
        /// 输入标识符
        /// </summary>
        public string Identifier { get; set; }
        #endregion

        #region 数据内容
        /// <summary>
        /// 原始数据集
        /// </summary>
        public DataSet RawDataSet { get; set; }

        /// <summary>
        /// 输入数据内容
        /// </summary>
        public object Content { get; set; }

        /// <summary>
        /// 输入数据的元数据
        /// </summary>
        public Dictionary<string, object> Metadata { get; set; } = new Dictionary<string, object>();

        /// <summary>
        /// 自定义属性
        /// </summary>
        public Dictionary<string, object> CustomProperties { get; set; } = new Dictionary<string, object>();
        #endregion

        #region 处理选项
        /// <summary>
        /// 验证规则
        /// </summary>
        public ValidationRules ValidationRules { get; set; }

        /// <summary>
        /// 处理优先级
        /// </summary>
        public int Priority { get; set; }

        /// <summary>
        /// 处理标记
        /// </summary>
        public HashSet<string> Tags { get; set; } = new HashSet<string>();

        /// <summary>
        /// 依赖项
        /// </summary>
        public List<string> Dependencies { get; set; } = new List<string>();

        /// <summary>
        /// 是否启用缓存
        /// </summary>
        public bool EnableCaching { get; set; } = true;

        /// <summary>
        /// 是否强制重新生成
        /// </summary>
        public bool ForceRegenerate { get; set; }
        #endregion

        #region 生成选项
        /// <summary>
        /// 代码生成选项
        /// </summary>
        public CodeGenerationOptions CodeGeneration { get; set; } = new CodeGenerationOptions();

        /// <summary>
        /// 本地化选项
        /// </summary>
        public LocalizationOptions Localization { get; set; } = new LocalizationOptions();

        /// <summary>
        /// 验证选项
        /// </summary>
        public ValidationOptions Validation { get; set; } = new ValidationOptions();

        /// <summary>
        /// 压缩选项
        /// </summary>
        public CompressionOptions Compression { get; set; } = new CompressionOptions();

        /// <summary>
        /// 加密选项
        /// </summary>
        public EncryptionOptions Encryption { get; set; } = new EncryptionOptions();
        #endregion

        #region 构造函数
        /// <summary>
        /// 创建管道输入
        /// </summary>
        public PipelineInput()
        {
            Identifier = Guid.NewGuid().ToString();
        }

        /// <summary>
        /// 使用配置类型和名称创建管道输入
        /// </summary>
        public PipelineInput(string configType, string configName) : this()
        {
            ConfigType = configType;
            ConfigName = configName;
        }
        #endregion

        #region 公共方法
        /// <summary>
        /// 添加标记
        /// </summary>
        public void AddTag(string tag)
        {
            if (!string.IsNullOrEmpty(tag))
            {
                Tags.Add(tag);
            }
        }

        /// <summary>
        /// 添加依赖项
        /// </summary>
        public void AddDependency(string dependency)
        {
            if (!string.IsNullOrEmpty(dependency) && !Dependencies.Contains(dependency))
            {
                Dependencies.Add(dependency);
            }
        }

        /// <summary>
        /// 验证输入是否有效
        /// </summary>
        public bool Validate(out List<string> errors)
        {
            errors = new List<string>();

            if (string.IsNullOrEmpty(ConfigType))
            {
                errors.Add("配置类型不能为空");
            }

            if (string.IsNullOrEmpty(ConfigName))
            {
                errors.Add("配置名称不能为空");
            }

            if (string.IsNullOrEmpty(SourceFilePath))
            {
                errors.Add("源文件路径不能为空");
            }

            if (string.IsNullOrEmpty(OutputPath))
            {
                errors.Add("输出路径不能为空");
            }

            return errors.Count == 0;
        }

        /// <summary>
        /// 克隆输入
        /// </summary>
        public PipelineInput Clone()
        {
            var input = new PipelineInput
            {
                ConfigType = this.ConfigType,
                ConfigName = this.ConfigName,
                SourceFilePath = this.SourceFilePath,
                OutputPath = this.OutputPath,
                TargetType = this.TargetType,
                Identifier = Guid.NewGuid().ToString(),
                RawDataSet = this.RawDataSet,
                Content = this.Content,
                ValidationRules = this.ValidationRules,
                Priority = this.Priority,
                EnableCaching = this.EnableCaching,
                ForceRegenerate = this.ForceRegenerate,
                CodeGeneration = this.CodeGeneration,
                Localization = this.Localization,
                Validation = this.Validation,
                Compression = this.Compression,
                Encryption = this.Encryption
            };

            foreach (var kvp in this.Metadata)
            {
                input.Metadata[kvp.Key] = kvp.Value;
            }

            foreach (var kvp in this.CustomProperties)
            {
                input.CustomProperties[kvp.Key] = kvp.Value;
            }

            foreach (var tag in this.Tags)
            {
                input.Tags.Add(tag);
            }

            input.Dependencies.AddRange(this.Dependencies);

            return input;
        }
        #endregion
    }

    #region 选项类
    /// <summary>
    /// 代码生成选项
    /// </summary>
    public class CodeGenerationOptions
    {
        /// <summary>
        /// 目标命名空间
        /// </summary>
        public string TargetNamespace { get; set; }

        /// <summary>
        /// 是否生成访问器
        /// </summary>
        public bool GenerateAccessors { get; set; } = true;

        /// <summary>
        /// 是否生成验证代码
        /// </summary>
        public bool GenerateValidation { get; set; } = true;

        /// <summary>
        /// 是否生成索引代码
        /// </summary>
        public bool GenerateIndexing { get; set; } = true;

        /// <summary>
        /// 是否生成本地化代码
        /// </summary>
        public bool GenerateLocalization { get; set; } = true;

        /// <summary>
        /// 自定义选项
        /// </summary>
        public Dictionary<string, object> CustomOptions { get; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 本地化选项
    /// </summary>
    public class LocalizationOptions
    {
        /// <summary>
        /// 默认语言
        /// </summary>
        public string DefaultLanguage { get; set; } = "en";

        /// <summary>
        /// 支持的语言列表
        /// </summary>
        public List<string> SupportedLanguages { get; } = new List<string>();

        /// <summary>
        /// 自定义选项
        /// </summary>
        public Dictionary<string, object> CustomOptions { get; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 验证选项
    /// </summary>
    public class ValidationOptions
    {
        /// <summary>
        /// 是否启用验证
        /// </summary>
        public bool EnableValidation { get; set; } = true;

        /// <summary>
        /// 是否在第一个错误时停止
        /// </summary>
        public bool StopOnFirstError { get; set; } = true;

        /// <summary>
        /// 自定义选项
        /// </summary>
        public Dictionary<string, object> CustomOptions { get; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 压缩选项
    /// </summary>
    public class CompressionOptions
    {
        /// <summary>
        /// 是否启用压缩
        /// </summary>
        public bool EnableCompression { get; set; } = true;

        /// <summary>
        /// 压缩级别
        /// </summary>
        public int CompressionLevel { get; set; } = 6;

        /// <summary>
        /// 压缩算法
        /// </summary>
        public string CompressionAlgorithm { get; set; } = "GZIP";

        /// <summary>
        /// 自定义选项
        /// </summary>
        public Dictionary<string, object> CustomOptions { get; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 加密选项
    /// </summary>
    public class EncryptionOptions
    {
        /// <summary>
        /// 是否启用加密
        /// </summary>
        public bool EnableEncryption { get; set; }

        /// <summary>
        /// 加密密钥
        /// </summary>
        public string EncryptionKey { get; set; }

        /// <summary>
        /// 加密算法
        /// </summary>
        public string EncryptionAlgorithm { get; set; } = "AES";

        /// <summary>
        /// 自定义选项
        /// </summary>
        public Dictionary<string, object> CustomOptions { get; } = new Dictionary<string, object>();
    }
    #endregion
}
