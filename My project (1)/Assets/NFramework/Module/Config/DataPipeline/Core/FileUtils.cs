using System.IO;
using System.Linq;
using System.Text;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline
{
    public static class FileUtils
    {
        /// <summary>
        /// 统一的文件写入方法
        /// </summary>
        /// <param name="filePath">文件完整路径</param>
        /// <param name="content">文件内容</param>
        /// <param name="context">处理上下文</param>
        /// <param name="result">处理结果</param>
        /// <param name="fileType">文件类型描述，用于日志</param>
        public static void WriteGeneratedFile(string filePath, string content, CodeGenerationContext context, CodeGenerationResult result, string fileType)
        {
            // 确保目录存在
            var directory = Path.GetDirectoryName(filePath);
            if (!string.IsNullOrEmpty(directory))
            {
                Directory.CreateDirectory(directory);
            }

            // 写入文件
            File.WriteAllText(filePath, content, Encoding.UTF8);

            // 记录到结果中
            var fileName = Path.GetFileName(filePath);
            result.GeneratedFiles[fileName] = content;

            // 添加日志
            var logMessage = $"生成{fileType}: {filePath}";
            context.AddLog(logMessage);

            // 获取调用栈信息
            var stackTrace = new System.Diagnostics.StackTrace(true);
            var callStack = string.Join("\n",
                stackTrace.GetFrames().ToList()
                    .Skip(1) // 跳过当前方法
                    .Take(5) // 只取前5层调用
                    .Select(frame =>
                    {
                        var method = frame.GetMethod();
                        var fileName = frame.GetFileName();
                        var lineNumber = frame.GetFileLineNumber();
                        return $"    at {method.DeclaringType}.{method.Name} in {fileName}:line {lineNumber}";
                    }));

            Debug.Log($"[FileUtils] {logMessage}\n" +
                     $"内容长度: {content.Length}\n" +
                     $"内容预览: {(content.Length > 200 ? content.Substring(0, 200) + "..." : content)}\n" +
                     $"调用栈:\n{callStack}");
        }
    }
}
