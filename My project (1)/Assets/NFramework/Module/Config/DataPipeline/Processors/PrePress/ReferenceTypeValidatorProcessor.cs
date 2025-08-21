using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using NFramework.Module.Config.DataPipeline.Core;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline.Processors
{
    /// <summary>
    /// 引用类型验证处理器 - 验证@ref标记引用的类型是否存在
    /// </summary>
    public class ReferenceTypeValidatorProcessor : IPreProcessor
    {
        public string Name => "Reference Type Validator";
        public int Priority => PrePressPriority.ReferenceTypeValidator; // 在引用解析之前执行
        public bool IsEnabled { get; set; } = true;

        private readonly HashSet<string> _validConfigTypes;

        public ReferenceTypeValidatorProcessor()
        {
            // 初始化有效的配置类型列表
            _validConfigTypes = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            LoadValidConfigTypes();
        }

        public bool Process(PreProcessContext context)
        {
            try
            {
                context.AddLog($"开始验证引用类型 - 当前配置: {context.ConfigName}");
                context.AddLog($"有效的配置类型: {string.Join(", ", _validConfigTypes)}");

                if (context.CurrentSheet == null || context.CurrentSheet.Rows.Count == 0)
                {
                    context.AddError($"数据表为空，无法验证引用类型 - 表名: {context.ConfigName}");
                    return false;
                }

                // 获取表头（第一行）
                var headerRow = context.CurrentSheet.Rows[0];
                var invalidRefs = new List<string>();
                var foundRefs = new List<string>();

                // 检查每个列的标记
                for (int i = 0; i < headerRow.ItemArray.Length; i++)
                {
                    var cellValue = headerRow[i]?.ToString()?.Trim();
                    if (string.IsNullOrEmpty(cellValue)) continue;

                    context.AddLog($"检查列 {i + 1}: {cellValue}");

                    // 检查是否包含@ref标记
                    if (cellValue.Contains("@ref"))
                    {
                        // 先分割出字段名和标记部分
                        var mainParts = cellValue.Split('@');
                        if (mainParts.Length < 2)
                        {
                            context.AddError($"列 {i + 1} 的标记格式无效: {cellValue}");
                            continue;
                        }

                        var fieldName = mainParts[0].Trim();
                        var tagPart = mainParts[1].Trim(); // "ref skill" 或 "ref"

                        // 从标记部分提取引用类型
                        if (!tagPart.StartsWith("ref_"))
                        {
                            invalidRefs.Add($"{fieldName} -> 格式无效");
                            context.AddError($"字段 {fieldName} 的引用标记格式无效，应为 '@ref_type'，例如：'@ref_skill'");
                            continue;
                        }

                        var refType = tagPart.Substring(4).ToLower(); // 跳过 "ref_" 前缀
                        if (string.IsNullOrEmpty(refType))
                        {
                            invalidRefs.Add($"{fieldName} -> 缺少引用类型");
                            context.AddError($"字段 {fieldName} 的引用标记缺少类型名称");
                            continue;
                        }

                        // 记录找到的引用
                        foundRefs.Add($"{fieldName}(@ref_{refType})");
                        foundRefs.Add($"{fieldName}(@ref {refType})");

                        // 验证引用类型是否存在
                        if (!_validConfigTypes.Contains(refType))
                        {
                            invalidRefs.Add($"{fieldName} -> {refType}");
                            context.AddError($"字段 {fieldName} 引用了不存在的配置类型: {refType}");
                            context.AddLog($"提示: 有效的配置类型包括: {string.Join(", ", _validConfigTypes)}");
                        }
                        else
                        {
                            context.AddLog($"验证通过: 字段 {fieldName} 引用类型 {refType}");
                        }
                    }
                }

                if (foundRefs.Count > 0)
                {
                    context.AddLog($"找到的引用字段: {string.Join(", ", foundRefs)}");
                }
                else
                {
                    context.AddLog("未找到任何引用字段");
                }

                if (invalidRefs.Count > 0)
                {
                    var errorMsg = $"在 {context.ConfigName} 中发现 {invalidRefs.Count} 个无效的引用类型:\n" +
                                 string.Join("\n", invalidRefs.Select(r => "  - " + r));
                    context.AddError(errorMsg);
                    return false;
                }

                context.AddLog($"引用类型验证完成 - {context.ConfigName}");
                return true;
            }
            catch (Exception ex)
            {
                context.AddError($"引用类型验证失败: {ex.Message}\n{ex.StackTrace}");
                return false;
            }
        }

        private void LoadValidConfigTypes()
        {
            try
            {
                // 从配置目录加载所有有效的配置类型
                var configDir = Path.Combine(Application.dataPath, "ConfigData", "Excel");
                Debug.Log($"正在从目录加载配置类型: {configDir}");

                if (Directory.Exists(configDir))
                {
                    var files = Directory.GetFiles(configDir, "*.csv");
                    Debug.Log($"找到 {files.Length} 个CSV文件");

                    foreach (var file in files)
                    {
                        var fileName = Path.GetFileNameWithoutExtension(file);
                        var configType = fileName
                            .Replace("Config", "", StringComparison.OrdinalIgnoreCase)
                            .ToLower();
                        _validConfigTypes.Add(configType);
                        Debug.Log($"添加配置类型: {fileName} -> {configType}");
                    }
                }
                else
                {
                    Debug.LogWarning($"配置目录不存在: {configDir}");
                }

                // 添加一些默认的基础类型
                var defaultTypes = new[] { "character", "skill", "item", "monster", "quest", "npc" };
                Debug.Log($"添加默认配置类型: {string.Join(", ", defaultTypes)}");
                
                foreach (var type in defaultTypes)
                {
                    _validConfigTypes.Add(type);
                }

                Debug.Log($"配置类型加载完成，共 {_validConfigTypes.Count} 个有效类型: {string.Join(", ", _validConfigTypes)}");
            }
            catch (Exception ex)
            {
                Debug.LogError($"加载有效配置类型失败: {ex.Message}\n{ex.StackTrace}");
            }
        }
    }
}
