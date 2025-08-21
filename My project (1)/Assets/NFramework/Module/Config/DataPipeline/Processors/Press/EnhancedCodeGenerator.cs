using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Collections.Generic;
using NFramework.Module.Config.DataPipeline.Core;

namespace NFramework.Module.Config.DataPipeline.Processors
{
    /// <summary>
    /// 增强的代码生成器 - 支持客户端/服务端分离、引用字段、多语言等功能
    /// </summary>
    public class EnhancedCodeGenerator : ICodeGenerator
    {
        public string Name => "Enhanced Code Generator";
        public int Priority => 100;
        public bool IsEnabled { get; set; } = true;

        private readonly EnhancedCodeGenerationSettings _settings;

        public EnhancedCodeGenerator(EnhancedCodeGenerationSettings settings = null)
        {
            _settings = settings ?? new EnhancedCodeGenerationSettings();
        }

        public CodeGenerationResult Generate(CodeGenerationContext context)
        {
            var result = new CodeGenerationResult();

            try
            {
                context.AddLog("开始增强代码生成");

                if (context.SchemaDefinition == null)
                {
                    result.Errors.Add("Schema定义为空");
                    return result;
                }

                var schema = context.SchemaDefinition;
                
                // 1. 生成FlatBuffer Schema文件
                GenerateFbsFile(schema, context, result);

                // 生成数据类代码
                GenerateDataClassCode(schema, context, result);

                result.Success = true;
                context.AddLog("增强代码生成完成");
            }
            catch (Exception ex)
            {
                result.Success = false;
                result.Errors.Add($"增强代码生成失败: {ex.Message}");
                context.AddError($"增强代码生成失败: {ex.Message}");
            }

            return result;
        }

