using System;
using System.Data;
using System.IO;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 增强的Excel数据加载器
    /// </summary>
    public static class EnhancedExcelDataLoader
    {
        /// <summary>
        /// 创建管道输入
        /// </summary>
        public static PipelineInput CreatePipelineInput(string filePath, string configType, string configName)
        {
            try
            {
                var dataSet = LoadExcelFile(filePath);
                
                return new PipelineInput
                {
                    ConfigType = configType,
                    ConfigName = configName,
                    SourceFilePath = filePath,
                    RawDataSet = dataSet,
                    OutputPath = Path.Combine("Assets/Generated/Config", $"{configName}.bytes")
                };
            }
            catch (Exception ex)
            {
                Debug.LogError($"Failed to create pipeline input for {filePath}: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// 加载Excel文件
        /// </summary>
        private static DataSet LoadExcelFile(string filePath)
        {
            // 这里简单创建一个示例DataSet
            // 实际项目中应该使用NPOI或其他Excel读取库
            var dataSet = new DataSet();
            var table = new DataTable();
            
            // 添加示例列
            table.Columns.Add("ID");
            table.Columns.Add("Name");
            table.Columns.Add("Value");

            // 添加类型行
            var typeRow = table.NewRow();
            typeRow["ID"] = "int";
            typeRow["Name"] = "string";
            typeRow["Value"] = "float";
            table.Rows.Add(typeRow);

            // 添加示例数据行
            var dataRow = table.NewRow();
            dataRow["ID"] = "1";
            dataRow["Name"] = "Example";
            dataRow["Value"] = "1.5";
            table.Rows.Add(dataRow);

            dataSet.Tables.Add(table);
            return dataSet;
        }
    }
}
