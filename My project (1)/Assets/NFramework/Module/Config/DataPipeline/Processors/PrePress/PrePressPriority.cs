namespace NFramework.Module.Config.DataPipeline
{
    public class PrePressPriority
    {
        public const int SchemaGenerator = 100;
        public const int DataCleaner = 200;
        public const int Localization = 300;
        public const int ReferenceTypeValidator = 350;  // 在引用解析之前执行
        public const int ReferenceResolver = 400;
        public const int Array2DProcessor = 500;
        public const int Custom = 600;
    }
}