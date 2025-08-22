using System;
using System.Linq;
using System.Text;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 增强代码生成器
    /// </summary>
    public class EnhancedCodeGenerator : ICodeGenerator
    {
        public string Name => "Enhanced Code Generator";
        public int Priority => 100;
        public bool IsEnabled { get; set; } = true;
        public string TargetLanguage => "C#";
        public string[] SupportedFileExtensions => new[] { ".cs" };

        private readonly EnhancedCodeGenerationSettings _settings;

        public EnhancedCodeGenerator(EnhancedCodeGenerationSettings settings)
        {
            _settings = settings ?? new EnhancedCodeGenerationSettings();
        }

        public CodeGenerationResult Generate(CodeGenerationContext context)
        {
            var result = new CodeGenerationResult();

            try
            {
                if (context.SchemaDefinition == null)
                {
                    context.AddError("Schema definition is missing");
                    result.Success = false;
                    result.Errors.Add("Schema definition is missing");
                    return result;
                }

                // 生成主类文件
                GenerateMainClass(context, result);

                // 生成访问器
                if (_settings.GenerateAccessors)
                {
                    GenerateAccessor(context, result);
                }

                // 生成索引
                if (_settings.GenerateIndexes)
                {
                    GenerateIndexes(context, result);
                }

                // 生成本地化支持
                if (_settings.GenerateLocalization)
                {
                    GenerateLocalization(context, result);
                }

                result.Success = true;
                result.GeneratedTypes.Add(context.SchemaDefinition.TypeName);
                if (_settings.GenerateAccessors)
                {
                    result.GeneratedTypes.Add($"{context.SchemaDefinition.TypeName}Accessor");
                }
            }
            catch (Exception ex)
            {
                context.AddError($"Code generation failed: {ex.Message}");
                result.Success = false;
                result.Errors.Add($"Code generation failed: {ex.Message}");
            }

            return result;
        }

        private void GenerateMainClass(CodeGenerationContext context, CodeGenerationResult result)
        {
            var schema = context.SchemaDefinition;
            var sb = new StringBuilder();

            // 添加using语句
            sb.AppendLine("using System;");
            sb.AppendLine("using System.Collections.Generic;");
            if (_settings.GenerateLocalization)
            {
                sb.AppendLine("using NFramework.Module.Config.Localization;");
            }
            sb.AppendLine();

            // 添加命名空间
            sb.AppendLine($"namespace {_settings.Namespace}");
            sb.AppendLine("{");

            // 添加类注释
            if (_settings.GenerateComments)
            {
                sb.AppendLine("    /// <summary>");
                sb.AppendLine($"    /// {schema.TypeName} 配置类");
                sb.AppendLine("    /// </summary>");
            }

            // 添加类定义
            sb.AppendLine($"    public partial class {schema.TypeName}");
            sb.AppendLine("    {");

            // 添加字段
            foreach (var field in schema.Fields)
            {
                if (_settings.GenerateComments)
                {
                    sb.AppendLine("        /// <summary>");
                    sb.AppendLine($"        /// {field.Name}");
                    sb.AppendLine("        /// </summary>");
                }

                var typeName = GetTypeName(field);
                sb.AppendLine($"        public {typeName} {field.Name} {{ get; set; }}");
                sb.AppendLine();
            }

            // 添加验证方法
            if (_settings.GenerateValidation)
            {
                GenerateValidationMethod(sb, schema);
            }

            sb.AppendLine("    }");
            sb.AppendLine("}");

            // 保存生成的文件
            var fileName = $"{schema.TypeName}.cs";
            result.GeneratedFiles[fileName] = sb.ToString();
        }

        private void GenerateAccessor(CodeGenerationContext context, CodeGenerationResult result)
        {
            var schema = context.SchemaDefinition;
            var sb = new StringBuilder();

            // 添加using语句
            sb.AppendLine("using System;");
            sb.AppendLine("using System.Collections.Generic;");
            sb.AppendLine();

            // 添加命名空间
            sb.AppendLine($"namespace {_settings.Namespace}");
            sb.AppendLine("{");

            // 添加访问器类注释
            if (_settings.GenerateComments)
            {
                sb.AppendLine("    /// <summary>");
                sb.AppendLine($"    /// {schema.TypeName} 配置访问器");
                sb.AppendLine("    /// </summary>");
            }

            // 添加访问器类定义
            sb.AppendLine($"    public class {schema.TypeName}Accessor");
            sb.AppendLine("    {");

            // 添加单例实现
            sb.AppendLine($"        private static {schema.TypeName}Accessor _instance;");
            sb.AppendLine($"        public static {schema.TypeName}Accessor Instance");
            sb.AppendLine("        {");
            sb.AppendLine("            get");
            sb.AppendLine("            {");
            sb.AppendLine("                if (_instance == null)");
            sb.AppendLine("                {");
            sb.AppendLine($"                    _instance = new {schema.TypeName}Accessor();");
            sb.AppendLine("                }");
            sb.AppendLine("                return _instance;");
            sb.AppendLine("            }");
            sb.AppendLine("        }");
            sb.AppendLine();

            // 添加数据字典
            sb.AppendLine($"        private Dictionary<int, {schema.TypeName}> _data = new Dictionary<int, {schema.TypeName}>();");
            sb.AppendLine();

            // 添加基本方法
            sb.AppendLine("        public void Initialize(Dictionary<int, byte[]> rawData)");
            sb.AppendLine("        {");
            sb.AppendLine("            _data.Clear();");
            sb.AppendLine("            foreach (var kvp in rawData)");
            sb.AppendLine("            {");
            sb.AppendLine("                // TODO: 实现数据反序列化");
            sb.AppendLine("            }");
            sb.AppendLine("        }");
            sb.AppendLine();

            sb.AppendLine($"        public {schema.TypeName} Get(int id)");
            sb.AppendLine("        {");
            sb.AppendLine("            return _data.TryGetValue(id, out var item) ? item : null;");
            sb.AppendLine("        }");
            sb.AppendLine();

            sb.AppendLine($"        public IReadOnlyDictionary<int, {schema.TypeName}> GetAll()");
            sb.AppendLine("        {");
            sb.AppendLine("            return _data;");
            sb.AppendLine("        }");

            sb.AppendLine("    }");
            sb.AppendLine("}");

            // 保存生成的文件
            var fileName = $"{schema.TypeName}Accessor.cs";
            result.GeneratedFiles[fileName] = sb.ToString();
        }

        private void GenerateIndexes(CodeGenerationContext context, CodeGenerationResult result)
        {
            var schema = context.SchemaDefinition;
            var sb = new StringBuilder();

            // 添加using语句
            sb.AppendLine("using System;");
            sb.AppendLine("using System.Collections.Generic;");
            sb.AppendLine("using System.Linq;");
            sb.AppendLine();

            // 添加命名空间
            sb.AppendLine($"namespace {_settings.Namespace}");
            sb.AppendLine("{");

            // 添加索引类定义
            sb.AppendLine($"    public partial class {schema.TypeName}");
            sb.AppendLine("    {");

            // 为每个字段生成索引
            foreach (var field in schema.Fields)
            {
                var typeName = GetTypeName(field);
                if (field.IsArray) continue; // 跳过数组字段

                sb.AppendLine($"        private static Dictionary<{typeName}, List<{schema.TypeName}>> _{field.Name}Index;");
                sb.AppendLine();

                sb.AppendLine($"        public static IReadOnlyList<{schema.TypeName}> GetBy{field.Name}({typeName} value)");
                sb.AppendLine("        {");
                sb.AppendLine($"            if (_{field.Name}Index == null)");
                sb.AppendLine("            {");
                sb.AppendLine($"                _{field.Name}Index = new Dictionary<{typeName}, List<{schema.TypeName}>>();");
                sb.AppendLine($"                foreach (var item in {schema.TypeName}Accessor.Instance.GetAll().Values)");
                sb.AppendLine("                {");
                sb.AppendLine($"                    if (!_{field.Name}Index.ContainsKey(item.{field.Name}))");
                sb.AppendLine("                    {");
                sb.AppendLine($"                        _{field.Name}Index[item.{field.Name}] = new List<{schema.TypeName}>();");
                sb.AppendLine("                    }");
                sb.AppendLine($"                    _{field.Name}Index[item.{field.Name}].Add(item);");
                sb.AppendLine("                }");
                sb.AppendLine("            }");
                sb.AppendLine();
                sb.AppendLine($"            return _{field.Name}Index.TryGetValue(value, out var list) ? list : new List<{schema.TypeName}>();");
                sb.AppendLine("        }");
                sb.AppendLine();
            }

            sb.AppendLine("    }");
            sb.AppendLine("}");

            // 保存生成的文件
            var fileName = $"{schema.TypeName}.Indexes.cs";
            result.GeneratedFiles[fileName] = sb.ToString();
        }

        private void GenerateLocalization(CodeGenerationContext context, CodeGenerationResult result)
        {
            var schema = context.SchemaDefinition;
            var sb = new StringBuilder();

            // 添加using语句
            sb.AppendLine("using System;");
            sb.AppendLine("using System.Collections.Generic;");
            sb.AppendLine("using NFramework.Module.Config.Localization;");
            sb.AppendLine();

            // 添加命名空间
            sb.AppendLine($"namespace {_settings.Namespace}");
            sb.AppendLine("{");

            // 添加本地化扩展类定义
            sb.AppendLine($"    public partial class {schema.TypeName}");
            sb.AppendLine("    {");

            // 为每个字符串字段生成本地化方法
            foreach (var field in schema.Fields)
            {
                if (field.Type.ToLower() != "string") continue;

                if (_settings.GenerateComments)
                {
                    sb.AppendLine("        /// <summary>");
                    sb.AppendLine($"        /// 获取本地化的 {field.Name}");
                    sb.AppendLine("        /// </summary>");
                }

                sb.AppendLine($"        public string Get{field.Name}Localized(string language = null)");
                sb.AppendLine("        {");
                sb.AppendLine($"            return LocalizationManager.GetText({field.Name}, language);");
                sb.AppendLine("        }");
                sb.AppendLine();
            }

            sb.AppendLine("    }");
            sb.AppendLine("}");

            // 保存生成的文件
            var fileName = $"{schema.TypeName}.Localization.cs";
            result.GeneratedFiles[fileName] = sb.ToString();
        }

        private void GenerateValidationMethod(StringBuilder sb, SchemaDefinition schema)
        {
            sb.AppendLine("        public bool Validate(out string error)");
            sb.AppendLine("        {");
            sb.AppendLine("            error = null;");
            sb.AppendLine();

            // 验证必需字段
            foreach (var field in schema.Fields.Where(f => f.IsRequired))
            {
                if (field.Type.ToLower() == "string")
                {
                    sb.AppendLine($"            if (string.IsNullOrEmpty({field.Name}))");
                    sb.AppendLine("            {");
                    sb.AppendLine($"                error = \"{field.Name} is required\";");
                    sb.AppendLine("                return false;");
                    sb.AppendLine("            }");
                    sb.AppendLine();
                }
                else if (field.IsArray)
                {
                    sb.AppendLine($"            if ({field.Name} == null || {field.Name}.Count == 0)");
                    sb.AppendLine("            {");
                    sb.AppendLine($"                error = \"{field.Name} is required and cannot be empty\";");
                    sb.AppendLine("                return false;");
                    sb.AppendLine("            }");
                    sb.AppendLine();
                }
            }

            // 验证引用字段
            foreach (var field in schema.Fields.Where(f => !string.IsNullOrEmpty(f.ReferencedTypeName)))
            {
                var refType = field.ReferencedTypeName;
                sb.AppendLine($"            if ({field.Name} != null)");
                sb.AppendLine("            {");
                sb.AppendLine($"                var refObj = {refType}Accessor.Instance.Get({field.Name});");
                sb.AppendLine("                if (refObj == null)");
                sb.AppendLine("                {");
                sb.AppendLine($"                    error = $\"Invalid reference: {field.Name} = {{{field.Name}}} not found in {refType}\";");
                sb.AppendLine("                    return false;");
                sb.AppendLine("                }");
                sb.AppendLine("            }");
                sb.AppendLine();
            }

            sb.AppendLine("            return true;");
            sb.AppendLine("        }");
        }

        private string GetTypeName(FieldDefinition field)
        {
            var baseType = field.Type;
            
            // 处理基本类型
            switch (baseType.ToLower())
            {
                case "int":
                case "int32":
                    baseType = "int";
                    break;
                case "long":
                case "int64":
                    baseType = "long";
                    break;
                case "float":
                case "single":
                    baseType = "float";
                    break;
                case "double":
                    baseType = "double";
                    break;
                case "bool":
                case "boolean":
                    baseType = "bool";
                    break;
                case "string":
                    baseType = "string";
                    break;
            }

            // 处理数组
            if (field.IsArray)
            {
                baseType = $"List<{baseType}>";
            }

            // 处理可空类型
            if (!field.IsRequired && !field.IsArray && baseType != "string")
            {
                baseType = $"{baseType}?";
            }

            return baseType;
        }
    }
}