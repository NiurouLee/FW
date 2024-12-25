using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace Game.ShwoDataUtil
{
    public class TreeNode
    {
        public static string findstr = "";
        public string Name { get; set; } // 成员名称
        public object Value { get; set; } // 成员值
        public List<TreeNode> Children { get; set; } // 子节点列表
        public bool IsExpanded { get; set; } // 用于控制节点的展开和折叠
        //JsonFormatter s_MsgFormatter;

        public TreeNode(string name, object value)
        {
            Name = name;
            Value = value;
            Children = new List<TreeNode>();
            IsExpanded = false;

        }
        public bool HasChildren()
        {
            if (Children != null && Children.Count > 0)
            {
                return true;
            }
            return false;
        }

        // 输出树状结构为字符串形式
        public string ToStringRepresentation(string prefix = "", int _x = 1)
        {
            x = _x;
            var result = $"{prefix}{Name}: {FormatValue(Value)}\n";
            foreach (var child in Children)
            {
                result += child.ToStringRepresentation(prefix + "  ", x + 1);
            }
            return result;
        }
        int x;
        public string DArray(Array arys)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(' ', x * 4);
            sb.Append(arys.GetType().ToString());
            foreach (var item in arys)
            {
                if (item != null)
                {
                    sb.Append($"   {item.ToString()}, ");
                }
                else
                {
                    sb.Append($"   null, ");

                }
            }
            return sb.ToString();
        }
        public string DIEnumerable(IEnumerable arys)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(' ', x * 4);
            sb.AppendLine();
            foreach (var item in arys)
            {
                sb.AppendLine($"   {item.ToString()}, ");
            }
            return sb.ToString();
        }
        public string GetFormatValue()
        {
            return FormatValue(Value);
        }

        public string FormatValue(object o = null)
        {
            if (o == null)
                o = Value;
            if (o == null)
                return ("null");
            if (TypeUtil.IsValueArray(o.GetType()))
                return DArray(o as Array);

            if (o is DateTime)
                return (((DateTime)o).ToShortDateString());

            if (o is string)
                return string.Format("\"{0}\"", o);

            if (o is char && (char)o == '\0')
                return string.Empty;
            if (o is ValueType)
                return (o.ToString());
            return (TypeUtil.GetSimplifiedName(o.GetType()));
        }

    }
}
