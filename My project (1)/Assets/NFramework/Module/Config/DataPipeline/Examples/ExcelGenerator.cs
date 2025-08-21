using System;
using System.IO;
using UnityEngine;
using UnityEditor;

namespace NFramework.Module.Config.DataPipeline.Examples
{
    /// <summary>
    /// Excel示例文件生成器（CSV格式）
    /// </summary>
    public static class ExcelGenerator
    {
        /// <summary>
        /// 创建示例Excel文件（CSV格式）
        /// </summary>
        // [MenuItem("NFramework/Generate Sample Excel Files (CSV Format)")]  // 已禁用，简化菜单
        public static void CreateSampleExcelFiles()
        {
            var outputDir = Path.Combine(Application.dataPath, "ConfigData", "Excel");
            Directory.CreateDirectory(outputDir);
            
            // 创建角色配置示例
            CreateCharacterConfigExample(outputDir);
            
            // 创建技能配置示例
            CreateSkillConfigExample(outputDir);
            
            // 创建物品配置示例
            CreateItemConfigExample(outputDir);
            
            Debug.Log($"示例配置文件已创建在: {outputDir}");
            Debug.Log("注意：生成的是CSV文件，可以用Excel打开并编辑");
            
            // 刷新Asset Database
            AssetDatabase.Refresh();
        }
        
        /// <summary>
        /// 创建角色配置示例
        /// </summary>
        private static void CreateCharacterConfigExample(string outputDir)
        {
            var filePath = Path.Combine(outputDir, "CharacterConfig.csv");
            var csv = new System.Text.StringBuilder();
            
            // 第一行：字段名（包含标记）
            csv.AppendLine("ID@All,Name@Lan,Description@Client,Level@Server,SkillId@Ref,HP,MP,Skills@All,Attributes@All,InternalNotes@PM");
            
            // 第二行：字段类型
            csv.AppendLine("int,string,string,int,int,int,int,repeated int,map<string;int>,string");
            
            // 第三行：字段描述
            csv.AppendLine("角色唯一ID,角色名称（多语言）,角色描述（仅客户端）,角色等级（仅服务端）,默认技能ID（引用Skill表）,生命值,魔法值,技能列表,属性映射,内部备注（不生成代码）");
            
            // 第四行：字段默认值
            csv.AppendLine("0,\"\",\"\",1,0,100,50,\"\",\"\",\"\"");
            
            // 数据行
            csv.AppendLine("1001,战士,\"强大的近战职业，擅长近身作战\",10,2001,150,30,\"2001;2002;2003\",\"STR:20;DEF:15;AGI:8\",主要职业之一");
            csv.AppendLine("1002,法师,\"精通各种魔法的职业，远程攻击专家\",8,2004,80,120,\"2004;2005;2006\",\"INT:25;DEF:5;AGI:12\",魔法系职业");
            csv.AppendLine("1003,弓箭手,\"远程物理攻击专家，敏捷型职业\",9,2007,100,60,\"2007;2008;2009\",\"AGI:22;STR:12;DEF:8\",敏捷系职业");
            csv.AppendLine("1004,牧师,\"治疗和辅助专家，团队不可缺少\",7,2010,90,100,\"2010;2011;2012\",\"INT:18;DEF:12;AGI:10\",辅助系职业");
            
            File.WriteAllText(filePath, csv.ToString(), System.Text.Encoding.UTF8);
            Debug.Log($"创建角色配置示例: {filePath}");
        }
        
