using System;
using System.IO;
using System.IO.Compression;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 压缩处理器
    /// </summary>
    public class CompressionProcessor : IPostProcessor
    {
        public string Name => "Compression Processor";
        public int Priority => 100;
        public bool IsEnabled { get; set; } = true;

        public bool Process(PostProcessContext context)
        {
            try
            {
                if (context.BinaryData == null || context.BinaryData.Length == 0)
                {
                    context.AddWarning("No data to compress");
                    return true;
                }

                context.AddLog($"Compressing data: {context.BinaryData.Length} bytes");

                using (var memoryStream = new MemoryStream())
                {
                    using (var gzipStream = new GZipStream(memoryStream, CompressionMode.Compress))
                    {
                        gzipStream.Write(context.BinaryData, 0, context.BinaryData.Length);
                    }

                    context.BinaryData = memoryStream.ToArray();
                }

                context.AddLog($"Compressed data size: {context.BinaryData.Length} bytes");
                return true;
            }
            catch (Exception ex)
            {
                context.AddError($"Compression failed: {ex.Message}");
                return false;
            }
        }
    }
}