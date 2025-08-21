using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using NFramework.Module.Config.DataPipeline.Core;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline.Processors
{
    /// <summary>
    /// 引用解析处理器 - 处理@Ref标记的字段，生成引用属性
    /// </summary>
    public class ReferenceResolverProcessor : IPreProcessor
    {
        public string Name => "Reference Resolver Processor";
        public int Priority => PrePressPriority.ReferenceResolver; // 在Schema生成之后，本地化处理之前
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

                var referenceFields = context.SchemaDefinition.Fields
                    .Where(f => f.Attributes.ContainsKey("reference") && (bool)f.Attributes["reference"])
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

                context.AddLog("引用字段处理完成");
                return true;
            }
            catch (Exception ex)
            {
                context.AddError($"引用字段处理失败: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// 处理单个引用字段
        /// </summary>
        private void ProcessReferenceField(FieldDefinition field, PreProcessContext context)
        {
            try
            {
                // 获取列索引和引用类型
                var (columnIndex, refType) = FindColumnIndexAndRefType(context.CurrentSheet, field.Name);
                
                if (string.IsNullOrEmpty(refType))
                {
                    context.AddWarning($"引用字段 {field.Name} 没有指定引用类型 (@ref type)");
                    return;
                }

                context.AddLog($"处理引用字段: {field.Name} -> 引用类型: {refType}");

                // 在数据表中添加引用解析逻辑
                if (context.CurrentSheet != null)
                {
                    AddReferenceColumn(context.CurrentSheet, field, refType, context);
                }

                // 记录引用关系
                RecordReferenceRelation(field, refType, context);
            }
            catch (Exception ex)
            {
                context.AddError($"处理引用字段 {field.Name} 失败: {ex.Message}");
            }
        }

        /// <summary>
        /// 在数据表中添加引用列
        /// </summary>
        private void AddReferenceColumn(DataTable table, FieldDefinition field, string refType, PreProcessContext context)
        {
            try
            {
                var sourceColumnName = field.Attributes["original_name"]?.ToString() ?? field.Name;
                var (sourceColumnIndex, _) = FindColumnIndexAndRefType(table, sourceColumnName);

                if (sourceColumnIndex < 0)
                {
                    context.AddError($"找不到引用字段的源列: {sourceColumnName}");
                    return;
                }

                // 添加新的引用列，使用引用类型作为前缀
                var refColumnName = $"Ref_{refType}_{field.Name}";
                if (!table.Columns.Contains(refColumnName))
                {
                    table.Columns.Add(refColumnName, typeof(object));

                    // 为新列填充数据
                    PopulateReferenceColumn(table, sourceColumnIndex, table.Columns.Count - 1, refType, context);
                }
            }
            catch (Exception ex)
            {
                context.AddError($"添加引用列失败: {ex.Message}");
            }
        }

        /// <summary>
        /// 填充引用列数据
        /// </summary>
        private void PopulateReferenceColumn(DataTable table, int sourceColumnIndex, int refColumnIndex,
            string refType, PreProcessContext context)
        {
            try
            {
                // 从第5行开始处理数据（跳过前4行的头信息）
                for (int row = 4; row < table.Rows.Count; row++)
                {
                    var sourceValue = table.Rows[row][sourceColumnIndex];
                    if (sourceValue != null && sourceValue != DBNull.Value)
                    {
                        var refId = sourceValue.ToString();
                        if (!string.IsNullOrEmpty(refId))
                        {
                            // 存储引用信息，包含引用类型和ID
                            // 这里的引用ID将用于在运行时查找对应类型表中的具体行
                            table.Rows[row][refColumnIndex] = $"{refType}:{refId}";
                        }
                    }
                }

                context.AddLog($"已填充引用列 {refType}，共处理 {table.Rows.Count - 4} 行数据");
            }
            catch (Exception ex)
            {
                context.AddError($"填充引用列数据失败: {ex.Message}");
            }
        }

        /// <summary>
        /// 查找列索引
        /// </summary>
        /// <summary>
        /// 查找列索引并解析引用类型
        /// </summary>
        private (int index, string refType) FindColumnIndexAndRefType(DataTable table, string columnName)
        {
            if (table.Rows.Count == 0) return (-1, null);

            var headerRow = table.Rows[0];
            for (int i = 0; i < headerRow.ItemArray.Length; i++)
            {
                var cellValue = headerRow[i]?.ToString()?.Trim();
                if (!string.IsNullOrEmpty(cellValue))
                {
                    // 检查是否包含@ref标记和类型
                    if (cellValue.Contains("@ref"))
                    {
                        var parts = cellValue.Split(new[] { '@', ' ' }, StringSplitOptions.RemoveEmptyEntries);
                        var cleanName = parts[0].Trim();
                        if (cleanName.Equals(columnName, StringComparison.OrdinalIgnoreCase))
                        {
                            // 获取引用类型（如 "skill"）
                            var refType = parts.Length > 1 ? parts[1].Trim() : null;
                            return (i, refType);
                        }
                    }
                    // 处理没有@ref的普通列
                    else if (cellValue.Equals(columnName, StringComparison.OrdinalIgnoreCase))
                    {
                        return (i, null);
                    }
                }
            }

            return (-1, null);
        }

        /// <summary>
        /// 记录引用关系
        /// </summary>
        private void RecordReferenceRelation(FieldDefinition field, string referenceId, PreProcessContext context)
        {
            if (!context.Properties.ContainsKey("ReferenceRelations"))
            {
                context.Properties["ReferenceRelations"] = new Dictionary<string, List<ReferenceRelation>>();
            }

            var relations = (Dictionary<string, List<ReferenceRelation>>)context.Properties["ReferenceRelations"];

            if (!relations.ContainsKey(referenceId))
            {
                relations[referenceId] = new List<ReferenceRelation>();
            }

            relations[referenceId].Add(new ReferenceRelation
            {
                SourceField = field.Name,
                SourceTable = context.ConfigName,
                TargetType = referenceId,
                IsRequired = field.IsRequired
            });
        }

        /// <summary>
        /// 验证引用完整性
        /// </summary>
        private void ValidateReferences(PreProcessContext context)
        {
            try
            {
                context.AddLog("开始验证引用完整性");

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

                    // 这里可以添加更复杂的引用验证逻辑
                    // 例如检查目标配置表是否存在、引用ID是否有效等

                    foreach (var relation in relationList)
                    {
                        if (relation.IsRequired)
                        {
                            // 验证必需引用字段
                            ValidateRequiredReference(relation, context);
                        }
                    }
                }

                context.AddLog("引用完整性验证完成");
            }
            catch (Exception ex)
            {
                context.AddError($"引用完整性验证失败: {ex.Message}");
            }
        }

        /// <summary>
        /// 验证必需的引用字段
        /// </summary>
        private void ValidateRequiredReference(ReferenceRelation relation, PreProcessContext context)
        {
            // 这里可以实现具体的引用验证逻辑
            // 例如：检查引用的ID是否在目标表中存在

            context.AddLog($"验证必需引用: {relation.SourceTable}.{relation.SourceField} -> {relation.TargetType}");
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
