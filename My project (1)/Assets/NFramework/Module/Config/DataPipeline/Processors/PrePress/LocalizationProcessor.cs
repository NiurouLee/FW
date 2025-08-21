using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text.RegularExpressions;
using NFramework.Module.Config.DataPipeline.Core;

namespace NFramework.Module.Config.DataPipeline.Processors
{
    /// <summary>
    /// 本地化处理器 - 处理多语言文本和本地化键值
    /// </summary>
    public class LocalizationProcessor : IPreProcessor
    {
        public string Name => "Localization Processor";
        public int Priority => PrePressPriority.Localization;
        public bool IsEnabled { get; set; } = true;

        private readonly LocalizationSettings _settings;

        public LocalizationProcessor(LocalizationSettings settings = null)
        {
            _settings = settings ?? new LocalizationSettings();
        }

        public bool Process(PreProcessContext context)
        {
            try
            {
                context.AddLog("开始本地化处理");

                if (context.CurrentSheet == null)
                {
                    context.AddError("当前数据表为空");
                    return false;
                }

                var table = context.CurrentSheet;
                var localizationKeys = new Dictionary<string, string>();
                int processedTexts = 0;

                // 1. 识别需要本地化的列
                var textColumns = IdentifyTextColumns(table, context);
                context.AddLog($"识别到 {textColumns.Count} 个文本列需要本地化处理");

                // 2. 处理每个文本列
                foreach (var columnIndex in textColumns)
                {
                    var columnName = GetColumnName(table, columnIndex);
                    context.AddLog($"处理文本列: {columnName}");

                    // 从第5行开始处理数据（跳过前4行的头信息）
                    for (int row = 4; row < table.Rows.Count; row++) 
                    {
                        var cellValue = table.Rows[row][columnIndex];
                        if (cellValue != null && cellValue != DBNull.Value)
                        {
                            var textValue = cellValue.ToString();
                            if (!string.IsNullOrWhiteSpace(textValue))
                            {
                                var processedValue = ProcessTextValue(textValue, columnName, row, localizationKeys, context);
                                table.Rows[row][columnIndex] = processedValue;
                                processedTexts++;
                            }
                        }
                    }
                }

                // 3. 生成本地化键值表
                if (_settings.GenerateLocalizationFile && localizationKeys.Count > 0)
                {
                    GenerateLocalizationFile(localizationKeys, context);
                }

                // 4. 添加本地化元数据到Schema
                if (context.SchemaDefinition != null)
                {
                    context.SchemaDefinition.Metadata["LocalizedFields"] = textColumns;
                    context.SchemaDefinition.Metadata["LocalizationKeys"] = localizationKeys;
                }

                context.AddLog($"本地化处理完成，处理了 {processedTexts} 个文本值，生成了 {localizationKeys.Count} 个本地化键");
                return true;
            }
            catch (Exception ex)
            {
                context.AddError($"本地化处理失败: {ex.Message}");
                return false;
            }
        }

        private List<int> IdentifyTextColumns(DataTable table, PreProcessContext context)
        {
            var textColumns = new List<int>();

            // 检查Schema中标记为本地化的字段
            if (context.SchemaDefinition != null)
            {
                var localizationFields = context.SchemaDefinition.Fields
                    .Where(f => f.Attributes.ContainsKey("localization") && (bool)f.Attributes["localization"])
                    .ToList();

                foreach (var field in localizationFields)
                {
                    var columnIndex = FindColumnIndexByFieldName(table, field.Attributes["original_name"]?.ToString() ?? field.Name);
                    if (columnIndex >= 0)
                    {
                        textColumns.Add(columnIndex);
                        context.AddLog($"通过@Lan标记识别本地化列: {field.Name}");
                    }
                }
            }

            // 传统方式：通过列名和内容识别文本列
            for (int col = 0; col < table.Columns.Count; col++)
            {
                if (textColumns.Contains(col)) continue; // 已经通过标记识别的跳过

                var columnName = GetColumnName(table, col);
                
                // 通过列名识别文本列
                if (_settings.TextColumnPatterns.Any(pattern => 
                    columnName.ToLower().Contains(pattern.ToLower())))
                {
                    textColumns.Add(col);
                    continue;
                }

                // 通过数据内容识别文本列
                if (IsTextColumn(table, col))
                {
                    textColumns.Add(col);
                }
            }

            return textColumns;
        }

