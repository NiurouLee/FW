using System;
using System.IO;
using System.Text;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// FlatBuffer代码生成器
    /// </summary>
    public class FlatBufferCodeGenerator : ICodeGenerator
    {
        public string Name => "FlatBuffer Code Generator";
        public int Priority => 100;
        public bool IsEnabled { get; set; } = true;
        public string TargetLanguage => "FlatBuffers";
        public string[] SupportedFileExtensions => new[] { ".fbs", ".cs" };

        private readonly string _flatcPath;
        private readonly string _tempDir;

        public FlatBufferCodeGenerator(string flatcPath)
        {
            _flatcPath = flatcPath;
            _tempDir = Path.Combine(Application.temporaryCachePath, "FlatBufferTemp");
            Directory.CreateDirectory(_tempDir);
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

                // 生成FlatBuffer Schema文件
                var schemaFile = GenerateSchema(context);
                result.GeneratedFiles[schemaFile] = File.ReadAllText(schemaFile);

                // 使用flatc生成C#代码
                var csharpFile = GenerateCSharpCode(schemaFile, context);
                if (File.Exists(csharpFile))
                {
                    result.GeneratedFiles[csharpFile] = File.ReadAllText(csharpFile);
                    result.GeneratedTypes.Add(context.SchemaDefinition.TypeName);
                }

                // 生成访问器代码
                if (context.Settings is CodeGenerationSettings settings && settings.GenerateAccessors)
                {
                    var accessorFile = GenerateAccessor(context);
                    result.GeneratedFiles[accessorFile] = File.ReadAllText(accessorFile);
                    result.GeneratedTypes.Add($"{context.SchemaDefinition.TypeName}Accessor");
                }

                result.Success = true;
                return result;
            }
            catch (Exception ex)
            {
                context.AddError($"FlatBuffer code generation failed: {ex.Message}");
                result.Success = false;
                result.Errors.Add($"FlatBuffer code generation failed: {ex.Message}");
                return result;
            }
        }

        private string GenerateSchema(CodeGenerationContext context)
        {
            var schema = context.SchemaDefinition;
            var sb = new StringBuilder();

            // 添加命名空间
            sb.AppendLine($"namespace {schema.Namespace};");
            sb.AppendLine();

            // 添加表定义
            sb.AppendLine($"table {schema.TypeName} {{");

            // 添加字段
            int fieldId = 1;
            foreach (var field in schema.Fields)
            {
                var fieldType = GetFlatBufferType(field);
                var required = field.IsRequired ? "required " : "";
                sb.AppendLine($"    {field.Name}:{required}{fieldType}; // {fieldId}");
                fieldId++;
            }

            sb.AppendLine("}");
            sb.AppendLine();

            // 添加根类型声明
            sb.AppendLine($"root_type {schema.TypeName};");

            // 保存Schema文件
            var schemaPath = Path.Combine(_tempDir, $"{schema.TypeName}.fbs");
            File.WriteAllText(schemaPath, sb.ToString());

            return schemaPath;
        }

        private string GenerateCSharpCode(string schemaFile, CodeGenerationContext context)
        {
            var outputDir = context.OutputDirectory;
            Directory.CreateDirectory(outputDir);

            // 构建flatc命令
            var startInfo = new System.Diagnostics.ProcessStartInfo
            {
                FileName = _flatcPath,
                Arguments = $"--csharp --gen-onefile -o \"{outputDir}\" \"{schemaFile}\"",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            };

            // 执行命令
            using (var process = System.Diagnostics.Process.Start(startInfo))
            {
                var output = process.StandardOutput.ReadToEnd();
                var error = process.StandardError.ReadToEnd();
                process.WaitForExit();

                if (process.ExitCode != 0)
                {
                    throw new Exception($"flatc failed: {error}");
                }
            }

            return Path.Combine(outputDir, $"{context.SchemaDefinition.TypeName}_generated.cs");
        }

        private string GenerateAccessor(CodeGenerationContext context)
        {
            var schema = context.SchemaDefinition;
            var sb = new StringBuilder();

            // 添加using语句
            sb.AppendLine("using System;");
            sb.AppendLine("using System.Collections.Generic;");
            sb.AppendLine("using FlatBuffers;");
            sb.AppendLine();

            // 添加命名空间
            sb.AppendLine($"namespace {schema.Namespace}");
            sb.AppendLine("{");

            // 添加访问器类
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

            // 添加初始化方法
            sb.AppendLine("        public void Initialize(Dictionary<int, byte[]> rawData)");
            sb.AppendLine("        {");
            sb.AppendLine("            _data.Clear();");
            sb.AppendLine("            foreach (var kvp in rawData)");
            sb.AppendLine("            {");
            sb.AppendLine("                var bb = new ByteBuffer(kvp.Value);");
            sb.AppendLine($"                _data[kvp.Key] = {schema.TypeName}.GetRootAs{schema.TypeName}(bb);");
            sb.AppendLine("            }");
            sb.AppendLine("        }");
            sb.AppendLine();

            // 添加访问方法
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

            // 保存访问器文件
            var accessorPath = Path.Combine(context.OutputDirectory, $"{schema.TypeName}Accessor.cs");
            File.WriteAllText(accessorPath, sb.ToString());

            return accessorPath;
        }

        private string GetFlatBufferType(FieldDefinition field)
        {
            var baseType = field.Type.ToLower();

            switch (baseType)
            {
                case "int":
                case "int32":
                    return "int";
                case "long":
                case "int64":
                    return "long";
                case "float":
                case "single":
                    return "float";
                case "double":
                    return "double";
                case "bool":
                case "boolean":
                    return "bool";
                case "string":
                    return "string";
                default:
                    // 如果是引用类型，直接使用类型名
                    return field.Type;
            }
        }
    }
}