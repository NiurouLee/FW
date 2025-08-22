using System.IO;
using System.Text;
using UnityEngine;
using UnityEditor;
using NFramework.Module.Config.DataPipeline;

namespace NFramework.Module.Config.DataPipeline.Examples
{
    /// <summary>
    /// 二维数组支持示例
    /// </summary>
    public static class Array2DExample
    {
        /// <summary>
        /// 创建二维数组示例文件
        /// </summary>
        // [MenuItem("NFramework/Generate 2D Array Example")]  // 已禁用，简化菜单
        public static void Create2DArrayExample()
        {
            var outputDir = Path.Combine(Application.dataPath, "ConfigData", "Excel");
            Directory.CreateDirectory(outputDir);
            
            Create2DArrayConfigExample(outputDir);
            CreateGameMapExample(outputDir);
            
            Debug.Log($"二维数组示例文件已创建在: {outputDir}");
            Debug.Log("这些示例展示了如何使用二维数组类型");
            
            AssetDatabase.Refresh();
        }
        
        /// <summary>
        /// 创建二维数组配置示例
        /// </summary>
        private static void Create2DArrayConfigExample(string outputDir)
        {
            var filePath = Path.Combine(outputDir, "Array2DConfig.csv");
            var csv = new StringBuilder();
            
            // 演示各种二维数组类型
            csv.AppendLine("ID@All,Matrix@All,GameBoard@Client,ServerGrid@Server,StringMatrix@All@Lan");
            csv.AppendLine("int,int[][],repeated repeated int,float[][],string[][]");
            csv.AppendLine("配置ID,整数矩阵,游戏棋盘（客户端）,服务端网格,字符串矩阵（多语言）");
            csv.AppendLine("0,\"\",\"\",\"\",\"\"");
            
            // 示例数据 - 使用分号分隔行，逗号分隔列
            csv.AppendLine("1001,\"1,2,3;4,5,6;7,8,9\",\"0,0,1;0,1,0;1,0,0\",\"1.0,2.5;3.2,4.8\",\"A,B;C,D\"");
            csv.AppendLine("1002,\"10,20;30,40\",\"1,1,1;1,1,1;1,1,1\",\"0.1,0.2,0.3;0.4,0.5,0.6\",\"Hello,World;你好,世界\"");
            csv.AppendLine("1003,\"100;200;300\",\"2,2,2;2,2,2\",\"10.5,20.5\",\"Title,Content;标题,内容\"");
            
            File.WriteAllText(filePath, csv.ToString(), Encoding.UTF8);
            Debug.Log($"创建二维数组配置示例: {filePath}");
        }
        
        /// <summary>
        /// 创建游戏地图示例（二维数组的实际应用）
        /// </summary>
        private static void CreateGameMapExample(string outputDir)
        {
            var filePath = Path.Combine(outputDir, "GameMapConfig.csv");
            var csv = new StringBuilder();
            
            // 游戏地图配置，使用二维数组表示地形
            csv.AppendLine("MapID@All,MapName@Client@Lan,TerrainData@All,EnemySpawns@Server,TreasureLocations@Client");
            csv.AppendLine("int,string,int[][],int[][],int[][]");
            csv.AppendLine("地图ID,地图名称（客户端+多语言）,地形数据,敌人刷新点（服务端）,宝箱位置（客户端）");
            csv.AppendLine("0,\"\",\"\",\"\",\"\"");
            
            // 示例地图数据
            // 地形类型：0=草地，1=石头，2=水，3=树木
            csv.AppendLine("2001,新手村,\"0,0,1,1;0,1,2,2;1,2,3,3;1,1,0,0\",\"0,1;2,3\",\"1,2;3,0\"");
            csv.AppendLine("2002,森林迷宫,\"3,3,3,3,3;3,0,0,0,3;3,0,1,0,3;3,0,0,0,3;3,3,3,3,3\",\"1,1;3,3;1,3\",\"2,2\"");
            csv.AppendLine("2003,水晶洞穴,\"1,1,1;1,2,1;1,1,1\",\"1,0;0,1\",\"1,1\"");
            
            File.WriteAllText(filePath, csv.ToString(), Encoding.UTF8);
            Debug.Log($"创建游戏地图示例: {filePath}");
        }
        
