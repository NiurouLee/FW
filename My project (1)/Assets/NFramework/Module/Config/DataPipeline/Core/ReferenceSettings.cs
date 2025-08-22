using System;
using System.Collections.Generic;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 引用设置
    /// </summary>
    public class ReferenceSettings
    {
        #region 基本设置
        /// <summary>
        /// 是否启用引用检查
        /// </summary>
        public bool EnableReferenceCheck { get; set; } = true;

        /// <summary>
        /// 是否允许循环引用
        /// </summary>
        public bool AllowCircularReferences { get; set; } = false;

        /// <summary>
        /// 是否在引用缺失时抛出异常
        /// </summary>
        public bool ThrowOnMissingReference { get; set; } = true;

        /// <summary>
        /// 是否启用延迟加载
        /// </summary>
        public bool EnableLazyLoading { get; set; } = false;

        /// <summary>
        /// 是否启用引用计数
        /// </summary>
        public bool EnableReferenceCount { get; set; } = false;

        /// <summary>
        /// 是否启用自动清理未使用的引用
        /// </summary>
        public bool EnableAutoCleanup { get; set; } = false;
        #endregion

        #region 性能设置
        /// <summary>
        /// 引用解析超时时间（毫秒）
        /// </summary>
        public int ResolutionTimeoutMs { get; set; } = 5000;

        /// <summary>
        /// 引用缓存大小
        /// </summary>
        public int ReferenceCacheSize { get; set; } = 1000;

        /// <summary>
        /// 缓存过期时间（秒）
        /// </summary>
        public int CacheExpirationSeconds { get; set; } = 300;

        /// <summary>
        /// 最大递归深度
        /// </summary>
        public int MaxRecursionDepth { get; set; } = 10;

        /// <summary>
        /// 批量加载阈值
        /// </summary>
        public int BatchLoadThreshold { get; set; } = 100;
        #endregion

        #region 格式设置
        /// <summary>
        /// 引用前缀
        /// </summary>
        public string ReferencePrefix { get; set; } = "@";

        /// <summary>
        /// 引用分隔符
        /// </summary>
        public string ReferenceSeparator { get; set; } = ".";

        /// <summary>
        /// 数组引用分隔符
        /// </summary>
        public string ArrayReferenceSeparator { get; set; } = ",";

        /// <summary>
        /// 引用格式化模板
        /// </summary>
        public string ReferenceFormat { get; set; } = "{prefix}{type}{separator}{id}";
        #endregion

        #region 验证设置
        /// <summary>
        /// 引用验证规则
        /// </summary>
        public List<ReferenceValidationRule> ValidationRules { get; } = new List<ReferenceValidationRule>();

        /// <summary>
        /// 是否验证引用完整性
        /// </summary>
        public bool ValidateReferenceIntegrity { get; set; } = true;

        /// <summary>
        /// 是否验证引用类型
        /// </summary>
        public bool ValidateReferenceType { get; set; } = true;

        /// <summary>
        /// 是否验证引用权限
        /// </summary>
        public bool ValidateReferencePermission { get; set; } = false;
        #endregion

        #region 类型映射
        /// <summary>
        /// 引用类型映射
        /// </summary>
        public Dictionary<string, Type> ReferenceTypeMap { get; } = new Dictionary<string, Type>();

        /// <summary>
        /// 引用别名映射
        /// </summary>
        public Dictionary<string, string> ReferenceAliases { get; } = new Dictionary<string, string>();

        /// <summary>
        /// 自定义引用解析器
        /// </summary>
        public Dictionary<string, Func<string, object>> CustomResolvers { get; } = new Dictionary<string, Func<string, object>>();
        #endregion

        #region 高级设置
        /// <summary>
        /// 引用加载策略
        /// </summary>
        public ReferenceLoadingStrategy LoadingStrategy { get; set; } = ReferenceLoadingStrategy.Eager;

        /// <summary>
        /// 引用解析策略
        /// </summary>
        public ReferenceResolutionStrategy ResolutionStrategy { get; set; } = ReferenceResolutionStrategy.Strict;

        /// <summary>
        /// 引用缓存策略
        /// </summary>
        public ReferenceCachingStrategy CachingStrategy { get; set; } = ReferenceCachingStrategy.Memory;

        /// <summary>
        /// 引用清理策略
        /// </summary>
        public ReferenceCleanupStrategy CleanupStrategy { get; set; } = ReferenceCleanupStrategy.Manual;
        #endregion

        #region 事件处理
        /// <summary>
        /// 引用解析前事件
        /// </summary>
        public event EventHandler<ReferenceEventArgs> BeforeReferenceResolution;

        /// <summary>
        /// 引用解析后事件
        /// </summary>
        public event EventHandler<ReferenceEventArgs> AfterReferenceResolution;

        /// <summary>
        /// 引用错误事件
        /// </summary>
        public event EventHandler<ReferenceErrorEventArgs> OnReferenceError;
        #endregion

        #region 构造函数
        /// <summary>
        /// 创建引用设置
        /// </summary>
        public ReferenceSettings()
        {
            InitializeDefaultValidationRules();
            InitializeDefaultTypeMap();
        }
        #endregion

        #region 公共方法
        /// <summary>
        /// 注册引用类型
        /// </summary>
        public void RegisterReferenceType<T>(string typeName)
        {
            ReferenceTypeMap[typeName] = typeof(T);
        }

        /// <summary>
        /// 注册引用别名
        /// </summary>
        public void RegisterReferenceAlias(string alias, string actualName)
        {
            ReferenceAliases[alias] = actualName;
        }

        /// <summary>
        /// 注册自定义解析器
        /// </summary>
        public void RegisterCustomResolver(string typeName, Func<string, object> resolver)
        {
            CustomResolvers[typeName] = resolver;
        }

        /// <summary>
        /// 添加验证规则
        /// </summary>
        public void AddValidationRule(ReferenceValidationRule rule)
        {
            ValidationRules.Add(rule);
        }

        /// <summary>
        /// 克隆设置
        /// </summary>
        public ReferenceSettings Clone()
        {
            var settings = new ReferenceSettings
            {
                EnableReferenceCheck = this.EnableReferenceCheck,
                AllowCircularReferences = this.AllowCircularReferences,
                ThrowOnMissingReference = this.ThrowOnMissingReference,
                EnableLazyLoading = this.EnableLazyLoading,
                EnableReferenceCount = this.EnableReferenceCount,
                EnableAutoCleanup = this.EnableAutoCleanup,
                ResolutionTimeoutMs = this.ResolutionTimeoutMs,
                ReferenceCacheSize = this.ReferenceCacheSize,
                CacheExpirationSeconds = this.CacheExpirationSeconds,
                MaxRecursionDepth = this.MaxRecursionDepth,
                BatchLoadThreshold = this.BatchLoadThreshold,
                ReferencePrefix = this.ReferencePrefix,
                ReferenceSeparator = this.ReferenceSeparator,
                ArrayReferenceSeparator = this.ArrayReferenceSeparator,
                ReferenceFormat = this.ReferenceFormat,
                ValidateReferenceIntegrity = this.ValidateReferenceIntegrity,
                ValidateReferenceType = this.ValidateReferenceType,
                ValidateReferencePermission = this.ValidateReferencePermission,
                LoadingStrategy = this.LoadingStrategy,
                ResolutionStrategy = this.ResolutionStrategy,
                CachingStrategy = this.CachingStrategy,
                CleanupStrategy = this.CleanupStrategy
            };

            // 复制集合
            foreach (var rule in this.ValidationRules)
            {
                settings.ValidationRules.Add(rule);
            }

            foreach (var map in this.ReferenceTypeMap)
            {
                settings.ReferenceTypeMap[map.Key] = map.Value;
            }

            foreach (var alias in this.ReferenceAliases)
            {
                settings.ReferenceAliases[alias.Key] = alias.Value;
            }

            foreach (var resolver in this.CustomResolvers)
            {
                settings.CustomResolvers[resolver.Key] = resolver.Value;
            }

            return settings;
        }
        #endregion

        #region 私有方法
        private void InitializeDefaultValidationRules()
        {
            ValidationRules.Add(new ReferenceValidationRule
            {
                Name = "Required Reference",
                Validate = (value, type) => value != null,
                ErrorMessage = "Reference is required"
            });
        }

        private void InitializeDefaultTypeMap()
        {
            // 可以添加一些默认的类型映射
        }

        protected virtual void OnBeforeReferenceResolution(ReferenceEventArgs e)
        {
            BeforeReferenceResolution?.Invoke(this, e);
        }

        protected virtual void OnAfterReferenceResolution(ReferenceEventArgs e)
        {
            AfterReferenceResolution?.Invoke(this, e);
        }

        protected virtual void OnReferenceErrorOccurred(ReferenceErrorEventArgs e)
        {
            OnReferenceError?.Invoke(this, e);
        }
        #endregion
    }

    #region 辅助类型
    /// <summary>
    /// 引用验证规则
    /// </summary>
    public class ReferenceValidationRule
    {
        /// <summary>
        /// 规则名称
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// 验证函数
        /// </summary>
        public Func<object, Type, bool> Validate { get; set; }

        /// <summary>
        /// 错误消息
        /// </summary>
        public string ErrorMessage { get; set; }
    }

    /// <summary>
    /// 引用事件参数
    /// </summary>
    public class ReferenceEventArgs : EventArgs
    {
        /// <summary>
        /// 引用值
        /// </summary>
        public object Value { get; set; }

        /// <summary>
        /// 引用类型
        /// </summary>
        public Type ReferenceType { get; set; }

        /// <summary>
        /// 引用路径
        /// </summary>
        public string Path { get; set; }
    }

    /// <summary>
    /// 引用错误事件参数
    /// </summary>
    public class ReferenceErrorEventArgs : ReferenceEventArgs
    {
        /// <summary>
        /// 错误消息
        /// </summary>
        public string ErrorMessage { get; set; }

        /// <summary>
        /// 异常对象
        /// </summary>
        public Exception Exception { get; set; }
    }

    /// <summary>
    /// 引用加载策略
    /// </summary>
    public enum ReferenceLoadingStrategy
    {
        /// <summary>
        /// 立即加载
        /// </summary>
        Eager,

        /// <summary>
        /// 延迟加载
        /// </summary>
        Lazy,

        /// <summary>
        /// 批量加载
        /// </summary>
        Batch
    }

    /// <summary>
    /// 引用解析策略
    /// </summary>
    public enum ReferenceResolutionStrategy
    {
        /// <summary>
        /// 严格模式
        /// </summary>
        Strict,

        /// <summary>
        /// 宽松模式
        /// </summary>
        Lenient,

        /// <summary>
        /// 自动修复
        /// </summary>
        AutoFix
    }

    /// <summary>
    /// 引用缓存策略
    /// </summary>
    public enum ReferenceCachingStrategy
    {
        /// <summary>
        /// 内存缓存
        /// </summary>
        Memory,

        /// <summary>
        /// 持久化缓存
        /// </summary>
        Persistent,

        /// <summary>
        /// 分布式缓存
        /// </summary>
        Distributed,

        /// <summary>
        /// 无缓存
        /// </summary>
        None
    }

    /// <summary>
    /// 引用清理策略
    /// </summary>
    public enum ReferenceCleanupStrategy
    {
        /// <summary>
        /// 手动清理
        /// </summary>
        Manual,

        /// <summary>
        /// 自动清理
        /// </summary>
        Auto,

        /// <summary>
        /// 定期清理
        /// </summary>
        Scheduled
    }
    #endregion
}