        /// <summary>
        /// 获取列名（从第一行获取）
        /// </summary>
        private string GetColumnName(DataTable table, int columnIndex)
        {
            if (table.Rows.Count == 0 || columnIndex >= table.Columns.Count) 
                return "";

            var cellValue = table.Rows[0][columnIndex]?.ToString()?.Trim();
            if (string.IsNullOrEmpty(cellValue)) 
                return "";

            // 如果包含标记，只返回字段名部分
            return cellValue.Contains("@") ? cellValue.Split('@')[0].Trim() : cellValue;
        }

        /// <summary>
        /// 根据字段名查找列索引
        /// </summary>
        private int FindColumnIndexByFieldName(DataTable table, string fieldName)
        {
            if (table.Rows.Count == 0 || string.IsNullOrEmpty(fieldName)) 
                return -1;

            var headerRow = table.Rows[0];
            for (int i = 0; i < headerRow.ItemArray.Length; i++)
            {
                var cellValue = headerRow[i]?.ToString()?.Trim();
                if (!string.IsNullOrEmpty(cellValue))
                {
                    // 移除标记后比较
                    var cleanName = cellValue.Contains("@") ? cellValue.Split('@')[0].Trim() : cellValue;
                    if (cleanName.Equals(fieldName, StringComparison.OrdinalIgnoreCase))
                    {
                        return i;
                    }
                }
            }
            
            return -1;
        }

        private bool IsTextColumn(DataTable table, int columnIndex)
        {
            int textCount = 0;
            int totalCount = 0;

            for (int row = 1; row < System.Math.Min(table.Rows.Count, 20); row++) // 检查前20行
            {
                var value = table.Rows[row][columnIndex];
                if (value != null && value != DBNull.Value)
                {
                    var stringValue = value.ToString();
                    totalCount++;

                    // 检查是否包含中文或长文本
                    if (ContainsChinese(stringValue) || stringValue.Length > _settings.MinTextLength)
                    {
                        textCount++;
                    }
                }
            }

            return totalCount > 0 && (textCount / (double)totalCount) > 0.3; // 30%以上为文本
        }

        private bool ContainsChinese(string text)
        {
            return Regex.IsMatch(text, @"[\u4e00-\u9fa5]");
        }

        private string ProcessTextValue(string textValue, string columnName, int rowIndex, 
            Dictionary<string, string> localizationKeys, PreProcessContext context)
        {
            // 检查是否已经是本地化键
            if (_settings.LocalizationKeyPattern != null && 
                Regex.IsMatch(textValue, _settings.LocalizationKeyPattern))
            {
                return textValue; // 已经是本地化键，不需要处理
            }

            // 检查是否需要本地化
            if (!ShouldLocalize(textValue))
            {
                return textValue; // 不需要本地化
            }

            // 生成本地化键
            var localizationKey = GenerateLocalizationKey(textValue, columnName, rowIndex);
            
            // 确保键的唯一性
            var uniqueKey = EnsureUniqueKey(localizationKey, localizationKeys);
            
            // 存储本地化映射
            localizationKeys[uniqueKey] = textValue;

            context.AddLog($"生成本地化键: {uniqueKey} -> {textValue}");

            return _settings.LocalizationKeyFormat.Replace("{key}", uniqueKey);
        }

        private bool ShouldLocalize(string text)
        {
            if (string.IsNullOrWhiteSpace(text))
                return false;

            // 如果包含中文，需要本地化
            if (ContainsChinese(text))
                return true;

            // 如果文本长度超过阈值，需要本地化
            if (text.Length > _settings.MinTextLength)
                return true;

            // 如果匹配本地化模式，需要本地化
            if (_settings.LocalizationPatterns.Any(pattern => 
                Regex.IsMatch(text, pattern, RegexOptions.IgnoreCase)))
                return true;

            return false;
        }

