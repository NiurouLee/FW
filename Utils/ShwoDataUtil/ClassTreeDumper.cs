using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Text;
using Google.Protobuf;

namespace Game.ShwoDataUtil
{
    public class ClassTreeDumper
    {
        public static string DumpAll(object element)
        {
            var instance = new ClassTreeDumper(2);
            instance._parsedData = new StringBuilder();
            instance.root = new TreeNode("root", element);
            instance.root.IsExpanded = true;
            instance.DumpElement(element, "root", instance.root);
            return instance._parsedData.ToString();
        }


        private int _level;
        private readonly int _indentSize;
        public readonly StringBuilder _stringBuilder;
        private readonly Dictionary<string, string> _hashListOfFoundElements;
        public TreeNode root;
        private readonly HashSet<object> _visitedObjects; // 新增：用于跟踪已访问的对象


        private ClassTreeDumper(int indentSize)
        {
            _indentSize = indentSize;
            _stringBuilder = new StringBuilder();
            _hashListOfFoundElements = new Dictionary<string, string>();
            _visitedObjects = new HashSet<object>(); // 初始化
        }

        // public static string Dump(object element)
        // {
        //     return Dump(element, 2);
        // }
        private StringBuilder _parsedData;

        public static string Dump(object element)
        {
            var instance = new ClassTreeDumper(2);
            instance.root = new TreeNode("root", element);
            instance.root.IsExpanded = true;
            instance.DumpElement(element, "root", instance.root);
            return instance._parsedData.ToString();
        }

        public static ClassTreeDumper Dump2(object element)
        {
            var instance = new ClassTreeDumper(2);
            instance.root = new TreeNode("root", element);
            instance.root.IsExpanded = true;
            instance.DumpElement(element, "root", instance.root);
            return instance;
        }

        public static string Dump(object element, int indentSize)
        {
            var instance = new ClassTreeDumper(indentSize);
            return instance.DumpElement(element, "root");
        }

