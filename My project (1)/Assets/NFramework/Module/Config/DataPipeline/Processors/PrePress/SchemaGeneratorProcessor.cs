using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using NFramework.Module.Config.DataPipeline.Core;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline.Processors
{
    /// <summary>
    /// Schema生成处理器 - 自动分析Excel结构生成FlatBuffer Schema
    /// </summary>
    public class SchemaGeneratorProcessor : IPreProcessor
    {
        public string Name => "Schema Generator";
        public int Priority => PrePressPriority.SchemaGenerator; // 高优先级，需要最先执行
        public bool IsEnabled { get; set; } = true;

        public bool Process(PreProcessContext context)
        {
            try
            {
                context.AddLog("开始生成Schema定义");

                if (context.RawDataSet?.Tables == null || context.RawDataSet.Tables.Count == 0)
                {
                    context.AddError("没有找到可用的数据表");
                    return false;
                }

                // 取第一个表作为主数据表
                var mainTable = context.RawDataSet.Tables[0];
                context.CurrentSheet = mainTable;

                // 生成Schema定义
                var schema = GenerateSchemaFromTable(mainTable, context.ConfigType);
                context.SchemaDefinition = schema;

                context.AddLog($"成功生成Schema定义，包含 {schema.Fields.Count} 个字段");
                return true;
            }
            catch (Exception ex)
            {
                context.AddError($"生成Schema失败: {ex.Message}");
                return false;
            }
        }

        private SchemaDefinition GenerateSchemaFromTable(DataTable table, string configType)
        {
            var schema = new SchemaDefinition
            {
                Name = configType,
                Namespace = "GameConfig"
            };

            if (table.Rows.Count < 4)
            {
                throw new InvalidOperationException("数据表至少需要包含4行：字段名、字段类型、字段描述、字段默认值");
            }

            // 按照需求.txt的格式：第一行为字段名字，第二行为字段类型，第三行为字段描述，第四行为字段默认值
            var fieldNameRow = table.Rows[0];      // 第一行：字段名
            var fieldTypeRow = table.Rows[1];      // 第二行：字段类型
            var fieldDescRow = table.Rows[2];      // 第三行：字段描述
            var fieldDefaultRow = table.Rows[3];   // 第四行：字段默认值

            for (int i = 0; i < table.Columns.Count; i++)
            {
                var columnName = fieldNameRow[i]?.ToString()?.Trim();
                var columnType = fieldTypeRow[i]?.ToString()?.Trim();
                var columnDesc = fieldDescRow[i]?.ToString()?.Trim();
                var columnDefault = fieldDefaultRow[i]?.ToString()?.Trim();

                if (string.IsNullOrEmpty(columnName))
                {
                    continue;
                }

                // 解析字段标记
                var fieldInfo = ParseFieldInfo(columnName, columnType, columnDesc, columnDefault);

                // 如果标记为@PM（不生成任何代码），则跳过
                if (fieldInfo.GenerationType == FieldGenerationType.None)
                {
                    continue;
                }

                var field = new FieldDefinition
                {
                    Name = fieldInfo.CleanName,
                    Type = fieldInfo.FbsType,
                    IsRequired = !string.IsNullOrEmpty(columnDefault) ? false : IsFieldRequired(table, i, 4), // 从第5行开始检查数据
                    Comment = columnDesc,
                    DefaultValue = ParseDefaultValue(columnDefault, fieldInfo.FbsType)
                };

                // 添加字段特殊属性
                field.Attributes["generation_type"] = fieldInfo.GenerationType.ToString();
                field.Attributes["original_name"] = columnName;
                field.Attributes["original_type"] = columnType;
                field.Attributes["tag_combination"] = fieldInfo.TagCombination ?? "";

                if (fieldInfo.IsLocalization)
                {
                    field.Attributes["localization"] = true;
                }

                if (fieldInfo.IsReference)
                {
                    field.Attributes["reference"] = true;
                    field.Attributes["reference_type"] = fieldInfo.ReferenceType;
                }

                if (IsIdField(fieldInfo.CleanName))
                {
                    field.Attributes["key"] = true;
                }

                if (IsArrayField(fieldInfo.FbsType))
                {
                    field.Attributes["separator"] = DetectArraySeparator(table, i, 4);
                }

                schema.Fields.Add(field);

                // 如果是引用字段，添加额外的引用字段
                if (fieldInfo.IsReference)
                {
                    var refField = new FieldDefinition
                    {
                        Name = $"Ref{fieldInfo.ReferenceType}",
                        Type = fieldInfo.ReferenceType,
                        IsRequired = false,
                        Comment = $"引用字段：{columnDesc}"
                    };
                    refField.Attributes["generated_reference"] = true;
                    refField.Attributes["source_field"] = fieldInfo.CleanName;
                    schema.Fields.Add(refField);
                }
            }

            return schema;
        }

        private string InferFieldType(object sampleValue, DataTable table, int columnIndex)
        {
            if (sampleValue == null || sampleValue == DBNull.Value)
            {
                // 检查其他行来推断类型
                for (int row = 2; row < System.Math.Min(table.Rows.Count, 10); row++)
                {
                    var value = table.Rows[row][columnIndex];
                    if (value != null && value != DBNull.Value)
                    {
                        sampleValue = value;
                        break;
                    }
                }
            }

            if (sampleValue == null || sampleValue == DBNull.Value)
            {
                return "string"; // 默认类型
            }

            var valueStr = sampleValue.ToString();

            // 检查是否为数组（包含分隔符）
            if (ContainsArraySeparator(valueStr))
            {
                var elementType = InferArrayElementType(valueStr);
                return $"[{elementType}]";
            }

            // 基本类型推断
            if (bool.TryParse(valueStr, out _))
                return "bool";

            if (int.TryParse(valueStr, out _))
                return "int";

            if (long.TryParse(valueStr, out _))
                return "long";

            if (float.TryParse(valueStr, out _))
                return "float";

            if (double.TryParse(valueStr, out _))
                return "double";

            // 检查是否为枚举（通过命名约定）
            if (IsEnumField(valueStr))
                return "int"; // 枚举在FlatBuffer中用int表示

            return "string";
        }

        private bool ContainsArraySeparator(string value)
        {
            if (string.IsNullOrEmpty(value))
                return false;

            var separators = new[] { ",", ";", "|", ":" };
            return separators.Any(sep => value.Contains(sep));
        }

        private string InferArrayElementType(string arrayValue)
        {
            var separators = new[] { ",", ";", "|", ":" };
            string[] elements = null;

            foreach (var sep in separators)
            {
                if (arrayValue.Contains(sep))
                {
                    elements = arrayValue.Split(new[] { sep }, StringSplitOptions.RemoveEmptyEntries);
                    break;
                }
            }

            if (elements == null || elements.Length == 0)
                return "string";

            var firstElement = elements[0].Trim();

            if (int.TryParse(firstElement, out _))
                return "int";
            if (float.TryParse(firstElement, out _))
                return "float";
            if (bool.TryParse(firstElement, out _))
                return "bool";

            return "string";
        }

        private string DetectArraySeparator(DataTable table, int columnIndex, int startRow = 1)
        {
            var separators = new[] { ",", ";", "|", ":" };

            for (int row = startRow; row < System.Math.Min(table.Rows.Count, startRow + 10); row++)
            {
                var value = table.Rows[row][columnIndex]?.ToString();
                if (!string.IsNullOrEmpty(value))
                {
                    foreach (var sep in separators)
                    {
                        if (value.Contains(sep))
                            return sep;
                    }
                }
            }

            return ","; // 默认分隔符
        }

        private bool IsFieldRequired(DataTable table, int columnIndex, int startRow = 1)
        {
            int nullCount = 0;
            int totalCount = 0;

            for (int row = startRow; row < table.Rows.Count; row++)
            {
                var value = table.Rows[row][columnIndex];
                totalCount++;

                if (value == null || value == DBNull.Value || string.IsNullOrWhiteSpace(value.ToString()))
                {
                    nullCount++;
                }
            }

            // 如果超过50%的值为空，则认为不是必需字段
            return totalCount > 0 && (nullCount / (double)totalCount) < 0.5;
        }

        private bool IsIdField(string fieldName)
        {
            var idPatterns = new[] { "id", "ID", "Id", "key", "Key", "KEY" };
            return idPatterns.Any(pattern =>
                fieldName.Equals(pattern, StringComparison.OrdinalIgnoreCase) ||
                fieldName.EndsWith(pattern, StringComparison.OrdinalIgnoreCase));
        }

        private bool IsArrayField(string fieldType)
        {
            return fieldType.StartsWith("[") && fieldType.EndsWith("]");
        }

        private bool IsEnumField(string value)
        {
            // 简单的枚举检测逻辑，可以根据需要扩展
            if (string.IsNullOrEmpty(value))
                return false;

            // 检查是否包含典型的枚举值特征
            var enumPatterns = new[] { "Type", "Status", "State", "Mode", "Level" };
            return enumPatterns.Any(pattern => value.Contains(pattern));
        }

        private string SanitizeFieldName(string fieldName)
        {
            if (string.IsNullOrEmpty(fieldName))
                return "UnknownField";

            // 移除特殊字符，只保留字母数字和下划线
            var sanitized = System.Text.RegularExpressions.Regex.Replace(fieldName, @"[^a-zA-Z0-9_]", "");

            // 确保以字母开头
            if (char.IsDigit(sanitized[0]))
            {
                sanitized = "Field_" + sanitized;
            }

            return sanitized;
        }

        /// <summary>
        /// 解析字段信息，包括特殊标记
        /// </summary>
        private FieldInfo ParseFieldInfo(string columnName, string columnType, string columnDesc, string columnDefault)
        {
            var fieldInfo = new FieldInfo
            {
                OriginalName = columnName,
                OriginalType = columnType,
                Description = columnDesc,
                DefaultValue = columnDefault
            };

            // 解析字段名中的标记
            var cleanName = columnName;

            if (columnName.Contains("@"))
            {
                var parts = columnName.Split('@');
                cleanName = parts[0].Trim();

                // 收集所有标记
                var tags = new List<string>();
                for (int i = 1; i < parts.Length; i++)
                {
                    var tag = parts[i].Trim().ToUpper();
                    if (!string.IsNullOrEmpty(tag))
                    {
                        tags.Add(tag);
                    }
                }

                // 处理标记组合
                ProcessTagCombination(fieldInfo, tags);
            }

            fieldInfo.CleanName = SanitizeFieldName(cleanName);

            // 解析类型信息
            fieldInfo.FbsType = ParseFieldType(columnType, fieldInfo);

            return fieldInfo;
        }

        /// <summary>
        /// 处理标记组合，支持多标记同时存在
        /// </summary>
        private void ProcessTagCombination(FieldInfo fieldInfo, List<string> tags)
        {
            // 优先级：PM > 具体生成类型 > ALL
            // 功能标记（LAN, REF）可以与生成类型标记组合

            foreach (var tag in tags)
            {
                switch (tag)
                {
                    case "PM":
                        fieldInfo.GenerationType = FieldGenerationType.None;
                        // PM标记优先级最高，直接返回
                        return;

                    case "LAN":
                        fieldInfo.IsLocalization = true;
                        break;

                    case "REF":
                        fieldInfo.IsReference = true;
                        break;
                }
            }

            // 处理生成类型标记（如果没有PM标记）
            if (fieldInfo.GenerationType != FieldGenerationType.None)
            {
                // 检查是否有具体的生成类型标记
                if (tags.Contains("CLIENT"))
                {
                    fieldInfo.GenerationType = FieldGenerationType.ClientOnly;
                }
                else if (tags.Contains("SERVER"))
                {
                    fieldInfo.GenerationType = FieldGenerationType.ServerOnly;
                }
                else if (tags.Contains("ALL"))
                {
                    fieldInfo.GenerationType = FieldGenerationType.All;
                }
                // 如果没有指定生成类型，默认为All
                else if (fieldInfo.IsLocalization || fieldInfo.IsReference)
                {
                    fieldInfo.GenerationType = FieldGenerationType.All;
                }
            }

            // 记录标记组合信息，用于调试和验证
            fieldInfo.TagCombination = string.Join(",", tags);
        }

        /// <summary>
        /// 解析字段类型，支持数组、map等复杂类型
        /// </summary>
        private string ParseFieldType(string originalType, FieldInfo fieldInfo)
        {
            if (string.IsNullOrEmpty(originalType))
                return "string";

            var type = originalType.Trim().ToLower();

            // 处理引用类型
            if (fieldInfo.IsReference)
            {
                // 从类型中提取引用的目标类型
                fieldInfo.ReferenceType = ExtractReferenceType(type);
                return "int"; // 引用字段存储为ID
            }

            // 处理数组类型 (repeated type 或 type[])
            if (type.StartsWith("repeated ") || type.Contains("[]"))
            {
                var elementType = type.StartsWith("repeated ")
                    ? type.Substring("repeated ".Length).Trim()
                    : type.Replace("[]", "").Trim();

                // 检查是否为二维数组
                if (elementType.StartsWith("repeated ") || elementType.Contains("[]"))
                {
                    // 二维数组：repeated repeated int 或 int[][]
                    var innerElementType = elementType.StartsWith("repeated ")
                        ? elementType.Substring("repeated ".Length).Trim()
                        : elementType.Replace("[]", "").Trim();

                    fieldInfo.Is2DArray = true;
                    fieldInfo.ElementType = ConvertBasicType(innerElementType);
                    return $"[[{fieldInfo.ElementType}]]"; // 使用双括号表示二维数组
                }
                else
                {
                    // 一维数组
                    fieldInfo.IsArray = true;
                    fieldInfo.ElementType = ConvertBasicType(elementType);
                    return $"[{fieldInfo.ElementType}]";
                }
            }

            // 处理Map类型 (map<key,value>)
            if (type.StartsWith("map<") && type.EndsWith(">"))
            {
                var mapContent = type.Substring(4, type.Length - 5); // 移除 "map<" 和 ">"
                var keyValue = mapContent.Split(',');
                if (keyValue.Length == 2)
                {
                    var keyType = ConvertBasicType(keyValue[0].Trim());
                    var valueType = ConvertBasicType(keyValue[1].Trim());
                    return $"[{keyType}_{valueType}_Pair]"; // FlatBuffer中用数组表示map
                }
            }

            // 处理键值对数组 (例如: KeyValuePair<int,string>[])
            if (type.Contains("keyvaluepair") || type.Contains("kvp"))
            {
                // 简化处理，返回通用的键值对数组类型
                return "[KeyValuePair]";
            }

            // 基本类型转换
            return ConvertBasicType(type);
        }

        /// <summary>
        /// 转换基本类型
        /// </summary>
        private string ConvertBasicType(string type)
        {
            return type switch
            {
                "int" or "integer" => "int",
                "long" => "long",
                "float" => "float",
                "double" => "double",
                "bool" or "boolean" => "bool",
                "string" or "text" => "string",
                "short" => "short",
                "ushort" => "ushort",
                "uint" => "uint",
                "ulong" => "ulong",
                "byte" => "byte",
                "sbyte" => "sbyte",
                _ => "string" // 默认类型
            };
        }

        /// <summary>
        /// 从类型字符串中提取引用类型
        /// </summary>
        private string ExtractReferenceType(string type)
        {
            // 简单的引用类型提取，可以根据需要扩展
            if (type.Contains("config") || type.Contains("table"))
            {
                return type.Replace("config", "").Replace("table", "").Trim();
            }

            return type;
        }

        /// <summary>
        /// 解析默认值
        /// </summary>
        private object ParseDefaultValue(string defaultValue, string fieldType)
        {
            if (string.IsNullOrEmpty(defaultValue))
                return null;

            try
            {
                return fieldType switch
                {
                    "bool" => bool.Parse(defaultValue),
                    "int" => int.Parse(defaultValue),
                    "long" => long.Parse(defaultValue),
                    "float" => float.Parse(defaultValue),
                    "double" => double.Parse(defaultValue),
                    _ => defaultValue
                };
            }
            catch
            {
                return defaultValue; // 解析失败时返回原始字符串
            }
        }
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
    /// 字段信息
    /// </summary>
    public class FieldInfo
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
