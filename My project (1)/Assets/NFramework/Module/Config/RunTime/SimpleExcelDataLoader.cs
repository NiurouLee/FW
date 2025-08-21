using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 简化的Excel数据加载器 - 支持CSV格式，无需外部依赖
    /// </summary>
    public static class SimpleExcelDataLoader
    {
        /// <summary>
        /// 从CSV文件加载数据，支持标准4行格式
        /// </summary>
        /// <param name="filePath">CSV文件路径</param>
        /// <returns>包含数据的DataSet</returns>
        public static DataSet LoadCSVData(string filePath)
        {
            if (!File.Exists(filePath))
            {
                throw new FileNotFoundException($"CSV文件不存在: {filePath}");
            }

            try
            {
                var dataSet = new DataSet();
                var lines = File.ReadAllLines(filePath, Encoding.UTF8);
                
                if (lines.Length < 4)
                {
                    throw new InvalidOperationException("CSV文件至少需要4行：字段名、字段类型、字段描述、字段默认值");
                }

                // 创建数据表
                var tableName = Path.GetFileNameWithoutExtension(filePath);
                var table = new DataTable(tableName);
                
                // 解析第一行获取列数
                var firstLine = lines[0];
                var columns = ParseCSVLine(firstLine);
                
                // 创建列
                for (int i = 0; i < columns.Length; i++)
                {
                    table.Columns.Add($"Column{i}", typeof(object));
                }
                
                // 添加所有行数据
                foreach (var line in lines)
                {
                    if (string.IsNullOrWhiteSpace(line)) continue;
                    
                    var values = ParseCSVLine(line);
                    var row = table.NewRow();
                    
                    for (int i = 0; i < System.Math.Min(values.Length, table.Columns.Count); i++)
                    {
                        row[i] = values[i];
                    }
                    
                    table.Rows.Add(row);
                }
                
                // 验证和处理表格
                ValidateAndProcessTable(table, filePath);
                
                dataSet.Tables.Add(table);
                Debug.Log($"成功加载CSV文件: {filePath}, 共 {table.Rows.Count} 行数据");
                
                return dataSet;
            }
            catch (Exception ex)
            {
                throw new Exception($"加载CSV文件失败 {filePath}: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// 解析CSV行，支持引号包围的字段
        /// </summary>
        private static string[] ParseCSVLine(string line)
        {
            var result = new List<string>();
            var current = new StringBuilder();
            bool inQuotes = false;
            
            for (int i = 0; i < line.Length; i++)
            {
                char c = line[i];
                
                if (c == '"')
                {
                    if (inQuotes && i + 1 < line.Length && line[i + 1] == '"')
                    {
                        // 转义的引号
                        current.Append('"');
                        i++; // 跳过下一个引号
                    }
                    else
                    {
                        // 开始或结束引号
                        inQuotes = !inQuotes;
                    }
                }
                else if (c == ',' && !inQuotes)
                {
                    // 字段分隔符
                    result.Add(current.ToString());
                    current.Clear();
                }
                else
                {
                    current.Append(c);
                }
            }
            
            // 添加最后一个字段
            result.Add(current.ToString());
            
            return result.ToArray();
        }

        /// <summary>
        /// 验证和处理数据表，确保符合4行格式要求
        /// </summary>
        private static void ValidateAndProcessTable(DataTable table, string filePath)
        {
            if (table.Rows.Count < 4)
            {
                throw new InvalidOperationException($"表 {table.TableName} 在文件 {filePath} 中至少需要4行：字段名、字段类型、字段描述、字段默认值");
            }

            // 分析表头信息
            var headerInfo = AnalyzeTableHeader(table);
            
            // 记录表头信息到表的扩展属性中
            table.ExtendedProperties["HeaderInfo"] = headerInfo;
            table.ExtendedProperties["OriginalFileName"] = Path.GetFileName(filePath);

            Debug.Log($"处理表 {table.TableName}: {headerInfo.ValidColumns.Count} 个有效列, {table.Rows.Count - 4} 行数据");
        }

        /// <summary>
        /// 分析表头信息
        /// </summary>
        private static TableHeaderInfo AnalyzeTableHeader(DataTable table)
        {
            var headerInfo = new TableHeaderInfo
            {
                TableName = table.TableName
            };

            var fieldNameRow = table.Rows[0];      // 第一行：字段名
            var fieldTypeRow = table.Rows[1];      // 第二行：字段类型
            var fieldDescRow = table.Rows[2];      // 第三行：字段描述
            var fieldDefaultRow = table.Rows[3];   // 第四行：字段默认值

            for (int col = 0; col < table.Columns.Count; col++)
            {
                var columnInfo = new ColumnInfo
                {
                    ColumnIndex = col,
                    FieldName = GetCellValue(fieldNameRow, col),
                    FieldType = GetCellValue(fieldTypeRow, col),
                    FieldDescription = GetCellValue(fieldDescRow, col),
                    FieldDefault = GetCellValue(fieldDefaultRow, col)
                };

                // 跳过空的字段名
                if (string.IsNullOrWhiteSpace(columnInfo.FieldName))
                {
                    continue;
                }

                // 解析字段标记
                ParseFieldTags(columnInfo);

                // 验证字段类型
                ValidateFieldType(columnInfo);

                headerInfo.ValidColumns.Add(columnInfo);
                
                // 如果标记为@PM，记录但不包含在处理列表中
                if (columnInfo.GenerationType != FieldGenerationType.None)
                {
                    headerInfo.ProcessableColumns.Add(columnInfo);
                }
            }

            return headerInfo;
        }

        /// <summary>
        /// 获取单元格值
        /// </summary>
        private static string GetCellValue(DataRow row, int columnIndex)
        {
            if (columnIndex >= row.ItemArray.Length)
                return "";

            var value = row[columnIndex];
            return value?.ToString()?.Trim() ?? "";
        }

        /// <summary>
        /// 解析字段标记
        /// </summary>
        private static void ParseFieldTags(ColumnInfo columnInfo)
        {
            var fieldName = columnInfo.FieldName;
            
            if (fieldName.Contains("@"))
            {
                var parts = fieldName.Split('@');
                columnInfo.CleanFieldName = parts[0].Trim();
                
                for (int i = 1; i < parts.Length; i++)
                {
                    var tag = parts[i].Trim().ToUpper();
                    
                    switch (tag)
                    {
                        case "PM":
                            columnInfo.GenerationType = FieldGenerationType.None;
                            break;
                        case "CLIENT":
                            columnInfo.GenerationType = FieldGenerationType.ClientOnly;
                            break;
                        case "SERVER":
                            columnInfo.GenerationType = FieldGenerationType.ServerOnly;
                            break;
                        case "ALL":
                            columnInfo.GenerationType = FieldGenerationType.All;
                            break;
                        case "LAN":
                            columnInfo.IsLocalization = true;
                            break;
                        case "REF":
                            columnInfo.IsReference = true;
                            break;
                    }
                }
            }
            else
            {
                columnInfo.CleanFieldName = fieldName;
            }

            // 清理字段名
            columnInfo.CleanFieldName = SanitizeFieldName(columnInfo.CleanFieldName);
        }

        /// <summary>
        /// 验证字段类型
        /// </summary>
        private static void ValidateFieldType(ColumnInfo columnInfo)
        {
            var fieldType = columnInfo.FieldType;
            
            if (string.IsNullOrWhiteSpace(fieldType))
            {
                columnInfo.ParsedType = "string";
                columnInfo.Warnings.Add("字段类型为空，默认使用string类型");
                return;
            }

            try
            {
                columnInfo.ParsedType = ParseFieldType(fieldType, columnInfo);
            }
            catch (Exception ex)
            {
                columnInfo.ParsedType = "string";
                columnInfo.Errors.Add($"字段类型解析失败: {ex.Message}");
            }
        }

        /// <summary>
        /// 解析字段类型
        /// </summary>
        private static string ParseFieldType(string originalType, ColumnInfo columnInfo)
        {
            var type = originalType.Trim().ToLower();
            
            // 处理引用类型
            if (columnInfo.IsReference)
            {
                columnInfo.ReferenceType = ExtractReferenceType(type);
                return "int"; // 引用字段存储为ID
            }
            
            // 处理数组类型
            if (type.StartsWith("repeated ") || type.Contains("[]"))
            {
                var elementType = type.StartsWith("repeated ") 
                    ? type.Substring("repeated ".Length).Trim()
                    : type.Replace("[]", "").Trim();
                
                columnInfo.IsArray = true;
                columnInfo.ElementType = ConvertBasicType(elementType);
                return $"[{columnInfo.ElementType}]";
            }
            
            // 处理Map类型 - 支持分号分隔符（CSV友好）
            if (type.StartsWith("map<") && type.EndsWith(">"))
            {
                var mapContent = type.Substring(4, type.Length - 5);
                var keyValue = mapContent.Split(new char[] { ',', ';' }); // 支持逗号和分号
                if (keyValue.Length == 2)
                {
                    columnInfo.IsMap = true;
                    columnInfo.KeyType = ConvertBasicType(keyValue[0].Trim());
                    columnInfo.ValueType = ConvertBasicType(keyValue[1].Trim());
                    return $"[{columnInfo.KeyType}_{columnInfo.ValueType}_Pair]";
                }
            }
            
            // 处理键值对数组
            if (type.Contains("keyvaluepair") || type.Contains("kvp"))
            {
                columnInfo.IsKeyValuePairArray = true;
                return "[KeyValuePair]";
            }
            
            return ConvertBasicType(type);
        }

        /// <summary>
        /// 转换基本类型
        /// </summary>
        private static string ConvertBasicType(string type)
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
                _ => "string"
            };
        }

        /// <summary>
        /// 提取引用类型
        /// </summary>
        private static string ExtractReferenceType(string type)
        {
            if (type.Contains("config") || type.Contains("table"))
            {
                return type.Replace("config", "").Replace("table", "").Trim();
            }
            
            return type;
        }

        /// <summary>
        /// 清理字段名
        /// </summary>
        private static string SanitizeFieldName(string fieldName)
        {
            if (string.IsNullOrEmpty(fieldName))
                return "UnknownField";

            var sanitized = System.Text.RegularExpressions.Regex.Replace(fieldName, @"[^a-zA-Z0-9_]", "");
            
            if (char.IsDigit(sanitized[0]))
            {
                sanitized = "Field_" + sanitized;
            }

            return sanitized;
        }

        /// <summary>
        /// 创建标准的PipelineInput（CSV版本）
        /// </summary>
        public static Core.PipelineInput CreatePipelineInput(string csvFilePath, string configType = null, string configName = null)
        {
            var dataSet = LoadCSVData(csvFilePath);
            
            // 如果没有指定配置类型，使用文件名
            if (string.IsNullOrEmpty(configType))
            {
                configType = Path.GetFileNameWithoutExtension(csvFilePath);
            }
            
            // 如果没有指定配置名，使用第一个表的名字
            if (string.IsNullOrEmpty(configName))
            {
                configName = dataSet.Tables[0].TableName;
            }

            return new Core.PipelineInput
            {
                ConfigType = configType,
                ConfigName = configName,
                SourceFilePath = csvFilePath,
                RawDataSet = dataSet,
                OutputPath = Path.Combine("Assets/Generated/Config", configType)
            };
        }
    }
}
