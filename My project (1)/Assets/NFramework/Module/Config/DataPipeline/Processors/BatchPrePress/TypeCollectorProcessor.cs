using System;
using System.Collections.Generic;
using System.Data;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 类型收集器 - 负责从配置文件中收集类型信息
    /// </summary>
    public class TypeCollectorProcessor : ICollector
    {
        public string Name => "Type Collector";
        public int Priority => 100;
        public bool IsEnabled { get; set; } = true;

        public bool Collect(CollectionContext context)
        {
            try
            {
                var typeInfo = new TypeInfo
                {
                    ConfigName = context.ConfigName,
                    ConfigType = context.ConfigType
                };

                // 从DataSet中收集类型信息
                if (context.RawDataSet?.Tables.Count > 0)
                {
                    var mainTable = context.RawDataSet.Tables[0];
                    CollectFromDataTable(mainTable, typeInfo);
                }

                // 将收集到的类型信息存储在上下文中
                context.CollectedData["TypeInfo"] = typeInfo;
                return true;
            }
            catch (Exception ex)
            {
                context.AddError($"Failed to collect type information: {ex.Message}");
                return false;
            }
        }

        private void CollectFromDataTable(DataTable table, TypeInfo typeInfo)
        {
            if (table.Rows.Count < 2) // 至少需要表头和一行数据
            {
                return;
            }

            // 假设第一行是字段名，第二行是类型
            for (int i = 0; i < table.Columns.Count; i++)
            {
                var fieldName = table.Columns[i].ColumnName;
                var fieldType = table.Rows[0][i].ToString(); // 类型行

                typeInfo.Fields.Add(new FieldInfo
                {
                    Name = fieldName,
                    Type = fieldType,
                    IsArray = fieldType.Contains("[]"),
                    IsRequired = !fieldType.EndsWith("?")
                });
            }
        }
    }

    /// <summary>
    /// 类型批处理器 - 负责处理所有收集到的类型信息
    /// </summary>
    public class TypeBatchProcessor : IBatchProcessor
    {
        public string Name => "Type Batch Processor";
        public int Priority => 100;
        public bool IsEnabled { get; set; } = true;

        public bool ProcessBatch(BatchProcessContext context)
        {
            try
            {
                var allTypes = new Dictionary<string, TypeInfo>();

                // 收集所有类型信息
                foreach (var kvp in context.CollectedContexts)
                {
                    if (kvp.Value.CollectedData.TryGetValue("TypeInfo", out var typeInfoObj) &&
                        typeInfoObj is TypeInfo typeInfo)
                    {
                        allTypes[kvp.Key] = typeInfo;
                    }
                }

                // 处理类型之间的关系
                foreach (var typeInfo in allTypes.Values)
                {
                    ProcessTypeRelations(typeInfo, allTypes);
                }

                // 生成Schema定义
                foreach (var kvp in allTypes)
                {
                    var schemaDefinition = GenerateSchemaDefinition(kvp.Value);
                    context.SharedData[$"{kvp.Key}_Schema"] = schemaDefinition;
                }

                return true;
            }
            catch (Exception ex)
            {
                context.AddError($"Failed to process types in batch: {ex.Message}");
                return false;
            }
        }

        private void ProcessTypeRelations(TypeInfo typeInfo, Dictionary<string, TypeInfo> allTypes)
        {
            foreach (var field in typeInfo.Fields)
            {
                // 检查字段类型是否引用了其他配置类型
                var baseType = field.IsArray ? field.Type.Replace("[]", "") : field.Type;
                if (allTypes.ContainsKey(baseType))
                {
                    field.ReferencedType = allTypes[baseType];
                }
            }
        }

        private SchemaDefinition GenerateSchemaDefinition(TypeInfo typeInfo)
        {
            var schema = new SchemaDefinition
            {
                TypeName = typeInfo.ConfigName,
                Namespace = "Generated.Config"
            };

            foreach (var field in typeInfo.Fields)
            {
                schema.Fields.Add(new FieldDefinition
                {
                    Name = field.Name,
                    Type = field.Type,
                    IsArray = field.IsArray,
                    IsRequired = field.IsRequired,
                    ReferencedTypeName = field.ReferencedType?.ConfigName
                });
            }

            return schema;
        }
    }

    /// <summary>
    /// 类型信息
    /// </summary>
    public class TypeInfo
    {
        public string ConfigName { get; set; }
        public string ConfigType { get; set; }
        public List<FieldInfo> Fields { get; } = new List<FieldInfo>();
    }

    /// <summary>
    /// 字段信息
    /// </summary>
    public class FieldInfo
    {
        public string Name { get; set; }
        public string Type { get; set; }
        public bool IsArray { get; set; }
        public bool IsRequired { get; set; }
        public TypeInfo ReferencedType { get; set; }
    }
}