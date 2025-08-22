using System;
using System.Collections.Generic;
using System.Linq;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 验证结果
    /// </summary>
    public class ValidationResult
    {
        #region 基本信息
        /// <summary>
        /// 是否验证通过
        /// </summary>
        public bool IsValid { get; set; }

        /// <summary>
        /// 验证开始时间
        /// </summary>
        public DateTime StartTime { get; set; }

        /// <summary>
        /// 验证结束时间
        /// </summary>
        public DateTime EndTime { get; set; }

        /// <summary>
        /// 验证持续时间
        /// </summary>
        public TimeSpan Duration { get; set; }

        /// <summary>
        /// 验证器名称
        /// </summary>
        public string ValidatorName { get; set; }

        /// <summary>
        /// 验证路径
        /// </summary>
        public string[] ValidationPath { get; set; }
        #endregion

        #region 错误和警告
        /// <summary>
        /// 错误列表
        /// </summary>
        public List<ValidationError> Errors { get; } = new List<ValidationError>();

        /// <summary>
        /// 警告列表
        /// </summary>
        public List<string> Warnings { get; } = new List<string>();

        /// <summary>
        /// 信息列表
        /// </summary>
        public List<string> Infos { get; } = new List<string>();
        #endregion

        #region 验证数据
        /// <summary>
        /// 验证的数据类型
        /// </summary>
        public Type ValidatedType { get; set; }

        /// <summary>
        /// 验证的字段数量
        /// </summary>
        public int ValidatedFieldCount { get; set; }

        /// <summary>
        /// 验证的记录数量
        /// </summary>
        public int ValidatedRecordCount { get; set; }

        /// <summary>
        /// 验证的规则数量
        /// </summary>
        public int ValidatedRuleCount { get; set; }

        /// <summary>
        /// 验证数据
        /// </summary>
        public Dictionary<string, object> ValidationData { get; } = new Dictionary<string, object>();
        #endregion

        #region 统计信息
        /// <summary>
        /// 错误统计（按错误类型）
        /// </summary>
        public Dictionary<ValidationErrorType, int> ErrorStats { get; } = new Dictionary<ValidationErrorType, int>();

        /// <summary>
        /// 错误统计（按严重程度）
        /// </summary>
        public Dictionary<ValidationSeverity, int> SeverityStats { get; } = new Dictionary<ValidationSeverity, int>();

        /// <summary>
        /// 性能指标
        /// </summary>
        public ValidationPerformanceMetrics PerformanceMetrics { get; } = new ValidationPerformanceMetrics();
        #endregion

        #region 构造函数
        /// <summary>
        /// 创建验证结果
        /// </summary>
        public ValidationResult()
        {
            StartTime = DateTime.Now;
            InitializeStats();
        }

        /// <summary>
        /// 使用验证器名称创建验证结果
        /// </summary>
        public ValidationResult(string validatorName) : this()
        {
            ValidatorName = validatorName;
        }
        #endregion

        #region 公共方法
        /// <summary>
        /// 添加错误
        /// </summary>
        public void AddError(ValidationError error)
        {
            Errors.Add(error);
            IsValid = false;

            // 更新统计信息
            if (!ErrorStats.ContainsKey(error.ErrorType))
            {
                ErrorStats[error.ErrorType] = 0;
            }
            ErrorStats[error.ErrorType]++;

            if (!SeverityStats.ContainsKey(error.Severity))
            {
                SeverityStats[error.Severity] = 0;
            }
            SeverityStats[error.Severity]++;
        }

        /// <summary>
        /// 添加错误
        /// </summary>
        public void AddError(string message, ValidationErrorType errorType = ValidationErrorType.Custom, ValidationSeverity severity = ValidationSeverity.Error)
        {
            AddError(new ValidationError
            {
                Message = message,
                ErrorType = errorType,
                Severity = severity,
                Timestamp = DateTime.Now
            });
        }

        /// <summary>
        /// 添加警告
        /// </summary>
        public void AddWarning(string message)
        {
            Warnings.Add(message);
        }

        /// <summary>
        /// 添加信息
        /// </summary>
        public void AddInfo(string message)
        {
            Infos.Add(message);
        }

        /// <summary>
        /// 完成验证
        /// </summary>
        public void Complete()
        {
            EndTime = DateTime.Now;
            Duration = EndTime - StartTime;
            UpdatePerformanceMetrics();
        }

        /// <summary>
        /// 合并验证结果
        /// </summary>
        public void Merge(ValidationResult other)
        {
            if (other == null) return;

            IsValid &= other.IsValid;
            Errors.AddRange(other.Errors);
            Warnings.AddRange(other.Warnings);
            Infos.AddRange(other.Infos);

            // 合并统计信息
            foreach (var stat in other.ErrorStats)
            {
                if (!ErrorStats.ContainsKey(stat.Key))
                {
                    ErrorStats[stat.Key] = 0;
                }
                ErrorStats[stat.Key] += stat.Value;
            }

            foreach (var stat in other.SeverityStats)
            {
                if (!SeverityStats.ContainsKey(stat.Key))
                {
                    SeverityStats[stat.Key] = 0;
                }
                SeverityStats[stat.Key] += stat.Value;
            }

            // 更新计数
            ValidatedFieldCount += other.ValidatedFieldCount;
            ValidatedRecordCount += other.ValidatedRecordCount;
            ValidatedRuleCount += other.ValidatedRuleCount;

            // 合并性能指标
            PerformanceMetrics.Merge(other.PerformanceMetrics);
        }

        /// <summary>
        /// 获取验证摘要
        /// </summary>
        public string GetSummary()
        {
            return $"Validation {(IsValid ? "succeeded" : "failed")}\n" +
                   $"Duration: {Duration.TotalSeconds:F2}s\n" +
                   $"Fields validated: {ValidatedFieldCount}\n" +
                   $"Records validated: {ValidatedRecordCount}\n" +
                   $"Rules validated: {ValidatedRuleCount}\n" +
                   $"Errors: {Errors.Count}\n" +
                   $"Warnings: {Warnings.Count}\n" +
                   GetErrorBreakdown();
        }
        #endregion

        #region 私有方法
        private void InitializeStats()
        {
            // 初始化错误类型统计
            foreach (ValidationErrorType errorType in Enum.GetValues(typeof(ValidationErrorType)))
            {
                ErrorStats[errorType] = 0;
            }

            // 初始化严重程度统计
            foreach (ValidationSeverity severity in Enum.GetValues(typeof(ValidationSeverity)))
            {
                SeverityStats[severity] = 0;
            }
        }

        private void UpdatePerformanceMetrics()
        {
            PerformanceMetrics.TotalDuration = Duration;
            PerformanceMetrics.ErrorsPerSecond = Duration.TotalSeconds > 0 
                ? Errors.Count / Duration.TotalSeconds 
                : 0;
            PerformanceMetrics.RecordsPerSecond = Duration.TotalSeconds > 0 
                ? ValidatedRecordCount / Duration.TotalSeconds 
                : 0;
        }

        private string GetErrorBreakdown()
        {
            var breakdown = new System.Text.StringBuilder();
            breakdown.AppendLine("\nError breakdown:");

            // 按错误类型统计
            if (ErrorStats.Any(x => x.Value > 0))
            {
                breakdown.AppendLine("By type:");
                foreach (var stat in ErrorStats.Where(x => x.Value > 0))
                {
                    breakdown.AppendLine($"  {stat.Key}: {stat.Value}");
                }
            }

            // 按严重程度统计
            if (SeverityStats.Any(x => x.Value > 0))
            {
                breakdown.AppendLine("By severity:");
                foreach (var stat in SeverityStats.Where(x => x.Value > 0))
                {
                    breakdown.AppendLine($"  {stat.Key}: {stat.Value}");
                }
            }

            return breakdown.ToString();
        }
        #endregion
    }

    /// <summary>
    /// 验证错误
    /// </summary>
    public class ValidationError
    {
        /// <summary>
        /// 错误消息
        /// </summary>
        public string Message { get; set; }

        /// <summary>
        /// 错误代码
        /// </summary>
        public string ErrorCode { get; set; }

        /// <summary>
        /// 错误类型
        /// </summary>
        public ValidationErrorType ErrorType { get; set; }

        /// <summary>
        /// 错误严重程度
        /// </summary>
        public ValidationSeverity Severity { get; set; }

        /// <summary>
        /// 字段名
        /// </summary>
        public string Field { get; set; }

        /// <summary>
        /// 字段值
        /// </summary>
        public object Value { get; set; }

        /// <summary>
        /// 验证规则名称
        /// </summary>
        public string RuleName { get; set; }

        /// <summary>
        /// 验证路径
        /// </summary>
        public string[] ValidationPath { get; set; }

        /// <summary>
        /// 时间戳
        /// </summary>
        public DateTime Timestamp { get; set; }

        /// <summary>
        /// 附加数据
        /// </summary>
        public Dictionary<string, object> Data { get; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 验证错误类型
    /// </summary>
    public enum ValidationErrorType
    {
        /// <summary>
        /// 必填字段缺失
        /// </summary>
        Required,

        /// <summary>
        /// 格式错误
        /// </summary>
        Format,

        /// <summary>
        /// 范围错误
        /// </summary>
        Range,

        /// <summary>
        /// 引用错误
        /// </summary>
        Reference,

        /// <summary>
        /// 自定义错误
        /// </summary>
        Custom,

        /// <summary>
        /// 类型错误
        /// </summary>
        Type,

        /// <summary>
        /// 长度错误
        /// </summary>
        Length,

        /// <summary>
        /// 模式匹配错误
        /// </summary>
        Pattern,

        /// <summary>
        /// 比较错误
        /// </summary>
        Comparison,

        /// <summary>
        /// 依赖错误
        /// </summary>
        Dependency
    }

    /// <summary>
    /// 验证严重程度
    /// </summary>
    public enum ValidationSeverity
    {
        /// <summary>
        /// 信息
        /// </summary>
        Info,

        /// <summary>
        /// 警告
        /// </summary>
        Warning,

        /// <summary>
        /// 错误
        /// </summary>
        Error,

        /// <summary>
        /// 严重错误
        /// </summary>
        Critical
    }

    /// <summary>
    /// 验证性能指标
    /// </summary>
    public class ValidationPerformanceMetrics
    {
        /// <summary>
        /// 总持续时间
        /// </summary>
        public TimeSpan TotalDuration { get; set; }

        /// <summary>
        /// 每秒错误数
        /// </summary>
        public double ErrorsPerSecond { get; set; }

        /// <summary>
        /// 每秒记录数
        /// </summary>
        public double RecordsPerSecond { get; set; }

        /// <summary>
        /// CPU使用时间（毫秒）
        /// </summary>
        public long CpuTimeMs { get; set; }

        /// <summary>
        /// 内存使用峰值（字节）
        /// </summary>
        public long PeakMemoryBytes { get; set; }

        /// <summary>
        /// 自定义指标
        /// </summary>
        public Dictionary<string, double> CustomMetrics { get; } = new Dictionary<string, double>();

        /// <summary>
        /// 合并性能指标
        /// </summary>
        public void Merge(ValidationPerformanceMetrics other)
        {
            if (other == null) return;

            TotalDuration += other.TotalDuration;
            ErrorsPerSecond = (ErrorsPerSecond + other.ErrorsPerSecond) / 2; // 取平均值
            RecordsPerSecond = (RecordsPerSecond + other.RecordsPerSecond) / 2; // 取平均值
            CpuTimeMs += other.CpuTimeMs;
            PeakMemoryBytes = Math.Max(PeakMemoryBytes, other.PeakMemoryBytes);

            foreach (var metric in other.CustomMetrics)
            {
                if (!CustomMetrics.ContainsKey(metric.Key))
                {
                    CustomMetrics[metric.Key] = metric.Value;
                }
                else
                {
                    CustomMetrics[metric.Key] = (CustomMetrics[metric.Key] + metric.Value) / 2; // 取平均值
                }
            }
        }
    }
}
