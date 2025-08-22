using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text.RegularExpressions;

namespace NFramework.Module.Config.DataPipeline.Processors
{
    /// <summary>
    /// 数据清理前处理器 - 清理和标准化Excel数据
    /// </summary>
    public class DataCleanerProcessor : IPreProcessor
    {
        public string Name => "Data Cleaner";
        public int Priority => PrePressPriority.DataCleaner; // 中等优先级
        public bool IsEnabled { get; set; } = true;

        private readonly DataCleaningSettings _settings;

        public DataCleanerProcessor(DataCleaningSettings settings = null)
        {
            _settings = settings ?? new DataCleaningSettings();
        }

        public bool Process(PreProcessContext context)
        {
            try
            {
                context.AddLog("开始数据清理处理");

                if (context.CurrentSheet == null)
                {
                    context.AddError("当前数据表为空");
                    return false;
                }

                var table = context.CurrentSheet;
                int cleanedRows = 0;
                int cleanedCells = 0;

                // 1. 清理空行
                if (_settings.RemoveEmptyRows)
                {
                    cleanedRows += RemoveEmptyRows(table, context);
                }

                // 2. 清理和标准化数据
                for (int row = 0; row < table.Rows.Count; row++)
                {
                    for (int col = 0; col < table.Columns.Count; col++)
                    {
                        var originalValue = table.Rows[row][col];
                        var cleanedValue = CleanCellValue(originalValue, row, col, context);

                        if (!Equals(originalValue, cleanedValue))
                        {
                            table.Rows[row][col] = cleanedValue;
                            cleanedCells++;
                        }
                    }
                }

                // 3. 验证数据完整性
                if (_settings.ValidateDataIntegrity)
                {
                    ValidateDataIntegrity(table, context);
                }

                // 4. 标准化列名
                if (_settings.StandardizeColumnNames)
                {
                    StandardizeColumnNames(table, context);
                }

                context.AddLog($"数据清理完成，清理了 {cleanedRows} 行和 {cleanedCells} 个单元格");
                return true;
            }
            catch (Exception ex)
            {
                context.AddError($"数据清理失败: {ex.Message}");
                return false;
            }
        }

        private int RemoveEmptyRows(DataTable table, PreProcessContext context)
        {
            var rowsToRemove = new List<DataRow>();

            foreach (DataRow row in table.Rows)
            {
                bool isEmpty = true;
                foreach (var item in row.ItemArray)
                {
                    if (item != null && item != DBNull.Value && !string.IsNullOrWhiteSpace(item.ToString()))
                    {
                        isEmpty = false;
                        break;
                    }
                }

                if (isEmpty)
                {
                    rowsToRemove.Add(row);
                }
            }

            foreach (var row in rowsToRemove)
            {
                table.Rows.Remove(row);
            }

            if (rowsToRemove.Count > 0)
            {
                context.AddLog($"移除了 {rowsToRemove.Count} 个空行");
            }

            return rowsToRemove.Count;
        }

        private object CleanCellValue(object value, int row, int col, PreProcessContext context)
        {
            if (value == null || value == DBNull.Value)
            {
                return _settings.DefaultValueForNull;
            }

            var stringValue = value.ToString();

            // 移除前后空白
            if (_settings.TrimWhitespace)
            {
                stringValue = stringValue.Trim();
            }

            // 标准化换行符
            if (_settings.StandardizeLineBreaks)
            {
                stringValue = stringValue.Replace("\r\n", "\n").Replace("\r", "\n");
            }

            // 移除特殊字符
            if (_settings.RemoveSpecialCharacters)
            {
                stringValue = Regex.Replace(stringValue, @"[^\w\s\.\-,;:|]", "");
            }

            // 标准化数字格式
            if (_settings.StandardizeNumbers)
            {
                stringValue = StandardizeNumber(stringValue);
            }

            // 处理布尔值
            if (_settings.StandardizeBooleans)
            {
                stringValue = StandardizeBoolean(stringValue);
            }

            // 处理数组值
            if (_settings.StandardizeArrays)
            {
                stringValue = StandardizeArray(stringValue);
            }

            return string.IsNullOrEmpty(stringValue) ? _settings.DefaultValueForEmpty : stringValue;
        }

        private string StandardizeNumber(string value)
        {
            if (string.IsNullOrEmpty(value))
                return value;

            // 移除千位分隔符
            value = value.Replace(",", "").Replace(" ", "");

            // 标准化小数点
            value = value.Replace("。", ".");

            return value;
        }

        private string StandardizeBoolean(string value)
        {
            if (string.IsNullOrEmpty(value))
                return value;

            var lowerValue = value.ToLower().Trim();

            // 标准化各种布尔值表示
            return lowerValue switch
            {
                "true" or "1" or "yes" or "y" or "是" or "真" or "对" => "true",
                "false" or "0" or "no" or "n" or "否" or "假" or "错" => "false",
                _ => value
            };
        }

