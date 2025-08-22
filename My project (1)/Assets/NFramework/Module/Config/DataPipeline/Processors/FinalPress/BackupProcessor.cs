using System;
using System.IO;
using System.Linq;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 备份处理器
    /// </summary>
    public class BackupProcessor : IFinalProcessor
    {
        public string Name => "Backup Processor";
        public int Priority => 100;
        public bool IsEnabled { get; set; } = true;

        private readonly BackupSettings _settings;

        public BackupProcessor(BackupSettings settings)
        {
            _settings = settings ?? new BackupSettings();
        }

        public bool ProcessFinal(FinalProcessContext context)
        {
            try
            {
                if (!_settings.CreateBackup)
                {
                    context.AddLog("Backup is disabled");
                    return true;
                }

                var backupDir = Path.Combine(Application.dataPath, _settings.BackupDirectory);
                Directory.CreateDirectory(backupDir);

                // 清理旧备份
                CleanupOldBackups(backupDir);

                // 创建新备份
                var timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
                var backupPath = Path.Combine(backupDir, $"Config_Backup_{timestamp}.bytes");

                // 保存所有处理结果
                foreach (var kvp in context.ProcessedResults)
                {
                    var resultPath = Path.Combine(backupDir, $"{kvp.Key}_{timestamp}.bytes");
                    File.WriteAllBytes(resultPath, kvp.Value as byte[] ?? Array.Empty<byte>());
                }

                context.AddLog($"Backup created at: {backupPath}");
                return true;
            }
            catch (Exception ex)
            {
                context.AddError($"Backup failed: {ex.Message}");
                return false;
            }
        }

        private void CleanupOldBackups(string backupDir)
        {
            try
            {
                var backupFiles = Directory.GetFiles(backupDir, "Config_Backup_*.bytes")
                    .OrderByDescending(f => f)
                    .Skip(_settings.MaxBackupCount);

                foreach (var file in backupFiles)
                {
                    File.Delete(file);
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"Failed to cleanup old backups: {ex.Message}");
            }
        }
    }
}