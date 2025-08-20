
using System;
using System.Collections.Generic;
using Unity.VisualScripting;

namespace NFramework.Module.ConfigModule
{
    /// <summary>
    /// 生成一个FBS struct 结构
    /// </summary>
    public static class Excel2FbsStructs
    {

        public static string RepeatedPrefix = "repeated";
        public static string RepeatedSuffix = "[]";
        public static string MapPrefix = "map";


        private static readonly Dictionary<string, string> TypeMapping = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
    {
        { "int", "int" },
        { "integer", "int" },
        { "long", "long" },
        { "float", "float" },
        { "double", "double" },
        { "bool", "bool" },
        { "boolean", "bool" },
        { "string", "string" },
        { "short", "short" },
        { "ushort", "ushort" },
        { "uint", "uint" },
        { "ulong", "ulong" },
        { "byte", "byte" },
        { "sbyte", "sbyte" }
    };
        public static List<FbsStruct> Convert(ExcelHeader inHeaders)
        {
            var fbsStructs = new List<FbsStruct>();
            ConvertMainStruct(inHeaders, fbsStructs);
            return fbsStructs;
        }

        public static void ConvertMainStruct(ExcelHeader inHeader, List<FbsStruct> outFbsStructs)
        {
            var fbsMainStruct = new FbsStruct();
            fbsMainStruct.Name = inHeader.SheetName;
            fbsMainStruct.Des = inHeader.SheetName;
            foreach (var column in inHeader.Columns)
            {
                var fbsField = new FbsField(column);
                fbsMainStruct.Fields.Add(fbsField);
            }
            outFbsStructs.Add(fbsMainStruct);
            ConvertSubStruct(fbsMainStruct, outFbsStructs);
        }

        /// <summary>
        /// 子结构
        /// </summary>
        /// <param name="inFbsStruct"></param>
        /// <param name="outFbsStructs"></param>
        private static void ConvertSubStruct(FbsStruct inFbsStruct, List<FbsStruct> outFbsStructs)
        {
            foreach (var field in inFbsStruct.Fields)
            {
                if (field.IsSubType())
                {
                    outFbsStructs.Add(field.GetSubFbsStruct());
                }
            }
        }

        /// <summary>
        /// Type 转换
        /// </summary>
        /// <param name="excelType"></param>
        /// <returns></returns>
        private static string ConvertToFbsType(string excelType)
        {
            if (string.IsNullOrEmpty(excelType))
                return "string"; // 默认类型

            // 移除可能的空格和特殊字符
            string cleanType = excelType.Trim().ToLower();

            // 检查是否是数组类型
            if (cleanType.Contains("["))
            {
                // 提取基础类型
                string baseType = cleanType.Split('[')[0].Trim();

                // 提取数组维度
                string arrayPart = cleanType.Substring(cleanType.IndexOf('['));
                arrayPart = arrayPart.Replace(" ", ""); // 移除空格

                // 转换基础类型
                if (TypeMapping.TryGetValue(baseType, out string fbsBaseType))
                {
                    return $"{fbsBaseType}{arrayPart}";
                }

                // 如果基础类型不匹配，使用string
                return $"string{arrayPart}";
            }

            // 查找对应的FBS类型
            if (TypeMapping.TryGetValue(cleanType, out string fbsType))
            {
                return fbsType;
            }

            // 如果没有找到匹配的类型，返回string
            return "string";
        }
    }



}
