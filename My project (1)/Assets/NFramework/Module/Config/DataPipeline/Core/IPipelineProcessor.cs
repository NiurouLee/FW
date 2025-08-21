using System;
using System.Collections.Generic;

namespace NFramework.Module.Config.DataPipeline.Core
{
    /// <summary>
    /// 管道处理器基础接口
    /// </summary>
    public interface IPipelineProcessor
    {
        string Name { get; }
        int Priority { get; }
        bool IsEnabled { get; set; }
    }

    /// <summary>
    /// 前处理器接口
    /// </summary>
    public interface IPreProcessor : IPipelineProcessor
    {
        /// <summary>
        /// 处理原始Excel数据
        /// </summary>
        /// <param name="context">处理上下文</param>
        /// <returns>是否继续处理</returns>
        bool Process(PreProcessContext context);
    }

    /// <summary>
    /// 数据处理器接口
    /// </summary>
    public interface IDataProcessor : IPipelineProcessor
    {
        /// <summary>
        /// 处理数据对象
        /// </summary>
        /// <param name="context">处理上下文</param>
        /// <returns>是否继续处理</returns>
        bool Process(DataProcessContext context);
    }

    /// <summary>
    /// 后处理器接口
    /// </summary>
    public interface IPostProcessor : IPipelineProcessor
    {
        /// <summary>
        /// 处理生成的二进制数据
        /// </summary>
        /// <param name="context">处理上下文</param>
        /// <returns>是否继续处理</returns>
        bool Process(PostProcessContext context);
    }

    /// <summary>
    /// 验证器接口
    /// </summary>
    public interface IValidator : IPipelineProcessor
    {
        /// <summary>
        /// 验证数据
        /// </summary>
        /// <param name="context">验证上下文</param>
        /// <returns>验证结果</returns>
        ValidationResult Validate(ValidationContext context);
    }

    /// <summary>
    /// 代码生成器接口
    /// </summary>
    public interface ICodeGenerator : IPipelineProcessor
    {
        /// <summary>
        /// 生成代码
        /// </summary>
        /// <param name="context">生成上下文</param>
        /// <returns>生成结果</returns>
        CodeGenerationResult Generate(CodeGenerationContext context);
    }
}
