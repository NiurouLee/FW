using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 配置工具类
    /// </summary>
    public static class ConfigUtils
    {
        /// <summary>
        /// 获取字段类型
        /// </summary>
        public static Type GetFieldType(string typeString)
        {
            switch (typeString.ToLower())
            {
                case "int":
                case "int32":
                    return typeof(int);
                case "long":
                case "int64":
                    return typeof(long);
                case "float":
                case "single":
                    return typeof(float);
                case "double":
                    return typeof(double);
                case "bool":
                case "boolean":
                    return typeof(bool);
                case "string":
                    return typeof(string);
                default:
                    return null;
            }
        }

        /// <summary>
        /// 解析字段值
        /// </summary>
        public static object ParseFieldValue(string value, string typeString)
        {
            if (string.IsNullOrEmpty(value))
                return null;

            try
            {
                var type = GetFieldType(typeString);
                if (type == null)
                    return value;

                if (type == typeof(int))
                    return int.Parse(value);
                if (type == typeof(long))
                    return long.Parse(value);
                if (type == typeof(float))
                    return float.Parse(value);
                if (type == typeof(double))
                    return double.Parse(value);
                if (type == typeof(bool))
                    return bool.Parse(value);

                return value;
            }
            catch (Exception ex)
            {
                Debug.LogError($"Failed to parse value '{value}' as {typeString}: {ex.Message}");
                return null;
            }
        }

        /// <summary>
        /// 检查是否是引用类型
        /// </summary>
        public static bool IsReferenceType(string typeString)
        {
            if (string.IsNullOrEmpty(typeString))
                return false;

            // 移除数组标记和可空标记
            typeString = typeString.Replace("[]", "").Replace("?", "");

            // 如果不是基本类型，就认为是引用类型
            return GetFieldType(typeString) == null;
        }

        /// <summary>
        /// 获取引用的配置类型
        /// </summary>
        public static string GetReferencedConfigType(string typeString)
        {
            if (string.IsNullOrEmpty(typeString))
                return null;

            // 移除数组标记和可空标记
            typeString = typeString.Replace("[]", "").Replace("?", "");

            // 如果是基本类型，返回null
            return GetFieldType(typeString) == null ? typeString : null;
        }

        /// <summary>
        /// 检查是否是数组类型
        /// </summary>
        public static bool IsArrayType(string typeString)
        {
            return !string.IsNullOrEmpty(typeString) && typeString.Contains("[]");
        }

        /// <summary>
        /// 检查是否是可空类型
        /// </summary>
        public static bool IsNullableType(string typeString)
        {
            return !string.IsNullOrEmpty(typeString) && typeString.EndsWith("?");
        }

        /// <summary>
        /// 从DataTable中提取字段定义
        /// </summary>
        public static List<FieldDefinition> ExtractFieldDefinitions(DataTable table)
        {
            var fields = new List<FieldDefinition>();

            if (table.Rows.Count < 1)
                return fields;

            // 假设第一行是字段名，第二行是类型
            for (int i = 0; i < table.Columns.Count; i++)
            {
                var fieldName = table.Columns[i].ColumnName;
                var fieldType = table.Rows[0][i].ToString();

                fields.Add(new FieldDefinition
                {
                    Name = fieldName,
                    Type = fieldType,
                    IsArray = IsArrayType(fieldType),
                    IsRequired = !IsNullableType(fieldType)
                });
            }

            return fields;
        }

        /// <summary>
        /// 验证引用完整性
        /// </summary>
        public static bool ValidateReferences(Dictionary<string, HashSet<string>> references, out List<string> errors)
        {
            errors = new List<string>();

            foreach (var kvp in references)
            {
                foreach (var refId in kvp.Value)
                {
                    if (!references.ContainsKey(refId))
                    {
                        errors.Add($"Invalid reference: {kvp.Key} -> {refId}");
                    }
                }
            }

            return errors.Count == 0;
        }

        /// <summary>
        /// 检测循环引用
        /// </summary>
        public static bool DetectCircularReferences(Dictionary<string, HashSet<string>> references, out List<string> circularPaths)
        {
            circularPaths = new List<string>();
            var visited = new HashSet<string>();
            var recursionStack = new HashSet<string>();

            foreach (var configId in references.Keys)
            {
                if (!visited.Contains(configId))
                {
                    var path = new List<string>();
                    if (HasCircularReference(configId, references, visited, recursionStack, path))
                    {
                        circularPaths.Add(string.Join(" -> ", path) + " -> " + path[0]);
                    }
                }
            }

            return circularPaths.Count == 0;
        }

        private static bool HasCircularReference(
            string current,
            Dictionary<string, HashSet<string>> references,
            HashSet<string> visited,
            HashSet<string> recursionStack,
            List<string> path)
        {
            visited.Add(current);
            recursionStack.Add(current);
            path.Add(current);

            if (references.TryGetValue(current, out var deps))
            {
                foreach (var dep in deps)
                {
                    if (!visited.Contains(dep))
                    {
                        if (HasCircularReference(dep, references, visited, recursionStack, path))
                            return true;
                    }
                    else if (recursionStack.Contains(dep))
                    {
                        path.Add(dep);
                        return true;
                    }
                }
            }

            recursionStack.Remove(current);
            path.RemoveAt(path.Count - 1);
            return false;
        }
    }
}
