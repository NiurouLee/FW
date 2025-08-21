using System;
using System.IO;
using System.Linq;
using System.Text;
using NFramework.Module.Config.DataPipeline.Core;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline.Processors
{
    /// <summary>
    /// FlatBuffer代码生成器 - 生成.fbs文件和C#代码
    /// </summary>
    public class FlatBufferCodeGenerator : ICodeGenerator
    {
        public string Name => "FlatBuffer Code Generator";
        public int Priority => 10;
        public bool IsEnabled { get; set; } = true;

        private readonly string _flatcPath;

        public FlatBufferCodeGenerator(string flatcPath = null)
        {
            _flatcPath = flatcPath ?? FindFlatcExecutable();
        }

        public CodeGenerationResult Generate(CodeGenerationContext context)
        {
            var result = new CodeGenerationResult();

            try
            {
                context.AddLog("开始生成FlatBuffer代码");

                if (context.SchemaDefinition == null)
                {
                    result.Errors.Add("Schema定义为空");
                    return result;
                }

                // 1. 生成.fbs文件
                var fbsContent = GenerateFbsFile(context.SchemaDefinition);
                var fbsFileName = $"{context.SchemaDefinition.Name}.fbs";
                var fbsFilePath = Path.Combine(context.OutputDirectory, fbsFileName);

                Directory.CreateDirectory(context.OutputDirectory);
                File.WriteAllText(fbsFilePath, fbsContent, Encoding.UTF8);

                result.GeneratedFiles[fbsFileName] = fbsContent;
                context.AddLog($"生成FBS文件: {fbsFilePath}");

                // 2. 使用flatc编译生成C#代码
                if (!string.IsNullOrEmpty(_flatcPath) && File.Exists(_flatcPath))
                {
                    var csharpCode = CompileFbsToCs(fbsFilePath, context.OutputDirectory);
                    if (!string.IsNullOrEmpty(csharpCode))
                    {
                        var csFileName = $"{context.SchemaDefinition.Name}.cs";
                        result.GeneratedFiles[csFileName] = csharpCode;
                        context.AddLog($"生成C#代码: {csFileName}");
                    }
                }
                else
                {
                    // 如果没有flatc，生成基础的C#代码模板
                    var csharpCode = GenerateBasicCsCode(context.SchemaDefinition, context.Settings);
                    var csFileName = $"{context.SchemaDefinition.Name}.cs";

                    var csFilePath = Path.Combine(context.OutputDirectory, csFileName);
                    File.WriteAllText(csFilePath, csharpCode, Encoding.UTF8);

                    result.GeneratedFiles[csFileName] = csharpCode;
                    context.AddLog($"生成基础C#代码: {csFilePath}");
                }

                // 3. 生成访问器代码
                if (context.Settings.GenerateAccessors)
                {
                    var accessorCode = GenerateAccessorCode(context.SchemaDefinition, context.Settings);
                    var accessorFileName = $"{context.SchemaDefinition.Name}Accessor.cs";
                    var accessorFilePath = Path.Combine(context.OutputDirectory, accessorFileName);

                    File.WriteAllText(accessorFilePath, accessorCode, Encoding.UTF8);
                    result.GeneratedFiles[accessorFileName] = accessorCode;
                    context.AddLog($"生成访问器代码: {accessorFilePath}");
                }

                result.Success = true;
                context.AddLog("FlatBuffer代码生成完成");
            }
            catch (Exception ex)
            {
                result.Success = false;
                result.Errors.Add($"代码生成失败: {ex.Message}");
                context.AddError($"代码生成失败: {ex.Message}");
            }

            return result;
        }

        private string GenerateFbsFile(SchemaDefinition schema)
        {
            var sb = new StringBuilder();

            // 文件头注释
            sb.AppendLine($"// Auto-generated FlatBuffer schema for {schema.Name}");
            sb.AppendLine($"// Generated at: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
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
                var fieldLine = $"  {field.Name}: {ConvertToFbsType(field.Type)}";

                if (!field.IsRequired)
                {
                    fieldLine += $" = {GetDefaultValue(field.Type, field.DefaultValue)}";
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

            return sb.ToString();
        }

        private string ConvertToFbsType(string csharpType)
        {
            // 处理二维数组类型
            if (csharpType.StartsWith("[[") && csharpType.EndsWith("]]"))
            {
                var elementType = csharpType.Substring(2, csharpType.Length - 4);
                var fbsElementType = ConvertToFbsType(elementType);
                return $"[{fbsElementType}_Array]"; // 二维数组在FlatBuffer中表示为一维数组的数组
            }

            // 处理一维数组类型
            if (csharpType.StartsWith("[") && csharpType.EndsWith("]"))
            {
                var elementType = csharpType.Substring(1, csharpType.Length - 2);
                return $"[{ConvertToFbsType(elementType)}]";
            }

            return csharpType switch
            {
                "bool" => "bool",
                "int" => "int",
                "long" => "long",
                "float" => "float",
                "double" => "double",
                "string" => "string",
                _ => "string" // 默认为string
            };
        }

        private string GetDefaultValue(string type, object defaultValue)
        {
            if (defaultValue != null)
                return defaultValue.ToString();

            return type switch
            {
                "bool" => "false",
                "int" => "0",
                "long" => "0",
                "float" => "0.0",
                "double" => "0.0",
                "string" => "\"\"",
                _ => "null"
            };
        }

        private string CompileFbsToCs(string fbsFilePath, string outputDirectory)
        {
            try
            {
                var processInfo = new System.Diagnostics.ProcessStartInfo
                {
                    FileName = _flatcPath,
                    Arguments = $"--csharp -o \"{outputDirectory}\" \"{fbsFilePath}\"",
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true
                };

                using (var process = System.Diagnostics.Process.Start(processInfo))
                {
                    process.WaitForExit();

                    if (process.ExitCode == 0)
                    {
                        // 查找生成的C#文件
                        var csFiles = Directory.GetFiles(outputDirectory, "*.cs", SearchOption.AllDirectories);
                        var targetFile = csFiles.FirstOrDefault(f => Path.GetFileNameWithoutExtension(f).EndsWith(Path.GetFileNameWithoutExtension(fbsFilePath)));

                        if (targetFile != null && File.Exists(targetFile))
                        {
                            return File.ReadAllText(targetFile);
                        }
                    }
                    else
                    {
                        var error = process.StandardError.ReadToEnd();
                        Debug.LogError($"flatc compilation failed: {error}");
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"Failed to run flatc: {ex.Message}");
            }

            return null;
        }

        private string GenerateBasicCsCode(SchemaDefinition schema, CodeGenerationSettings settings)
        {
            var sb = new StringBuilder();
            var className = schema.Name;
            var namespaceName = settings.Namespace;

            // 文件头
            sb.AppendLine("// <auto-generated>");
            sb.AppendLine($"// Generated at: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
            sb.AppendLine("// </auto-generated>");
            sb.AppendLine();

            sb.AppendLine("using System;");
            sb.AppendLine("using FlatBuffers;");
            sb.AppendLine();

            // 命名空间
            sb.AppendLine($"namespace {namespaceName}");
            sb.AppendLine("{");

            // 类定义
            sb.AppendLine($"    public struct {className} : IFlatbufferObject");
            sb.AppendLine("    {");
            sb.AppendLine("        private Table __p;");
            sb.AppendLine();

            sb.AppendLine($"        public ByteBuffer ByteBuffer => __p.bb;");
            sb.AppendLine();

            // 构造函数
            sb.AppendLine($"        public {className}(int _i, ByteBuffer _bb) {{ __p = new Table(_i, _bb); }}");
            sb.AppendLine();

            // 静态创建方法
            sb.AppendLine($"        public static {className} GetRootAs{className}(ByteBuffer _bb) {{ return GetRootAs{className}(_bb, new {className}()); }}");
            sb.AppendLine($"        public static {className} GetRootAs{className}(ByteBuffer _bb, {className} obj) {{ return (obj.__assign(_bb.GetInt(_bb.Position) + _bb.Position, _bb)); }}");
            sb.AppendLine();

            // 属性生成
            int fieldIndex = 0;
            foreach (var field in schema.Fields)
            {
                GenerateProperty(sb, field, fieldIndex++, settings);
            }

            // __assign方法
            sb.AppendLine($"        public void __init(int _i, ByteBuffer _bb) {{ __p = new Table(_i, _bb); }}");
            sb.AppendLine($"        public {className} __assign(int _i, ByteBuffer _bb) {{ __init(_i, _bb); return this; }}");

            sb.AppendLine("    }");
            sb.AppendLine("}");

            return sb.ToString();
        }

        private void GenerateProperty(StringBuilder sb, FieldDefinition field, int index, CodeGenerationSettings settings)
        {
            var propertyName = field.Name;
            var propertyType = ConvertToCsType(field.Type);
            var offset = 4 + index * 2; // FlatBuffer字段偏移计算

            if (settings.GenerateComments && !string.IsNullOrEmpty(field.Comment))
            {
                sb.AppendLine($"        /// <summary>");
                sb.AppendLine($"        /// {field.Comment}");
                sb.AppendLine($"        /// </summary>");
            }

            if (field.Type.StartsWith("[")) // 数组类型
            {
                var elementType = field.Type.Substring(1, field.Type.Length - 2);
                var csElementType = ConvertToCsType(elementType);

                sb.AppendLine($"        public {csElementType}? {propertyName}(int j) {{ int o = __p.__offset({offset}); return o != 0 ? __p.bb.Get{GetFbMethodName(csElementType)}(__p.__vector(o) + j * {GetTypeSize(csElementType)}) : ({csElementType}?)null; }}");
                sb.AppendLine($"        public int {propertyName}Length {{ get {{ int o = __p.__offset({offset}); return o != 0 ? __p.__vector_len(o) : 0; }} }}");
            }
            else if (propertyType == "string")
            {
                sb.AppendLine($"        public string {propertyName} {{ get {{ int o = __p.__offset({offset}); return o != 0 ? __p.__string(o + __p.bb_pos) : null; }} }}");
            }
            else
            {
                var defaultValue = GetCsDefaultValue(propertyType, field.DefaultValue);
                sb.AppendLine($"        public {propertyType} {propertyName} {{ get {{ int o = __p.__offset({offset}); return o != 0 ? __p.bb.Get{GetFbMethodName(propertyType)}(o + __p.bb_pos) : {defaultValue}; }} }}");
            }

            sb.AppendLine();
        }

        private string ConvertToCsType(string fbType)
        {
            return fbType switch
            {
                "bool" => "bool",
                "int" => "int",
                "long" => "long",
                "float" => "float",
                "double" => "double",
                "string" => "string",
                _ => "string"
            };
        }

        private string GetFbMethodName(string csType)
        {
            return csType switch
            {
                "bool" => "Bool",
                "int" => "Int",
                "long" => "Long",
                "float" => "Float",
                "double" => "Double",
                _ => "String"
            };
        }

        private int GetTypeSize(string csType)
        {
            return csType switch
            {
                "bool" => 1,
                "int" => 4,
                "long" => 8,
                "float" => 4,
                "double" => 8,
                _ => 4 // 默认
            };
        }

        private string GetCsDefaultValue(string csType, object defaultValue)
        {
            if (defaultValue != null)
                return defaultValue.ToString();

            return csType switch
            {
                "bool" => "false",
                "int" => "0",
                "long" => "0L",
                "float" => "0.0f",
                "double" => "0.0",
                "string" => "null",
                _ => "null"
            };
        }

        private string GenerateAccessorCode(SchemaDefinition schema, CodeGenerationSettings settings)
        {
            var sb = new StringBuilder();
            var className = schema.Name;
            var accessorName = $"{className}Accessor";

            sb.AppendLine("// <auto-generated>");
            sb.AppendLine($"// Accessor class for {className}");
            sb.AppendLine($"// Generated at: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
            sb.AppendLine("// </auto-generated>");
            sb.AppendLine();

            sb.AppendLine("using System;");
            sb.AppendLine("using System.Collections.Generic;");
            sb.AppendLine("using FlatBuffers;");
            sb.AppendLine();

            sb.AppendLine($"namespace {settings.Namespace}");
            sb.AppendLine("{");
            sb.AppendLine($"    public class {accessorName}");
            sb.AppendLine("    {");
            sb.AppendLine($"        private readonly {className} _data;");
            sb.AppendLine();

            sb.AppendLine($"        public {accessorName}({className} data)");
            sb.AppendLine("        {");
            sb.AppendLine("            _data = data;");
            sb.AppendLine("        }");
            sb.AppendLine();

            // 生成便捷访问属性
            foreach (var field in schema.Fields)
            {
                var propertyName = field.Name;
                var propertyType = ConvertToCsType(field.Type);

                if (settings.GenerateComments && !string.IsNullOrEmpty(field.Comment))
                {
                    sb.AppendLine($"        /// <summary>");
                    sb.AppendLine($"        /// {field.Comment}");
                    sb.AppendLine($"        /// </summary>");
                }

                sb.AppendLine($"        public {propertyType} {propertyName} => _data.{propertyName};");
                sb.AppendLine();
            }

            sb.AppendLine("    }");
            sb.AppendLine("}");

            return sb.ToString();
        }

        private string FindFlatcExecutable()
        {
            // 在常见位置查找flatc可执行文件
            var possiblePaths = new[]
            {
                "flatc",
                "flatc.exe",
                Path.Combine(Application.dataPath, "Tools", "flatc.exe"),
                Path.Combine(Application.dataPath, "..", "Tools", "flatc.exe"),
                "/usr/local/bin/flatc",
                "/usr/bin/flatc"
            };

            foreach (var path in possiblePaths)
            {
                try
                {
                    if (File.Exists(path))
                        return path;
                }
                catch
                {
                    // 忽略访问错误
                }
            }

            return null;
        }
    }
}
