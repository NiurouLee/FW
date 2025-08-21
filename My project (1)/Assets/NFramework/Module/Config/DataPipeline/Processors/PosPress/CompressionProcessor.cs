using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using NFramework.Module.Config.DataPipeline.Core;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline.Processors
{
    /// <summary>
    /// 压缩后处理器 - 压缩FlatBuffer二进制数据
    /// </summary>
    public class CompressionProcessor : IPostProcessor
    {
        public string Name => "Compression Processor";
        public int Priority => 200;
        public bool IsEnabled { get; set; } = true;

        public bool Process(PostProcessContext context)
        {
            try
            {
                if (context.CompressionSettings?.Enabled != true)
                {
                    context.AddLog("压缩功能未启用，跳过压缩处理");
                    return true;
                }

                context.AddLog($"开始压缩处理，使用 {context.CompressionSettings.Type} 算法");

                var originalData = context.BinaryData;
                if (originalData == null || originalData.Length == 0)
                {
                    context.AddError("没有数据需要压缩");
                    return false;
                }

                var compressedData = CompressData(originalData, context.CompressionSettings, context);
                
                if (compressedData != null && compressedData.Length < originalData.Length)
                {
                    context.BinaryData = compressedData;
                    
                    var compressionRatio = (1.0 - (double)compressedData.Length / originalData.Length) * 100;
                    context.AddLog($"压缩完成，原始大小: {originalData.Length} 字节，压缩后: {compressedData.Length} 字节，压缩率: {compressionRatio:F1}%");
                    
                    // 添加压缩元数据
                    context.Properties["OriginalSize"] = originalData.Length;
                    context.Properties["CompressedSize"] = compressedData.Length;
                    context.Properties["CompressionRatio"] = compressionRatio;
                    context.Properties["CompressionType"] = context.CompressionSettings.Type.ToString();
                }
                else
                {
                    context.AddWarning("压缩后数据大小没有减少，保持原始数据");
                }

                return true;
            }
            catch (Exception ex)
            {
                context.AddError($"压缩处理失败: {ex.Message}");
                return false;
            }
        }

        private byte[] CompressData(byte[] data, CompressionSettings settings, PostProcessContext context)
        {
            return settings.Type switch
            {
                Core.CompressionType.GZip => CompressWithGZip(data, settings.Level),
                Core.CompressionType.Deflate => CompressWithDeflate(data, settings.Level),
                Core.CompressionType.LZ4 => CompressWithLZ4(data, settings.Level),
                _ => data
            };
        }

        private byte[] CompressWithGZip(byte[] data, int level)
        {
            using (var output = new MemoryStream())
            {
                using (var gzip = new GZipStream(output, System.IO.Compression.CompressionLevel.Optimal))
                {
                    gzip.Write(data, 0, data.Length);
                }
                return output.ToArray();
            }
        }

        private byte[] CompressWithDeflate(byte[] data, int level)
        {
            using (var output = new MemoryStream())
            {
                using (var deflate = new DeflateStream(output, System.IO.Compression.CompressionLevel.Optimal))
                {
                    deflate.Write(data, 0, data.Length);
                }
                return output.ToArray();
            }
        }

        private byte[] CompressWithLZ4(byte[] data, int level)
        {
            // LZ4压缩需要额外的库，这里提供接口
            // 可以使用 K4os.Compression.LZ4 或其他LZ4实现
            Debug.LogWarning("LZ4压缩需要额外的库支持，当前返回原始数据");
            return data;
        }
    }

    /// <summary>
    /// 加密后处理器 - 加密FlatBuffer二进制数据
    /// </summary>
    public class EncryptionProcessor : IPostProcessor
    {
        public string Name => "Encryption Processor";
        public int Priority => 300;
        public bool IsEnabled { get; set; } = true;

        public bool Process(PostProcessContext context)
        {
            try
            {
                if (context.EncryptionSettings?.Enabled != true)
                {
                    context.AddLog("加密功能未启用，跳过加密处理");
                    return true;
                }

                context.AddLog($"开始加密处理，使用 {context.EncryptionSettings.Type} 算法");

                var originalData = context.BinaryData;
                if (originalData == null || originalData.Length == 0)
                {
                    context.AddError("没有数据需要加密");
                    return false;
                }

                var encryptedData = EncryptData(originalData, context.EncryptionSettings, context);
                
                if (encryptedData != null)
                {
                    context.BinaryData = encryptedData;
                    context.AddLog($"加密完成，原始大小: {originalData.Length} 字节，加密后: {encryptedData.Length} 字节");
                    
                    // 添加加密元数据
                    context.Properties["EncryptionType"] = context.EncryptionSettings.Type.ToString();
                    context.Properties["EncryptedSize"] = encryptedData.Length;
                }

                return true;
            }
            catch (Exception ex)
            {
                context.AddError($"加密处理失败: {ex.Message}");
                return false;
            }
        }

        private byte[] EncryptData(byte[] data, EncryptionSettings settings, PostProcessContext context)
        {
            return settings.Type switch
            {
                Core.EncryptionType.AES => EncryptWithAES(data, settings.Key),
                Core.EncryptionType.XOR => EncryptWithXOR(data, settings.Key),
                _ => data
            };
        }

        private byte[] EncryptWithAES(byte[] data, string key)
        {
            // AES加密实现
            // 这里需要使用System.Security.Cryptography或Unity的加密API
            Debug.LogWarning("AES加密需要额外实现，当前返回原始数据");
            return data;
        }

        private byte[] EncryptWithXOR(byte[] data, string key)
        {
            if (string.IsNullOrEmpty(key))
            {
                Debug.LogWarning("XOR加密密钥为空，返回原始数据");
                return data;
            }

            var keyBytes = System.Text.Encoding.UTF8.GetBytes(key);
            var encryptedData = new byte[data.Length];

            for (int i = 0; i < data.Length; i++)
            {
                encryptedData[i] = (byte)(data[i] ^ keyBytes[i % keyBytes.Length]);
            }

            return encryptedData;
        }
    }

    /// <summary>
    /// 索引构建后处理器 - 为数据构建索引以提高查询性能
    /// </summary>
    public class IndexBuilderProcessor : IPostProcessor
    {
        public string Name => "Index Builder";
        public int Priority => 100;
        public bool IsEnabled { get; set; } = true;

        private readonly IndexSettings _settings;

        public IndexBuilderProcessor(IndexSettings settings = null)
        {
            _settings = settings ?? new IndexSettings();
        }

        public bool Process(PostProcessContext context)
        {
            try
            {
                context.AddLog("开始构建数据索引");

                // 这里可以实现各种索引构建逻辑
                // 例如：为ID字段构建哈希索引，为数值字段构建范围索引等

                var indexData = BuildIndexes(context);
                
                if (indexData != null && indexData.Length > 0)
                {
                    var indexFileName = $"{context.ConfigName}_index.dat";
                    context.AdditionalFiles[indexFileName] = indexData;
                    context.AddLog($"构建索引完成，索引大小: {indexData.Length} 字节");
                }

                return true;
            }
            catch (Exception ex)
            {
                context.AddError($"构建索引失败: {ex.Message}");
                return false;
            }
        }

        private byte[] BuildIndexes(PostProcessContext context)
        {
            // 这里实现具体的索引构建逻辑
            // 可以根据数据特征构建不同类型的索引
            
            // 示例：构建简单的元数据索引
            var indexInfo = new
            {
                DataSize = context.BinaryData?.Length ?? 0,
                IndexType = "Metadata",
                CreatedTime = DateTime.Now,
                Version = 1
            };

            return System.Text.Encoding.UTF8.GetBytes(JsonUtility.ToJson(indexInfo));
        }
    }

    /// <summary>
    /// 索引设置
    /// </summary>
    public class IndexSettings
    {
        public bool BuildHashIndex { get; set; } = true;
        public bool BuildRangeIndex { get; set; } = true;
        public List<string> IndexedFields { get; set; } = new List<string>();
    }
}
