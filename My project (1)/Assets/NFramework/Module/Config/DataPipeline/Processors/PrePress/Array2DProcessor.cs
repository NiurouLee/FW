using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using NFramework.Module.Config.DataPipeline.Core;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline.Processors
{
    /// <summary>
    /// 二维数组处理器 - 处理二维数组数据的解析和验证
    /// </summary>
    public class Array2DProcessor : IPreProcessor
    {
        public string Name => "2D Array Processor";
        public int Priority => PrePressPriority.Array2DProcessor; // 在Schema生成之后，其他处理器之前
        public bool IsEnabled { get; set; } = true;

        private readonly Array2DSettings _settings;

        public Array2DProcessor(Array2DSettings settings = null)
        {
            _settings = settings ?? new Array2DSettings();
        }

        public bool Process(PreProcessContext context)
        {
            try
            {
                context.AddLog("开始处理二维数组字段");

                if (context.SchemaDefinition == null || context.CurrentSheet == null)
                {
                    context.AddError("Schema定义或数据表为空");
                    return false;
                }

                var array2DFields = context.SchemaDefinition.Fields
                    .Where(f => f.Type.StartsWith("[[") && f.Type.EndsWith("]]"))
                    .ToList();

                if (array2DFields.Count == 0)
                {
                    context.AddLog("没有找到需要处理的二维数组字段");
                    return true;
                }

                context.AddLog($"找到 {array2DFields.Count} 个二维数组字段需要处理");

                // 处理每个二维数组字段
                foreach (var field in array2DFields)
                {
                    ProcessArray2DField(field, context);
                }

                context.AddLog("二维数组字段处理完成");
                return true;
            }
            catch (Exception ex)
            {
                context.AddError($"二维数组字段处理失败: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// 处理单个二维数组字段
        /// </summary>
        private void ProcessArray2DField(FieldDefinition field, PreProcessContext context)
        {
            try
            {
                var originalName = field.Attributes["original_name"]?.ToString() ?? field.Name;
                var columnIndex = FindColumnIndex(context.CurrentSheet, originalName);
                
                if (columnIndex < 0)
                {
                    context.AddError($"找不到二维数组字段的源列: {originalName}");
                    return;
                }

                context.AddLog($"处理二维数组字段: {field.Name}");

                // 验证和处理二维数组数据
                ValidateAndProcess2DArrayData(context.CurrentSheet, columnIndex, field, context);

                // 添加二维数组元数据
                field.Attributes["is_2d_array"] = true;
                field.Attributes["row_separator"] = _settings.RowSeparator;
                field.Attributes["column_separator"] = _settings.ColumnSeparator;
            }
            catch (Exception ex)
            {
                context.AddError($"处理二维数组字段 {field.Name} 失败: {ex.Message}");
            }
        }

        /// <summary>
        /// 验证和处理二维数组数据
        /// </summary>
        private void ValidateAndProcess2DArrayData(DataTable table, int columnIndex, FieldDefinition field, PreProcessContext context)
        {
            try
            {
                var elementType = ExtractElementType(field.Type);
                int validRows = 0;
                int totalRows = 0;
                var maxColumns = 0;
                var minColumns = int.MaxValue;

                // 从第5行开始处理数据（跳过前4行的头信息）
                for (int row = 4; row < table.Rows.Count; row++)
                {
                    var cellValue = table.Rows[row][columnIndex];
                    if (cellValue != null && cellValue != DBNull.Value)
                    {
                        var arrayData = cellValue.ToString();
                        if (!string.IsNullOrWhiteSpace(arrayData))
                        {
                            totalRows++;
                            var parseResult = Parse2DArrayData(arrayData, elementType, context);
                            
                            if (parseResult.IsValid)
                            {
                                validRows++;
                                maxColumns = System.Math.Max(maxColumns, parseResult.MaxColumns);
                                minColumns = System.Math.Min(minColumns, parseResult.MinColumns);
                                
                                // 将解析后的数据写回表格（标准化格式）
                                table.Rows[row][columnIndex] = parseResult.NormalizedData;
                            }
                            else
                            {
                                context.AddError($"行 {row + 1} 的二维数组数据格式错误: {arrayData}");
                            }
                        }
                    }
                }

                // 记录统计信息
                field.Attributes["total_data_rows"] = totalRows;
                field.Attributes["valid_data_rows"] = validRows;
                field.Attributes["max_columns"] = maxColumns;
                field.Attributes["min_columns"] = minColumns == int.MaxValue ? 0 : minColumns;

                context.AddLog($"二维数组字段 {field.Name} 处理完成：{validRows}/{totalRows} 行有效数据，列数范围 {minColumns}-{maxColumns}");
            }
            catch (Exception ex)
            {
                context.AddError($"验证二维数组数据失败: {ex.Message}");
            }
        }

        /// <summary>
        /// 解析二维数组数据
        /// </summary>
        private Array2DParseResult Parse2DArrayData(string arrayData, string elementType, PreProcessContext context)
        {
            var result = new Array2DParseResult();
            
            try
            {
                // 按行分割
                var rows = arrayData.Split(new[] { _settings.RowSeparator }, StringSplitOptions.RemoveEmptyEntries);
                var parsedRows = new List<string>();
                
                foreach (var row in rows)
                {
                    // 按列分割
                    var columns = row.Split(new[] { _settings.ColumnSeparator }, StringSplitOptions.RemoveEmptyEntries);
                    var parsedColumns = new List<string>();
                    
                    foreach (var column in columns)
                    {
                        var trimmedValue = column.Trim();
                        if (ValidateElementValue(trimmedValue, elementType))
                        {
                            parsedColumns.Add(trimmedValue);
                        }
                        else
                        {
                            result.Errors.Add($"无效的元素值: {trimmedValue}，期望类型: {elementType}");
                        }
                    }
                    
                    if (parsedColumns.Count > 0)
                    {
                        parsedRows.Add(string.Join(_settings.ColumnSeparator.ToString(), parsedColumns));
                        result.MaxColumns = System.Math.Max(result.MaxColumns, parsedColumns.Count);
                        result.MinColumns = System.Math.Min(result.MinColumns, parsedColumns.Count);
                    }
                }
                
                result.IsValid = parsedRows.Count > 0 && result.Errors.Count == 0;
                result.NormalizedData = string.Join(_settings.RowSeparator.ToString(), parsedRows);
                result.RowCount = parsedRows.Count;
            }
            catch (Exception ex)
            {
                result.IsValid = false;
                result.Errors.Add($"解析二维数组数据异常: {ex.Message}");
            }
            
            return result;
        }

        /// <summary>
        /// 验证元素值是否符合指定类型
        /// </summary>
        private bool ValidateElementValue(string value, string elementType)
        {
            if (string.IsNullOrWhiteSpace(value))
                return false;

            return elementType switch
            {
                "int" => int.TryParse(value, out _),
                "long" => long.TryParse(value, out _),
                "float" => float.TryParse(value, out _),
                "double" => double.TryParse(value, out _),
                "bool" => bool.TryParse(value, out _),
                "string" => true, // 字符串总是有效的
                _ => true // 未知类型默认有效
            };
        }

        /// <summary>
        /// 从FlatBuffer类型字符串中提取元素类型
        /// </summary>
        private string ExtractElementType(string fbsType)
        {
            if (fbsType.StartsWith("[[") && fbsType.EndsWith("]]"))
            {
                return fbsType.Substring(2, fbsType.Length - 4);
            }
            return "string";
        }

        /// <summary>
        /// 查找列索引
        /// </summary>
        private int FindColumnIndex(DataTable table, string columnName)
        {
            if (table.Rows.Count == 0) return -1;

            var headerRow = table.Rows[0];
            for (int i = 0; i < headerRow.ItemArray.Length; i++)
            {
                var cellValue = headerRow[i]?.ToString()?.Trim();
                if (!string.IsNullOrEmpty(cellValue))
                {
                    // 移除标记后比较
                    var cleanName = cellValue.Contains("@") ? cellValue.Split('@')[0].Trim() : cellValue;
                    if (cleanName.Equals(columnName, StringComparison.OrdinalIgnoreCase))
                    {
                        return i;
                    }
                }
            }
            
            return -1;
        }
    }

    /// <summary>
    /// 二维数组解析结果
    /// </summary>
    public class Array2DParseResult
    {
        public bool IsValid { get; set; }
        public string NormalizedData { get; set; }
        public int RowCount { get; set; }
        public int MaxColumns { get; set; }
        public int MinColumns { get; set; } = int.MaxValue;
        public List<string> Errors { get; set; } = new List<string>();
    }


}