        /// <summary>
        /// 创建技能配置示例
        /// </summary>
        private static void CreateSkillConfigExample(string outputDir)
        {
            var filePath = Path.Combine(outputDir, "SkillConfig.csv");
            var csv = new System.Text.StringBuilder();
            
            // 表头
            csv.AppendLine("ID@All,Name@Lan,Description@Lan,Type@All,Damage@Server,CoolDown@All,ManaCost@All,Effects@All");
            csv.AppendLine("int,string,string,int,int,float,int,repeated string");
            csv.AppendLine("技能ID,技能名称,技能描述,技能类型,伤害值,冷却时间,魔法消耗,技能效果");
            csv.AppendLine("0,\"\",\"\",1,0,1.0,0,\"\"");
            
            // 数据
            csv.AppendLine("2001,重击,对单个敌人造成大量物理伤害,1,50,3.0,10,\"DAMAGE;STUN\"");
            csv.AppendLine("2002,防御姿态,提高自身防御力,2,0,5.0,5,DEFENSE_UP");
            csv.AppendLine("2003,战吼,提升队友攻击力,3,0,30.0,15,\"TEAM_BUFF;ATK_UP\"");
            csv.AppendLine("2004,火球术,发射火球攻击敌人,1,80,2.5,20,\"DAMAGE;BURN\"");
            csv.AppendLine("2005,冰冻术,冻结敌人,4,30,4.0,25,\"DAMAGE;FREEZE\"");
            csv.AppendLine("2006,闪电术,召唤闪电攻击敌人,1,70,2.0,18,\"DAMAGE;SHOCK\"");
            csv.AppendLine("2007,精准射击,远程精准攻击,1,60,2.5,8,\"DAMAGE;CRIT\"");
            csv.AppendLine("2008,多重射击,同时攻击多个敌人,1,40,4.0,12,\"DAMAGE;MULTI_TARGET\"");
            csv.AppendLine("2009,隐身,进入隐身状态,5,0,10.0,20,STEALTH");
            csv.AppendLine("2010,治疗术,恢复队友生命值,6,0,3.0,15,HEAL");
            csv.AppendLine("2011,群体治疗,恢复全队生命值,6,0,8.0,30,\"HEAL;AREA\"");
            csv.AppendLine("2012,神圣护盾,为队友提供护盾,7,0,15.0,25,\"SHIELD;BUFF\"");
            
            File.WriteAllText(filePath, csv.ToString(), System.Text.Encoding.UTF8);
            Debug.Log($"创建技能配置示例: {filePath}");
        }
        
        /// <summary>
        /// 创建物品配置示例
        /// </summary>
        private static void CreateItemConfigExample(string outputDir)
        {
            var filePath = Path.Combine(outputDir, "ItemConfig.csv");
            var csv = new System.Text.StringBuilder();
            
            // 表头
            csv.AppendLine("ID@All,Name@Lan,Description@Lan,Type@All,Rarity@All,Price@Client,DropRate@Server,Properties@All,Stackable@All");
            csv.AppendLine("int,string,string,int,int,int,float,map<string;int>,bool");
            csv.AppendLine("物品ID,物品名称,物品描述,物品类型,稀有度,价格,掉落率,属性加成,可堆叠");
            csv.AppendLine("0,\"\",\"\",1,1,0,0.0,\"\",true");
            
            // 数据
            csv.AppendLine("3001,铁剑,普通的铁制长剑,1,1,100,0.1,\"ATK:10;DUR:50\",false");
            csv.AppendLine("3002,生命药水,恢复50点生命值,2,1,50,0.3,HP:50,true");
            csv.AppendLine("3003,魔法药水,恢复30点魔法值,2,1,40,0.3,MP:30,true");
            csv.AppendLine("3004,钢铁盔甲,坚固的钢铁护甲,3,2,500,0.05,\"DEF:25;DUR:100\",false");
            csv.AppendLine("3005,传说之剑,传说中的神器,1,5,10000,0.001,\"ATK:100;CRI:20;DUR:500\",false");
            csv.AppendLine("3006,魔法戒指,增加魔法力的戒指,4,3,800,0.02,\"INT:15;MP:20\",false");
            csv.AppendLine("3007,敏捷靴,提升移动速度的靴子,5,2,300,0.08,\"AGI:12;SPD:10\",false");
            csv.AppendLine("3008,复活卷轴,复活倒下的队友,6,4,2000,0.005,REVIVE:1,true");
            
            File.WriteAllText(filePath, csv.ToString(), System.Text.Encoding.UTF8);
            Debug.Log($"创建物品配置示例: {filePath}");
        }

    }
}
