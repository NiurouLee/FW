using System;
using System.Collections.Generic;
using Unity.Collections;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline
{
    public class SQLiteConfigDataProvider : IConfigDataProvider
    {
        private object _dataManager;
        private readonly string _databaseName;

        public SQLiteConfigDataProvider(string databaseName = "game_config.db")
        {
            _databaseName = databaseName;
        }

        public void Initialize()
        {
            try
            {
                string databasePath = GetDatabasePath();

#if MONO_SQLITE
                _dataManager = new SQLiteDataManager(databasePath);
                Debug.Log("使用标准SQLite数据管理器");
#else
                _dataManager = new SQLite4Unity3dDataManager(databasePath);
                Debug.Log("使用SQLite4Unity3d数据管理器");
#endif
            }
            catch (Exception ex)
            {
                Debug.LogError($"初始化SQLite数据管理器失败: {ex.Message}");
                throw;
            }
        }

        public void Dispose()
        {
            if (_dataManager is IDisposable disposable)
            {
                disposable.Dispose();
            }
            _dataManager = null;
        }

        public NativeArray<byte> LoadBinaryData(string configType, string configId, Allocator allocator)
        {
            try
            {
                byte[] data = null;
#if SQLITE4UNITY3D
                if (_dataManager is SQLite4Unity3dDataManager sqlite4Unity3d)
                {
                    data = sqlite4Unity3d.LoadFlatBufferData(configType, configId);
                }
#else
                if (_dataManager is SQLiteDataManager sqliteManager)
                {
                    data = sqliteManager.LoadFlatBufferData(configType, configId);
                }
#endif

                if (data == null || data.Length == 0)
                {
                    return new NativeArray<byte>(0, allocator);
                }

                var nativeArray = new NativeArray<byte>(data.Length, allocator);
                nativeArray.CopyFrom(data);
                return nativeArray;
            }
            catch (Exception ex)
            {
                Debug.LogError($"从SQLite加载数据失败: {configType}.{configId}, 错误: {ex.Message}");
                return new NativeArray<byte>(0, allocator);
            }
        }

        public List<string> GetAllConfigNames(string configType)
        {
            try
            {
#if SQLITE4UNITY3D
                if (_dataManager is SQLite4Unity3dDataManager sqlite4Unity3d)
                {
                    return sqlite4Unity3d.GetConfigNames(configType);
                }
#else
                if (_dataManager is SQLiteDataManager sqliteManager)
                {
                    return sqliteManager.GetConfigNames(configType);
                }
#endif
                return new List<string>();
            }
            catch (Exception ex)
            {
                Debug.LogError($"获取配置名称列表失败: {configType}, 错误: {ex.Message}");
                return new List<string>();
            }
        }

        private string GetDatabasePath()
        {
            string path;
#if UNITY_EDITOR
            path = Application.dataPath + "/../ConfigData";
#elif UNITY_ANDROID
            path = Application.persistentDataPath;
#elif UNITY_IOS
            path = Application.persistentDataPath;
#else
            path = Application.dataPath + "/ConfigData";
#endif

            return System.IO.Path.Combine(path, _databaseName);
        }
    }
}