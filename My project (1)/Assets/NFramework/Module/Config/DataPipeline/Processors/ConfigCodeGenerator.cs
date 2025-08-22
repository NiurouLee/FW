using System;
using System.IO;
using System.Diagnostics;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline
{
    public class ConfigCodeGenerator
    {
        private readonly string _flatcPath;
        private readonly string _schemaPath;
        private readonly string _outputPath;
        private readonly EnhancedCodeProcessor _processor;

        public ConfigCodeGenerator(string flatcPath, string schemaPath, string outputPath)
        {
            _flatcPath = flatcPath;
            _schemaPath = schemaPath;
            _outputPath = outputPath;
            _processor = new EnhancedCodeProcessor();
        }

        public bool GenerateCode(string schemaFile)
        {
            try
            {
                // 1. 使用flatc生成基础代码
                if (!GenerateFlatBufferCode(schemaFile))
                {
                    return false;
                }

                // 2. 处理生成的代码，添加扩展功能
                string generatedFile = Path.Combine(_outputPath, Path.GetFileNameWithoutExtension(schemaFile) + ".cs");
                _processor.ProcessGeneratedCode(generatedFile);

                return true;
            }
            catch (Exception ex)
            {
                UnityEngine.Debug.LogError($"生成代码失败: {ex.Message}");
                return false;
            }
        }

        private bool GenerateFlatBufferCode(string schemaFile)
        {
            try
            {
                string schemaFullPath = Path.Combine(_schemaPath, schemaFile);
                if (!File.Exists(schemaFullPath))
                {
                    UnityEngine.Debug.LogError($"Schema文件不存在: {schemaFullPath}");
                    return false;
                }

                // 确保输出目录存在
                Directory.CreateDirectory(_outputPath);

                // 构建flatc命令
                var startInfo = new ProcessStartInfo
                {
                    FileName = _flatcPath,
                    Arguments = $"--csharp --gen-onefile -o {_outputPath} {schemaFullPath}",
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true
                };

                using (var process = Process.Start(startInfo))
                {
                    string output = process.StandardOutput.ReadToEnd();
                    string error = process.StandardError.ReadToEnd();
                    process.WaitForExit();

                    if (process.ExitCode != 0)
                    {
                        UnityEngine.Debug.LogError($"flatc执行失败: {error}");
                        return false;
                    }

                    if (!string.IsNullOrEmpty(output))
                    {
                        UnityEngine.Debug.Log($"flatc输出: {output}");
                    }
                }

                return true;
            }
            catch (Exception ex)
            {
                UnityEngine.Debug.LogError($"执行flatc失败: {ex.Message}");
                return false;
            }
        }
    }
}