        /// <summary>
        /// 测试二维数组解析
        /// </summary>
        // [MenuItem("NFramework/Test 2D Array Parsing")]  // 已禁用，简化菜单
        public static void Test2DArrayParsing()
        {
            try
            {
                Debug.Log("=== 二维数组解析测试 ===");
                
                // 确保示例文件存在
                Create2DArrayExample();
                
                // 加载并解析二维数组示例
                var configDataDir = Path.Combine(Application.dataPath, "ConfigData", "Excel");
                var csvPath = Path.Combine(configDataDir, "Array2DConfig.csv");
                
                if (File.Exists(csvPath))
                {
                    var input = EnhancedExcelDataLoader.CreatePipelineInput(csvPath, "Array2DConfig", "Array2DTest");
                    
                    // 创建管道配置
                    var config = new PipelineConfiguration
                    {
                        EnableSchemaGeneration = true,
                        EnableCodeGeneration = true,
                        EnableLocalization = true
                    };
                    
                    var pipeline = ConfigPipelineFactory.CreateStandardPipeline(config);
                    
                    // 执行处理
                    var result = pipeline.Execute(input);
                    
                    if (result.Success)
                    {
                        Debug.Log("✓ 二维数组解析测试成功");
                        Debug.Log($"生成的文件: {string.Join(", ", result.GeneratedFiles.Keys)}");
                        
                        // 显示Schema信息
                        if (result.Logs.Count > 0)
                        {
                            foreach (var log in result.Logs)
                            {
                                if (log.Contains("二维数组") || log.Contains("2D") || log.Contains("Matrix"))
                                {
                                    Debug.Log($"  二维数组处理: {log}");
                                }
                            }
                        }
                    }
                    else
                    {
                        Debug.LogError("✗ 二维数组解析测试失败");
                        foreach (var error in result.Errors)
                        {
                            Debug.LogError($"    {error}");
                        }
                    }
                }
                else
                {
                    Debug.LogError($"测试文件不存在: {csvPath}");
                }
            }
            catch (System.Exception ex)
            {
                Debug.LogError($"二维数组解析测试异常: {ex.Message}");
            }
        }
        
        /// <summary>
        /// 显示二维数组使用说明
        /// </summary>
        // [MenuItem("NFramework/Show 2D Array Usage")]  // 已禁用，简化菜单
        public static void Show2DArrayUsage()
        {
            var message = @"二维数组使用说明:

支持的类型语法:
✅ int[][]              - C#风格二维数组
✅ repeated repeated int - FlatBuffer风格二维数组
✅ string[][]           - 字符串二维数组
✅ float[][]            - 浮点数二维数组

数据格式:
- 使用分号(;)分隔行
- 使用逗号(,)分隔列
- 示例: ""1,2,3;4,5,6;7,8,9""

实际应用场景:
1. 游戏地图地形数据
2. 技能效果矩阵
3. 属性加成表格
4. 关卡设计数据

示例:
Matrix@All -> int[][]
""1,2,3;4,5,6""

生成的访问方法:
- GetMatrix(int row, int col) - 获取指定位置的值
- MatrixRowCount - 获取行数
- GetMatrixColCount(int row) - 获取指定行的列数

注意事项:
- 二维数组在FlatBuffer中会被转换为特殊结构
- 支持不规则数组（每行列数可以不同）
- 可以与其他标记组合使用（@Client, @Server, @Lan等）";

            EditorUtility.DisplayDialog("二维数组使用说明", message, "确定");
        }
    }
}
