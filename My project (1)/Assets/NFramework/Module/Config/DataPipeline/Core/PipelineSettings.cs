using System;
using System.Collections.Generic;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 管道设置
    /// </summary>
    public class PipelineSettings
    {
        #region 基本设置
        /// <summary>
        /// 是否启用代码生成
        /// </summary>
        public bool EnableCodeGeneration { get; set; } = true;

        /// <summary>
        /// 是否启用验证
        /// </summary>
        public bool EnableValidation { get; set; } = true;

        /// <summary>
        /// 是否在验证错误时停止
        /// </summary>
        public bool StopOnValidationError { get; set; } = true;

        /// <summary>
        /// 代码输出目录
        /// </summary>
        public string CodeOutputDirectory { get; set; } = "Assets/Generated/Config";

        /// <summary>
        /// 是否启用引用解析
        /// </summary>
        public bool EnableReferenceResolution { get; set; } = true;

        /// <summary>
        /// 是否启用本地化
        /// </summary>
        public bool EnableLocalization { get; set; } = false;

        /// <summary>
        /// 是否启用索引生成
        /// </summary>
        public bool EnableIndexing { get; set; } = true;

        /// <summary>
        /// 是否启用二维数组处理
        /// </summary>
        public bool EnableArray2DProcessing { get; set; } = true;

        /// <summary>
        /// 是否启用备份
        /// </summary>
        public bool EnableBackup { get; set; } = true;
        #endregion

        #region 功能设置
        /// <summary>
        /// 压缩设置
        /// </summary>
        public CompressionSettings CompressionSettings { get; set; } = new CompressionSettings();

        /// <summary>
        /// 加密设置
        /// </summary>
        public EncryptionSettings EncryptionSettings { get; set; } = new EncryptionSettings();

        /// <summary>
        /// 代码生成设置
        /// </summary>
        public CodeGenerationSettings CodeGenerationSettings { get; set; } = new CodeGenerationSettings();

        /// <summary>
        /// 本地化设置
        /// </summary>
        public LocalizationSettings LocalizationSettings { get; set; } = new LocalizationSettings();

        /// <summary>
        /// 引用设置
        /// </summary>
        public ReferenceSettings ReferenceSettings { get; set; } = new ReferenceSettings();

        /// <summary>
        /// 数据清理设置
        /// </summary>
        public DataCleaningSettings DataCleaningSettings { get; set; } = new DataCleaningSettings();

        /// <summary>
        /// 索引设置
        /// </summary>
        public IndexSettings IndexSettings { get; set; } = new IndexSettings();

        /// <summary>
        /// 备份设置
        /// </summary>
        public BackupSettings BackupSettings { get; set; } = new BackupSettings();

        /// <summary>
        /// 二维数组设置
        /// </summary>
        public Array2DSettings Array2DSettings { get; set; } = new Array2DSettings();

        /// <summary>
        /// 验证规则
        /// </summary>
        public ValidationRules ValidationRules { get; set; } = new ValidationRules();
        #endregion

        #region 性能设置
        /// <summary>
        /// 是否启用并行处理
        /// </summary>
        public bool EnableParallelProcessing { get; set; } = true;

        /// <summary>
        /// 最大并行度
        /// </summary>
        public int MaxDegreeOfParallelism { get; set; } = -1;

        /// <summary>
        /// 是否启用缓存
        /// </summary>
        public bool EnableCaching { get; set; } = true;

        /// <summary>
        /// 缓存大小限制（MB）
        /// </summary>
        public int CacheSizeLimitMB { get; set; } = 100;

        /// <summary>
        /// 是否启用增量处理
        /// </summary>
        public bool EnableIncrementalProcessing { get; set; } = true;
        #endregion

        #region 调试设置
        /// <summary>
        /// 是否启用详细日志
        /// </summary>
        public bool EnableVerboseLogging { get; set; } = false;

        /// <summary>
        /// 是否保存中间文件
        /// </summary>
        public bool SaveIntermediateFiles { get; set; } = false;

        /// <summary>
        /// 是否生成调试信息
        /// </summary>
        public bool GenerateDebugInfo { get; set; } = false;

        /// <summary>
        /// 是否在出错时暂停
        /// </summary>
        public bool PauseOnError { get; set; } = false;
        #endregion

        #region 扩展设置
        /// <summary>
        /// 自定义设置
        /// </summary>
        public Dictionary<string, object> CustomSettings { get; } = new Dictionary<string, object>();

        /// <summary>
        /// 插件设置
        /// </summary>
        public Dictionary<string, object> PluginSettings { get; } = new Dictionary<string, object>();

        /// <summary>
        /// 环境变量
        /// </summary>
        public Dictionary<string, string> EnvironmentVariables { get; } = new Dictionary<string, string>();
        #endregion

        #region 构造函数
        /// <summary>
        /// 创建默认设置
        /// </summary>
        public PipelineSettings()
        {
            InitializeDefaultSettings();
        }

        /// <summary>
        /// 使用自定义设置创建
        /// </summary>
        public PipelineSettings(Action<PipelineSettings> configure)
        {
            InitializeDefaultSettings();
            configure?.Invoke(this);
        }
        #endregion

        #region 私有方法
        private void InitializeDefaultSettings()
        {
            // 设置默认环境变量
            EnvironmentVariables["PIPELINE_VERSION"] = "1.0.0";
            EnvironmentVariables["PIPELINE_MODE"] = "PRODUCTION";

            // 设置默认插件设置
            PluginSettings["ENABLE_PLUGINS"] = true;
            PluginSettings["PLUGIN_DIRECTORY"] = "Plugins";

            // 设置默认自定义设置
            CustomSettings["DEFAULT_CULTURE"] = "en-US";
            CustomSettings["TIMESTAMP_FORMAT"] = "yyyy-MM-dd HH:mm:ss";
        }
        #endregion

        #region 公共方法
        /// <summary>
        /// 验证设置是否有效
        /// </summary>
        public bool Validate(out List<string> errors)
        {
            errors = new List<string>();

            // 验证基本设置
            if (string.IsNullOrEmpty(CodeOutputDirectory))
            {
                errors.Add("代码输出目录不能为空");
            }

            // 验证性能设置
            if (MaxDegreeOfParallelism == 0)
            {
                errors.Add("最大并行度不能为0");
            }

            if (CacheSizeLimitMB <= 0)
            {
                errors.Add("缓存大小限制必须大于0");
            }

            // 验证功能设置的一致性
            if (EnableLocalization && LocalizationSettings == null)
            {
                errors.Add("启用了本地化但未提供本地化设置");
            }

            if (EnableBackup && BackupSettings == null)
            {
                errors.Add("启用了备份但未提供备份设置");
            }

            return errors.Count == 0;
        }

        /// <summary>
        /// 克隆设置
        /// </summary>
        public PipelineSettings Clone()
        {
            var settings = new PipelineSettings();
            
            // 复制基本设置
            settings.EnableCodeGeneration = this.EnableCodeGeneration;
            settings.EnableValidation = this.EnableValidation;
            settings.StopOnValidationError = this.StopOnValidationError;
            settings.CodeOutputDirectory = this.CodeOutputDirectory;
            settings.EnableReferenceResolution = this.EnableReferenceResolution;
            settings.EnableLocalization = this.EnableLocalization;
            settings.EnableIndexing = this.EnableIndexing;
            settings.EnableArray2DProcessing = this.EnableArray2DProcessing;
            settings.EnableBackup = this.EnableBackup;

            // 复制功能设置
            settings.CompressionSettings = this.CompressionSettings;
            settings.EncryptionSettings = this.EncryptionSettings;
            settings.CodeGenerationSettings = this.CodeGenerationSettings;
            settings.LocalizationSettings = this.LocalizationSettings;
            settings.ReferenceSettings = this.ReferenceSettings;
            settings.DataCleaningSettings = this.DataCleaningSettings;
            settings.IndexSettings = this.IndexSettings;
            settings.BackupSettings = this.BackupSettings;
            settings.Array2DSettings = this.Array2DSettings;
            settings.ValidationRules = this.ValidationRules;

            // 复制性能设置
            settings.EnableParallelProcessing = this.EnableParallelProcessing;
            settings.MaxDegreeOfParallelism = this.MaxDegreeOfParallelism;
            settings.EnableCaching = this.EnableCaching;
            settings.CacheSizeLimitMB = this.CacheSizeLimitMB;
            settings.EnableIncrementalProcessing = this.EnableIncrementalProcessing;

            // 复制调试设置
            settings.EnableVerboseLogging = this.EnableVerboseLogging;
            settings.SaveIntermediateFiles = this.SaveIntermediateFiles;
            settings.GenerateDebugInfo = this.GenerateDebugInfo;
            settings.PauseOnError = this.PauseOnError;

            // 复制扩展设置
            foreach (var kvp in this.CustomSettings)
            {
                settings.CustomSettings[kvp.Key] = kvp.Value;
            }

            foreach (var kvp in this.PluginSettings)
            {
                settings.PluginSettings[kvp.Key] = kvp.Value;
            }

            foreach (var kvp in this.EnvironmentVariables)
            {
                settings.EnvironmentVariables[kvp.Key] = kvp.Value;
            }

            return settings;
        }
        #endregion
    }
}
