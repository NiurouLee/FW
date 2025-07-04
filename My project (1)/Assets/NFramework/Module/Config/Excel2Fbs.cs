using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Text;
using System;
using System.Threading.Tasks;
using UnityEditor;

namespace NFramework.Module.Config
{

    /// <summary>
    /// 将Excel文件结构转换为FBS文件
    /// </summary>
    public static class Excel2Fbs
    {
        public static string ExcelPath = "D:/Project/FW/My project (1)/Assets/NFramework/ThridyPartyLibs/Flatbuffer/Excel";
        public static string FBSPath = "D:/Project/FW/My project (1)/Assets/NFramework/ThridyPartyLibs/Flatbuffer/Fbs";
        private static List<ExcelHeader> ExcelHeaders = new();
        private static object lockObject = new object();

        /// <summary>
        ///  获取这个路径下所有.xls .xlsx.  
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        private static List<string> GetAllExcelFiles(string path)
        {
            List<string> excelFiles = new List<string>();

            // 支持的Excel文件扩展名
            string[] excelExtensions = new string[] { ".xls", ".xlsx", ".xlsm" };

            try
            {
                // 获取当前目录下的所有Excel文件
                foreach (string extension in excelExtensions)
                {
                    excelFiles.AddRange(Directory.GetFiles(path, $"*{extension}", SearchOption.TopDirectoryOnly));
                }

                // 递归获取子目录中的Excel文件
                string[] subDirectories = Directory.GetDirectories(path);
                foreach (string subDir in subDirectories)
                {
                    excelFiles.AddRange(GetAllExcelFiles(subDir));
                }
            }
            catch (System.Exception e)
            {
                Debug.LogError($"Error while searching for Excel files: {e.Message}");
            }

            return excelFiles;
        }

        /// <summary>
        /// 读取前四行
        /// </summary>
        /// <param name="excelPath"></param>
        private static void ReadFirstFourRows(string excelPath)
        {
            try
            {
                Debug.Log($"Reading first 4 rows from {excelPath}:");

                // 读取文件的前1000字节（通常包含前几行的内容）
                byte[] buffer = new byte[1000];
                using (FileStream fs = new FileStream(excelPath, FileMode.Open, FileAccess.Read))
                {
                    fs.Read(buffer, 0, buffer.Length);
                }

                // 将二进制数据转换为字符串
                string content = Encoding.UTF8.GetString(buffer);

                // 按行分割并取前4行
                string[] lines = content.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);

                // 创建表头对象
                var header = new ExcelHeader
                {
                    FileName = Path.GetFileName(excelPath),
                    SheetName = "Sheet1", // 默认使用第一个sheet
                    Columns = new List<ExcelColumn>()
                };

                // 获取列数（以第一行的列数为准）
                int columnCount = lines[0].Split('\t').Length;

                // 为每一列创建ExcelColumn对象
                for (int col = 0; col < columnCount; col++)
                {
                    var column = new ExcelColumn();

                    // 填充每一列的前四行数据
                    for (int row = 0; row < System.Math.Min(4, lines.Length); row++)
                    {
                        string[] cells = lines[row].Split('\t');
                        if (col < cells.Length)
                        {
                            switch (row)
                            {
                                case 0:
                                    column.ColumnName = cells[col];
                                    break;
                                case 1:
                                    column.ColumnType = cells[col];
                                    break;
                                case 2:
                                    column.ColumnDes = cells[col];
                                    break;
                                case 3:
                                    column.DefaultValue = cells[col];
                                    break;
                            }
                        }
                    }

                    header.Columns.Add(column);
                }

                // 使用锁来保护共享资源
                lock (lockObject)
                {
                    ExcelHeaders.Add(header);
                }
            }
            catch (System.Exception e)
            {
                Debug.LogError($"Error reading Excel file {excelPath}: {e.Message}");
            }
        }

        [MenuItem("NFramework/Excel2Fbs")]
        public static async void Convert()
        {
            if (string.IsNullOrEmpty(ExcelPath))
            {
                Debug.LogError("ExcelPath is not set!");
                return;
            }

            List<string> excelFiles = GetAllExcelFiles(ExcelPath);
            Debug.Log($"Found {excelFiles.Count} Excel files:");

            // 创建任务列表
            var tasks = new List<Task>();

            // 为每个Excel文件创建一个任务
            foreach (string file in excelFiles)
            {
                string currentFile = file; // 创建局部变量以避免闭包问题
                tasks.Add(Task.Run(() =>
                {
                    Debug.Log($"Processing file: {currentFile}");
                    ReadFirstFourRows(currentFile);
                }));
            }

            // 等待所有任务完成
            await Task.WhenAll(tasks);
            tasks.Clear();

            Debug.Log("All Excel files processed!");

            // 生成FBS文件
            foreach (var header in ExcelHeaders)
            {
                tasks.Add(Task.Run(() =>
                {
                    ConvertHeaderToFbs(header);
                }));
            }
            await Task.WhenAll(tasks);
        }

        private static void ConvertHeaderToFbs(ExcelHeader inHeader)
        {
            try
            {
                var fbs = new StringBuilder();

                // 添加文件头注释
                fbs.AppendLine("// Auto-generated FBS file");
                fbs.AppendLine($"// Source: {inHeader.FileName}");
                fbs.AppendLine($"// Sheet: {inHeader.SheetName}");
                fbs.AppendLine();

                // 添加命名空间
                fbs.AppendLine("namespace ExcelConfig;");
                fbs.AppendLine();

                var structs = Excel2FbsStructs.Convert(inHeader);

                foreach (var fbsStruct in structs)
                {
                    fbs.Append(fbsStruct.GetFbsString());
                }

                fbs.AppendLine();

                // 确保输出目录存在
                if (!Directory.Exists(FBSPath))
                {
                    Directory.CreateDirectory(FBSPath);
                }

                // 生成输出文件名
                string outputFileName = Path.ChangeExtension(inHeader.FileName, ".fbs");
                string outputPath = Path.Combine(FBSPath, outputFileName);

                // 写入文件
                File.WriteAllText(outputPath, fbs.ToString());
                Debug.Log($"Generated FBS file: {outputPath}");
            }
            catch (System.Exception e)
            {
                Debug.LogError($"Error generating FBS file for {inHeader.FileName}: {e.Message}");
            }
        }

    }
}
