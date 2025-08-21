using System;
using System.Collections.Generic;
using System.Data;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline.Core
{
    /// <summary>
    /// 管道处理上下文基类
    /// </summary>
    public abstract class PipelineContext
    {
        public string ConfigType { get; set; }
        public string ConfigName { get; set; }
        public string SourceFilePath { get; set; }
        public Dictionary<string, object> Properties { get; } = new Dictionary<string, object>();
        public List<string> Logs { get; } = new List<string>();
        public List<string> Warnings { get; } = new List<string>();
        public List<string> Errors { get; } = new List<string>();

        public void AddLog(string message) => Logs.Add($"[{DateTime.Now:HH:mm:ss}] {message}");
        public void AddWarning(string message) => Warnings.Add($"[{DateTime.Now:HH:mm:ss}] {message}");
        public void AddError(string message) => Errors.Add($"[{DateTime.Now:HH:mm:ss}] {message}");

        public bool HasErrors => Errors.Count > 0;
        public bool HasWarnings => Warnings.Count > 0;
    }

    /// <summary>
    /// 前处理上下文
    /// </summary>
    public class PreProcessContext : PipelineContext
    {
        public DataSet RawDataSet { get; set; }
        public DataTable CurrentSheet { get; set; }
        public Dictionary<string, DataTable> ProcessedSheets { get; } = new Dictionary<string, DataTable>();
        public SchemaDefinition SchemaDefinition { get; set; }
    }

    /// <summary>
    /// 数据处理上下文
    /// </summary>
    public class DataProcessContext : PipelineContext
    {
        public DataTable SourceData { get; set; }
        public List<object> ProcessedObjects { get; } = new List<object>();
        public Type TargetType { get; set; }
        public SchemaDefinition SchemaDefinition { get; set; }
        public Dictionary<string, object> TypeConverters { get; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 后处理上下文
    /// </summary>
    public class PostProcessContext : PipelineContext
    {
        public byte[] BinaryData { get; set; }
        public string OutputPath { get; set; }
        public Dictionary<string, byte[]> AdditionalFiles { get; } = new Dictionary<string, byte[]>();
        public CompressionSettings CompressionSettings { get; set; }
        public EncryptionSettings EncryptionSettings { get; set; }
    }

    /// <summary>
    /// 验证上下文
    /// </summary>
    public class ValidationContext : PipelineContext
    {
        public object DataToValidate { get; set; }
        public Type DataType { get; set; }
        public ValidationRules ValidationRules { get; set; }
        public List<ValidationError> ValidationErrors { get; } = new List<ValidationError>();
    }

    /// <summary>
    /// 代码生成上下文
    /// </summary>
    public class CodeGenerationContext : PipelineContext
    {
        public SchemaDefinition SchemaDefinition { get; set; }
        public string OutputDirectory { get; set; }
        public CodeGenerationSettings Settings { get; set; }
        public Dictionary<string, string> GeneratedFiles { get; } = new Dictionary<string, string>();
    }

    /// <summary>
    /// Schema定义
    /// </summary>
    [Serializable]
    public class SchemaDefinition
    {
        public string Name { get; set; }
        public string Namespace { get; set; }
        public List<FieldDefinition> Fields { get; } = new List<FieldDefinition>();
        public Dictionary<string, object> Metadata { get; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 字段定义
    /// </summary>
    [Serializable]
    public class FieldDefinition
    {
        public string Name { get; set; }
        public string Type { get; set; }
        public bool IsRequired { get; set; }
        public object DefaultValue { get; set; }
        public string Comment { get; set; }
        public Dictionary<string, object> Attributes { get; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 验证结果
    /// </summary>
    public class ValidationResult
    {
        public bool IsValid { get; set; }
        public List<ValidationError> Errors { get; } = new List<ValidationError>();
        public List<string> Warnings { get; } = new List<string>();
    }

    /// <summary>
    /// 验证错误
    /// </summary>
    public class ValidationError
    {
        public string Field { get; set; }
        public string Message { get; set; }
        public object Value { get; set; }
        public ValidationSeverity Severity { get; set; }
    }

    /// <summary>
    /// 验证严重程度
    /// </summary>
    public enum ValidationSeverity
    {
        Info,
        Warning,
        Error,
        Critical
    }

    /// <summary>
    /// 代码生成结果
    /// </summary>
    public class CodeGenerationResult
    {
        public bool Success { get; set; }
        public Dictionary<string, string> GeneratedFiles { get; } = new Dictionary<string, string>();
        public List<string> Errors { get; } = new List<string>();
    }

    /// <summary>
    /// 验证规则
    /// </summary>
    public class ValidationRules
    {
        public Dictionary<string, List<IValidationRule>> FieldRules { get; } = new Dictionary<string, List<IValidationRule>>();
        public List<IValidationRule> GlobalRules { get; } = new List<IValidationRule>();
    }

    /// <summary>
    /// 压缩设置
    /// </summary>
    public class CompressionSettings
    {
        public bool Enabled { get; set; }
        public CompressionType Type { get; set; } = CompressionType.GZip;
        public int Level { get; set; } = 6;
    }

    /// <summary>
    /// 加密设置
    /// </summary>
    public class EncryptionSettings
    {
        public bool Enabled { get; set; }
        public EncryptionType Type { get; set; } = EncryptionType.AES;
        public string Key { get; set; }
    }

    /// <summary>
    /// 代码生成设置
    /// </summary>
    public class CodeGenerationSettings
    {
        public string Namespace { get; set; } = "GameConfig";
        public bool GenerateAccessors { get; set; } = true;
        public bool GenerateValidation { get; set; } = true;
        public bool GenerateComments { get; set; } = true;
        public string OutputPath { get; set; }
    }

    public enum CompressionType
    {
        None,
        GZip,
        Deflate,
        LZ4
    }

    public enum EncryptionType
    {
        None,
        AES,
        XOR
    }

    /// <summary>
    /// 验证规则接口
    /// </summary>
    public interface IValidationRule
    {
        string Name { get; }
        ValidationResult Validate(object value, string fieldName);
    }
}
