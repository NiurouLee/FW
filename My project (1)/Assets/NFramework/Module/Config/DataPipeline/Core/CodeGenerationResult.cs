using System;
using System.Collections.Generic;
using System.Linq;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 代码生成结果
    /// </summary>
    public class CodeGenerationResult
    {
        #region 基本信息
        /// <summary>
        /// 是否成功
        /// </summary>
        public bool Success { get; set; }

        /// <summary>
        /// 生成开始时间
        /// </summary>
        public DateTime StartTime { get; set; }

        /// <summary>
        /// 生成结束时间
        /// </summary>
        public DateTime EndTime { get; set; }

        /// <summary>
        /// 生成持续时间
        /// </summary>
        public TimeSpan Duration { get; set; }

        /// <summary>
        /// 生成器名称
        /// </summary>
        public string GeneratorName { get; set; }

        /// <summary>
        /// 目标语言
        /// </summary>
        public string TargetLanguage { get; set; }
        #endregion

        #region 生成内容
        /// <summary>
        /// 生成的代码内容
        /// </summary>
        public string GeneratedCode { get; set; }

        /// <summary>
        /// 生成的文件字典（文件路径 -> 文件内容）
        /// </summary>
        public Dictionary<string, string> GeneratedFiles { get; } = new Dictionary<string, string>();

        /// <summary>
        /// 生成的资源文件字典（文件路径 -> 文件内容）
        /// </summary>
        public Dictionary<string, byte[]> GeneratedResources { get; } = new Dictionary<string, byte[]>();

        /// <summary>
        /// 生成的类型列表
        /// </summary>
        public List<GeneratedType> GeneratedTypes { get; } = new List<GeneratedType>();

        /// <summary>
        /// 生成的文档
        /// </summary>
        public Dictionary<string, string> GeneratedDocs { get; } = new Dictionary<string, string>();
        #endregion

        #region 错误和警告
        /// <summary>
        /// 错误列表
        /// </summary>
        public List<string> Errors { get; } = new List<string>();

        /// <summary>
        /// 警告列表
        /// </summary>
        public List<string> Warnings { get; } = new List<string>();

        /// <summary>
        /// 编译错误列表
        /// </summary>
        public List<CompilationError> CompilationErrors { get; } = new List<CompilationError>();
        #endregion

        #region 统计信息
        /// <summary>
        /// 生成的文件数量
        /// </summary>
        public int FileCount => GeneratedFiles.Count;

        /// <summary>
        /// 生成的代码行数
        /// </summary>
        public int LineCount { get; set; }

        /// <summary>
        /// 生成的类型数量
        /// </summary>
        public int TypeCount => GeneratedTypes.Count;

        /// <summary>
        /// 性能指标
        /// </summary>
        public CodeGenerationMetrics Metrics { get; } = new CodeGenerationMetrics();
        #endregion

        #region 构造函数
        /// <summary>
        /// 创建代码生成结果
        /// </summary>
        public CodeGenerationResult()
        {
            StartTime = DateTime.Now;
        }

        /// <summary>
        /// 使用生成器名称创建代码生成结果
        /// </summary>
        public CodeGenerationResult(string generatorName) : this()
        {
            GeneratorName = generatorName;
        }
        #endregion

        #region 公共方法
        /// <summary>
        /// 添加生成的文件
        /// </summary>
        public void AddFile(string filePath, string content)
        {
            GeneratedFiles[filePath] = content;
            LineCount += content.Count(c => c == '\n') + 1;
            UpdateMetrics();
        }

        /// <summary>
        /// 添加生成的资源文件
        /// </summary>
        public void AddResource(string filePath, byte[] content)
        {
            GeneratedResources[filePath] = content;
            UpdateMetrics();
        }

        /// <summary>
        /// 添加生成的类型
        /// </summary>
        public void AddType(GeneratedType type)
        {
            GeneratedTypes.Add(type);
            UpdateMetrics();
        }

        /// <summary>
        /// 添加错误
        /// </summary>
        public void AddError(string error)
        {
            Errors.Add(error);
            Success = false;
        }

        /// <summary>
        /// 添加警告
        /// </summary>
        public void AddWarning(string warning)
        {
            Warnings.Add(warning);
        }

        /// <summary>
        /// 添加编译错误
        /// </summary>
        public void AddCompilationError(CompilationError error)
        {
            CompilationErrors.Add(error);
            Success = false;
        }

        /// <summary>
        /// 完成生成
        /// </summary>
        public void Complete()
        {
            EndTime = DateTime.Now;
            Duration = EndTime - StartTime;
            Success = Errors.Count == 0 && CompilationErrors.Count == 0;
            UpdateMetrics();
        }

        /// <summary>
        /// 获取生成摘要
        /// </summary>
        public string GetSummary()
        {
            return $"Code generation {(Success ? "succeeded" : "failed")}\n" +
                   $"Generator: {GeneratorName}\n" +
                   $"Language: {TargetLanguage}\n" +
                   $"Duration: {Duration.TotalSeconds:F2}s\n" +
                   $"Files: {FileCount}\n" +
                   $"Lines: {LineCount}\n" +
                   $"Types: {TypeCount}\n" +
                   $"Errors: {Errors.Count}\n" +
                   $"Warnings: {Warnings.Count}\n" +
                   GetMetricsSummary();
        }

        /// <summary>
        /// 克隆生成结果
        /// </summary>
        public CodeGenerationResult Clone()
        {
            var result = new CodeGenerationResult
            {
                Success = this.Success,
                StartTime = this.StartTime,
                EndTime = this.EndTime,
                Duration = this.Duration,
                GeneratorName = this.GeneratorName,
                TargetLanguage = this.TargetLanguage,
                GeneratedCode = this.GeneratedCode,
                LineCount = this.LineCount
            };

            // 复制集合
            foreach (var file in this.GeneratedFiles)
            {
                result.GeneratedFiles[file.Key] = file.Value;
            }

            foreach (var resource in this.GeneratedResources)
            {
                result.GeneratedResources[resource.Key] = resource.Value;
            }

            foreach (var type in this.GeneratedTypes)
            {
                result.GeneratedTypes.Add(type.Clone());
            }

            foreach (var doc in this.GeneratedDocs)
            {
                result.GeneratedDocs[doc.Key] = doc.Value;
            }

            result.Errors.AddRange(this.Errors);
            result.Warnings.AddRange(this.Warnings);
            result.CompilationErrors.AddRange(this.CompilationErrors.Select(e => e.Clone()));

            return result;
        }
        #endregion

        #region 私有方法
        private void UpdateMetrics()
        {
            Metrics.FileCount = FileCount;
            Metrics.LineCount = LineCount;
            Metrics.TypeCount = TypeCount;
            Metrics.TotalSize = GeneratedFiles.Values.Sum(v => v.Length) +
                              GeneratedResources.Values.Sum(v => v.Length);
        }

        private string GetMetricsSummary()
        {
            return $"\nPerformance Metrics:\n" +
                   $"  Memory Usage: {Metrics.MemoryUsageBytes / 1024:N0} KB\n" +
                   $"  Total Size: {Metrics.TotalSize / 1024:N0} KB\n" +
                   $"  Generation Speed: {Metrics.LinesPerSecond:N0} lines/sec";
        }
        #endregion
    }

    #region 辅助类型
    /// <summary>
    /// 生成的类型信息
    /// </summary>
    public class GeneratedType
    {
        /// <summary>
        /// 类型名称
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// 命名空间
        /// </summary>
        public string Namespace { get; set; }

        /// <summary>
        /// 类型种类
        /// </summary>
        public TypeKind Kind { get; set; }

        /// <summary>
        /// 访问级别
        /// </summary>
        public AccessLevel AccessLevel { get; set; }

        /// <summary>
        /// 基类列表
        /// </summary>
        public List<string> BaseTypes { get; } = new List<string>();

        /// <summary>
        /// 接口列表
        /// </summary>
        public List<string> Interfaces { get; } = new List<string>();

        /// <summary>
        /// 成员列表
        /// </summary>
        public List<GeneratedMember> Members { get; } = new List<GeneratedMember>();

        /// <summary>
        /// 克隆类型信息
        /// </summary>
        public GeneratedType Clone()
        {
            var type = new GeneratedType
            {
                Name = this.Name,
                Namespace = this.Namespace,
                Kind = this.Kind,
                AccessLevel = this.AccessLevel
            };

            type.BaseTypes.AddRange(this.BaseTypes);
            type.Interfaces.AddRange(this.Interfaces);
            type.Members.AddRange(this.Members.Select(m => m.Clone()));

            return type;
        }
    }

    /// <summary>
    /// 生成的成员信息
    /// </summary>
    public class GeneratedMember
    {
        /// <summary>
        /// 成员名称
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// 成员类型
        /// </summary>
        public string Type { get; set; }

        /// <summary>
        /// 成员种类
        /// </summary>
        public MemberKind Kind { get; set; }

        /// <summary>
        /// 访问级别
        /// </summary>
        public AccessLevel AccessLevel { get; set; }

        /// <summary>
        /// 克隆成员信息
        /// </summary>
        public GeneratedMember Clone()
        {
            return new GeneratedMember
            {
                Name = this.Name,
                Type = this.Type,
                Kind = this.Kind,
                AccessLevel = this.AccessLevel
            };
        }
    }

    /// <summary>
    /// 编译错误
    /// </summary>
    public class CompilationError
    {
        /// <summary>
        /// 错误代码
        /// </summary>
        public string ErrorCode { get; set; }

        /// <summary>
        /// 错误消息
        /// </summary>
        public string Message { get; set; }

        /// <summary>
        /// 文件路径
        /// </summary>
        public string FilePath { get; set; }

        /// <summary>
        /// 行号
        /// </summary>
        public int Line { get; set; }

        /// <summary>
        /// 列号
        /// </summary>
        public int Column { get; set; }

        /// <summary>
        /// 克隆编译错误
        /// </summary>
        public CompilationError Clone()
        {
            return new CompilationError
            {
                ErrorCode = this.ErrorCode,
                Message = this.Message,
                FilePath = this.FilePath,
                Line = this.Line,
                Column = this.Column
            };
        }
    }

    /// <summary>
    /// 代码生成性能指标
    /// </summary>
    public class CodeGenerationMetrics
    {
        /// <summary>
        /// 文件数量
        /// </summary>
        public int FileCount { get; set; }

        /// <summary>
        /// 代码行数
        /// </summary>
        public int LineCount { get; set; }

        /// <summary>
        /// 类型数量
        /// </summary>
        public int TypeCount { get; set; }

        /// <summary>
        /// 总大小（字节）
        /// </summary>
        public long TotalSize { get; set; }

        /// <summary>
        /// 内存使用（字节）
        /// </summary>
        public long MemoryUsageBytes { get; set; }

        /// <summary>
        /// 每秒生成行数
        /// </summary>
        public double LinesPerSecond { get; set; }
    }

    /// <summary>
    /// 类型种类
    /// </summary>
    public enum TypeKind
    {
        /// <summary>
        /// 类
        /// </summary>
        Class,

        /// <summary>
        /// 结构体
        /// </summary>
        Struct,

        /// <summary>
        /// 接口
        /// </summary>
        Interface,

        /// <summary>
        /// 枚举
        /// </summary>
        Enum,

        /// <summary>
        /// 委托
        /// </summary>
        Delegate
    }

    /// <summary>
    /// 成员种类
    /// </summary>
    public enum MemberKind
    {
        /// <summary>
        /// 字段
        /// </summary>
        Field,

        /// <summary>
        /// 属性
        /// </summary>
        Property,

        /// <summary>
        /// 方法
        /// </summary>
        Method,

        /// <summary>
        /// 事件
        /// </summary>
        Event,

        /// <summary>
        /// 构造函数
        /// </summary>
        Constructor
    }
    #endregion
}
