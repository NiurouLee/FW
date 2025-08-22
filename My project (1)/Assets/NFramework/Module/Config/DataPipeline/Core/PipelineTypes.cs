using System;
using System.Collections.Generic;

namespace NFramework.Module.Config.DataPipeline
{


    /// <summary>
    /// 压缩设置
    /// </summary>
    public class CompressionSettings
    {
        public bool EnableCompression { get; set; } = true;
        public int CompressionLevel { get; set; } = 6;
        public string CompressionAlgorithm { get; set; } = "GZIP";
        public bool UseCustomCompressor { get; set; } = false;
        public Dictionary<string, object> CustomSettings { get; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 加密设置
    /// </summary>
    public class EncryptionSettings
    {
        public bool EnableEncryption { get; set; } = false;
        public string EncryptionKey { get; set; }
        public string EncryptionAlgorithm { get; set; } = "AES";
        public bool UseCustomEncryption { get; set; } = false;
        public Dictionary<string, object> CustomSettings { get; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 代码生成设置
    /// </summary>
    public class CodeGenerationSettings
    {
        public string OutputPath { get; set; }
        public string Namespace { get; set; }
        public bool GenerateAccessors { get; set; } = true;
        public bool GenerateValidation { get; set; } = true;
        public bool GenerateIndexing { get; set; } = true;
        public bool GenerateLocalization { get; set; } = true;
        public Dictionary<string, object> CustomSettings { get; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 本地化设置
    /// </summary>
    public class LocalizationSettings
    {
        public bool EnableLocalization { get; set; } = true;
        public string DefaultLanguage { get; set; } = "en";
        public List<string> SupportedLanguages { get; } = new List<string>();
        public Dictionary<string, object> CustomSettings { get; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 数据清理设置
    /// </summary>
    public class DataCleaningSettings
    {
        public bool TrimStrings { get; set; } = true;
        public bool RemoveEmptyEntries { get; set; } = false;
        public bool NormalizeLineEndings { get; set; } = true;
        public Dictionary<string, object> CustomSettings { get; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 索引设置
    /// </summary>
    public class IndexSettings
    {
        public bool EnableIndexing { get; set; } = true;
        public bool CaseSensitive { get; set; } = true;
        public int IndexCacheSize { get; set; } = 1000;
        public Dictionary<string, object> CustomSettings { get; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 备份设置
    /// </summary>
    public class BackupSettings
    {
        /// <summary>
        /// 是否启用备份
        /// </summary>
        public bool EnableBackup { get; set; } = true;

        /// <summary>
        /// 备份目录路径
        /// </summary>
        public string BackupPath { get; set; }

        /// <summary>
        /// 最大备份数量
        /// </summary>
        public int MaxBackupCount { get; set; } = 5;

        /// <summary>
        /// 是否压缩备份
        /// </summary>
        public bool CompressBackup { get; set; } = true;

        /// <summary>
        /// 备份文件名格式
        /// </summary>
        public string BackupFileFormat { get; set; } = "backup_{0:yyyyMMddHHmmss}.{1}";

        /// <summary>
        /// 是否保留时间戳
        /// </summary>
        public bool PreserveTimestamp { get; set; } = true;

        /// <summary>
        /// 自定义设置
        /// </summary>
        public Dictionary<string, object> CustomSettings { get; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 二维数组设置
    /// </summary>
    public class Array2DSettings
    {
        public bool EnableArray2D { get; set; } = true;
        public string RowHeaderPrefix { get; set; } = "Row_";
        public string ColumnHeaderPrefix { get; set; } = "Col_";
        public bool UseCustomHeaders { get; set; } = false;
        public Dictionary<string, string> CustomHeaders { get; } = new Dictionary<string, string>();
        public Dictionary<string, object> CustomSettings { get; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 增强代码生成设置
    /// </summary>
    public class EnhancedCodeGenerationSettings
    {
        public bool EnableEnhancedGeneration { get; set; } = true;
        public string CodeStyle { get; set; } = "Default";
        public bool GenerateComments { get; set; } = true;
        public Dictionary<string, object> CustomProperties { get; set; } = new Dictionary<string, object>();
    }
}