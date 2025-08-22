using System;
using System.IO;
using UnityEngine;
using NFramework.Module.Config.DataPipeline;

namespace NFramework.Module.Config.DataPipeline.Examples
{
    /// <summary>
    /// 简单的示例配置文件生成器
    /// </summary>
    public static class SimpleExcelGenerator
    {
        /// <summary>
        /// 创建示例配置文件
        /// </summary>
        public static void CreateSampleConfigFiles()
        {
            try
            {
                var configDir = Path.Combine(Application.dataPath, "ConfigData", "Excel");
                Directory.CreateDirectory(configDir);

                // 创建角色配置
                CreateCharacterConfig(configDir);

                // 创建物品配置
                CreateItemConfig(configDir);

                Debug.Log("示例配置文件创建成功");
            }
            catch (Exception ex)
            {
                Debug.LogError($"创建示例配置文件失败: {ex.Message}");
            }
        }

        private static void CreateCharacterConfig(string configDir)
        {
            var content = "ID,Name,Level,HP,Attack,Defense\n" +
                         "int,string,int,float,float,float\n" +
                         "1,Hero,1,100,10,5\n" +
                         "2,Monster,1,50,5,2\n";

            File.WriteAllText(Path.Combine(configDir, "Character.csv"), content);
        }

        private static void CreateItemConfig(string configDir)
        {
            var content = "ID,Name,Type,Price,Description\n" +
                         "int,string,string,int,string\n" +
                         "1,Sword,Weapon,100,A basic sword\n" +
                         "2,Potion,Consumable,50,Recovers HP\n";

            File.WriteAllText(Path.Combine(configDir, "Item.csv"), content);
        }
    }
}