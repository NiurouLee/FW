namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 基础处理器接口
    /// </summary>
    public interface IProcessor
    {
        string Name { get; }
        int Priority { get; }
        bool IsEnabled { get; }
    }

    /// <summary>
    /// 收集器接口 - 用于收集单个配置文件的信息
    /// </summary>
    public interface ICollector : IProcessor
    {
        bool Collect(CollectionContext context);
    }

    /// <summary>
    /// 批处理器接口 - 用于统一处理所有配置类型
    /// </summary>
    public interface IBatchProcessor : IProcessor
    {
        bool ProcessBatch(BatchProcessContext context);
    }

    /// <summary>
    /// 单文件预处理器接口
    /// </summary>
    public interface IPreProcessor : IProcessor
    {
        bool Process(PreProcessContext context);
    }

    /// <summary>
    /// 单文件生成器接口
    /// </summary>
    public interface IGenerator : IProcessor
    {
        CodeGenerationResult Generate(CodeGenerationContext context);
    }

    /// <summary>
    /// 代码生成器接口
    /// </summary>
    public interface ICodeGenerator : IGenerator
    {
        string TargetLanguage { get; }
        string[] SupportedFileExtensions { get; }
    }

    /// <summary>
    /// 单文件后处理器接口
    /// </summary>
    public interface IPostProcessor : IProcessor
    {
        bool Process(PostProcessContext context);
    }

    /// <summary>
    /// 统一后处理器接口 - 用于处理所有文件的最终处理
    /// </summary>
    public interface IFinalProcessor : IProcessor
    {
        bool ProcessFinal(FinalProcessContext context);
    }

    /// <summary>
    /// 验证器接口
    /// </summary>
    public interface IValidator : IProcessor
    {
        ValidationResult Validate(ValidationContext context);
    }
}