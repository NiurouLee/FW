using System;
using System.Collections.Generic;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 字段定义
    /// </summary>
    public class FieldDefinition
    {
        /// <summary>
        /// 字段名称
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// 字段类型
        /// </summary>
        public string Type { get; set; }

        /// <summary>
        /// 字段默认值
        /// </summary>
        public object DefaultValue { get; set; }

        /// <summary>
        /// 字段描述
        /// </summary>
        public string Description { get; set; }

        /// <summary>
        /// 字段是否为必填项
        /// </summary>
        public bool IsRequired { get; set; }

        /// <summary>
        /// 字段是否为数组
        /// </summary>
        public bool IsArray { get; set; }

        /// <summary>
        /// 字段是否为可空类型
        /// </summary>
        public bool IsNullable { get; set; }

        /// <summary>
        /// 字段是否为引用类型
        /// </summary>
        public bool IsReference { get; set; }

        /// <summary>
        /// 引用的类型名称（如果是引用类型）
        /// </summary>
        public string ReferencedTypeName { get; set; }

        /// <summary>
        /// 字段标记列表（如 Client, Server, Lan 等）
        /// </summary>
        public List<string> Tags { get; set; } = new List<string>();

        /// <summary>
        /// 字段的验证规则
        /// </summary>
        public List<ValidationRule> ValidationRules { get; set; } = new List<ValidationRule>();

        /// <summary>
        /// 字段的元数据
        /// </summary>
        public Dictionary<string, object> Metadata { get; set; } = new Dictionary<string, object>();

        /// <summary>
        /// 字段的访问级别
        /// </summary>
        public AccessLevel AccessLevel { get; set; } = AccessLevel.Public;

        /// <summary>
        /// 字段的序列化选项
        /// </summary>
        public SerializationOptions SerializationOptions { get; set; } = new SerializationOptions();

        /// <summary>
        /// 字段的注释列表
        /// </summary>
        public List<string> Comments { get; set; } = new List<string>();

        /// <summary>
        /// 字段的分类
        /// </summary>
        public string Category { get; set; }

        /// <summary>
        /// 字段是否支持本地化
        /// </summary>
        public bool IsLocalized { get; set; }

        /// <summary>
        /// 字段是否需要索引
        /// </summary>
        public bool IsIndexed { get; set; }

        /// <summary>
        /// 字段的值范围约束
        /// </summary>
        public RangeConstraint Range { get; set; }

        /// <summary>
        /// 自定义属性
        /// </summary>
        public Dictionary<string, object> CustomProperties { get; set; } = new Dictionary<string, object>();
    }

    /// <summary>
    /// 访问级别
    /// </summary>
    public enum AccessLevel
    {
        /// <summary>
        /// 公共的
        /// </summary>
        Public,

        /// <summary>
        /// 私有的
        /// </summary>
        Private,

        /// <summary>
        /// 保护的
        /// </summary>
        Protected,

        /// <summary>
        /// 内部的
        /// </summary>
        Internal
    }

    /// <summary>
    /// 序列化选项
    /// </summary>
    public class SerializationOptions
    {
        /// <summary>
        /// 是否序列化
        /// </summary>
        public bool Serialize { get; set; } = true;

        /// <summary>
        /// 序列化名称
        /// </summary>
        public string SerializeName { get; set; }

        /// <summary>
        /// 是否忽略默认值
        /// </summary>
        public bool IgnoreDefault { get; set; }

        /// <summary>
        /// 是否忽略空值
        /// </summary>
        public bool IgnoreNull { get; set; }

        /// <summary>
        /// 自定义序列化器类型
        /// </summary>
        public Type CustomSerializer { get; set; }

        /// <summary>
        /// 自定义反序列化器类型
        /// </summary>
        public Type CustomDeserializer { get; set; }
    }


    /// <summary>
    /// 范围约束
    /// </summary>
    public class RangeConstraint
    {
        /// <summary>
        /// 最小值
        /// </summary>
        public object MinValue { get; set; }

        /// <summary>
        /// 最大值
        /// </summary>
        public object MaxValue { get; set; }

        /// <summary>
        /// 是否包含最小值
        /// </summary>
        public bool IncludeMin { get; set; } = true;

        /// <summary>
        /// 是否包含最大值
        /// </summary>
        public bool IncludeMax { get; set; } = true;

        /// <summary>
        /// 错误消息
        /// </summary>
        public string Message { get; set; }
    }
}
