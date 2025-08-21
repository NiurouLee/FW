using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline.Core
{
    /// <summary>
    /// 配置数据处理管道核心
    /// </summary>
    public class ConfigPipeline
    {
        private readonly List<IPreProcessor> _preProcessors = new List<IPreProcessor>();
        private readonly List<IDataProcessor> _dataProcessors = new List<IDataProcessor>();
        private readonly List<IPostProcessor> _postProcessors = new List<IPostProcessor>();
        private readonly List<IValidator> _validators = new List<IValidator>();
        private readonly List<ICodeGenerator> _codeGenerators = new List<ICodeGenerator>();

        private readonly PipelineSettings _settings;

        public ConfigPipeline(PipelineSettings settings = null)
        {
            _settings = settings ?? new PipelineSettings();
            InitializeDefaultProcessors();
        }

        /// <summary>
        /// 注册前处理器
        /// </summary>
        public ConfigPipeline RegisterPreProcessor(IPreProcessor processor)
        {
            if (processor != null && !_preProcessors.Contains(processor))
            {
                _preProcessors.Add(processor);
                _preProcessors.Sort((a, b) => a.Priority.CompareTo(b.Priority));
            }
            return this;
        }

        /// <summary>
        /// 注册数据处理器
        /// </summary>
        public ConfigPipeline RegisterDataProcessor(IDataProcessor processor)
        {
            if (processor != null && !_dataProcessors.Contains(processor))
            {
                _dataProcessors.Add(processor);
                _dataProcessors.Sort((a, b) => a.Priority.CompareTo(b.Priority));
            }
            return this;
        }

        /// <summary>
        /// 注册后处理器
        /// </summary>
        public ConfigPipeline RegisterPostProcessor(IPostProcessor processor)
        {
            if (processor != null && !_postProcessors.Contains(processor))
            {
                _postProcessors.Add(processor);
                _postProcessors.Sort((a, b) => a.Priority.CompareTo(b.Priority));
            }
            return this;
        }

        /// <summary>
        /// 注册验证器
        /// </summary>
        public ConfigPipeline RegisterValidator(IValidator validator)
        {
            if (validator != null && !_validators.Contains(validator))
            {
                _validators.Add(validator);
                _validators.Sort((a, b) => a.Priority.CompareTo(b.Priority));
            }
            return this;
        }

        /// <summary>
        /// 注册代码生成器
        /// </summary>
        public ConfigPipeline RegisterCodeGenerator(ICodeGenerator generator)
        {
            if (generator != null && !_codeGenerators.Contains(generator))
            {
                _codeGenerators.Add(generator);
                _codeGenerators.Sort((a, b) => a.Priority.CompareTo(b.Priority));
            }
            return this;
        }

        /// <summary>
        /// 执行完整的处理管道
        /// </summary>
        public PipelineResult Execute(PipelineInput input)
        {
            var result = new PipelineResult
            {
                Input = input,
                StartTime = DateTime.Now
            };

            try
            {
                // 1. 前处理阶段
                var preProcessContext = new PreProcessContext
                {
                    ConfigType = input.ConfigType,
                    ConfigName = input.ConfigName,
                    SourceFilePath = input.SourceFilePath,
                    RawDataSet = input.RawDataSet
                };

                if (!ExecutePreProcessors(preProcessContext, result))
                {
                    return result;
                }

                // 2. 代码生成阶段（如果需要）
                if (_settings.EnableCodeGeneration)
                {
                    var codeGenContext = new CodeGenerationContext
                    {
                        ConfigType = input.ConfigType,
                        ConfigName = input.ConfigName,
                        SchemaDefinition = preProcessContext.SchemaDefinition,
                        OutputDirectory = _settings.CodeOutputDirectory,
                        Settings = _settings.CodeGenerationSettings
                    };

                    if (!ExecuteCodeGenerators(codeGenContext, result))
                    {
                        return result;
                    }
                }

                // 3. 数据处理阶段
                var dataProcessContext = new DataProcessContext
                {
                    ConfigType = input.ConfigType,
                    ConfigName = input.ConfigName,
                    SourceData = preProcessContext.CurrentSheet,
                    SchemaDefinition = preProcessContext.SchemaDefinition,
                    TargetType = input.TargetType
                };

                if (!ExecuteDataProcessors(dataProcessContext, result))
                {
                    return result;
                }

                // 4. 验证阶段
                if (_settings.EnableValidation)
                {
                    var validationContext = new ValidationContext
                    {
                        ConfigType = input.ConfigType,
                        ConfigName = input.ConfigName,
                        DataToValidate = dataProcessContext.ProcessedObjects,
                        DataType = input.TargetType,
                        ValidationRules = input.ValidationRules
                    };

                    if (!ExecuteValidators(validationContext, result))
                    {
                        return result;
                    }
                }

                // 5. 后处理阶段
                var postProcessContext = new PostProcessContext
                {
                    ConfigType = input.ConfigType,
                    ConfigName = input.ConfigName,
                    BinaryData = result.BinaryData,
                    OutputPath = input.OutputPath,
                    CompressionSettings = _settings.CompressionSettings,
                    EncryptionSettings = _settings.EncryptionSettings
                };

                if (!ExecutePostProcessors(postProcessContext, result))
                {
                    return result;
                }

                result.Success = true;
                result.BinaryData = postProcessContext.BinaryData;

                // 复制后处理生成的文件到结果中
                foreach (var kvp in postProcessContext.AdditionalFiles)
                {
                    result.OutputFiles[kvp.Key] = kvp.Value;
                }

            }
            catch (Exception ex)
            {
                result.Success = false;
                result.Errors.Add($"Pipeline execution failed: {ex.Message}");
                Debug.LogError($"Pipeline execution failed: {ex}");
            }
            finally
            {
                result.EndTime = DateTime.Now;
                result.Duration = result.EndTime - result.StartTime;
            }

            return result;
        }

        private bool ExecutePreProcessors(PreProcessContext context, PipelineResult result)
        {
            var preProcessors = _preProcessors.Where(p => p.IsEnabled).ToList();
            preProcessors.Sort((a, b) => a.Priority.CompareTo(b.Priority));
            foreach (var processor in preProcessors)
            {
                try
                {
                    context.AddLog($"Executing pre-processor: {processor.Name}");

                    // 先添加日志和警告
                    result.Logs.AddRange(context.Logs);
                    result.Warnings.AddRange(context.Warnings);

                    if (!processor.Process(context))
                    {
                        // 添加处理器失败的错误信息
                        result.Errors.Add($"Pre-processor {processor.Name} failed");
                        
                        // 添加处理器的具体错误信息
                        if (context.HasErrors)
                        {
                            result.Errors.AddRange(context.Errors);
                        }
                        
                        // 添加处理器的日志，可能包含有用的上下文信息
                        result.Logs.AddRange(context.Logs);
                        return false;
                    }

                    // 继续添加新的日志和警告
                    result.Logs.AddRange(context.Logs);
                    result.Warnings.AddRange(context.Warnings);

                    if (context.HasErrors)
                    {
                        result.Errors.AddRange(context.Errors);
                        return false;
                    }
                }
                catch (Exception ex)
                {
                    result.Errors.Add($"Pre-processor {processor.Name} threw exception: {ex.Message}");
                    return false;
                }
            }

            return true;
        }

        private bool ExecuteDataProcessors(DataProcessContext context, PipelineResult result)
        {
            foreach (var processor in _dataProcessors.Where(p => p.IsEnabled))
            {
                try
                {
                    context.AddLog($"Executing data processor: {processor.Name}");

                    if (!processor.Process(context))
                    {
                        result.Errors.Add($"Data processor {processor.Name} failed");
                        return false;
                    }

                    result.Logs.AddRange(context.Logs);
                    result.Warnings.AddRange(context.Warnings);

                    if (context.HasErrors)
                    {
                        result.Errors.AddRange(context.Errors);
                        return false;
                    }
                }
                catch (Exception ex)
                {
                    result.Errors.Add($"Data processor {processor.Name} threw exception: {ex.Message}");
                    return false;
                }
            }

            return true;
        }

        private bool ExecutePostProcessors(PostProcessContext context, PipelineResult result)
        {
            foreach (var processor in _postProcessors.Where(p => p.IsEnabled))
            {
                try
                {
                    context.AddLog($"Executing post-processor: {processor.Name}");

                    if (!processor.Process(context))
                    {
                        result.Errors.Add($"Post-processor {processor.Name} failed");
                        return false;
                    }

                    result.Logs.AddRange(context.Logs);
                    result.Warnings.AddRange(context.Warnings);

                    if (context.HasErrors)
                    {
                        result.Errors.AddRange(context.Errors);
                        return false;
                    }
                }
                catch (Exception ex)
                {
                    result.Errors.Add($"Post-processor {processor.Name} threw exception: {ex.Message}");
                    return false;
                }
            }

            return true;
        }

        private bool ExecuteValidators(ValidationContext context, PipelineResult result)
        {
            var allValidationResults = new List<ValidationResult>();

            foreach (var validator in _validators.Where(v => v.IsEnabled))
            {
                try
                {
                    context.AddLog($"Executing validator: {validator.Name}");

                    var validationResult = validator.Validate(context);
                    allValidationResults.Add(validationResult);

                    if (!validationResult.IsValid && _settings.StopOnValidationError)
                    {
                        result.Errors.AddRange(validationResult.Errors.Select(e => e.Message));
                        return false;
                    }

                    result.Warnings.AddRange(validationResult.Warnings);
                }
                catch (Exception ex)
                {
                    result.Errors.Add($"Validator {validator.Name} threw exception: {ex.Message}");
                    if (_settings.StopOnValidationError)
                    {
                        return false;
                    }
                }
            }

            // 汇总验证结果
            result.ValidationResults = allValidationResults;
            return true;
        }

        private bool ExecuteCodeGenerators(CodeGenerationContext context, PipelineResult result)
        {
            var codeGenerators = _codeGenerators.Where(g => g.IsEnabled).ToList();
            codeGenerators.Sort((a, b) => a.Priority.CompareTo(b.Priority));
            foreach (var generator in codeGenerators)
            {
                try
                {
                    context.AddLog($"Executing code generator: {generator.Name}");

                    var generationResult = generator.Generate(context);

                    if (!generationResult.Success)
                    {
                        result.Errors.AddRange(generationResult.Errors);
                        return false;
                    }

                    // 合并生成的文件
                    foreach (var kvp in generationResult.GeneratedFiles)
                    {
                        result.GeneratedFiles[kvp.Key] = kvp.Value;
                    }
                }
                catch (Exception ex)
                {
                    result.Errors.Add($"Code generator {generator.Name} threw exception: {ex.Message}");
                    return false;
                }
            }

            return true;
        }

        private void InitializeDefaultProcessors()
        {
            // 这里可以注册默认的处理器
            // 实际项目中应该通过配置或依赖注入来管理
        }

        /// <summary>
        /// 获取所有已注册的处理器信息
        /// </summary>
        public PipelineInfo GetPipelineInfo()
        {
            return new PipelineInfo
            {
                PreProcessors = _preProcessors.Select(p => new ProcessorInfo { Name = p.Name, Priority = p.Priority, IsEnabled = p.IsEnabled }).ToList(),
                DataProcessors = _dataProcessors.Select(p => new ProcessorInfo { Name = p.Name, Priority = p.Priority, IsEnabled = p.IsEnabled }).ToList(),
                PostProcessors = _postProcessors.Select(p => new ProcessorInfo { Name = p.Name, Priority = p.Priority, IsEnabled = p.IsEnabled }).ToList(),
                Validators = _validators.Select(p => new ProcessorInfo { Name = p.Name, Priority = p.Priority, IsEnabled = p.IsEnabled }).ToList(),
                CodeGenerators = _codeGenerators.Select(p => new ProcessorInfo { Name = p.Name, Priority = p.Priority, IsEnabled = p.IsEnabled }).ToList()
            };
        }
    }

    /// <summary>
    /// 管道设置
    /// </summary>
    public class PipelineSettings
    {
        public bool EnableValidation { get; set; } = true;
        public bool EnableCodeGeneration { get; set; } = true;
        public bool StopOnValidationError { get; set; } = true;
        public string CodeOutputDirectory { get; set; } = "Assets/Generated/Config";
        public CompressionSettings CompressionSettings { get; set; } = new CompressionSettings();
        public EncryptionSettings EncryptionSettings { get; set; } = new EncryptionSettings();
        public CodeGenerationSettings CodeGenerationSettings { get; set; } = new CodeGenerationSettings();
    }

    /// <summary>
    /// 管道输入
    /// </summary>
    public class PipelineInput
    {
        public string ConfigType { get; set; }
        public string ConfigName { get; set; }
        public string SourceFilePath { get; set; }
        public System.Data.DataSet RawDataSet { get; set; }
        public Type TargetType { get; set; }
        public string OutputPath { get; set; }
        public ValidationRules ValidationRules { get; set; }
    }

    /// <summary>
    /// 管道结果
    /// </summary>
    public class PipelineResult
    {
        public bool Success { get; set; }
        public PipelineInput Input { get; set; }
        public byte[] BinaryData { get; set; }
        public Dictionary<string, byte[]> OutputFiles { get; } = new Dictionary<string, byte[]>();
        public Dictionary<string, string> GeneratedFiles { get; } = new Dictionary<string, string>();
        public List<ValidationResult> ValidationResults { get; set; } = new List<ValidationResult>();
        public List<string> Logs { get; } = new List<string>();
        public List<string> Warnings { get; } = new List<string>();
        public List<string> Errors { get; } = new List<string>();
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public TimeSpan Duration { get; set; }
    }

    /// <summary>
    /// 管道信息
    /// </summary>
    public class PipelineInfo
    {
        public List<ProcessorInfo> PreProcessors { get; set; } = new List<ProcessorInfo>();
        public List<ProcessorInfo> DataProcessors { get; set; } = new List<ProcessorInfo>();
        public List<ProcessorInfo> PostProcessors { get; set; } = new List<ProcessorInfo>();
        public List<ProcessorInfo> Validators { get; set; } = new List<ProcessorInfo>();
        public List<ProcessorInfo> CodeGenerators { get; set; } = new List<ProcessorInfo>();
    }

    /// <summary>
    /// 处理器信息
    /// </summary>
    public class ProcessorInfo
    {
        public string Name { get; set; }
        public int Priority { get; set; }
        public bool IsEnabled { get; set; }
    }
}
