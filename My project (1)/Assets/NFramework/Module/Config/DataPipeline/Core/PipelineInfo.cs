using System;
using System.Collections.Generic;
using System.Linq;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 管道信息
    /// </summary>
    public class PipelineInfo
    {
        #region 基本信息
        /// <summary>
        /// 管道名称
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// 管道描述
        /// </summary>
        public string Description { get; set; }

        /// <summary>
        /// 管道版本
        /// </summary>
        public string Version { get; set; }

        /// <summary>
        /// 管道创建日期
        /// </summary>
        public DateTime CreatedDate { get; set; }

        /// <summary>
        /// 管道修改日期
        /// </summary>
        public DateTime LastModifiedDate { get; set; }

        /// <summary>
        /// 管道状态
        /// </summary>
        public PipelineStatus Status { get; set; }
        #endregion

        #region 处理器信息
        /// <summary>
        /// 收集器列表
        /// </summary>
        public List<ProcessorInfo> Collectors { get; set; } = new List<ProcessorInfo>();

        /// <summary>
        /// 批处理器列表
        /// </summary>
        public List<ProcessorInfo> BatchProcessors { get; set; } = new List<ProcessorInfo>();

        /// <summary>
        /// 预处理器列表
        /// </summary>
        public List<ProcessorInfo> PreProcessors { get; set; } = new List<ProcessorInfo>();

        /// <summary>
        /// 生成器列表
        /// </summary>
        public List<ProcessorInfo> Generators { get; set; } = new List<ProcessorInfo>();

        /// <summary>
        /// 代码生成器列表
        /// </summary>
        public List<ProcessorInfo> CodeGenerators { get; set; } = new List<ProcessorInfo>();

        /// <summary>
        /// 后处理器列表
        /// </summary>
        public List<ProcessorInfo> PostProcessors { get; set; } = new List<ProcessorInfo>();

        /// <summary>
        /// 最终处理器列表
        /// </summary>
        public List<ProcessorInfo> FinalProcessors { get; set; } = new List<ProcessorInfo>();

        /// <summary>
        /// 验证器列表
        /// </summary>
        public List<ProcessorInfo> Validators { get; set; } = new List<ProcessorInfo>();
        #endregion

        #region 统计信息
        /// <summary>
        /// 处理器总数
        /// </summary>
        public int TotalProcessors => GetTotalProcessorCount();

        /// <summary>
        /// 启用的处理器数量
        /// </summary>
        public int EnabledProcessors => GetEnabledProcessorCount();

        /// <summary>
        /// 处理器执行统计
        /// </summary>
        public Dictionary<string, ProcessorStats> ProcessorStatistics { get; } = new Dictionary<string, ProcessorStats>();

        /// <summary>
        /// 性能指标
        /// </summary>
        public PipelinePerformanceMetrics PerformanceMetrics { get; } = new PipelinePerformanceMetrics();
        #endregion

        #region 配置信息
        /// <summary>
        /// 管道设置
        /// </summary>
        public PipelineSettings Settings { get; set; }

        /// <summary>
        /// 处理器依赖关系
        /// </summary>
        public Dictionary<string, List<string>> ProcessorDependencies { get; } = new Dictionary<string, List<string>>();

        /// <summary>
        /// 处理器执行顺序
        /// </summary>
        public List<string> ExecutionOrder { get; } = new List<string>();

        /// <summary>
        /// 自定义配置
        /// </summary>
        public Dictionary<string, object> CustomConfiguration { get; } = new Dictionary<string, object>();
        #endregion

        #region 构造函数
        /// <summary>
        /// 创建管道信息
        /// </summary>
        public PipelineInfo()
        {
            CreatedDate = DateTime.Now;
            LastModifiedDate = DateTime.Now;
            Status = PipelineStatus.Created;
        }
        #endregion

        #region 公共方法
        /// <summary>
        /// 更新处理器统计
        /// </summary>
        public void UpdateProcessorStats(string processorName, ProcessorStats stats)
        {
            ProcessorStatistics[processorName] = stats;
            LastModifiedDate = DateTime.Now;
        }

        /// <summary>
        /// 更新管道状态
        /// </summary>
        public void UpdateStatus(PipelineStatus newStatus)
        {
            Status = newStatus;
            LastModifiedDate = DateTime.Now;
        }

        /// <summary>
        /// 获取处理器信息
        /// </summary>
        public ProcessorInfo GetProcessorInfo(string processorName)
        {
            return GetAllProcessors()
                .FirstOrDefault(p => p.Name == processorName);
        }

        /// <summary>
        /// 获取处理器统计
        /// </summary>
        public ProcessorStats GetProcessorStats(string processorName)
        {
            return ProcessorStatistics.TryGetValue(processorName, out var stats)
                ? stats
                : null;
        }

        /// <summary>
        /// 获取管道摘要
        /// </summary>
        public string GetSummary()
        {
            return $"Pipeline: {Name} (v{Version})\n" +
                   $"Status: {Status}\n" +
                   $"Total Processors: {TotalProcessors}\n" +
                   $"Enabled Processors: {EnabledProcessors}\n" +
                   $"Last Modified: {LastModifiedDate}\n" +
                   GetProcessorBreakdown();
        }

        /// <summary>
        /// 克隆管道信息
        /// </summary>
        public PipelineInfo Clone()
        {
            var info = new PipelineInfo
            {
                Name = this.Name,
                Description = this.Description,
                Version = this.Version,
                CreatedDate = this.CreatedDate,
                LastModifiedDate = this.LastModifiedDate,
                Status = this.Status,
                Settings = this.Settings?.Clone()
            };

            // 复制处理器列表
            info.Collectors.AddRange(this.Collectors.Select(p => p.Clone()));
            info.BatchProcessors.AddRange(this.BatchProcessors.Select(p => p.Clone()));
            info.PreProcessors.AddRange(this.PreProcessors.Select(p => p.Clone()));
            info.Generators.AddRange(this.Generators.Select(p => p.Clone()));
            info.CodeGenerators.AddRange(this.CodeGenerators.Select(p => p.Clone()));
            info.PostProcessors.AddRange(this.PostProcessors.Select(p => p.Clone()));
            info.FinalProcessors.AddRange(this.FinalProcessors.Select(p => p.Clone()));
            info.Validators.AddRange(this.Validators.Select(p => p.Clone()));

            // 复制统计信息
            foreach (var stat in this.ProcessorStatistics)
            {
                info.ProcessorStatistics[stat.Key] = stat.Value.Clone();
            }

            // 复制依赖关系
            foreach (var dep in this.ProcessorDependencies)
            {
                info.ProcessorDependencies[dep.Key] = new List<string>(dep.Value);
            }

            // 复制执行顺序
            info.ExecutionOrder.AddRange(this.ExecutionOrder);

            // 复制自定义配置
            foreach (var config in this.CustomConfiguration)
            {
                info.CustomConfiguration[config.Key] = config.Value;
            }

            return info;
        }
        #endregion

        #region 私有方法
        private IEnumerable<ProcessorInfo> GetAllProcessors()
        {
            return Collectors
                .Concat(BatchProcessors)
                .Concat(PreProcessors)
                .Concat(Generators)
                .Concat(CodeGenerators)
                .Concat(PostProcessors)
                .Concat(FinalProcessors)
                .Concat(Validators);
        }

        private int GetTotalProcessorCount()
        {
            return Collectors.Count +
                   BatchProcessors.Count +
                   PreProcessors.Count +
                   Generators.Count +
                   CodeGenerators.Count +
                   PostProcessors.Count +
                   FinalProcessors.Count +
                   Validators.Count;
        }

        private int GetEnabledProcessorCount()
        {
            return GetAllProcessors().Count(p => p.IsEnabled);
        }

        private string GetProcessorBreakdown()
        {
            var breakdown = new System.Text.StringBuilder("\nProcessor Breakdown:\n");

            void AddProcessorType(string type, List<ProcessorInfo> processors)
            {
                if (processors.Count > 0)
                {
                    breakdown.AppendLine($"{type}: {processors.Count} ({processors.Count(p => p.IsEnabled)} enabled)");
                    foreach (var processor in processors)
                    {
                        breakdown.AppendLine($"  - {processor.Name} (Priority: {processor.Priority}, {(processor.IsEnabled ? "Enabled" : "Disabled")})");
                    }
                }
            }

            AddProcessorType("Collectors", Collectors);
            AddProcessorType("Batch Processors", BatchProcessors);
            AddProcessorType("Pre-Processors", PreProcessors);
            AddProcessorType("Generators", Generators);
            AddProcessorType("Code Generators", CodeGenerators);
            AddProcessorType("Post-Processors", PostProcessors);
            AddProcessorType("Final Processors", FinalProcessors);
            AddProcessorType("Validators", Validators);

            return breakdown.ToString();
        }
        #endregion
    }

    #region 辅助类型
    /// <summary>
    /// 处理器信息
    /// </summary>
    public class ProcessorInfo
    {
        /// <summary>
        /// 处理器名称
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// 处理器优先级
        /// </summary>
        public int Priority { get; set; }

        /// <summary>
        /// 是否启用
        /// </summary>
        public bool IsEnabled { get; set; }

        /// <summary>
        /// 处理器类型
        /// </summary>
        public string ProcessorType { get; set; }

        /// <summary>
        /// 处理器描述
        /// </summary>
        public string Description { get; set; }

        /// <summary>
        /// 克隆处理器信息
        /// </summary>
        public ProcessorInfo Clone()
        {
            return new ProcessorInfo
            {
                Name = this.Name,
                Priority = this.Priority,
                IsEnabled = this.IsEnabled,
                ProcessorType = this.ProcessorType,
                Description = this.Description
            };
        }
    }

    /// <summary>
    /// 处理器统计
    /// </summary>
    public class ProcessorStats
    {
        /// <summary>
        /// 执行次数
        /// </summary>
        public int ExecutionCount { get; set; }

        /// <summary>
        /// 成功次数
        /// </summary>
        public int SuccessCount { get; set; }

        /// <summary>
        /// 失败次数
        /// </summary>
        public int FailureCount { get; set; }

        /// <summary>
        /// 总执行时间（毫秒）
        /// </summary>
        public long TotalExecutionTimeMs { get; set; }

        /// <summary>
        /// 平均执行时间（毫秒）
        /// </summary>
        public double AverageExecutionTimeMs => ExecutionCount > 0 ? (double)TotalExecutionTimeMs / ExecutionCount : 0;

        /// <summary>
        /// 最后执行时间
        /// </summary>
        public DateTime LastExecutionTime { get; set; }

        /// <summary>
        /// 克隆处理器统计
        /// </summary>
        public ProcessorStats Clone()
        {
            return new ProcessorStats
            {
                ExecutionCount = this.ExecutionCount,
                SuccessCount = this.SuccessCount,
                FailureCount = this.FailureCount,
                TotalExecutionTimeMs = this.TotalExecutionTimeMs,
                LastExecutionTime = this.LastExecutionTime
            };
        }
    }

    /// <summary>
    /// 管道性能指标
    /// </summary>
    public class PipelinePerformanceMetrics
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

    /// <summary>
    /// 管道状态
    /// </summary>
    public enum PipelineStatus
    {
        /// <summary>
        /// 已创建
        /// </summary>
        Created,

        /// <summary>
        /// 已初始化
        /// </summary>
        Initialized,

        /// <summary>
        /// 运行中
        /// </summary>
        Running,

        /// <summary>
        /// 已暂停
        /// </summary>
        Paused,

        /// <summary>
        /// 已完成
        /// </summary>
        Completed,

        /// <summary>
        /// 已失败
        /// </summary>
        Failed,

        /// <summary>
        /// 已停止
        /// </summary>
        Stopped
    }
    #endregion
}
