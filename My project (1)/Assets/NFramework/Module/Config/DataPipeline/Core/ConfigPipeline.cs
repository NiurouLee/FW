using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 配置数据处理管道核心
    /// </summary>
    public class ConfigPipeline
    {
        private readonly List<ICollector> _collectors = new List<ICollector>();
        private readonly List<IBatchProcessor> _batchProcessors = new List<IBatchProcessor>();
        private readonly List<IPreProcessor> _preProcessors = new List<IPreProcessor>();
        private readonly List<IGenerator> _generators = new List<IGenerator>();
        private readonly List<ICodeGenerator> _codeGenerators = new List<ICodeGenerator>();
        private readonly List<IPostProcessor> _postProcessors = new List<IPostProcessor>();
        private readonly List<IFinalProcessor> _finalProcessors = new List<IFinalProcessor>();
        private readonly List<IValidator> _validators = new List<IValidator>();
        private readonly PipelineSettings _settings;

        public ConfigPipeline(PipelineSettings settings = null)
        {
            _settings = settings ?? new PipelineSettings();
            InitializeDefaultProcessors();
        }

        #region 注册处理器
        public ConfigPipeline RegisterCollector(ICollector collector)
        {
            if (collector != null && !_collectors.Contains(collector))
            {
                _collectors.Add(collector);
                _collectors.Sort((a, b) => a.Priority.CompareTo(b.Priority));
            }
            return this;
        }

        public ConfigPipeline RegisterBatchProcessor(IBatchProcessor processor)
        {
            if (processor != null && !_batchProcessors.Contains(processor))
            {
                _batchProcessors.Add(processor);
                _batchProcessors.Sort((a, b) => a.Priority.CompareTo(b.Priority));
            }
            return this;
        }

        public ConfigPipeline RegisterPreProcessor(IPreProcessor processor)
        {
            if (processor != null && !_preProcessors.Contains(processor))
            {
                _preProcessors.Add(processor);
                _preProcessors.Sort((a, b) => a.Priority.CompareTo(b.Priority));
            }
            return this;
        }

        public ConfigPipeline RegisterGenerator(IGenerator generator)
        {
            if (generator != null)
            {
                if (generator is ICodeGenerator codeGenerator)
                {
                    if (!_codeGenerators.Contains(codeGenerator))
                    {
                        _codeGenerators.Add(codeGenerator);
                        _codeGenerators.Sort((a, b) => a.Priority.CompareTo(b.Priority));
                    }
                }
                else if (!_generators.Contains(generator))
                {
                    _generators.Add(generator);
                    _generators.Sort((a, b) => a.Priority.CompareTo(b.Priority));
                }
            }
            return this;
        }

        public ConfigPipeline RegisterCodeGenerator(ICodeGenerator generator)
        {
            if (generator != null && !_codeGenerators.Contains(generator))
            {
                _codeGenerators.Add(generator);
                _codeGenerators.Sort((a, b) => a.Priority.CompareTo(b.Priority));
            }
            return this;
        }

        public ConfigPipeline RegisterPostProcessor(IPostProcessor processor)
        {
            if (processor != null && !_postProcessors.Contains(processor))
            {
                _postProcessors.Add(processor);
                _postProcessors.Sort((a, b) => a.Priority.CompareTo(b.Priority));
            }
            return this;
        }

        public ConfigPipeline RegisterFinalProcessor(IFinalProcessor processor)
        {
            if (processor != null && !_finalProcessors.Contains(processor))
            {
                _finalProcessors.Add(processor);
                _finalProcessors.Sort((a, b) => a.Priority.CompareTo(b.Priority));
            }
            return this;
        }

        public ConfigPipeline RegisterValidator(IValidator validator)
        {
            if (validator != null && !_validators.Contains(validator))
            {
                _validators.Add(validator);
                _validators.Sort((a, b) => a.Priority.CompareTo(b.Priority));
            }
            return this;
        }
        #endregion

        /// <summary>
        /// 执行完整的处理管道
        /// </summary>
        public PipelineResult Execute(List<PipelineInput> inputs)
        {
            var result = new PipelineResult
            {
                StartTime = DateTime.Now
            };

            try
            {
                // 1. 收集阶段 - 对每个输入文件进行收集
                var collectionResults = new Dictionary<string, CollectionContext>();
                foreach (var input in inputs)
                {
                    var collectionContext = new CollectionContext
                    {
                        ConfigType = input.ConfigType,
                        ConfigName = input.ConfigName,
                        SourceFilePath = input.SourceFilePath,
                        RawDataSet = input.RawDataSet
                    };

                    if (!ExecuteCollectors(collectionContext, result))
                    {
                        return result;
                    }

                    collectionResults[input.ConfigName] = collectionContext;
                }

                // 2. 统一处理阶段 - 处理所有收集到的类型
                var batchContext = new BatchProcessContext
                {
                    CollectedContexts = collectionResults
                };

                if (!ExecuteBatchProcessors(batchContext, result))
                {
                    return result;
                }

                // 3. 逐个预处理
                foreach (var input in inputs)
                {
                    var preProcessContext = new PreProcessContext
                    {
                        ConfigType = input.ConfigType,
                        ConfigName = input.ConfigName,
                        CurrentSheet = input.RawDataSet.Tables[0], // 假设第一个表是主表
                        SchemaDefinition = batchContext.SharedData[$"{input.ConfigName}_Schema"] as SchemaDefinition
                    };

                    if (!ExecutePreProcessors(preProcessContext, result))
                    {
                        return result;
                    }

                    // 执行验证
                    if (_settings.EnableValidation)
                    {
                        var validationContext = new ValidationContext
                        {
                            ConfigType = input.ConfigType,
                            ConfigName = input.ConfigName,
                            DataToValidate = preProcessContext.CurrentSheet,
                            DataType = input.TargetType,
                            ValidationRules = input.ValidationRules
                        };

                        if (!ExecuteValidators(validationContext, result))
                        {
                            return result;
                        }
                    }
                }

                // 4. 逐个生成
                if (_settings.EnableCodeGeneration)
                {
                    foreach (var input in inputs)
                    {
                        var codeGenContext = new CodeGenerationContext
                        {
                            ConfigType = input.ConfigType,
                            ConfigName = input.ConfigName,
                            SchemaDefinition = batchContext.SharedData[$"{input.ConfigName}_Schema"] as SchemaDefinition,
                            OutputDirectory = _settings.CodeOutputDirectory,
                            Settings = _settings.CodeGenerationSettings
                        };

                        // 执行代码生成器
                        if (!ExecuteCodeGenerators(codeGenContext, result))
                        {
                            return result;
                        }

                        // 执行其他生成器
                        if (!ExecuteGenerators(codeGenContext, result))
                        {
                            return result;
                        }
                    }
                }

                // 5. 逐个后处理
                foreach (var input in inputs)
                {
                    var postProcessContext = new PostProcessContext
                    {
                        ConfigType = input.ConfigType,
                        ConfigName = input.ConfigName,
                        OutputPath = input.OutputPath,
                        CompressionSettings = _settings.CompressionSettings,
                        EncryptionSettings = _settings.EncryptionSettings
                    };

                    if (!ExecutePostProcessors(postProcessContext, result))
                    {
                        return result;
                    }

                    // 合并后处理生成的文件
                    foreach (var kvp in postProcessContext.AdditionalFiles)
                    {
                        result.OutputFiles[kvp.Key] = kvp.Value;
                    }
                }

                // 6. 统一后处理
                var finalContext = new FinalProcessContext
                {
                    Settings = _settings
                };

                if (!ExecuteFinalProcessors(finalContext, result))
                {
                    return result;
                }

                result.Success = true;
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

        #region 执行处理器
        private bool ExecuteCollectors(CollectionContext context, PipelineResult result)
        {
            foreach (var collector in _collectors.Where(c => c.IsEnabled))
            {
                try
                {
                    context.AddLog($"Executing collector: {collector.Name}");

                    if (!collector.Collect(context))
                    {
                        result.Errors.Add($"Collector {collector.Name} failed");
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
                    result.Errors.Add($"Collector {collector.Name} threw exception: {ex.Message}");
                    return false;
                }
            }
            return true;
        }

        private bool ExecuteBatchProcessors(BatchProcessContext context, PipelineResult result)
        {
            foreach (var processor in _batchProcessors.Where(p => p.IsEnabled))
            {
                try
                {
                    context.AddLog($"Executing batch processor: {processor.Name}");

                    if (!processor.ProcessBatch(context))
                    {
                        result.Errors.Add($"Batch processor {processor.Name} failed");
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
                    result.Errors.Add($"Batch processor {processor.Name} threw exception: {ex.Message}");
                    return false;
                }
            }
            return true;
        }

        private bool ExecutePreProcessors(PreProcessContext context, PipelineResult result)
        {
            foreach (var processor in _preProcessors.Where(p => p.IsEnabled))
            {
                try
                {
                    context.AddLog($"Executing pre-processor: {processor.Name}");

                    if (!processor.Process(context))
                    {
                        result.Errors.Add($"Pre-processor {processor.Name} failed");
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
                    result.Errors.Add($"Pre-processor {processor.Name} threw exception: {ex.Message}");
                    return false;
                }
            }
            return true;
        }

        private bool ExecuteGenerators(CodeGenerationContext context, PipelineResult result)
        {
            foreach (var generator in _generators.Where(g => g.IsEnabled))
            {
                try
                {
                    context.AddLog($"Executing generator: {generator.Name}");

                    var genResult = generator.Generate(context);
                    if (!genResult.Success)
                    {
                        result.Errors.AddRange(genResult.Errors);
                        return false;
                    }

                    result.Logs.AddRange(context.Logs);
                    result.Warnings.AddRange(context.Warnings);
                    result.Warnings.AddRange(genResult.Warnings);

                    if (context.HasErrors)
                    {
                        result.Errors.AddRange(context.Errors);
                        return false;
                    }

                    // 合并生成的文件
                    foreach (var kvp in genResult.GeneratedFiles)
                    {
                        result.GeneratedFiles[kvp.Key] = kvp.Value;
                    }
                }
                catch (Exception ex)
                {
                    result.Errors.Add($"Generator {generator.Name} threw exception: {ex.Message}");
                    return false;
                }
            }
            return true;
        }

        private bool ExecuteCodeGenerators(CodeGenerationContext context, PipelineResult result)
        {
            foreach (var generator in _codeGenerators.Where(g => g.IsEnabled))
            {
                try
                {
                    context.AddLog($"Executing code generator: {generator.Name} ({generator.TargetLanguage})");

                    var genResult = generator.Generate(context);
                    if (!genResult.Success)
                    {
                        result.Errors.AddRange(genResult.Errors);
                        return false;
                    }

                    result.Logs.AddRange(context.Logs);
                    result.Warnings.AddRange(context.Warnings);
                    result.Warnings.AddRange(genResult.Warnings);

                    if (context.HasErrors)
                    {
                        result.Errors.AddRange(context.Errors);
                        return false;
                    }

                    // 合并生成的文件
                    foreach (var kvp in genResult.GeneratedFiles)
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

        private bool ExecuteFinalProcessors(FinalProcessContext context, PipelineResult result)
        {
            foreach (var processor in _finalProcessors.Where(p => p.IsEnabled))
            {
                try
                {
                    context.AddLog($"Executing final processor: {processor.Name}");

                    if (!processor.ProcessFinal(context))
                    {
                        result.Errors.Add($"Final processor {processor.Name} failed");
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
                    result.Errors.Add($"Final processor {processor.Name} threw exception: {ex.Message}");
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
        #endregion

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
                Collectors = _collectors.Select(p => new ProcessorInfo { Name = p.Name, Priority = p.Priority, IsEnabled = p.IsEnabled }).ToList(),
                BatchProcessors = _batchProcessors.Select(p => new ProcessorInfo { Name = p.Name, Priority = p.Priority, IsEnabled = p.IsEnabled }).ToList(),
                PreProcessors = _preProcessors.Select(p => new ProcessorInfo { Name = p.Name, Priority = p.Priority, IsEnabled = p.IsEnabled }).ToList(),
                Generators = _generators.Select(p => new ProcessorInfo { Name = p.Name, Priority = p.Priority, IsEnabled = p.IsEnabled }).ToList(),
                PostProcessors = _postProcessors.Select(p => new ProcessorInfo { Name = p.Name, Priority = p.Priority, IsEnabled = p.IsEnabled }).ToList(),
                FinalProcessors = _finalProcessors.Select(p => new ProcessorInfo { Name = p.Name, Priority = p.Priority, IsEnabled = p.IsEnabled }).ToList(),
                Validators = _validators.Select(p => new ProcessorInfo { Name = p.Name, Priority = p.Priority, IsEnabled = p.IsEnabled }).ToList()
            };
        }
    }
}