using System.IO;
using System.Text;
using UnityEngine;
using UnityEditor;
using NFramework.Module.Config.DataPipeline;

namespace NFramework.Module.Config.DataPipeline.Examples
{
    /// <summary>
    /// 多标记组合示例
    /// </summary>
    public static class MultiTagExample
    {
        /// <summary>
        /// 创建多标记组合示例文件
        /// </summary>
        // [MenuItem("NFramework/Generate Multi-Tag Example")]  // 已禁用，简化菜单
        public static void CreateMultiTagExample()
        {
            var outputDir = Path.Combine(Application.dataPath, "ConfigData", "Excel");
            Directory.CreateDirectory(outputDir);
            
            CreateMultiTagCharacterExample(outputDir);
            CreateMultiTagItemExample(outputDir);
            
            Debug.Log($"多标记示例文件已创建在: {outputDir}");
            Debug.Log("这些示例展示了如何在一个字段上使用多个标记");
            
            AssetDatabase.Refresh();
        }
        
        /// <summary>
        /// 创建多标记角色配置示例
        /// </summary>
        private static void CreateMultiTagCharacterExample(string outputDir)
        {
            var filePath = Path.Combine(outputDir, "MultiTagCharacterConfig.csv");
            var csv = new StringBuilder();
            
            // 演示各种标记组合
            csv.AppendLine("ID@All,Name@Client@Lan,Description@Client@Lan,ServerData@Server,SkillId@Client@Ref,AdminNotes@PM,Level@Server@Ref,Equipment@All@Ref");
            csv.AppendLine("int,string,string,string,int,string,int,repeated int");
            csv.AppendLine("角色ID,角色名称（客户端+多语言）,角色描述（客户端+多语言）,服务端数据,技能ID（客户端+引用）,管理员备注（不生成代码）,等级（服务端+引用）,装备列表（全部+引用）");
            csv.AppendLine("0,\"\",\"\",\"\",0,\"\",1,\"\"");
            
            // 示例数据
            csv.AppendLine("1001,战士,\"强大的近战职业，适合新手玩家\",\"internal_warrior_data\",2001,\"这是管理员的内部备注\",10,\"3001;3004;3007\"");
            csv.AppendLine("1002,法师,\"精通魔法的职业，需要策略思考\",\"internal_mage_data\",2004,\"法师职业平衡性需要调整\",8,\"3002;3003;3006\"");
            csv.AppendLine("1003,弓箭手,\"远程攻击专家，灵活机动\",\"internal_archer_data\",2007,\"弓箭手的攻击距离可能需要调整\",9,\"3001;3007;3008\"");
            
            File.WriteAllText(filePath, csv.ToString(), Encoding.UTF8);
            Debug.Log($"创建多标记角色配置示例: {filePath}");
        }
        
        /// <summary>
        /// 创建多标记物品配置示例
        /// </summary>
        private static void CreateMultiTagItemExample(string outputDir)
        {
            var filePath = Path.Combine(outputDir, "MultiTagItemConfig.csv");
            var csv = new StringBuilder();
            
            // 演示更复杂的标记组合
            csv.AppendLine("ID@All,Name@Client@Lan,Description@Client@Lan,Price@Client,DropRate@Server,AdminPrice@Server@PM,Properties@All,RequiredLevel@Client@Ref");
            csv.AppendLine("int,string,string,int,float,int,map<string;int>,int");
            csv.AppendLine("物品ID,物品名称（客户端+多语言）,物品描述（客户端+多语言）,客户端价格,服务端掉落率,管理员价格（服务端+不生成代码）,属性加成,需求等级（客户端+引用）");
            csv.AppendLine("0,\"\",\"\",0,0.0,0,\"\",1");
            
            // 示例数据
            csv.AppendLine("4001,魔法剑,\"注入了魔法力量的神秘武器\",1500,0.02,500,\"ATK:50;MAG:20;DUR:200\",15");
            csv.AppendLine("4002,治疗药剂,\"快速恢复生命值的珍贵药剂\",200,0.15,50,\"HP:100;HEAL_SPEED:2\",5");
            csv.AppendLine("4003,隐身斗篷,\"让穿戴者能够隐身的神奇斗篷\",3000,0.005,1000,\"STEALTH:60;AGI:15;DUR:150\",20");
            
            File.WriteAllText(filePath, csv.ToString(), Encoding.UTF8);
            Debug.Log($"创建多标记物品配置示例: {filePath}");
        }
        
        /// <summary>
        /// 测试多标记解析
        /// </summary>
        // [MenuItem("NFramework/Test Multi-Tag Parsing")]  // 已禁用，简化菜单
        public static void TestMultiTagParsing()
        {
            try
            {
                Debug.Log("=== 多标记解析测试 ===");
                
                // 确保示例文件存在
                CreateMultiTagExample();
                
                // 加载并解析多标记示例
                var configDataDir = Path.Combine(Application.dataPath, "ConfigData", "Excel");
                var csvPath = Path.Combine(configDataDir, "MultiTagCharacterConfig.csv");
                
                if (File.Exists(csvPath))
                {
                    var input = EnhancedExcelDataLoader.CreatePipelineInput(csvPath, "MultiTagCharacter", "MultiTagTest");
                    
                    // 创建管道配置
                    var config = new PipelineConfiguration
                    {
                        EnableSchemaGeneration = true,
                        EnableLocalization = true,
                        EnableReferenceResolution = true,
                        EnableCodeGeneration = true
                    };
                    
                    var pipeline = ConfigPipelineFactory.CreateStandardPipeline(config);
                    
                    // 执行处理
                    var result = pipeline.Execute(input);
                    
                    if (result.Success)
                    {
                        Debug.Log("✓ 多标记解析测试成功");
                        Debug.Log($"处理日志: {string.Join("; ", result.Logs)}");
                        
                        if (result.Warnings.Count > 0)
                        {
                            Debug.Log($"警告信息: {string.Join("; ", result.Warnings)}");
                        }
                    }
                    else
                    {
                        Debug.LogError("✗ 多标记解析测试失败");
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
                Debug.LogError($"多标记解析测试异常: {ex.Message}");
            }
        }
        
        /// <summary>
        /// 显示多标记使用说明
        /// </summary>
        // [MenuItem("NFramework/Show Multi-Tag Usage")]  // 已禁用，简化菜单
        public static void ShowMultiTagUsage()
        {
            var message = @"多标记组合使用说明:

支持的标记组合:
✅ Name@Client@Lan        - 客户端 + 多语言
✅ Description@Server@Lan - 服务端 + 多语言  
✅ SkillId@Client@Ref     - 客户端 + 引用
✅ Level@Server@Ref       - 服务端 + 引用
✅ Notes@PM               - 不生成代码（PM优先级最高）

标记优先级:
1. @PM - 最高优先级，直接跳过代码生成
2. @Client/@Server - 生成类型标记
3. @All - 默认生成类型
4. @Lan/@Ref - 功能标记，可与生成类型组合

示例:
- Name@Client@Lan: 只在客户端生成，且支持多语言
- SkillId@Server@Ref: 只在服务端生成，且自动生成引用访问器
- AdminData@PM: 完全不生成任何代码

注意事项:
- 标记顺序不重要: @Client@Lan 等同于 @Lan@Client
- PM标记会覆盖其他所有标记
- 如果没有指定生成类型，默认为@All
- 功能标记(@Lan, @Ref)可以与任何生成类型组合";

            EditorUtility.DisplayDialog("多标记使用说明", message, "确定");
        }
    }
}
