using System.Collections.Generic;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 管道上下文基类
    /// </summary>
    public abstract class PipelineContextBase
    {
        private readonly List<string> _logs = new List<string>();
        private readonly List<string> _warnings = new List<string>();
        private readonly List<string> _errors = new List<string>();

        public IReadOnlyList<string> Logs => _logs;
        public IReadOnlyList<string> Warnings => _warnings;
        public IReadOnlyList<string> Errors => _errors;

        public bool HasErrors => _errors.Count > 0;

        public void AddLog(string message)
        {
            _logs.Add(message);
        }

        public void AddWarning(string message)
        {
            _warnings.Add(message);
        }

        public void AddError(string message)
        {
            _errors.Add(message);
        }

        public void Clear()
        {
            _logs.Clear();
            _warnings.Clear();
            _errors.Clear();
        }
    }

    /// <summary>
    /// 收集阶段上下文
    /// </summary>
    public class CollectionContext : PipelineContextBase
    {
        public string ConfigType { get; set; }
        public string ConfigName { get; set; }
        public string SourceFilePath { get; set; }
        public System.Data.DataSet RawDataSet { get; set; }
        public Dictionary<string, object> CollectedData { get; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 批处理阶段上下文
    /// </summary>
    public class BatchProcessContext : PipelineContextBase
    {
        public Dictionary<string, CollectionContext> CollectedContexts { get; } = new Dictionary<string, CollectionContext>();
        public Dictionary<string, object> SharedData { get; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 预处理阶段上下文
    /// </summary>
    public class PreProcessContext : PipelineContextBase
    {
        public string ConfigType { get; set; }
        public string ConfigName { get; set; }
        public System.Data.DataTable CurrentSheet { get; set; }
        public SchemaDefinition SchemaDefinition { get; set; }
        public Dictionary<string, object> Properties { get; } = new Dictionary<string, object>();
        public HashSet<string> ValidConfigTypes { get; } = new HashSet<string>();
    }

    /// <summary>
    /// 代码生成上下文
    /// </summary>
    public class CodeGenerationContext : PipelineContextBase
    {
        public string ConfigType { get; set; }
        public string ConfigName { get; set; }
        public SchemaDefinition SchemaDefinition { get; set; }
        public string OutputDirectory { get; set; }
        public CodeGenerationSettings Settings { get; set; }
        public Dictionary<string, object> Properties { get; } = new Dictionary<string, object>();
        public Dictionary<string, string> GeneratedFiles { get; } = new Dictionary<string, string>();
    }

    /// <summary>
    /// 后处理阶段上下文
    /// </summary>
    public class PostProcessContext : PipelineContextBase
    {
        public string ConfigType { get; set; }
        public string ConfigName { get; set; }
        public byte[] BinaryData { get; set; }
        public string OutputPath { get; set; }
        public CompressionSettings CompressionSettings { get; set; }
        public EncryptionSettings EncryptionSettings { get; set; }
        public Dictionary<string, byte[]> AdditionalFiles { get; } = new Dictionary<string, byte[]>();
    }

    /// <summary>
    /// 最终处理阶段上下文
    /// </summary>
    public class FinalProcessContext : PipelineContextBase
    {
        public Dictionary<string, object> ProcessedResults { get; } = new Dictionary<string, object>();
        public Dictionary<string, byte[]> OutputFiles { get; } = new Dictionary<string, byte[]>();
        public PipelineSettings Settings { get; set; }
    }

    /// <summary>
    /// 验证上下文
    /// </summary>
    public class ValidationContext : PipelineContextBase
    {
        public string ConfigType { get; set; }
        public string ConfigName { get; set; }
        public object DataToValidate { get; set; }
        public System.Type DataType { get; set; }
        public ValidationRules ValidationRules { get; set; }
    }
}