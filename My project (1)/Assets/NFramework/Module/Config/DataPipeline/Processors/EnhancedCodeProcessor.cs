using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Collections.Generic;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline
{
    public class EnhancedCodeProcessor
    {
        private class FieldInfo
        {
            public string Name { get; set; }
            public string Type { get; set; }
            public bool IsRef { get; set; }
            public bool IsLan { get; set; }
            public string RefType { get; set; }
            public string Comment { get; set; }
        }

        public void ProcessGeneratedCode(string sourceFile)
        {
            if (!File.Exists(sourceFile))
            {
                Debug.LogError($"源文件不存在: {sourceFile}");
                return;
            }

            string content = File.ReadAllText(sourceFile);
            var enhancedContent = ProcessContent(content);
            File.WriteAllText(sourceFile, enhancedContent);
        }

        private string ProcessContent(string content)
        {
            var sb = new StringBuilder();
            var lines = content.Split('\n');
            var inClass = false;
            var className = string.Empty;
            var fields = new List<FieldInfo>();
            FieldInfo currentField = null;

            foreach (var line in lines)
            {
                var trimmedLine = line.Trim();

                // 检测类开始
                if (trimmedLine.Contains(" class ") && trimmedLine.Contains(" : IFlatbufferObject"))
                {
                    inClass = true;
                    className = trimmedLine.Split(' ').First(x => !string.IsNullOrEmpty(x) && x != "public" && x != "class");
                    sb.AppendLine(line);
                    continue;
                }

                // 处理字段注释
                if (inClass && trimmedLine.StartsWith("///"))
                {
                    var comment = trimmedLine.TrimStart('/').Trim();

                    // 检查是否是新字段的开始
                    if (currentField == null)
                    {
                        currentField = new FieldInfo { Comment = comment };
                    }
                    else
                    {
                        currentField.Comment += Environment.NewLine + comment;
                    }

                    // 检查特殊标记
                    if (comment.Contains("@ref"))
                    {
                        currentField.IsRef = true;
                        currentField.RefType = ExtractRefType(comment);
                    }
                    else if (comment.Contains("@lan"))
                    {
                        currentField.IsLan = true;
                    }
                }
                // 处理字段定义
                else if (inClass && currentField != null && trimmedLine.Contains("public") && !trimmedLine.Contains("("))
                {
                    var parts = trimmedLine.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                    currentField.Name = parts.Last().TrimEnd('{', '}', ';');
                    currentField.Type = parts[Array.IndexOf(parts, "public") + 1];
                    fields.Add(currentField);
                    currentField = null;
                }
                // 检测类结束
                else if (inClass && trimmedLine == "}")
                {
                    // 添加扩展方法
                    if (fields.Any(f => f.IsRef || f.IsLan))
                    {
                        sb.AppendLine();

                        // 生成引用访问器
                        foreach (var field in fields.Where(f => f.IsRef))
                        {
                            GenerateRefAccessor(sb, field);
                        }

                        // 生成多语言访问器
                        foreach (var field in fields.Where(f => f.IsLan))
                        {
                            GenerateLanAccessor(sb, field);
                        }
                    }

                    inClass = false;
                }

                sb.AppendLine(line);
            }

            return sb.ToString();
        }

        private void GenerateRefAccessor(StringBuilder sb, FieldInfo field)
        {
            sb.AppendLine($"        /// <summary>");
            sb.AppendLine($"        /// 获取{field.Name}引用的{field.RefType}配置");
            sb.AppendLine($"        /// </summary>");
            sb.AppendLine($"        public {field.RefType} Get{field.Name}Config()");
            sb.AppendLine("        {");
            sb.AppendLine($"            return Framework.I.G<ConfigM>().GetCfg<{field.RefType}>(this.{field.Name});");
            sb.AppendLine("        }");
            sb.AppendLine();
        }

        private void GenerateLanAccessor(StringBuilder sb, FieldInfo field)
        {
            sb.AppendLine($"        /// <summary>");
            sb.AppendLine($"        /// 获取{field.Name}的多语言文本");
            sb.AppendLine($"        /// </summary>");
            sb.AppendLine($"        public string Get{field.Name}Text()");
            sb.AppendLine("        {");
            sb.AppendLine($"            return Framework.I.G<LanM>().GetText(this.{field.Name});");
            sb.AppendLine("        }");
            sb.AppendLine();
        }

        private string ExtractRefType(string comment)
        {
            var start = comment.IndexOf("@ref") + 4;
            var end = comment.IndexOf(" ", start);
            return end < 0 ? comment.Substring(start).Trim() : comment.Substring(start, end - start).Trim();
        }
    }
}
