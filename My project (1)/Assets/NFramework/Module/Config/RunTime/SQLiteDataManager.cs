using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using UnityEngine;

#if MONO_SQLITE
using Mono.Data.Sqlite;
#endif

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// SQLite数据管理器
    /// </summary>
    public class SQLiteDataManager : IDisposable
    {
#if MONO_SQLITE
        private SqliteConnection _connection;
        private readonly string _databasePath;
        
        public SQLiteDataManager(string databasePath)
        {
            _databasePath = databasePath;
            InitializeDatabase();
        }
        
        private void InitializeDatabase()
        {
            try
            {
                var connectionString = $"URI=file:{_databasePath}";
                _connection = new SqliteConnection(connectionString);
                _connection.Open();
                
                // 创建配置数据表
                CreateConfigTable();
                
                Debug.Log($"SQLite数据库初始化成功: {_databasePath}");
            }
            catch (Exception ex)
            {
                Debug.LogError($"初始化SQLite数据库失败: {ex.Message}");
                throw;
            }
        }
        
        private void CreateConfigTable()
        {
            const string createTableSQL = @"
                CREATE TABLE IF NOT EXISTS config_data (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    config_type TEXT NOT NULL,
                    config_name TEXT NOT NULL,
                    binary_data BLOB NOT NULL,
                    data_size INTEGER NOT NULL,
                    created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
                    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP,
                    version INTEGER DEFAULT 1,
                    UNIQUE(config_type, config_name)
                )";
                
            using (var command = new SqliteCommand(createTableSQL, _connection))
            {
                command.ExecuteNonQuery();
            }
            
            // 创建索引
            const string createIndexSQL = @"
                CREATE INDEX IF NOT EXISTS idx_config_type_name 
                ON config_data(config_type, config_name)";
                
            using (var command = new SqliteCommand(createIndexSQL, _connection))
            {
                command.ExecuteNonQuery();
            }
        }
        
        /// <summary>
        /// 存储FlatBuffer二进制数据
        /// </summary>
        public void StoreFlatBufferData(string configType, string configName, byte[] binaryData)
        {
            try
            {
                const string insertOrReplaceSQL = @"
                    INSERT OR REPLACE INTO config_data 
                    (config_type, config_name, binary_data, data_size, updated_time, version) 
                    VALUES (@configType, @configName, @binaryData, @dataSize, CURRENT_TIMESTAMP, 
                           COALESCE((SELECT version + 1 FROM config_data 
                                   WHERE config_type = @configType AND config_name = @configName), 1))";
                
                using (var command = new SqliteCommand(insertOrReplaceSQL, _connection))
                {
                    command.Parameters.AddWithValue("@configType", configType);
                    command.Parameters.AddWithValue("@configName", configName);
                    command.Parameters.AddWithValue("@binaryData", binaryData);
                    command.Parameters.AddWithValue("@dataSize", binaryData.Length);
                    
                    int rowsAffected = command.ExecuteNonQuery();
                    
                    if (rowsAffected > 0)
                    {
                        Debug.Log($"成功存储配置数据: {configType}.{configName}, 大小: {binaryData.Length} 字节");
                    }
                    else
                    {
                        Debug.LogWarning($"存储配置数据失败: {configType}.{configName}");
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"存储FlatBuffer数据失败: {ex.Message}");
                throw;
            }
        }
        
        /// <summary>
        /// 读取FlatBuffer二进制数据
        /// </summary>
        public byte[] LoadFlatBufferData(string configType, string configName)
        {
            try
            {
                const string selectSQL = @"
                    SELECT binary_data, data_size, version 
                    FROM config_data 
                    WHERE config_type = @configType AND config_name = @configName";
                
                using (var command = new SqliteCommand(selectSQL, _connection))
                {
                    command.Parameters.AddWithValue("@configType", configType);
                    command.Parameters.AddWithValue("@configName", configName);
                    
                    using (var reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            var binaryData = (byte[])reader["binary_data"];
                            var dataSize = Convert.ToInt32(reader["data_size"]);
                            var version = Convert.ToInt32(reader["version"]);
                            
                            Debug.Log($"加载配置数据: {configType}.{configName}, 大小: {dataSize} 字节, 版本: {version}");
                            return binaryData;
                        }
                        else
                        {
                            Debug.LogWarning($"未找到配置数据: {configType}.{configName}");
                            return null;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"加载FlatBuffer数据失败: {ex.Message}");
                throw;
            }
        }
        
        /// <summary>
        /// 获取所有配置类型
        /// </summary>
        public List<string> GetAllConfigTypes()
        {
            var configTypes = new List<string>();
            
            try
            {
                const string selectSQL = "SELECT DISTINCT config_type FROM config_data ORDER BY config_type";
                
                using (var command = new SqliteCommand(selectSQL, _connection))
                {
                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            configTypes.Add(reader["config_type"].ToString());
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"获取配置类型失败: {ex.Message}");
            }
            
            return configTypes;
        }
        
        /// <summary>
        /// 获取指定类型的所有配置名称
        /// </summary>
        public List<string> GetConfigNames(string configType)
        {
            var configNames = new List<string>();
            
            try
            {
                const string selectSQL = @"
                    SELECT config_name, data_size, version, updated_time 
                    FROM config_data 
                    WHERE config_type = @configType 
                    ORDER BY config_name";
                
                using (var command = new SqliteCommand(selectSQL, _connection))
                {
                    command.Parameters.AddWithValue("@configType", configType);
                    
                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            configNames.Add(reader["config_name"].ToString());
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"获取配置名称失败: {ex.Message}");
            }
            
            return configNames;
        }
        
        /// <summary>
        /// 删除配置数据
        /// </summary>
        public bool DeleteConfigData(string configType, string configName = null)
        {
            try
            {
                string deleteSQL;
                SqliteCommand command;
                
                if (string.IsNullOrEmpty(configName))
                {
                    // 删除整个配置类型
                    deleteSQL = "DELETE FROM config_data WHERE config_type = @configType";
                    command = new SqliteCommand(deleteSQL, _connection);
                    command.Parameters.AddWithValue("@configType", configType);
                }
                else
                {
                    // 删除特定配置
                    deleteSQL = "DELETE FROM config_data WHERE config_type = @configType AND config_name = @configName";
                    command = new SqliteCommand(deleteSQL, _connection);
                    command.Parameters.AddWithValue("@configType", configType);
                    command.Parameters.AddWithValue("@configName", configName);
                }
                
                using (command)
                {
                    int rowsAffected = command.ExecuteNonQuery();
                    
                    if (rowsAffected > 0)
                    {
                        Debug.Log($"成功删除配置数据: {configType}.{configName ?? "*"}");
                        return true;
                    }
                    else
                    {
                        Debug.LogWarning($"未找到要删除的配置数据: {configType}.{configName ?? "*"}");
                        return false;
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"删除配置数据失败: {ex.Message}");
                return false;
            }
        }
        
        /// <summary>
        /// 获取数据库统计信息
        /// </summary>
        public DatabaseStats GetDatabaseStats()
        {
            try
            {
                const string statsSQL = @"
                    SELECT 
                        COUNT(*) as total_configs,
                        COUNT(DISTINCT config_type) as total_types,
                        SUM(data_size) as total_size,
                        AVG(data_size) as avg_size,
                        MAX(data_size) as max_size,
                        MIN(data_size) as min_size
                    FROM config_data";
                
                using (var command = new SqliteCommand(statsSQL, _connection))
                {
                    using (var reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            return new DatabaseStats
                            {
                                TotalConfigs = Convert.ToInt32(reader["total_configs"]),
                                TotalTypes = Convert.ToInt32(reader["total_types"]),
                                TotalSize = Convert.ToInt64(reader["total_size"]),
                                AverageSize = Convert.ToDouble(reader["avg_size"]),
                                MaxSize = Convert.ToInt32(reader["max_size"]),
                                MinSize = Convert.ToInt32(reader["min_size"])
                            };
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"获取数据库统计信息失败: {ex.Message}");
            }
            
            return new DatabaseStats();
        }
        
        public void Dispose()
        {
            try
            {
                _connection?.Close();
                _connection?.Dispose();
                Debug.Log("SQLite连接已关闭");
            }
            catch (Exception ex)
            {
                Debug.LogError($"关闭SQLite连接失败: {ex.Message}");
            }
        }
        
#else
        // 如果没有Mono.Data.Sqlite，提供一个空实现
        public SQLiteDataManager(string databasePath)
        {
            Debug.LogWarning("Mono.Data.Sqlite未安装，数据管理器将使用空实现");
        }

        public void StoreFlatBufferData(string configType, string configName, byte[] binaryData)
        {
            Debug.LogWarning("Mono.Data.Sqlite未安装，无法存储数据");
        }

        public byte[] LoadFlatBufferData(string configType, string configName)
        {
            Debug.LogWarning("Mono.Data.Sqlite未安装，无法加载数据");
            return null;
        }

        public List<string> GetConfigNames(string configType)
        {
            return new List<string>();
        }

        public List<string> GetAllConfigTypes()
        {
            return new List<string>();
        }

        public bool DeleteConfig(string configType, string configName = null)
        {
            return false;
        }

        public DatabaseStats GetDatabaseStats()
        {
            return new DatabaseStats();
        }

        public void ClearAllData() { }
        public void OptimizeDatabase() { }
        public void Dispose() { }
#endif
    }

    /// <summary>
    /// 数据库统计信息
    /// </summary>
    public struct DatabaseStats
    {
        public int TotalConfigs;
        public int TotalTypes;
        public long TotalSize;
        public double AverageSize;
        public int MaxSize;
        public int MinSize;

        // public string ToString()
        // {
        //     return $"配置总数: {TotalConfigs}, 类型数: {TotalTypes}, 总大小: {TotalSize:N0} 字节, " +
        //            $"平均大小: {AverageSize:F1} 字节, 最大: {MaxSize:N0}, 最小: {MinSize:N0}";
        // }
    }
}