        private string StandardizeArray(string value)
        {
            if (string.IsNullOrEmpty(value))
                return value;

            // 检测并标准化数组分隔符
            var separators = new[] { ";", "|", ":", "，" };

            foreach (var sep in separators)
            {
                if (value.Contains(sep))
                {
                    var elements = value.Split(new[] { sep }, StringSplitOptions.RemoveEmptyEntries)
                                       .Select(e => e.Trim())
                                       .Where(e => !string.IsNullOrEmpty(e));

                    return string.Join(",", elements);
                }
            }

            return value;
        }

        private void ValidateDataIntegrity(DataTable table, PreProcessContext context)
        {
            // 检查必需字段
            for (int col = 0; col < table.Columns.Count; col++)
            {
                var columnName = table.Columns[col].ColumnName;
                int nullCount = 0;

                for (int row = 1; row < table.Rows.Count; row++) // 跳过标题行
                {
                    var value = table.Rows[row][col];
                    if (value == null || value == DBNull.Value || string.IsNullOrWhiteSpace(value.ToString()))
                    {
                        nullCount++;
                    }
                }

                if (nullCount > 0)
                {
                    double nullPercentage = (double)nullCount / (table.Rows.Count - 1) * 100;

                    if (nullPercentage > _settings.MaxNullPercentage)
                    {
                        context.AddWarning($"列 '{columnName}' 有 {nullPercentage:F1}% 的空值");
                    }
                }
            }

            // 检查重复的ID列
            if (_settings.CheckDuplicateIds)
            {
                CheckDuplicateIds(table, context);
            }
        }

        private void CheckDuplicateIds(DataTable table, PreProcessContext context)
        {
            // 查找可能的ID列
            var idColumns = new List<int>();

            for (int col = 0; col < table.Columns.Count; col++)
            {
                var columnName = table.Columns[col].ColumnName.ToLower();
                if (columnName.Contains("id") || columnName.Contains("key"))
                {
                    idColumns.Add(col);
                }
            }

            foreach (var idCol in idColumns)
            {
                var values = new HashSet<string>();
                var duplicates = new List<string>();

                for (int row = 1; row < table.Rows.Count; row++)
                {
                    var value = table.Rows[row][idCol]?.ToString()?.Trim();
                    if (!string.IsNullOrEmpty(value))
                    {
                        if (!values.Add(value))
                        {
                            duplicates.Add(value);
                        }
                    }
                }

                if (duplicates.Count > 0)
                {
                    context.AddError($"列 '{table.Columns[idCol].ColumnName}' 发现重复值: {string.Join(", ", duplicates)}");
                }
            }
        }

        private void StandardizeColumnNames(DataTable table, PreProcessContext context)
        {
            for (int i = 0; i < table.Columns.Count; i++)
            {
                var originalName = table.Columns[i].ColumnName;
                var standardizedName = StandardizeColumnName(originalName);

                if (originalName != standardizedName)
                {
                    table.Columns[i].ColumnName = standardizedName;
                    context.AddLog($"列名标准化: '{originalName}' -> '{standardizedName}'");
                }
            }
        }

        private string StandardizeColumnName(string columnName)
        {
            if (string.IsNullOrEmpty(columnName))
                return "UnknownColumn";

            // 移除特殊字符，只保留字母数字和下划线
            var sanitized = Regex.Replace(columnName.Trim(), @"[^a-zA-Z0-9_\u4e00-\u9fa5]", "_");

            // 移除连续的下划线
            sanitized = Regex.Replace(sanitized, @"_+", "_");

            // 移除开头和结尾的下划线
            sanitized = sanitized.Trim('_');

            // 确保不为空
            if (string.IsNullOrEmpty(sanitized))
                sanitized = "UnknownColumn";

            // 确保以字母开头（对于英文字段名）
            if (char.IsDigit(sanitized[0]))
                sanitized = "Field_" + sanitized;

            return sanitized;
        }
    }

    /// <summary>
    /// 数据清理设置
    /// </summary>
    public class DataCleaningSettings
    {
        public bool RemoveEmptyRows { get; set; } = true;
        public bool TrimWhitespace { get; set; } = true;
        public bool StandardizeLineBreaks { get; set; } = true;
        public bool RemoveSpecialCharacters { get; set; } = false;
        public bool StandardizeNumbers { get; set; } = true;
        public bool StandardizeBooleans { get; set; } = true;
        public bool StandardizeArrays { get; set; } = true;
        public bool StandardizeColumnNames { get; set; } = true;
        public bool ValidateDataIntegrity { get; set; } = true;
        public bool CheckDuplicateIds { get; set; } = true;
        public double MaxNullPercentage { get; set; } = 50.0;
        public object DefaultValueForNull { get; set; } = "";
        public object DefaultValueForEmpty { get; set; } = "";
    }
}
