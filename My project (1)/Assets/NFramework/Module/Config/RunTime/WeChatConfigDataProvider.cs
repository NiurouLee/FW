using System;
using System.Collections.Generic;
using Unity.Collections;

namespace NFramework.Module.Config.DataPipeline
{
    public class WeChatConfigDataProvider : IConfigDataProvider
    {
        private readonly string _configPath;

        public WeChatConfigDataProvider(string configPath = "config")
        {
            _configPath = configPath;
        }

        public void Initialize() { }

        public void Dispose() { }

        public byte[] LoadBinaryData(string configType, string configName)
        {
            // TODO: 实现微信小程序文件读取
            // 示例: wx.getFileSystemManager().readFileSync(filePath)
            throw new NotImplementedException();
        }

        public List<string> GetAllConfigNames(string configType)
        {
            // TODO: 实现微信小程序目录读取
            // 示例: wx.getFileSystemManager().readdirSync(dirPath)
            throw new NotImplementedException();
        }

        private string GetFilePath(string configType, string configName)
        {
            return $"{_configPath}/{configType}/{configName}.bytes";
        }

        public NativeArray<byte> LoadBinaryData(string configType, string configId, Allocator allocator)
        {
            throw new NotImplementedException();
        }
    }
}