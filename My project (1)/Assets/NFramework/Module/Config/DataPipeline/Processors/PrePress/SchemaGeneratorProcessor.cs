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
        public string Name => "SchemaGenerator";

        public int Priority => 100;

        public bool IsEnabled => true;

        private readonly Dictionary<string, string> _typeMapping = new Dictionary<string, string>
        {
            { "int", "int32" },
            { "long", "int64" },
            { "float", "float32" },
            { "double", "float64" },
            { "bool", "bool" },
            { "string", "string" },
            { "byte", "int8" },
            { "short", "int16" },
            { "uint", "uint32" },
            { "ulong", "uint64" },
            { "ushort", "uint16" },
            { "sbyte", "int8" }
        };

        public bool Process(PreProcessContext context)
        {
            try
            {
                if (context == null || context.CurrentSheet == null)
                {
                    Debug.LogError("SchemaGenerator: Invalid context or data table");
                    return false;
                }

                var schema = new SchemaDefinition
                {
                    Name = context.ConfigName,
                    Namespace = "GameConfig",
                    Description = $"Auto generated schema for {context.ConfigName}"
                };

                // 分析表头
                var headerRow = context.CurrentSheet.Rows[0];
                var typeRow = context.CurrentSheet.Rows[1];
                var descRow = context.CurrentSheet.Rows[2];
                var defaultRow = context.CurrentSheet.Rows[3];

                for (int i = 0; i < context.CurrentSheet.Columns.Count; i++)
                {
                    var columnName = headerRow[i]?.ToString();
                    var columnType = typeRow[i]?.ToString();
                    var columnDesc = descRow[i]?.ToString();
                    var columnDefault = defaultRow[i]?.ToString();

                    if (string.IsNullOrEmpty(columnName) || string.IsNullOrEmpty(columnType))
                        continue;

                    var fieldInfo = ParseFieldInfo(columnName, columnType, columnDesc, columnDefault);
                    ProcessFieldInfo(fieldInfo);

                    if (fieldInfo.GenerationType != FieldGenerationType.None)
                    {
                        var field = new FieldDefinition
                        {
                            Name = fieldInfo.CleanName,
                            Type = fieldInfo.FbsType,
                            Description = fieldInfo.Description,
                            DefaultValue = fieldInfo.DefaultValue,
                            IsArray = fieldInfo.IsArray,
                            IsReference = fieldInfo.IsReference,
                            ReferencedTypeName = fieldInfo.ReferenceType,
                            IsLocalized = fieldInfo.IsLocalization,
                            CustomProperties = new Dictionary<string, object>
                            {
                                { "Is2DArray", fieldInfo.Is2DArray },
                                { "IsMap", fieldInfo.IsMap },
                                { "ElementType", fieldInfo.ElementType },
                                { "KeyType", fieldInfo.KeyType },
                                { "ValueType", fieldInfo.ValueType }
                            }
                        };

                        schema.Fields.Add(field);
                    }
                }

                context.SchemaDefinition = schema;
                return true;
            }
            catch (Exception ex)
            {
                Debug.LogError($"SchemaGenerator: Error processing schema: {ex}");
                return false;
            }
        }

        private void ProcessFieldInfo(SchemaFieldInfo fieldInfo)
        {
            // 清理字段名
            fieldInfo.CleanName = CleanFieldName(fieldInfo.OriginalName);

            // 处理类型标记
            ProcessTypeMarkers(fieldInfo);

            // 转换为FBS类型
            fieldInfo.FbsType = ConvertToFbsType(fieldInfo);
        }

        private string CleanFieldName(string originalName)
        {
            // 移除特殊标记
            var name = originalName.Split(new[] { '@', '#', '$' })[0].Trim();

            // 确保首字母小写
            if (name.Length > 0)
            {
                name = char.ToLowerInvariant(name[0]) + name.Substring(1);
            }

            return name;
        }

        private void ProcessTypeMarkers(SchemaFieldInfo fieldInfo)
        {
            var tags = fieldInfo.OriginalName.Split(new[] { '@', '#', '$' }, StringSplitOptions.RemoveEmptyEntries);
            fieldInfo.TagCombination = string.Join(",", tags);

            foreach (var tag in tags)
            {
                var cleanTag = tag.Trim().ToLower();

                switch (cleanTag)
                {
                    case "pm":
                        fieldInfo.GenerationType = FieldGenerationType.None;
                        break;
                    case "client":
                        fieldInfo.GenerationType = FieldGenerationType.ClientOnly;
                        break;
                    case "server":
                        fieldInfo.GenerationType = FieldGenerationType.ServerOnly;
                        break;
                    case "all":
                        fieldInfo.GenerationType = FieldGenerationType.All;
                        break;
                    case "loc":
                    case "localization":
                        fieldInfo.IsLocalization = true;
                        break;
                    case "ref":
                    case "reference":
                        fieldInfo.IsReference = true;
                        break;
                }
            }
        }

        private string ConvertToFbsType(SchemaFieldInfo fieldInfo)
        {
            var baseType = fieldInfo.OriginalType.ToLower();

            // 检查是否是数组类型
            if (baseType.EndsWith("[][]"))
            {
                fieldInfo.Is2DArray = true;
                fieldInfo.IsArray = true;
                baseType = baseType.Replace("[][]", "");
                fieldInfo.ElementType = GetFbsBaseType(baseType);
                return $"[{fieldInfo.ElementType}]";
            }
            else if (baseType.EndsWith("[]"))
            {
                fieldInfo.IsArray = true;
                baseType = baseType.Replace("[]", "");
                fieldInfo.ElementType = GetFbsBaseType(baseType);
                return $"[{fieldInfo.ElementType}]";
            }

            // 检查是否是Map类型
            if (baseType.StartsWith("map<") && baseType.EndsWith(">"))
            {
                fieldInfo.IsMap = true;
                var types = baseType.Substring(4, baseType.Length - 5).Split(',');
                if (types.Length == 2)
                {
                    fieldInfo.KeyType = GetFbsBaseType(types[0].Trim());
                    fieldInfo.ValueType = GetFbsBaseType(types[1].Trim());
                    return $"map<{fieldInfo.KeyType},{fieldInfo.ValueType}>";
                }
            }

            // 检查是否是键值对数组
            if (baseType.StartsWith("kvp<") && baseType.EndsWith(">"))
            {
                fieldInfo.IsKeyValuePairArray = true;
                var types = baseType.Substring(4, baseType.Length - 5).Split(',');
                if (types.Length == 2)
                {
                    fieldInfo.KeyType = GetFbsBaseType(types[0].Trim());
                    fieldInfo.ValueType = GetFbsBaseType(types[1].Trim());
                    return $"[KeyValuePair<{fieldInfo.KeyType},{fieldInfo.ValueType}>]";
                }
            }

            return GetFbsBaseType(baseType);
        }

        private string GetFbsBaseType(string type)
        {
            type = type.ToLower().Trim();
            if (_typeMapping.TryGetValue(type, out var fbsType))
            {
                return fbsType;
            }
            return type; // 如果找不到映射，返回原始类型
        }

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

            return fieldInfo;
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