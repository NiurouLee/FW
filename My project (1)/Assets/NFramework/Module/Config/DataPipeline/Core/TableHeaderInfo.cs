using System;
using System.Collections.Generic;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 表头信息 - 用于存储Excel表格的表头结构信息
    /// </summary>
    public class TableHeaderInfo
    {
        /// <summary>
        /// 表名
        /// </summary>
        public string TableName { get; set; }

        /// <summary>
        /// 所有有效的列（包括@PM标记的列）
        /// </summary>
        public List<ColumnInfo> ValidColumns { get; } = new List<ColumnInfo>();

        /// <summary>
        /// 需要处理的列（不包括@PM标记的列）
        /// </summary>
        public List<ColumnInfo> ProcessableColumns { get; } = new List<ColumnInfo>();

        /// <summary>
        /// 表的元数据
        /// </summary>
        public Dictionary<string, object> Metadata { get; } = new Dictionary<string, object>();

        /// <summary>
        /// 表的警告信息
        /// </summary>
        public List<string> Warnings { get; } = new List<string>();

        /// <summary>
        /// 表的错误信息
        /// </summary>
        public List<string> Errors { get; } = new List<string>();
    }

    /// <summary>
    /// 列信息 - 用于存储单个列的详细信息
    /// </summary>
    public class ColumnInfo
    {
        /// <summary>
        /// 列索引
        /// </summary>
        public int ColumnIndex { get; set; }

        /// <summary>
        /// 原始字段名（包含标记）
        /// </summary>
        public string FieldName { get; set; }

        /// <summary>
        /// 清理后的字段名（不含标记）
        /// </summary>
        public string CleanFieldName { get; set; }

        /// <summary>
        /// 原始字段类型
        /// </summary>
        public string FieldType { get; set; }

        /// <summary>
        /// 解析后的字段类型
        /// </summary>
        public string ParsedType { get; set; }

        /// <summary>
        /// 字段描述
        /// </summary>
        public string FieldDescription { get; set; }

        /// <summary>
        /// 字段默认值
        /// </summary>
        public string FieldDefault { get; set; }

        /// <summary>
        /// 生成类型
        /// </summary>
        public FieldGenerationType GenerationType { get; set; } = FieldGenerationType.All;

        /// <summary>
        /// 是否为本地化字段
        /// </summary>
        public bool IsLocalization { get; set; }

        /// <summary>
        /// 是否为引用字段
        /// </summary>
        public bool IsReference { get; set; }

        /// <summary>
        /// 引用的类型（如果是引用字段）
        /// </summary>
        public string ReferenceType { get; set; }

        /// <summary>
        /// 是否为数组
        /// </summary>
        public bool IsArray { get; set; }

        /// <summary>
        /// 数组元素类型（如果是数组）
        /// </summary>
        public string ElementType { get; set; }

        /// <summary>
        /// 是否为Map类型
        /// </summary>
        public bool IsMap { get; set; }

        /// <summary>
        /// Map的键类型（如果是Map）
        /// </summary>
        public string KeyType { get; set; }

        /// <summary>
        /// Map的值类型（如果是Map）
        /// </summary>
        public string ValueType { get; set; }

        /// <summary>
        /// 是否为键值对数组
        /// </summary>
        public bool IsKeyValuePairArray { get; set; }

        /// <summary>
        /// 列的警告信息
        /// </summary>
        public List<string> Warnings { get; } = new List<string>();

        /// <summary>
        /// 列的错误信息
        /// </summary>
        public List<string> Errors { get; } = new List<string>();

        /// <summary>
        /// 列的元数据
        /// </summary>
        public Dictionary<string, object> Metadata { get; } = new Dictionary<string, object>();
    }
}