        private string GenerateLocalizationKey(string text, string columnName, int rowIndex)
        {
            var keyBuilder = new List<string>();

            // 添加列名前缀
            if (!string.IsNullOrEmpty(columnName))
            {
                keyBuilder.Add(SanitizeKeyPart(columnName));
            }

            // 添加文本摘要
            var textSummary = GenerateTextSummary(text);
            if (!string.IsNullOrEmpty(textSummary))
            {
                keyBuilder.Add(textSummary);
            }

            // 添加行索引（如果需要）
            if (_settings.IncludeRowIndexInKey)
            {
                keyBuilder.Add($"R{rowIndex}");
            }

            return string.Join("_", keyBuilder).ToUpper();
        }

        private string GenerateTextSummary(string text)
        {
            if (string.IsNullOrEmpty(text))
                return "";

            // 移除特殊字符，只保留字母数字
            var sanitized = Regex.Replace(text, @"[^\w\s]", "");
            
            // 分割单词
            var words = sanitized.Split(new[] { ' ', '\t', '\n' }, StringSplitOptions.RemoveEmptyEntries);
            
            // 取前几个单词
            var selectedWords = words.Take(_settings.MaxWordsInKey).Select(SanitizeKeyPart);
            
            return string.Join("_", selectedWords);
        }

        private string SanitizeKeyPart(string part)
        {
            if (string.IsNullOrEmpty(part))
                return "";

            // 只保留字母数字和下划线
            var sanitized = Regex.Replace(part, @"[^\w]", "_");
            
            // 移除连续下划线
            sanitized = Regex.Replace(sanitized, @"_+", "_");
            
            // 移除首尾下划线
            sanitized = sanitized.Trim('_');

            return sanitized;
        }

        private string EnsureUniqueKey(string baseKey, Dictionary<string, string> existingKeys)
        {
            var uniqueKey = baseKey;
            int counter = 1;

            while (existingKeys.ContainsKey(uniqueKey))
            {
                uniqueKey = $"{baseKey}_{counter}";
                counter++;
            }

            return uniqueKey;
        }

        private void GenerateLocalizationFile(Dictionary<string, string> localizationKeys, PreProcessContext context)
        {
            try
            {
                var localizationData = new DataTable("Localization");
                localizationData.Columns.Add("Key", typeof(string));
                localizationData.Columns.Add("Text", typeof(string));
                localizationData.Columns.Add("Language", typeof(string));

                foreach (var kvp in localizationKeys)
                {
                    var row = localizationData.NewRow();
                    row["Key"] = kvp.Key;
                    row["Text"] = kvp.Value;
                    row["Language"] = _settings.DefaultLanguage;
                    localizationData.Rows.Add(row);
                }

                context.ProcessedSheets["Localization"] = localizationData;
                context.AddLog($"生成本地化数据表，包含 {localizationKeys.Count} 个条目");
            }
            catch (Exception ex)
            {
                context.AddError($"生成本地化文件失败: {ex.Message}");
            }
        }
    }

    /// <summary>
    /// 本地化设置
    /// </summary>
    public class LocalizationSettings
    {
        public List<string> TextColumnPatterns { get; set; } = new List<string> 
        { 
            "name", "description", "text", "title", "content", "message",
            "名称", "描述", "文本", "标题", "内容", "消息"
        };
        
        public List<string> LocalizationPatterns { get; set; } = new List<string>
        {
            @"[\u4e00-\u9fa5]", // 中文字符
            @".{20,}" // 长文本
        };
        
        public string LocalizationKeyPattern { get; set; } = @"^LOC_[A-Z0-9_]+$";
        public string LocalizationKeyFormat { get; set; } = "LOC_{key}";
        public int MinTextLength { get; set; } = 10;
        public int MaxWordsInKey { get; set; } = 3;
        public bool IncludeRowIndexInKey { get; set; } = false;
        public bool GenerateLocalizationFile { get; set; } = true;
        public string DefaultLanguage { get; set; } = "zh-CN";
    }
}
