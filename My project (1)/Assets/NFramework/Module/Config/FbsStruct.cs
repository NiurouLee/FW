
using System.Collections.Generic;
using System.Text;

namespace NFramework.Module.Config
{
    public class FbsStruct
    {
        /// <summary>
        /// 名字
        /// </summary>
        public string Name;
        /// <summary>
        /// 描述
        /// </summary>
        public string Des;
        /// <summary>
        /// 字段
        /// </summary>
        public List<FbsField> Fields = new List<FbsField>();

        public string GetFbsString()
        {
            var sb = new StringBuilder();
            sb.AppendLine($"struct {Name} {{");
            foreach (var field in Fields)
            {
                sb.AppendLine(field.GetFbsFileString());
            }
            sb.AppendLine("}");
            return sb.ToString();
        }
    }

    public class FbsField
    {
        public FbsField(ExcelColumn inExcelColumn)
        {
            ExcelColumn = inExcelColumn;
        }

        public ExcelColumn ExcelColumn;
        public string Name;
        public string Type;
        public string Des;
        public string DefaultValue;

        public bool IsSubType()
        {
            return false;
        }

        public FbsStruct GetSubFbsStruct()
        {
            return null;
        }

        public string GetFbsFileString()
        {
            if (IsSubType())
            {
                return string.Empty;
            }
            else
            {
                if (string.IsNullOrEmpty(DefaultValue))
                {
                    return $"{Name} : {Type}";
                }
                else
                {
                    return $"{Name} : {Type} = {DefaultValue}";
                }
            }
        }
    }
}
