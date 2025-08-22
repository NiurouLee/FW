using System;
using System.Collections.Generic;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 管道执行结果
    /// </summary>
    public class PipelineResult
    {
        #region 基本信息
        /// <summary>
        /// 是否成功
        /// </summary>
        public bool Success { get; set; }

        /// <summary>
        /// 开始时间
        /// </summary>
        public DateTime StartTime { get; set; }

        /// <summary>
        /// 结束时间
        /// </summary>
        public DateTime EndTime { get; set; }

        /// <summary>
        /// 执行时长
        /// </summary>
        public TimeSpan Duration { get; set; }

        /// <summary>
        /// 处理的文件数量
        /// </summary>
        public int ProcessedFileCount { get; set; }

        /// <summary>
        /// 生成的文件数量
        /// </summary>
        public int GeneratedFileCount { get; set; }

        /// <summary>
        /// 处理的总数据量（字节）
        /// </summary>
        public long ProcessedDataSize { get; set; }
        #endregion

        #region 输出数据
        /// <summary>
        /// 生成的二进制数据
        /// </summary>
        public byte[] BinaryData { get; set; }

        /// <summary>
        /// 生成的文件字典（文件名 -> 文件内容）
        /// </summary>
        public Dictionary<string, byte[]> GeneratedFiles { get; } = new Dictionary<string, byte[]>();

        /// <summary>
        /// 生成的代码文件字典（文件名 -> 代码内容）
        /// </summary>
        public Dictionary<string, string> GeneratedCodeFiles { get; } = new Dictionary<string, string>();

        /// <summary>
        /// 生成的资源文件字典（文件名 -> 资源内容）
        /// </summary>
        public Dictionary<string, byte[]> GeneratedResourceFiles { get; } = new Dictionary<string, byte[]>();

        /// <summary>
        /// 生成的元数据字典（文件名 -> 元数据）
        /// </summary>
        public Dictionary<string, Dictionary<string, object>> GeneratedMetadata { get; } = new Dictionary<string, Dictionary<string, object>>();
        #endregion

        #region 日志和错误
        /// <summary>
        /// 日志列表
        /// </summary>
        public List<LogEntry> Logs { get; } = new List<LogEntry>();

        /// <summary>
        /// 警告列表
        /// </summary>
        public List<string> Warnings { get; } = new List<string>();

        /// <summary>
        /// 错误列表
        /// </summary>
        public List<string> Errors { get; } = new List<string>();

        /// <summary>
        /// 验证结果列表
        /// </summary>
        public List<ValidationResult> ValidationResults { get; } = new List<ValidationResult>();

        /// <summary>
        /// 性能统计信息
        /// </summary>
        public Dictionary<string, PerformanceMetrics> PerformanceStats { get; } = new Dictionary<string, PerformanceMetrics>();
        #endregion

        #region 处理器信息
        /// <summary>
        /// 收集器执行结果
        /// </summary>
        public Dictionary<string, ProcessorResult> CollectorResults { get; } = new Dictionary<string, ProcessorResult>();

        /// <summary>
        /// 批处理器执行结果
        /// </summary>
        public Dictionary<string, ProcessorResult> BatchProcessorResults { get; } = new Dictionary<string, ProcessorResult>();

        /// <summary>
        /// 预处理器执行结果
        /// </summary>
        public Dictionary<string, ProcessorResult> PreProcessorResults { get; } = new Dictionary<string, ProcessorResult>();

        /// <summary>
        /// 生成器执行结果
        /// </summary>
        public Dictionary<string, ProcessorResult> GeneratorResults { get; } = new Dictionary<string, ProcessorResult>();

        /// <summary>
        /// 后处理器执行结果
        /// </summary>
        public Dictionary<string, ProcessorResult> PostProcessorResults { get; } = new Dictionary<string, ProcessorResult>();

        /// <summary>
        /// 最终处理器执行结果
        /// </summary>
        public Dictionary<string, ProcessorResult> FinalProcessorResults { get; } = new Dictionary<string, ProcessorResult>();
        #endregion

        #region 构造函数
        /// <summary>
        /// 创建管道结果
        /// </summary>
        public PipelineResult()
        {
            StartTime = DateTime.Now;
        }
        #endregion

        #region 公共方法
        /// <summary>
        /// 添加日志
        /// </summary>
        public void AddLog(string message, LogLevel level = LogLevel.Info)
        {
            Logs.Add(new LogEntry
            {
                Message = message,
                Level = level,
                Timestamp = DateTime.Now
            });
        }

        /// <summary>
        /// 添加警告
        /// </summary>
        public void AddWarning(string message)
        {
            Warnings.Add(message);
            AddLog(message, LogLevel.Warning);
        }

        /// <summary>
        /// 添加错误
        /// </summary>
        public void AddError(string message)
        {
            Errors.Add(message);
            AddLog(message, LogLevel.Error);
            Success = false;
        }

        /// <summary>
        /// 完成处理
        /// </summary>
        public void Complete()
        {
            EndTime = DateTime.Now;
            Duration = EndTime - StartTime;
        }

        /// <summary>
        /// 获取处理器执行结果
        /// </summary>
        public ProcessorResult GetProcessorResult(string processorName)
        {
            if (CollectorResults.TryGetValue(processorName, out var result)) return result;
            if (BatchProcessorResults.TryGetValue(processorName, out result)) return result;
            if (PreProcessorResults.TryGetValue(processorName, out result)) return result;
            if (GeneratorResults.TryGetValue(processorName, out result)) return result;
            if (PostProcessorResults.TryGetValue(processorName, out result)) return result;
            if (FinalProcessorResults.TryGetValue(processorName, out result)) return result;
            return null;
        }

        /// <summary>
        /// 获取结果摘要
        /// </summary>
        public string GetSummary()
        {
            return $"Pipeline execution {(Success ? "succeeded" : "failed")}\n" +
                   $"Duration: {Duration.TotalSeconds:F2}s\n" +
                   $"Files processed: {ProcessedFileCount}\n" +
                   $"Files generated: {GeneratedFileCount}\n" +
                   $"Warnings: {Warnings.Count}\n" +
                   $"Errors: {Errors.Count}";
        }
        #endregion
    }

    /// <summary>
    /// 日志级别
    /// </summary>
    public enum LogLevel
    {
        Debug,
        Info,
        Warning,
        Error,
        Critical
    }

    /// <summary>
    /// 日志条目
    /// </summary>
    public class LogEntry
    {
        /// <summary>
        /// 消息内容
        /// </summary>
        public string Message { get; set; }

        /// <summary>
        /// 日志级别
        /// </summary>
        public LogLevel Level { get; set; }

        /// <summary>
        /// 时间戳
        /// </summary>
        public DateTime Timestamp { get; set; }

        /// <summary>
        /// 上下文数据
        /// </summary>
        public Dictionary<string, object> Context { get; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 处理器执行结果
    /// </summary>
    public class ProcessorResult
    {
        /// <summary>
        /// 处理器名称
        /// </summary>
        public string ProcessorName { get; set; }

        /// <summary>
        /// 是否成功
        /// </summary>
        public bool Success { get; set; }

        /// <summary>
        /// 开始时间
        /// </summary>
        public DateTime StartTime { get; set; }

        /// <summary>
        /// 结束时间
        /// </summary>
        public DateTime EndTime { get; set; }

        /// <summary>
        /// 执行时长
        /// </summary>
        public TimeSpan Duration { get; set; }

        /// <summary>
        /// 处理的数据量（字节）
        /// </summary>
        public long ProcessedDataSize { get; set; }

        /// <summary>
        /// 错误信息
        /// </summary>
        public string ErrorMessage { get; set; }

        /// <summary>
        /// 输出数据
        /// </summary>
        public Dictionary<string, object> OutputData { get; } = new Dictionary<string, object>();

        /// <summary>
        /// 性能指标
        /// </summary>
        public PerformanceMetrics Metrics { get; } = new PerformanceMetrics();
    }

    /// <summary>
    /// 性能指标
    /// </summary>
    public class PerformanceMetrics
    {
        /// <summary>
        /// CPU使用时间（毫秒）
        /// </summary>
        public long CpuTimeMs { get; set; }

        /// <summary>
        /// 内存使用峰值（字节）
        /// </summary>
        public long PeakMemoryBytes { get; set; }

        /// <summary>
        /// IO操作次数
        /// </summary>
        public int IoOperations { get; set; }

        /// <summary>
        /// IO读取字节数
        /// </summary>
        public long IoReadBytes { get; set; }

        /// <summary>
        /// IO写入字节数
        /// </summary>
        public long IoWriteBytes { get; set; }

        /// <summary>
        /// 自定义指标
        /// </summary>
        public Dictionary<string, double> CustomMetrics { get; } = new Dictionary<string, double>();
    }
}