        private string DumpElement(object element, string name, TreeNode node = null)
        {
            if (element==null)
            {
                return "";
            }
            if (_visitedObjects.Contains(element)) // 检查对象是否已访问
            {
                return ""; // 如果已访问，直接返回
            }

            if (TypeUtil.IsDelegate(element.GetType()) || TypeUtil.IgoneType(element.GetType()))
                return "";

            _visitedObjects.Add(element); // 标记为已访问
            var addTtem = new TreeNode(name, element);
            if (element == null)
            {
                node.Children.Add(addTtem);
            }
            else if ((element is ValueType && !element.GetType().IsGenericType) || element is string)
            {
                _parsedData?.AppendLine($"{new string(' ', _level * _indentSize)}ID: {addTtem.Name}, V: {addTtem.GetFormatValue()}");
                node.Children.Add(addTtem);
            }
            else
            {
                var objectType = element.GetType();
                if (!typeof(IEnumerable).IsAssignableFrom(objectType))
                {
                    _level++;
                    _parsedData?.AppendLine($"{new string(' ', _level * _indentSize)}ID: {addTtem.Name}, V: {addTtem.GetFormatValue()}");
                }

                var enumerableElement = element as IEnumerable;
                if (enumerableElement != null)
                {
                    int index = 0;
                    foreach (object item in enumerableElement)
                    {
                        DumpElement(item, name + "_" + index, node);
                        index++;
                    }
                }
                else
                {
                    BindingFlags f = TypeUtil.GetBindingFlags(objectType);
                    MemberInfo[] members = element.GetType().GetMembers(f);
                    TreeNode newNode;
                    if (node == null)
                    {
                        root = addTtem;
                        root.IsExpanded = true;
                        node = root;
                    }
                    else
                    {
                        if (TypeUtil.IsGenericDict(objectType))
                        {
                            newNode = addTtem;
                            node.Children.Add(newNode);
                            node = newNode;
                        }
                        else if (TypeUtil.IsStruct(objectType))
                        {
                            newNode = addTtem;
                            node.Children.Add(newNode);
                            node = newNode;
                        }
                    }

                    foreach (var memberInfo in members)
                    {
                        var fieldInfo = memberInfo as FieldInfo;
                        var propertyInfo = memberInfo as PropertyInfo;

                        if (fieldInfo == null && propertyInfo == null)
                            continue;

                        var type = fieldInfo != null ? fieldInfo.FieldType : propertyInfo.PropertyType;
                        //UnityEngine.Debug.Log("value Type " + type.FullName + "  Name:" + memberInfo.Name);

                        if (TypeUtil.IsDelegate(type) || TypeUtil.IgoneType(type))
                            continue;
                        object value;
                        if (fieldInfo != null)
                        {
                            value = fieldInfo.GetValue(element);
                        }
                        else
                        {
                            try
                            {
                                if (propertyInfo.MemberType == MemberTypes.Method)
                                    continue;
                                value = propertyInfo.GetValue(element, null);
                            }
                            catch (Exception)
                            {
                                value = null;
                            }
                        }

                        if ((value != null && value == root.Value))
                        {
                            continue;
                        }

                        if (type.IsValueType || type == typeof(string) || TypeUtil.IsValueArray(type) || value == null || TypeUtil.isUnityObject(type))
                        {
                            if (TypeUtil.IsGenericDict(objectType) && memberInfo.Name == "Key")
                            {
                                continue;
                            }

                            var item = new TreeNode(memberInfo.Name, value);
                            _parsedData?.AppendLine($"{new string(' ', _level * _indentSize)}ID: {item.Name}, V: {item.GetFormatValue()}");
                            //Write("{0}: {1}", memberInfo.Name, FormatValue(value));
                            node.Children.Add(item);
                        }
                        else
                        {
                            var isEnumerable = TypeUtil.IsIEnumerable(type);
                            //Write("{0}: {1}", memberInfo.Name, isEnumerable ? "..." : "{ }");
                            //var alreadyTouched = !isEnumerable && AlreadyTouched(value);
                         
                            if (isEnumerable)
                            {
                                TreeNode n = new TreeNode(memberInfo.Name, value);
                                _parsedData?.AppendLine($"{new string(' ', _level * _indentSize)}ID: {n.Name}, V: {n.GetFormatValue()}");
                                node.Children.Add(n);
                                DumpElement(value, memberInfo.Name, n);
                            }
                            else if (TypeUtil.IsStruct(type))
                            {
                                _level++;
                                if (TypeUtil.IsGenericDict(objectType))
                                {
                                    DumpElement(value, memberInfo.Name, node);
                                }
                                else
                                {
                                    DumpElement(value, memberInfo.Name, node);
                                }
                                _level--;
                            }
                            else
                            {
                                //Write("{{{0}}} -- bidirectional reference found", value.GetType().FullName);
                                // Debug.LogError("{{{0}}} -- bidirectional reference found" + value.GetType().FullName);
                            }

                        
                        }
                    }
                }

                if (!typeof(IEnumerable).IsAssignableFrom(objectType))
                {
                    _level--;
                }
            }

            _visitedObjects.Remove(element); // 处理完成后，从已访问集合中移除
            return _stringBuilder.ToString();
        }

        private bool AlreadyTouched(object value)
        {
            return false;
        }

        private void Write(string value, params object[] args)
        {
            var space = new string(' ', _level * _indentSize);

            if (args != null && args.Length > 0)
                value = string.Format(value, args);

            _stringBuilder.AppendLine(space + value);
        }

        string GetID(object obj)
        {
            if (obj is IMessage)
            {
                return (obj as IMessage).ToByteString().ToBase64();
            }
            else
            {
                return obj.GetHashCode().ToString();
            }
        }

        private string FormatValue(object o)
        {
            if (o == null)
                return ("null");

            if (o is DateTime)
                return (((DateTime)o).ToShortDateString());

            if (o is string)
                return string.Format("\"{0}\"", o);

            if (o is char && (char)o == '\0')
                return string.Empty;

            if (o is ValueType)
                return (o.ToString());

            if (o is IEnumerable)
                return ("...");

            return ("{ }");
        }
    }
}