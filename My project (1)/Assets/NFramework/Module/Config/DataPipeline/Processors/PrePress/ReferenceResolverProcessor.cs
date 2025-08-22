using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 引用解析处理器 - 处理配置之间的引用关系
    /// </summary>
    public class ReferenceResolverProcessor : IPreProcessor
    {
        public string Name => "Reference Resolver";
        public int Priority => PrePressPriority.ReferenceResolver;
        public bool IsEnabled { get; set; } = true;

        private readonly ReferenceSettings _settings;

        public ReferenceResolverProcessor(ReferenceSettings settings = null)
        {
            _settings = settings ?? new ReferenceSettings();
        }

        public bool Process(PreProcessContext context)
        {
            try
            {
                context.AddLog("开始处理引用字段");

                if (context.SchemaDefinition == null)
                {
                    context.AddError("Schema定义为空，无法处理引用字段");
                    return false;
                }

                // 获取所有引用字段
                var referenceFields = context.SchemaDefinition.Fields
                    .Where(f => !string.IsNullOrEmpty(f.ReferencedTypeName))
                    .ToList();

                if (referenceFields.Count == 0)
                {
                    context.AddLog("没有找到需要处理的引用字段");
                    return true;
                }

                context.AddLog($"找到 {referenceFields.Count} 个引用字段需要处理");

                // 处理每个引用字段
                foreach (var field in referenceFields)
                {
                    ProcessReferenceField(field, context);
                }

                // 验证引用完整性
                if (_settings.ValidateReferences)
                {
                    ValidateReferences(context);
                }

                // 处理循环引用
                if (_settings.ResolveCircularReferences)
                {
                    DetectCircularReferences(context);
                }

                context.AddLog("引用字段处理完成");
                return true;
            }
            catch (Exception ex)
            {
                context.AddError($"引用字段处理失败: {ex.Message}");
                return false;
            }
        }

        private void ProcessReferenceField(FieldDefinition field, PreProcessContext context)
        {
            try
            {
                var columnIndex = FindColumnIndex(context.CurrentSheet, field.Name);
                if (columnIndex < 0)
                {
                    context.AddError($"找不到引用字段的列: {field.Name}");
                    return;
                }

                // 记录引用关系
                RecordReferenceRelation(field, context);

                // 添加引用解析列
                AddReferenceColumn(context.CurrentSheet, field, columnIndex, context);
            }
            catch (Exception ex)
            {
                context.AddError($"处理引用字段 {field.Name} 失败: {ex.Message}");
            }
        }

        private int FindColumnIndex(DataTable table, string columnName)
        {
            for (int i = 0; i < table.Columns.Count; i++)
            {
                if (table.Columns[i].ColumnName.Equals(columnName, StringComparison.OrdinalIgnoreCase))
                {
                    return i;
                }
            }
            return -1;
        }

        private void AddReferenceColumn(DataTable table, FieldDefinition field, int sourceColumnIndex, PreProcessContext context)
        {
            try
            {
                // 添加新的引用列，使用引用类型作为前缀
                var refColumnName = $"Ref_{field.ReferencedTypeName}_{field.Name}";
                if (!table.Columns.Contains(refColumnName))
                {
                    table.Columns.Add(refColumnName, typeof(string));

                    // 为新列填充数据
                    for (int row = 1; row < table.Rows.Count; row++) // 跳过类型行
                    {
                        var sourceValue = table.Rows[row][sourceColumnIndex];
                        if (sourceValue != null && sourceValue != DBNull.Value)
                        {
                            var refId = sourceValue.ToString();
                            if (!string.IsNullOrEmpty(refId))
                            {
                                table.Rows[row][refColumnName] = $"{field.ReferencedTypeName}:{refId}";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                context.AddError($"添加引用列失败: {ex.Message}");
            }
        }

        private void RecordReferenceRelation(FieldDefinition field, PreProcessContext context)
        {
            if (!context.Properties.ContainsKey("ReferenceRelations"))
            {
                context.Properties["ReferenceRelations"] = new Dictionary<string, List<ReferenceRelation>>();
            }

            var relations = (Dictionary<string, List<ReferenceRelation>>)context.Properties["ReferenceRelations"];

            if (!relations.ContainsKey(field.ReferencedTypeName))
            {
                relations[field.ReferencedTypeName] = new List<ReferenceRelation>();
            }

            relations[field.ReferencedTypeName].Add(new ReferenceRelation
            {
                SourceField = field.Name,
                SourceTable = context.ConfigName,
                TargetType = field.ReferencedTypeName,
                IsRequired = field.IsRequired
            });
        }

        private void ValidateReferences(PreProcessContext context)
        {
            try
            {
                if (!context.Properties.ContainsKey("ReferenceRelations"))
                {
                    return;
                }

                var relations = (Dictionary<string, List<ReferenceRelation>>)context.Properties["ReferenceRelations"];

                foreach (var kvp in relations)
                {
                    var targetType = kvp.Key;
                    var relationList = kvp.Value;

                    context.AddLog($"验证引用类型: {targetType}, 共有 {relationList.Count} 个引用");

                    // 验证目标类型是否存在
                    if (!context.ValidConfigTypes.Contains(targetType))
                    {
                        context.AddWarning($"引用的目标类型 {targetType} 不在已知的配置类型中");
                    }

                    // 验证必需引用字段
                    foreach (var relation in relationList.Where(r => r.IsRequired))
                    {
                        ValidateRequiredReference(relation, context);
                    }
                }
            }
            catch (Exception ex)
            {
                context.AddError($"引用验证失败: {ex.Message}");
            }
        }

        private void ValidateRequiredReference(ReferenceRelation relation, PreProcessContext context)
        {
            // 这里可以添加更多的验证逻辑
            // 例如：检查引用的ID是否在目标表中存在
            context.AddLog($"验证必需引用: {relation.SourceTable}.{relation.SourceField} -> {relation.TargetType}");
        }

        private void DetectCircularReferences(PreProcessContext context)
        {
            try
            {
                if (!context.Properties.ContainsKey("ReferenceRelations"))
                {
                    return;
                }

                var relations = (Dictionary<string, List<ReferenceRelation>>)context.Properties["ReferenceRelations"];
                var visited = new HashSet<string>();
                var recursionStack = new HashSet<string>();

                foreach (var kvp in relations)
                {
                    var sourceType = kvp.Key;
                    if (!visited.Contains(sourceType))
                    {
                        var path = new List<string>();
                        if (HasCircularReference(sourceType, relations, visited, recursionStack, path))
                        {
                            context.AddWarning($"检测到循环引用: {string.Join(" -> ", path)} -> {path[0]}");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                context.AddError($"循环引用检测失败: {ex.Message}");
            }
        }

        private bool HasCircularReference(
            string current,
            Dictionary<string, List<ReferenceRelation>> relations,
            HashSet<string> visited,
            HashSet<string> recursionStack,
            List<string> path)
        {
            visited.Add(current);
            recursionStack.Add(current);
            path.Add(current);

            if (relations.TryGetValue(current, out var deps))
            {
                foreach (var dep in deps.Select(r => r.TargetType).Distinct())
                {
                    if (!visited.Contains(dep))
                    {
                        if (HasCircularReference(dep, relations, visited, recursionStack, path))
                            return true;
                    }
                    else if (recursionStack.Contains(dep))
                    {
                        path.Add(dep);
                        return true;
                    }
                }
            }

            recursionStack.Remove(current);
            path.RemoveAt(path.Count - 1);
            return false;
        }
    }

    /// <summary>
    /// 引用关系信息
    /// </summary>
    public class ReferenceRelation
    {
        public string SourceField { get; set; }
        public string SourceTable { get; set; }
        public string TargetType { get; set; }
        public bool IsRequired { get; set; }
    }
}