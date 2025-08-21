using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using SQLite4Unity3d;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// SQLite4Unity3d数据管理器
    /// </summary>
    public class SQLite4Unity3dDataManager : IDisposable
    {
        private SQLiteConnection _connection;
        private readonly string _databasePath;

        public SQLite4Unity3dDataManager(string databasePath)
        {
            _databasePath = databasePath;
            InitializeDatabase();
        }

        private void InitializeDatabase()
        {
            try
            {
                // 确保目录存在
                var directory = Path.GetDirectoryName(_databasePath);
                if (!Directory.Exists(directory))
                {
                    Directory.CreateDirectory(directory);
                }

                _connection = new SQLiteConnection(_databasePath, SQLiteOpenFlags.ReadOnly);

                // 创建配置数据表
                CreateConfigTable();

                Debug.Log($"SQLite4Unity3d数据库初始化成功: {_databasePath}");
            }
            catch (Exception ex)
            {
                Debug.LogError($"SQLite4Unity3d数据库初始化失败: {ex.Message}");
                throw;
            }
        }

        private void CreateConfigTable()
        {
            var sql = @"
                CREATE TABLE IF NOT EXISTS config_data (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    config_type TEXT NOT NULL,
                    config_name TEXT NOT NULL,
                    binary_data BLOB NOT NULL,
                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                    UNIQUE(config_type, config_name)
                )";

            _connection.Execute(sql);

            // 创建索引
            _connection.Execute("CREATE INDEX IF NOT EXISTS idx_config_type ON config_data(config_type)");
            _connection.Execute("CREATE INDEX IF NOT EXISTS idx_config_name ON config_data(config_name)");
        }

        /// <summary>
        /// 存储FlatBuffer二进制数据
        /// </summary>
        public void StoreFlatBufferData(string configType, string configName, byte[] binaryData)
        {
            if (binaryData == null || binaryData.Length == 0)
            {
                Debug.LogWarning($"尝试存储空的二进制数据: {configType}.{configName}");
                return;
            }

            try
            {
                var sql = @"
                    INSERT OR REPLACE INTO config_data (config_type, config_name, binary_data, updated_at)
                    VALUES (?, ?, ?, datetime('now'))";

                _connection.Execute(sql, configType, configName, binaryData);

                Debug.Log($"存储配置数据成功: {configType}.{configName} ({binaryData.Length} bytes)");
            }
            catch (Exception ex)
            {
                Debug.LogError($"存储配置数据失败: {configType}.{configName}, 错误: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// 加载FlatBuffer二进制数据
        /// </summary>
        public byte[] LoadFlatBufferData(string configType, string configName)
        {
            try
            {
                var sql = "SELECT binary_data FROM config_data WHERE config_type = ? AND config_name = ?";
                var result = _connection.Query<ConfigDataRow>(sql, configType, configName);

                if (result.Count > 0)
                {
                    Debug.Log($"加载配置数据成功: {configType}.{configName}");
                    return result[0].binary_data;
                }

                Debug.LogWarning($"未找到配置数据: {configType}.{configName}");
                return null;
            }
            catch (Exception ex)
            {
                Debug.LogError($"加载配置数据失败: {configType}.{configName}, 错误: {ex.Message}");
                return null;
            }
        }

        /// <summary>
        /// 获取指定类型的所有配置名称
        /// </summary>
        public List<string> GetConfigNames(string configType)
        {
            try
            {
                var sql = "SELECT config_name FROM config_data WHERE config_type = ? ORDER BY config_name";
                var result = _connection.Query<ConfigNameRow>(sql, configType);

                var names = new List<string>();
                foreach (var row in result)
                {
                    names.Add(row.config_name);
                }

                return names;
            }
            catch (Exception ex)
            {
                Debug.LogError($"获取配置名称失败: {configType}, 错误: {ex.Message}");
                return new List<string>();
            }
        }

        /// <summary>
        /// 获取所有配置类型
        /// </summary>
        public List<string> GetAllConfigTypes()
        {
            try
            {
                var sql = "SELECT DISTINCT config_type FROM config_data ORDER BY config_type";
                var result = _connection.Query<ConfigTypeRow>(sql);

                var types = new List<string>();
                foreach (var row in result)
                {
                    types.Add(row.config_type);
                }

                return types;
            }
            catch (Exception ex)
            {
                Debug.LogError($"获取配置类型失败: {ex.Message}");
                return new List<string>();
            }
        }

        /// <summary>
        /// 删除配置数据
        /// </summary>
        public bool DeleteConfig(string configType, string configName = null)
        {
            try
            {
                string sql;
                int affectedRows;

                if (string.IsNullOrEmpty(configName))
                {
                    // 删除整个类型的配置
                    sql = "DELETE FROM config_data WHERE config_type = ?";
                    affectedRows = _connection.Execute(sql, configType);
                    Debug.Log($"删除配置类型成功: {configType}, 影响行数: {affectedRows}");
                }
                else
                {
                    // 删除特定配置
                    sql = "DELETE FROM config_data WHERE config_type = ? AND config_name = ?";
                    affectedRows = _connection.Execute(sql, configType, configName);
                    Debug.Log($"删除配置数据成功: {configType}.{configName}, 影响行数: {affectedRows}");
                }

                return affectedRows > 0;
            }
            catch (Exception ex)
            {
                Debug.LogError($"删除配置数据失败: {configType}.{configName}, 错误: {ex.Message}");
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
                var stats = new DatabaseStats();

                // 获取总记录数
                var countSql = "SELECT COUNT(*) as count FROM config_data";
                var countResult = _connection.Query<CountRow>(countSql);
                stats.TotalConfigs = countResult.Count > 0 ? countResult[0].count : 0;

                // 获取配置类型数
                var typesSql = "SELECT COUNT(DISTINCT config_type) as count FROM config_data";
                var typesResult = _connection.Query<CountRow>(typesSql);
                stats.TotalTypes = typesResult.Count > 0 ? typesResult[0].count : 0;

                // 获取数据库文件大小
                if (File.Exists(_databasePath))
                {
                    var fileInfo = new FileInfo(_databasePath);
                    stats.TotalSize = fileInfo.Length;
                }

                stats.TotalSize = 0;
                stats.AverageSize = 0;
                stats.MaxSize = 0;
                stats.MinSize = 0;

                return stats;
            }
            catch (Exception ex)
            {
                Debug.LogError($"获取数据库统计信息失败: {ex.Message}");
                return new DatabaseStats();
            }
        }

        /// <summary>
        /// 清空所有配置数据
        /// </summary>
        public void ClearAllData()
        {
            try
            {
                var sql = "DELETE FROM config_data";
                var affectedRows = _connection.Execute(sql);
                Debug.Log($"清空所有配置数据成功，删除了 {affectedRows} 条记录");
            }
            catch (Exception ex)
            {
                Debug.LogError($"清空配置数据失败: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// 执行VACUUM操作优化数据库
        /// </summary>
        public void OptimizeDatabase()
        {
            try
            {
                _connection.Execute("VACUUM");
                Debug.Log("数据库优化完成");
            }
            catch (Exception ex)
            {
                Debug.LogError($"数据库优化失败: {ex.Message}");
            }
        }

        public void Dispose()
        {
            try
            {
                _connection?.Close();
                _connection?.Dispose();
                Debug.Log("SQLite4Unity3d数据库连接已关闭");
            }
            catch (Exception ex)
            {
                Debug.LogError($"关闭SQLite4Unity3d数据库连接失败: {ex.Message}");
            }
        }

        // 内部类用于查询结果映射
        private class ConfigDataRow
        {
            public byte[] binary_data { get; set; }
        }

        private class ConfigNameRow
        {
            public string config_name { get; set; }
        }

        private class ConfigTypeRow
        {
            public string config_type { get; set; }
        }

        private class CountRow
        {
            public int count { get; set; }
        }

    }


}
