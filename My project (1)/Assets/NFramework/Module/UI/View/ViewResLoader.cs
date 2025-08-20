using NFramework.Module.ResModule;

namespace NFramework.Module.UIModule
{
    public partial class View
    {
        public ResLoadRecords ResLoadRecords { get; private set; }

        public void GenerateResLoadRecords()
        {
            ResLoadRecords = new ResLoadRecords();
        }
    }
}

