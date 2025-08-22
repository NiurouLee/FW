using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// Schema生成处理器 - 自动分析Excel结构生成FlatBuffer Schema
    /// </summary>
    public class SchemaGeneratorProcessor : IPreProcessor
    {
        // ... [保持其他代码不变，直到 ParseFieldInfo 方法] ...

        /// <summary>
        /// 解析字段信息，包括特殊标记
        /// </summary>
        private SchemaFieldInfo ParseFieldInfo(string columnName, string columnType, string columnDesc, string columnDefault)
        {
            var fieldInfo = new SchemaFieldInfo
            {
                OriginalName = columnName,
                OriginalType = columnType,
                Description = columnDesc,
                DefaultValue = columnDefault
            };

            // ... [保持方法内部代码不变，只替换 FieldInfo 为 SchemaFieldInfo] ...

            return fieldInfo;
        }

        /// <summary>
        /// 处理标记组合，支持多标记同时存在
        /// </summary>
        private void ProcessTagCombination(SchemaFieldInfo fieldInfo, List<string> tags)
        {
            // ... [保持方法内部代码不变] ...
        }

        /// <summary>
        /// 解析字段类型，支持数组、map等复杂类型
        /// </summary>
        private string ParseFieldType(string originalType, SchemaFieldInfo fieldInfo)
        {
            // ... [保持方法内部代码不变] ...
        }

        // ... [保持其他方法不变] ...
    }

    /// <summary>
    /// 字段生成类型
    /// </summary>
    public enum FieldGenerationType
    {
        None,        // @PM - 不生成任何代码
        ClientOnly,  // @Client - 只生成客户端代码
        ServerOnly,  // @Server - 只生成服务端代码
        All          // @All - 生成所有代码
    }

    /// <summary>
    /// Schema字段信息
    /// </summary>
    public class SchemaFieldInfo
    {
        public string OriginalName { get; set; }
        public string CleanName { get; set; }
        public string OriginalType { get; set; }
        public string FbsType { get; set; }
        public string Description { get; set; }
        public string DefaultValue { get; set; }
        public FieldGenerationType GenerationType { get; set; } = FieldGenerationType.All;
        public bool IsLocalization { get; set; }
        public bool IsReference { get; set; }
        public string ReferenceType { get; set; }
        public string TagCombination { get; set; } // 记录所有标记的组合，用于调试

        // 数组相关属性
        public bool IsArray { get; set; }
        public bool Is2DArray { get; set; }
        public string ElementType { get; set; }

        // Map相关属性
        public bool IsMap { get; set; }
        public string KeyType { get; set; }
        public string ValueType { get; set; }

        // 键值对数组
        public bool IsKeyValuePairArray { get; set; }
    }
}