using System;
using System.IO;
using System.Security.Cryptography;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 加密处理器
    /// </summary>
    public class EncryptionProcessor : IPostProcessor
    {
        public string Name => "Encryption Processor";
        public int Priority => 200; // 在压缩之后
        public bool IsEnabled { get; set; } = true;

        public bool Process(PostProcessContext context)
        {
            try
            {
                if (context.BinaryData == null || context.BinaryData.Length == 0)
                {
                    context.AddWarning("No data to encrypt");
                    return true;
                }

                if (string.IsNullOrEmpty(context.EncryptionSettings?.EncryptionKey))
                {
                    context.AddError("Encryption key is not set");
                    return false;
                }

                context.AddLog($"Encrypting data: {context.BinaryData.Length} bytes");

                using (var aes = Aes.Create())
                {
                    aes.Key = Convert.FromBase64String(context.EncryptionSettings.EncryptionKey);
                    aes.IV = string.IsNullOrEmpty(context.EncryptionSettings.EncryptionIV)
                        ? aes.IV // 使用随机IV
                        : Convert.FromBase64String(context.EncryptionSettings.EncryptionIV);

                    using (var memoryStream = new MemoryStream())
                    {
                        // 写入IV
                        memoryStream.Write(aes.IV, 0, aes.IV.Length);

                        using (var cryptoStream = new CryptoStream(memoryStream, aes.CreateEncryptor(), CryptoStreamMode.Write))
                        {
                            cryptoStream.Write(context.BinaryData, 0, context.BinaryData.Length);
                            cryptoStream.FlushFinalBlock();
                        }

                        context.BinaryData = memoryStream.ToArray();
                    }
                }

                context.AddLog($"Encrypted data size: {context.BinaryData.Length} bytes");
                return true;
            }
            catch (Exception ex)
            {
                context.AddError($"Encryption failed: {ex.Message}");
                return false;
            }
        }
    }
}