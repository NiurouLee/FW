using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NFramework.Module.IDGenerator;

namespace NFramework.Module.Entity
{
    public class World : Entity
    {
        public World()
        {
            IsCreated = true;
            IsNew = true;
            Id = Framework.Instance.GetModule<IDGeneratorModule>().GenerateInstanceId();
            this.IsRegister = true;
        }
    }
}