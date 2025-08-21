using System;
using System.IO;
using System.Text;
using UnityEngine;
using UnityEditor;

namespace NFramework.Module.Config.DataPipeline.Examples
{
    /// <summary>
    /// 简单的Excel示例文件生成器（生成CSV格式，可在Excel中打开）
    /// </summary>
    public static class SimpleExcelGenerator
    {
        /// <summary>
        /// 创建示例CSV文件
        /// </summary>
        [MenuItem("NFramework/1. Generate Sample CSV Files")]
        public static void CreateSampleConfigFiles()
        {
            var outputDir = Path.Combine(Application.dataPath, "ConfigData", "Excel");
            Directory.CreateDirectory(outputDir);
            
            // 创建角色配置示例
            CreateCharacterConfigCSV(outputDir);
            
            // 创建技能配置示例
            CreateSkillConfigCSV(outputDir);
            
            // 创建物品配置示例
            CreateItemConfigCSV(outputDir);
            
            // 创建二维数组示例
            Create2DArrayConfigCSV(outputDir);
            
            // 创建多标记示例
            MultiTagExample.CreateMultiTagExample();
            
            // 创建二维数组高级示例
            Array2DExample.Create2DArrayExample();
            
            Debug.Log($"示例配置文件已创建在: {outputDir}");
            Debug.Log("包含：基础配置、多标记组合、二维数组等所有功能示例");
            Debug.Log("注意：生成的是CSV文件，可以用Excel打开并编辑");
            
            // 刷新Asset Database
            AssetDatabase.Refresh();
        }
        
        /// <summary>
        /// 创建角色配置CSV示例
        /// </summary>
        private static void CreateCharacterConfigCSV(string outputDir)
        {
            var filePath = Path.Combine(outputDir, "CharacterConfig.csv");
            var sb = new StringBuilder();
            
            // 第一行：字段名（包含标记）
            sb.AppendLine("ID@All,Name@Lan,Description@Client,Level@Server,SkillId@ref_skill,HP,MP,Skills@ref_skill,Attributes@All,InternalNotes@PM");
            
            // 第二行：字段类型
            sb.AppendLine("int,string,string,int,int,int,int,repeated int,map<string;int>,string");
            
            // 第三行：字段描述
            sb.AppendLine("角色唯一ID,角色名称（多语言）,角色描述（仅客户端）,角色等级（仅服务端）,默认技能ID（引用Skill表）,生命值,魔法值,技能列表（引用Skill表）,属性映射,内部备注（不生成代码）");
            
            // 第四行：字段默认值
            sb.AppendLine("0,,\"\",1,0,100,50,\"\",\"\",\"\"");
            
            // 数据行
            sb.AppendLine("1001,战士,强大的近战职业；擅长近身作战,10,2001,150,30,2001;2002;2003,STR:20;DEF:15;AGI:8,主要职业之一");
            sb.AppendLine("1002,法师,精通各种魔法的职业；远程攻击专家,8,2004,80,120,2004;2005;2006,INT:25;DEF:5;AGI:12,魔法系职业");
            sb.AppendLine("1003,弓箭手,远程物理攻击专家；敏捷型职业,9,2007,100,60,2007;2008;2009,AGI:22;STR:12;DEF:8,敏捷系职业");
            sb.AppendLine("1004,牧师,治疗和辅助专家；团队不可缺少,7,2010,90,100,2010;2011;2012,INT:18;DEF:12;AGI:10,辅助系职业");
            
            File.WriteAllText(filePath, sb.ToString(), Encoding.UTF8);
            Debug.Log($"创建角色配置示例: {filePath}");
        }
        
        /// <summary>
        /// 创建技能配置CSV示例
        /// </summary>
        private static void CreateSkillConfigCSV(string outputDir)
        {
            var filePath = Path.Combine(outputDir, "SkillConfig.csv");
            var sb = new StringBuilder();
            
            // 表头
            sb.AppendLine("ID@All,Name@Lan,Description@Lan,Type@All,Damage@Server,CoolDown@All,ManaCost@All,Effects@All,RequiredItem@ref_item");
            sb.AppendLine("int,string,string,int,int,float,int,repeated string,int");
            sb.AppendLine("技能ID,技能名称,技能描述,技能类型,伤害值,冷却时间,魔法消耗,技能效果,需求物品（引用Item表）");
            sb.AppendLine("0,\"\",\"\",1,0,1.0,0,\"\",0");
            
            // 数据
            sb.AppendLine("2001,重击,对单个敌人造成大量物理伤害,1,50,3.0,10,DAMAGE;STUN,3001");
            sb.AppendLine("2002,防御姿态,提高自身防御力,2,0,5.0,5,DEFENSE_UP,3004");
            sb.AppendLine("2003,战吼,提升队友攻击力,3,0,30.0,15,TEAM_BUFF;ATK_UP,0");
            sb.AppendLine("2004,火球术,发射火球攻击敌人,1,80,2.5,20,DAMAGE;BURN,3006");
            sb.AppendLine("2005,冰冻术,冻结敌人,4,30,4.0,25,DAMAGE;FREEZE,3006");
            sb.AppendLine("2006,闪电术,召唤闪电攻击敌人,1,70,2.0,18,DAMAGE;SHOCK,3006");
            sb.AppendLine("2007,精准射击,远程精准攻击,1,60,2.5,8,DAMAGE;CRIT,3007");
            sb.AppendLine("2008,多重射击,同时攻击多个敌人,1,40,4.0,12,DAMAGE;MULTI_TARGET,3007");
            sb.AppendLine("2009,隐身,进入隐身状态,5,0,10.0,20,STEALTH,3007");
            sb.AppendLine("2010,治疗术,恢复队友生命值,6,0,3.0,15,HEAL,3002");
            sb.AppendLine("2011,群体治疗,恢复全队生命值,6,0,8.0,30,HEAL;AREA,3002");
            sb.AppendLine("2012,神圣护盾,为队友提供护盾,7,0,15.0,25,SHIELD;BUFF,3006");
            
            File.WriteAllText(filePath, sb.ToString(), Encoding.UTF8);
            Debug.Log($"创建技能配置示例: {filePath}");
        }
        
