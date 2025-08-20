
using System.Collections.Generic;

namespace NFramework.Module.ConfigModule
{
    /// <summary>
    /// Excel 表头,前四行
    /// </summary>
    public class ExcelHeader
    {
        public string FileName;
        public string SheetName;
        public List<ExcelColumn> Columns = new List<ExcelColumn>();
    }

    /// <summary>
    /// 一个excel 中sheet中一列的前四行
    /// </summary>
    public class ExcelColumn
    {
        /// <summary>
        /// 表中名字
        /// </summary>
        public string ColumnName;
        /// <summary>
        /// 表中类型
        /// </summary>
        public string ColumnType;
        /// <summary>
        /// 描述
        /// </summary>
        public string ColumnDes;
        /// <summary>
        /// 表中默认值 
        /// </summary>
        public string DefaultValue;


        public bool IsArray()
        {
            return ColumnType.Contains(Excel2FbsStructs.RepeatedPrefix);
        }

        public bool IsMap()
        {
            return ColumnType.Contains(Excel2FbsStructs.MapPrefix);
        }

        public bool IsArrayAndMap()
        {
            return IsArray() && IsMap();
        }

        /// <summary>
        /// 获取字段名 
        /// </summary>
        /// <returns></returns>
        public string GetName()
        {
            if (ColumnName.Contains("@"))
            {
                return ColumnName.ToLower().Split('@')[0];
            }
            return ColumnName;
        }

        public string GetArrayType()
        {
            return ColumnType.ToLower().Replace(Excel2FbsStructs.RepeatedPrefix, "").Replace(" ", "");
        }

    }
}