        /// <summary>
        /// 生成FlatBuffer Schema文件
        /// </summary>
        private void GenerateFbsFile(SchemaDefinition schema, CodeGenerationContext context, CodeGenerationResult result)
        {
            var sb = new StringBuilder();
            
            // 文件头注释
            sb.AppendLine($"// Auto-generated FlatBuffer schema for {schema.Name}");
            sb.AppendLine($"// Generated at: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
            sb.AppendLine("// Enhanced with support for references and localization");
            sb.AppendLine();

            // 命名空间
            if (!string.IsNullOrEmpty(schema.Namespace))
            {
                sb.AppendLine($"namespace {schema.Namespace};");
                sb.AppendLine();
            }

            // 生成表定义
            sb.AppendLine($"table {schema.Name} {{");

            foreach (var field in schema.Fields)
            {
                // 跳过生成的引用字段，它们会被特殊处理
                if (field.Attributes.ContainsKey("generated_reference") && (bool)field.Attributes["generated_reference"])
                    continue;

                var fieldLine = $"  {field.Name}: {ConvertToFbsType(field.Type)}";
                
                if (!field.IsRequired && field.DefaultValue != null)
                {
                    fieldLine += $" = {FormatDefaultValue(field.DefaultValue, field.Type)}";
                }

                fieldLine += ";";

                if (!string.IsNullOrEmpty(field.Comment))
                {
                    fieldLine += $" // {field.Comment}";
                }

                sb.AppendLine(fieldLine);
            }

            sb.AppendLine("}");
            sb.AppendLine();

            // 根表声明
            sb.AppendLine($"root_type {schema.Name};");

            var fbsFileName = $"{schema.Name}.fbs";
            var fbsFilePath = Path.Combine(context.OutputDirectory, fbsFileName);
            
            Directory.CreateDirectory(context.OutputDirectory);
            File.WriteAllText(fbsFilePath, sb.ToString(), Encoding.UTF8);
            
            result.GeneratedFiles[fbsFileName] = sb.ToString();
            context.AddLog($"生成FBS文件: {fbsFilePath}");
        }

        /// <summary>
        /// 生成客户端代码
        /// </summary>
        private void GenerateClientCode(SchemaDefinition schema, CodeGenerationContext context, CodeGenerationResult result)
        {
            var clientFields = schema.Fields.Where(f => ShouldGenerateForClient(f)).ToList();
            
            if (clientFields.Count == 0)
            {
                context.AddLog("没有需要生成客户端代码的字段");
                return;
            }

            var sb = new StringBuilder();
            GenerateClassHeader(sb, schema, "Client");

            // 生成客户端专用属性
            foreach (var field in clientFields)
            {
                GenerateProperty(sb, field, true, context);
            }

            // 生成引用属性访问器
            GenerateReferenceAccessors(sb, clientFields, context);

            // 生成多语言属性访问器
            GenerateLocalizationAccessors(sb, clientFields, context);

            sb.AppendLine("    }");
            sb.AppendLine("}");

            var clientFileName = $"{schema.Name}Client.cs";
            var clientFilePath = Path.Combine(context.OutputDirectory, "Client", clientFileName);
            
            Directory.CreateDirectory(Path.GetDirectoryName(clientFilePath));
            File.WriteAllText(clientFilePath, sb.ToString(), Encoding.UTF8);
            
            result.GeneratedFiles[clientFileName] = sb.ToString();
            context.AddLog($"生成客户端代码: {clientFilePath}");
        }

        /// <summary>
        /// 生成服务端代码
        /// </summary>
        private void GenerateServerCode(SchemaDefinition schema, CodeGenerationContext context, CodeGenerationResult result)
        {
            var serverFields = schema.Fields.Where(f => ShouldGenerateForServer(f)).ToList();
            
            if (serverFields.Count == 0)
            {
                context.AddLog("没有需要生成服务端代码的字段");
                return;
            }

            var sb = new StringBuilder();
            GenerateClassHeader(sb, schema, "Server");

            // 生成服务端专用属性
            foreach (var field in serverFields)
            {
                GenerateProperty(sb, field, false, context);
            }

            // 生成引用属性访问器
            GenerateReferenceAccessors(sb, serverFields, context);

            sb.AppendLine("    }");
            sb.AppendLine("}");

            var serverFileName = $"{schema.Name}Server.cs";
            var serverFilePath = Path.Combine(context.OutputDirectory, "Server", serverFileName);
            
            Directory.CreateDirectory(Path.GetDirectoryName(serverFilePath));
            File.WriteAllText(serverFilePath, sb.ToString(), Encoding.UTF8);
            
            result.GeneratedFiles[serverFileName] = sb.ToString();
            context.AddLog($"生成服务端代码: {serverFilePath}");
        }

        /// <summary>
        /// 生成访问器代码
        /// </summary>
        private void GenerateAccessorCode(SchemaDefinition schema, CodeGenerationContext context, CodeGenerationResult result)
        {
            var sb = new StringBuilder();
            
            GenerateFileHeader(sb, $"{schema.Name} Accessor");
            sb.AppendLine("using System;");
            sb.AppendLine("using System.Collections.Generic;");
            sb.AppendLine("using Google.FlatBuffers;");
            sb.AppendLine();

            sb.AppendLine($"namespace {_settings.Namespace}");
            sb.AppendLine("{");
            sb.AppendLine($"    public class {schema.Name}Accessor");
            sb.AppendLine("    {");
            sb.AppendLine($"        private readonly {schema.Name} _data;");
            sb.AppendLine();

            sb.AppendLine($"        public {schema.Name}Accessor({schema.Name} data)");
            sb.AppendLine("        {");
            sb.AppendLine("            _data = data;");
            sb.AppendLine("        }");
            sb.AppendLine();

            // 生成便捷访问属性
            foreach (var field in schema.Fields)
            {
                if (field.Attributes.ContainsKey("generated_reference") && (bool)field.Attributes["generated_reference"])
                    continue;

                GenerateAccessorProperty(sb, field, context);
            }

            sb.AppendLine("    }");
            sb.AppendLine("}");

            var accessorFileName = $"{schema.Name}Accessor.cs";
            var accessorFilePath = Path.Combine(context.OutputDirectory, accessorFileName);
            
            File.WriteAllText(accessorFilePath, sb.ToString(), Encoding.UTF8);
            result.GeneratedFiles[accessorFileName] = sb.ToString();
            context.AddLog($"生成访问器代码: {accessorFilePath}");
        }

        /// <summary>
        /// 生成数据类代码
        /// </summary>
        private void GenerateDataClassCode(SchemaDefinition schema, CodeGenerationContext context, CodeGenerationResult result)
        {
            var sb = new StringBuilder();
            
            GenerateFileHeader(sb, $"{schema.Name} Data Class");
            sb.AppendLine("// <auto-generated>");
            sb.AppendLine("using System;");
            sb.AppendLine("using Google.FlatBuffers;");
            sb.AppendLine();

            sb.AppendLine($"namespace {_settings.Namespace}");
            sb.AppendLine("{");
            sb.AppendLine($"    public struct {schema.Name} : IFlatbufferObject");
            sb.AppendLine("    {");
            sb.AppendLine("        private Table __p;");
            sb.AppendLine();
            sb.AppendLine("        public ByteBuffer ByteBuffer { get { return __p.bb; } }");
            sb.AppendLine("        public void __init(int _i, ByteBuffer _bb) { __p = new Table(_i, _bb); }");
            sb.AppendLine();

            // 生成字段和属性
            foreach (var field in schema.Fields)
            {
                if (!string.IsNullOrEmpty(field.Comment))
                {
                    sb.AppendLine($"        /// <summary>");
                    sb.AppendLine($"        /// {field.Comment}");
                    sb.AppendLine($"        /// </summary>");
                }

                var propertyType = ConvertToCsType(field.Type);
                var propertyName = field.Name;

                int fieldOffset = schema.Fields.ToList().IndexOf(field) * 2 + 4;
                
                // 处理引用字段
                if (field.Attributes.ContainsKey("reference"))
                {
                    var refType = field.Attributes["reference_type"].ToString(); // 获取引用类型
                    // 首字母大写
                    refType = char.ToUpper(refType[0]) + refType.Substring(1);
                    
                    // 生成原始ID属性
                    var defaultValue = GetCsDefaultValue(propertyType, field.DefaultValue);
                    sb.AppendLine($"        public {propertyType} {propertyName}");
                    sb.AppendLine("        {");
                    sb.AppendLine($"            get {{ int o = __p.__offset({fieldOffset}); return o != 0 ? __p.bb.Get{GetFbMethodName(propertyType)}(o + __p.bb_pos) : {defaultValue}; }}");
                    sb.AppendLine("        }");
                    sb.AppendLine();
                    
                    // 生成引用属性
                    sb.AppendLine($"        public {refType} Ref{propertyName}");
                    sb.AppendLine("        {");
                    sb.AppendLine($"            get {{ return Framework.I.G<ConfigM>().GetCfg<{refType}>(this.{propertyName}); }}");
                    sb.AppendLine("        }");
                }

                // 处理数组字段
                if (field.Type.StartsWith("[") && field.Type.EndsWith("]"))
                {
                    var elementType = field.Type.Substring(1, field.Type.Length - 2);
                    
                    // 如果是引用数组，我们需要生成两种访问器：一个用于原始ID，一个用于引用对象
                    if (field.Attributes.ContainsKey("reference"))
                    {
                        var refType = field.Attributes["reference_type"].ToString();
                        // 首字母大写
                        refType = char.ToUpper(refType[0]) + refType.Substring(1);
                        
                        // 原始ID数组访问器
                        sb.AppendLine($"        public int {propertyName}(int j)");
                        sb.AppendLine("        {");
                        sb.AppendLine($"            int o = __p.__offset({fieldOffset});");
                        sb.AppendLine($"            return o != 0 ? __p.bb.GetInt(__p.__vector(o) + j * 4) : 0;");
                        sb.AppendLine("        }");
                        
                        // 数组长度属性
                        sb.AppendLine($"        public int {propertyName}Length");
                        sb.AppendLine("        {");
                        sb.AppendLine($"            get {{ int o = __p.__offset({fieldOffset}); return o != 0 ? __p.__vector_len(o) : 0; }}");
                        sb.AppendLine("        }");
                        
                        // 单个元素的引用访问器
                        sb.AppendLine($"        public {refType} Ref{propertyName}At(int index)");
                        sb.AppendLine("        {");
                        sb.AppendLine($"            return Framework.I.G<ConfigM>().GetCfg<{refType}>(this.{propertyName}(index));");
                        sb.AppendLine("        }");

                        // 添加私有字段用于懒加载
                        sb.AppendLine($"        private List<{refType}> _{propertyName}RefList;");
                        
                        // 添加整个列表的引用访问器（懒加载）
                        sb.AppendLine($"        public List<{refType}> Ref{propertyName}");
                        sb.AppendLine("        {");
                        sb.AppendLine("            get");
                        sb.AppendLine("            {");
                        sb.AppendLine($"                if (_{propertyName}RefList == null)");
                        sb.AppendLine("                {");
                        sb.AppendLine($"                    _{propertyName}RefList = new List<{refType}>();");
                        sb.AppendLine($"                    for (int i = 0; i < {propertyName}Length; i++)");
                        sb.AppendLine("                    {");
                        sb.AppendLine($"                        _{propertyName}RefList.Add(Ref{propertyName}At(i));");
                        sb.AppendLine("                    }");
                        sb.AppendLine("                }");
                        sb.AppendLine($"                return _{propertyName}RefList;");
                        sb.AppendLine("            }");
                        sb.AppendLine("        }");
                    }
                    else
                    {
                        // 非引用数组的普通处理
                        var csElementType = ConvertToCsType(elementType);
                        
                        // 数组访问器
                        sb.AppendLine($"        public {csElementType} {propertyName}(int j)");
                        sb.AppendLine("        {");
                        sb.AppendLine($"            int o = __p.__offset({fieldOffset});");
                        sb.AppendLine($"            return o != 0 ? __p.bb.Get{GetFbMethodName(csElementType)}(__p.__vector(o) + j * {GetTypeSize(csElementType)}) : default({csElementType});");
                        sb.AppendLine("        }");
                        
                        // 数组长度属性
                        sb.AppendLine($"        public int {propertyName}Length");
                        sb.AppendLine("        {");
                        sb.AppendLine($"            get {{ int o = __p.__offset({fieldOffset}); return o != 0 ? __p.__vector_len(o) : 0; }}");
                        sb.AppendLine("        }");
                    }
                }
                // 处理字符串字段
                else if (propertyType == "string")
                {
                    sb.AppendLine($"        public string {propertyName}");
                    sb.AppendLine("        {");
                    sb.AppendLine($"            get {{ int o = __p.__offset({fieldOffset}); return o != 0 ? __p.__string(o + __p.bb_pos) : null; }}");
                    sb.AppendLine("        }");
                }
                // 处理基本类型字段
                else
                {
                    var defaultValue = GetCsDefaultValue(propertyType, field.DefaultValue);
                    sb.AppendLine($"        public {propertyType} {propertyName}");
                    sb.AppendLine("        {");
                    sb.AppendLine($"            get {{ int o = __p.__offset({fieldOffset}); return o != 0 ? __p.bb.Get{GetFbMethodName(propertyType)}(o + __p.bb_pos) : {defaultValue}; }}");
                    sb.AppendLine("        }");
                }
                sb.AppendLine();
            }

            // 生成静态创建方法
            sb.AppendLine($"        public static {schema.Name} GetRootAs{schema.Name}(ByteBuffer _bb)");
            sb.AppendLine("        {");
            sb.AppendLine($"            return GetRootAs{schema.Name}(_bb, new {schema.Name}());");
            sb.AppendLine("        }");
            sb.AppendLine();

            sb.AppendLine($"        public static {schema.Name} GetRootAs{schema.Name}(ByteBuffer _bb, {schema.Name} obj)");
            sb.AppendLine("        {");
            sb.AppendLine("            var offset = _bb.GetInt(_bb.Position) + _bb.Position;");
            sb.AppendLine("            obj.__init(offset, _bb);");
            sb.AppendLine("            return obj;");
            sb.AppendLine("        }");

            sb.AppendLine("    }");
            sb.AppendLine("}");

            var fileName = $"{schema.Name}.cs";
            var filePath = Path.Combine(context.OutputDirectory, fileName);
            
            File.WriteAllText(filePath, sb.ToString(), Encoding.UTF8);
            result.GeneratedFiles[fileName] = sb.ToString();
            context.AddLog($"生成数据类代码: {filePath}");
        }

        private int GetTypeSize(string csType)
        {
            switch (csType.ToLower())
            {
                case "byte": return 1;
                case "short": return 2;
                case "int": return 4;
                case "long": return 8;
                case "float": return 4;
                case "double": return 8;
                default: return 4;
            }
        }

        /// <summary>
        /// 判断字段是否应该为客户端生成
        /// </summary>
        private bool ShouldGenerateForClient(FieldDefinition field)
        {
            if (!field.Attributes.ContainsKey("generation_type"))
                return true;

            var generationType = field.Attributes["generation_type"].ToString();
            return generationType == "All" || generationType == "ClientOnly";
        }

        /// <summary>
        /// 判断字段是否应该为服务端生成
        /// </summary>
        private bool ShouldGenerateForServer(FieldDefinition field)
        {
            if (!field.Attributes.ContainsKey("generation_type"))
                return true;

            var generationType = field.Attributes["generation_type"].ToString();
            return generationType == "All" || generationType == "ServerOnly";
        }

        /// <summary>
        /// 检查字段是否有特定标记
        /// </summary>
        private bool HasTag(FieldDefinition field, string tag)
        {
            if (field.Attributes.ContainsKey("tag_combination"))
            {
                var tagCombination = field.Attributes["tag_combination"].ToString();
                return tagCombination.Contains(tag.ToUpper());
            }
            return false;
        }

        /// <summary>
        /// 生成类头部
        /// </summary>
        private void GenerateClassHeader(StringBuilder sb, SchemaDefinition schema, string suffix)
        {
            GenerateFileHeader(sb, $"{schema.Name} {suffix}");
            sb.AppendLine("using System;");
            sb.AppendLine("using Google.FlatBuffers;");
            sb.AppendLine();

            sb.AppendLine($"namespace {_settings.Namespace}");
            sb.AppendLine("{");
            sb.AppendLine($"    public partial struct {schema.Name}{suffix} : IFlatbufferObject");
            sb.AppendLine("    {");
            sb.AppendLine("        private Table __p;");
            sb.AppendLine();
            sb.AppendLine("        public ByteBuffer ByteBuffer => __p.bb;");
            sb.AppendLine();
            sb.AppendLine($"        public {schema.Name}{suffix}(int _i, ByteBuffer _bb) {{ __p = new Table(_i, _bb); }}");
            sb.AppendLine();
        }

        /// <summary>
        /// 生成文件头部注释
        /// </summary>
        private void GenerateFileHeader(StringBuilder sb, string description)
        {
            sb.AppendLine("// <auto-generated>");
            sb.AppendLine($"// {description}");
            sb.AppendLine($"// Generated at: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
            sb.AppendLine("// Enhanced with support for references and localization");
            sb.AppendLine("// </auto-generated>");
            sb.AppendLine();
        }

        /// <summary>
        /// 生成属性
        /// </summary>
        private void GenerateProperty(StringBuilder sb, FieldDefinition field, bool isClient, CodeGenerationContext context)
        {
            if (!string.IsNullOrEmpty(field.Comment))
            {
                sb.AppendLine($"        /// <summary>");
                sb.AppendLine($"        /// {field.Comment}");
                var tagCombination = field.Attributes["tag_combination"]?.ToString();
                if (!string.IsNullOrEmpty(tagCombination))
                {
                    sb.AppendLine($"        /// 标记组合: {tagCombination}");
                }
                sb.AppendLine($"        /// </summary>");
            }

            var propertyType = ConvertToCsType(field.Type);
            var propertyName = field.Name;

            // Handle 2D array types
            if (field.Type.StartsWith("[[") && field.Type.EndsWith("]]") && field.Attributes.ContainsKey("reference"))
            {
                var elementType = field.Type.Substring(2, field.Type.Length - 4);
                var csElementType = ConvertToCsType(elementType);
                
                sb.AppendLine($"        /// <summary>");
                sb.AppendLine($"        /// 获取二维数组中指定位置的值");
                sb.AppendLine($"        /// </summary>");
                sb.AppendLine($"        /// <param name=\"row\">行索引</param>");
                sb.AppendLine($"        /// <param name=\"col\">列索引</param>");
                sb.AppendLine($"        public {csElementType}? Get{propertyName}(int row, int col)");
                sb.AppendLine("        {");
                sb.AppendLine("            // 二维数组访问逻辑");
                sb.AppendLine($"            // 这里需要根据实际的FlatBuffer二维数组实现来调整");
                sb.AppendLine("            return null; // TODO: 实现二维数组访问");
                sb.AppendLine("        }");
                sb.AppendLine();
                
                sb.AppendLine($"        /// <summary>");
                sb.AppendLine($"        /// 获取二维数组的行数");
                sb.AppendLine($"        /// </summary>");
                sb.AppendLine($"        public int {propertyName}RowCount {{ get {{ return 0; /* TODO: 实现 */ }} }}");
                sb.AppendLine();
                
                sb.AppendLine($"        /// <summary>");
                sb.AppendLine($"        /// 获取二维数组指定行的列数");
                sb.AppendLine($"        /// </summary>");
                sb.AppendLine($"        public int Get{propertyName}ColCount(int row) {{ return 0; /* TODO: 实现 */ }}");
            }
            // Handle 1D array types
            else if (field.Type.StartsWith("[") && field.Type.EndsWith("]"))
            {
                var elementType = field.Type.Substring(1, field.Type.Length - 2);
                var csElementType = ConvertToCsType(elementType);
                
                sb.AppendLine($"        public {csElementType}? {propertyName}(int j) {{ int o = __p.__offset(4); return o != 0 ? __p.bb.Get{GetFbMethodName(csElementType)}(__p.__vector(o) + j * 4) : ({csElementType}?)null; }}");
                sb.AppendLine($"        public int {propertyName}Length {{ get {{ int o = __p.__offset(4); return o != 0 ? __p.__vector_len(o) : 0; }} }}");
            }
            else if (propertyType == "string")
            {
                sb.AppendLine($"        public string {propertyName} {{ get {{ int o = __p.__offset(4); return o != 0 ? __p.__string(o + __p.bb_pos) : null; }} }}");
            }
            else
            {
                var defaultValue = GetCsDefaultValue(propertyType, field.DefaultValue);
                sb.AppendLine($"        public {propertyType} {propertyName} {{ get {{ int o = __p.__offset(4); return o != 0 ? __p.bb.Get{GetFbMethodName(propertyType)}(o + __p.bb_pos) : {defaultValue}; }} }}");
            }

            sb.AppendLine();
        }

        /// <summary>
        /// 生成引用访问器
        /// </summary>
        private void GenerateReferenceAccessors(StringBuilder sb, List<FieldDefinition> fields, CodeGenerationContext context)
        {
            var referenceFields = fields.Where(f => f.Attributes.ContainsKey("reference") && (bool)f.Attributes["reference"]).ToList();
            
            foreach (var field in referenceFields)
            {
                var referenceType = field.Attributes["reference_type"]?.ToString();
                var tagCombination = field.Attributes["tag_combination"]?.ToString() ?? "";
                
                if (!string.IsNullOrEmpty(referenceType))
                {
                    sb.AppendLine($"        /// <summary>");
                    sb.AppendLine($"        /// 获取引用的{referenceType}配置");
                    if (!string.IsNullOrEmpty(tagCombination))
                    {
                        sb.AppendLine($"        /// 标记组合: {tagCombination}");
                    }
                    sb.AppendLine($"        /// </summary>");
                    sb.AppendLine($"        public {referenceType}Accessor Get{referenceType}()");
                    sb.AppendLine("        {");
                    sb.AppendLine($"            return {referenceType}Manager.Instance?.GetConfig({field.Name});");
                    sb.AppendLine("        }");
                    sb.AppendLine();
                }
            }
        }

        /// <summary>
        /// 生成多语言访问器
        /// </summary>
        private void GenerateLocalizationAccessors(StringBuilder sb, List<FieldDefinition> fields, CodeGenerationContext context)
        {
            var localizationFields = fields.Where(f => f.Attributes.ContainsKey("localization") && (bool)f.Attributes["localization"]).ToList();
            
            foreach (var field in localizationFields)
            {
                var tagCombination = field.Attributes["tag_combination"]?.ToString() ?? "";
                
                sb.AppendLine($"        /// <summary>");
                sb.AppendLine($"        /// 获取本地化文本：{field.Comment}");
                if (!string.IsNullOrEmpty(tagCombination))
                {
                    sb.AppendLine($"        /// 标记组合: {tagCombination}");
                }
                sb.AppendLine($"        /// </summary>");
                sb.AppendLine($"        public string Get{field.Name}Localized()");
                sb.AppendLine("        {");
                sb.AppendLine($"            return LocalizationManager.Instance?.GetText({field.Name}) ?? {field.Name};");
                sb.AppendLine("        }");
                sb.AppendLine();
            }
        }

        /// <summary>
        /// 生成访问器属性
        /// </summary>
        private void GenerateAccessorProperty(StringBuilder sb, FieldDefinition field, CodeGenerationContext context)
        {
            if (!string.IsNullOrEmpty(field.Comment))
            {
                sb.AppendLine($"        /// <summary>");
                sb.AppendLine($"        /// {field.Comment}");
                sb.AppendLine($"        /// </summary>");
            }

            var propertyType = ConvertToCsType(field.Type);
            sb.AppendLine($"        public {propertyType} {field.Name} => _data.{field.Name};");
            sb.AppendLine();
        }

        // 辅助方法
        private string ConvertToFbsType(string csharpType)
        {
            if (csharpType.StartsWith("repeated "))
            {
                var elementType = csharpType.Substring("repeated ".Length);
                return $"[{ConvertToFbsType(elementType)}]";
            }

            switch (csharpType.ToLower())
            {
                case "int":
                case "int32":
                    return "int32";
                case "long":
                case "int64":
                    return "int64";
                case "float":
                    return "float32";
                case "double":
                    return "float64";
                case "bool":
                    return "bool";
                case "string":
                    return "string";
                default:
                    return csharpType;
            }
        }

        private string ConvertToCsType(string fbType)
        {
            // 如果是数组类型
            if (fbType.StartsWith("[") && fbType.EndsWith("]"))
            {
                var elementType = fbType.Substring(1, fbType.Length - 2);
                return $"List<{ConvertToCsType(elementType)}>";
            }

            if (fbType.StartsWith("repeated "))
            {
                var elementType = fbType.Substring("repeated ".Length);
                return $"List<{ConvertToCsType(elementType)}>";
            }

            switch (fbType.ToLower())
            {
                case "int32":
                    return "int";
                case "int64":
                    return "long";
                case "float32":
                    return "float";
                case "float64":
                    return "double";
                case "bool":
                    return "bool";
                case "string":
                    return "string";
                default:
                    return fbType;
            }
        }

        private string GetFbMethodName(string csType)
        {
            switch (csType.ToLower())
            {
                case "byte":
                    return "Byte";
                case "short":
                    return "Short";
                case "int":
                    return "Int";
                case "long":
                    return "Long";
                case "float":
                    return "Float";
                case "double":
                    return "Double";
                case "bool":
                    return "Bool";
                default:
                    return "Int";
            }
        }

        private string GetCsDefaultValue(string csType, object defaultValue)
        {
            if (defaultValue != null)
                return defaultValue.ToString();

            switch (csType.ToLower())
            {
                case "byte":
                case "short":
                case "int":
                case "long":
                    return "0";
                case "float":
                case "double":
                    return "0.0";
                case "bool":
                    return "false";
                case "string":
                    return "null";
                default:
                    return "null";
            }
        }

        private string FormatDefaultValue(object defaultValue, string fieldType)
        {
            if (defaultValue == null)
                return "null";

            switch (fieldType.ToLower())
            {
                case "string":
                    return $"\"{defaultValue}\"";
                case "float":
                case "double":
                    return defaultValue.ToString() + "f";
                default:
                    return defaultValue.ToString();
            }
        }
    }

    /// <summary>
    /// 增强的代码生成设置
    /// </summary>
    public class EnhancedCodeGenerationSettings : CodeGenerationSettings
    {
        public new string Namespace { get; set; } = "GameConfig";
    }
}