        /// <summary>
        /// 创建物品配置CSV示例
        /// </summary>
        private static void CreateItemConfigCSV(string outputDir)
        {
            var filePath = Path.Combine(outputDir, "ItemConfig.csv");
            var sb = new StringBuilder();
            
            // 表头
            sb.AppendLine("ID@All,Name@Lan,Description@Lan,Type@All,Rarity@All,Price@Client,DropRate@Server,Properties@All,Stackable@All");
            sb.AppendLine("int,string,string,int,int,int,float,map<string;int>,bool");
            sb.AppendLine("物品ID,物品名称,物品描述,物品类型,稀有度,价格,掉落率,属性加成,可堆叠");
            sb.AppendLine("0,\"\",\"\",1,1,0,0.0,\"\",true");
            
            // 数据
            sb.AppendLine("3001,铁剑,普通的铁制长剑,1,1,100,0.1,ATK:10;DUR:50,false");
            sb.AppendLine("3002,生命药水,恢复50点生命值,2,1,50,0.3,HP:50,true");
            sb.AppendLine("3003,魔法药水,恢复30点魔法值,2,1,40,0.3,MP:30,true");
            sb.AppendLine("3004,钢铁盔甲,坚固的钢铁护甲,3,2,500,0.05,DEF:25;DUR:100,false");
            sb.AppendLine("3005,传说之剑,传说中的神器,1,5,10000,0.001,ATK:100;CRI:20;DUR:500,false");
            sb.AppendLine("3006,魔法戒指,增加魔法力的戒指,4,3,800,0.02,INT:15;MP:20,false");
            sb.AppendLine("3007,敏捷靴,提升移动速度的靴子,5,2,300,0.08,AGI:12;SPD:10,false");
            sb.AppendLine("3008,复活卷轴,复活倒下的队友,6,4,2000,0.005,REVIVE:1,true");
            
            File.WriteAllText(filePath, sb.ToString(), Encoding.UTF8);
            Debug.Log($"创建物品配置示例: {filePath}");
        }
        
        /// <summary>
        /// 创建二维数组配置示例
        /// </summary>
        private static void Create2DArrayConfigCSV(string outputDir)
        {
            var filePath = Path.Combine(outputDir, "Array2DConfig.csv");
            var sb = new StringBuilder();
            
            // 表头 - 演示各种二维数组类型和标记组合
            sb.AppendLine("ID@All,Matrix@All,GameBoard@Client,ServerGrid@Server,LocalizedMatrix@Client@Lan");
            sb.AppendLine("int,int[][],repeated repeated int,float[][],string[][]");
            sb.AppendLine("配置ID,整数矩阵,游戏棋盘（客户端）,服务端网格（浮点），本地化矩阵（客户端+多语言）");
            sb.AppendLine("0,\"\",\"\",\"\",\"\"");
            
            // 示例数据 - 使用分号分隔行，逗号分隔列
            sb.AppendLine("1001,\"1,2,3;4,5,6;7,8,9\",\"0,0,1;0,1,0;1,0,0\",\"1.0,2.5;3.2,4.8\",\"Hello,World;你好,世界\"");
            sb.AppendLine("1002,\"10,20;30,40\",\"1,1,1;1,1,1;1,1,1\",\"0.1,0.2,0.3;0.4,0.5,0.6\",\"Title,Content;标题,内容\"");
            sb.AppendLine("1003,\"100;200;300\",\"2,2,2;2,2,2\",\"10.5,20.5\",\"Start,End;开始,结束\"");
            sb.AppendLine("1004,\"1,2,3,4;5,6,7,8;9,10,11,12\",\"3,3,3,3;3,3,3,3\",\"100.0;200.0;300.0\",\"A,B,C;D,E,F\"");
            
            File.WriteAllText(filePath, sb.ToString(), Encoding.UTF8);
            Debug.Log($"创建二维数组配置示例: {filePath}");
        }

        /// <summary>
        /// 将CSV文件转换为Excel格式的说明
        /// </summary>
        // [MenuItem("NFramework/Show CSV to Excel Instructions")]  // 已禁用，简化菜单
        public static void ShowCSVToExcelInstructions()
        {
            var message = @"CSV to Excel 转换说明:

1. 打开生成的 .csv 文件（使用Excel或其他表格软件）

2. 数据格式说明：
   - 第1行：字段名（包含特殊标记）
   - 第2行：字段类型
   - 第3行：字段描述
   - 第4行：字段默认值
   - 第5行开始：实际数据

3. 特殊标记说明：
   @PM     - 不生成任何代码
   @Client - 只生成客户端代码
   @Server - 只生成服务端代码
   @All    - 生成所有代码（默认）
   @Lan    - 多语言字段
   @ref_type - 引用字段（例如：@ref_skill, @ref_item）

4. 复合类型格式：
   - 数组: repeated int 或 int[]
   - Map: map<string;int> (注意用分号分隔)
   - 数据中用分号分隔: ""item1;item2;item3""

5. 保存为 .xlsx 格式后即可使用管道处理

6. 使用菜单 'NFramework/Run Enhanced Pipeline Example' 测试处理";

            EditorUtility.DisplayDialog("CSV to Excel 说明", message, "确定");
        }
    }
}
